// ─── Middleware: auth enforcement + rate limiting ────────────────────────────
// Auth: checks if user is logged in. Does NOT check onboarding_complete.
//       Onboarding redirect happens in /app/layout.tsx (server component).
//       Public routes: /, /contact, /privacy, /terms, /auth/*
//       Everything else requires a valid session.
//
// Rate limiting (#182): applied to /api/* routes via @upstash/ratelimit.
//       5 tiers: standard (60/min), auth (10/min), search (30/min),
//       health (120/min), authenticated (120/min). Sliding window.

import { NextRequest, NextResponse } from "next/server";
import { createMiddlewareClient } from "@/lib/supabase/middleware";
import {
  getLimiter,
  resolveRateLimitTier,
  extractUserIdFromJWT,
  rateLimitEnabled,
} from "@/lib/rate-limiter";

// ─── Auth Helpers ───────────────────────────────────────────────────────────

const PUBLIC_PATHS = new Set(["/", "/contact", "/privacy", "/terms"]);

function isPublicPath(pathname: string): boolean {
  return PUBLIC_PATHS.has(pathname) || pathname.startsWith("/auth/");
}

// ─── Rate Limit Helpers ─────────────────────────────────────────────────────

function isBypassToken(request: NextRequest): boolean {
  const bypassToken = process.env.RATE_LIMIT_BYPASS_TOKEN;
  if (!bypassToken) return false;
  return request.headers.get("x-rate-limit-bypass") === bypassToken;
}

function resolveClientIp(request: NextRequest): string {
  return (
    request.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ??
    request.headers.get("x-real-ip") ??
    "127.0.0.1"
  );
}

/**
 * Apply rate limiting to a request. Returns a 429 NextResponse if the limit
 * is exceeded, otherwise adds X-RateLimit-* headers to the pass-through
 * response and returns it.
 */
async function applyRateLimit(
  request: NextRequest,
  response: NextResponse,
): Promise<NextResponse> {
  // Rate limiting disabled (no Redis) or bypass token present
  if (!rateLimitEnabled || isBypassToken(request)) return response;

  const { pathname } = request.nextUrl;
  const baseTier = resolveRateLimitTier(pathname);

  // Resolve identifier: authenticated users keyed by user ID, anon by IP
  const authHeader = request.headers.get("authorization");
  const userId = extractUserIdFromJWT(authHeader);
  const identifier = userId ?? resolveClientIp(request);

  // Promote standard → authenticated when a valid JWT is present
  const effectiveTier =
    userId && baseTier === "standard" ? "authenticated" : baseTier;
  const limiter = getLimiter(effectiveTier);

  // Limiter is null when Redis is not configured (shouldn't happen if
  // rateLimitEnabled is true, but guard defensively)
  if (!limiter) return response;

  const { success, limit, remaining, reset } = await limiter.limit(identifier);

  const rlHeaders: Record<string, string> = {
    "X-RateLimit-Limit": String(limit),
    "X-RateLimit-Remaining": String(remaining),
    "X-RateLimit-Reset": String(reset),
  };

  if (!success) {
    const retryAfter = Math.max(Math.ceil((reset - Date.now()) / 1000), 1);
    const body = {
      error: "Too Many Requests",
      message: `Rate limit exceeded. Try again in ${retryAfter}s.`,
      tier: effectiveTier,
    };

    return NextResponse.json(body, {
      status: 429,
      headers: {
        ...rlHeaders,
        "Retry-After": String(retryAfter),
        "x-request-id": response.headers.get("x-request-id") ?? "",
      },
    });
  }

  // Attach rate-limit headers to the pass-through response
  for (const [key, value] of Object.entries(rlHeaders)) {
    response.headers.set(key, value);
  }
  return response;
}

// ─── Main Middleware ─────────────────────────────────────────────────────────

export async function middleware(request: NextRequest) {
  const response = NextResponse.next({ request });

  // ── Request ID correlation (#183) ─────────────────────────────────────────
  const requestId = request.headers.get("x-request-id") ?? crypto.randomUUID();
  response.headers.set("x-request-id", requestId);

  const { pathname } = request.nextUrl;

  // ── API routes: rate limiting only (no auth enforcement) ──────────────────
  if (pathname.startsWith("/api/")) {
    return applyRateLimit(request, response);
  }

  // ── Non-API routes: auth enforcement ──────────────────────────────────────
  const supabase = createMiddlewareClient(request, response);

  // Refresh session token (important for @supabase/ssr)
  // Wrap in try/catch so pages still load when Supabase is unreachable
  // (e.g. paused free-tier project, CI without a real instance).
  let user = null;
  try {
    const { data } = await supabase.auth.getUser();
    user = data.user;
  } catch {
    // Supabase unreachable — treat as unauthenticated
  }

  // Allow public routes
  if (isPublicPath(pathname)) {
    // If logged in user visits /auth/login or /auth/signup, redirect to app
    if (user && (pathname === "/auth/login" || pathname === "/auth/signup")) {
      return NextResponse.redirect(new URL("/app/search", request.url));
    }
    return response;
  }

  // Protected routes require auth
  if (!user) {
    const loginUrl = new URL("/auth/login", request.url);
    // Preserve full path + querystring so login can redirect back
    const redirectTo = request.nextUrl.pathname + request.nextUrl.search;
    loginUrl.searchParams.set("redirect", redirectTo);
    return NextResponse.redirect(loginUrl);
  }

  return response;
}

export const config = {
  matcher: [
    // Match all paths except static assets (includes /api for rate limiting)
    // eslint-disable-next-line no-useless-escape -- Next.js requires a plain string literal for static analysis
    "/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
};
