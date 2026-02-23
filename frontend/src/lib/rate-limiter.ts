// ─── Rate Limiting Configuration ────────────────────────────────────────────
// Issue: #182 — [Hardening 3/7] Rate Limiting + Abuse Protection
//
// Uses @upstash/ratelimit with sliding window algorithm.
// Production: Upstash Redis for distributed state across Vercel functions.
// Development / CI: rate limiting disabled (no Redis configured).

import { Ratelimit, type Duration } from "@upstash/ratelimit";
import { Redis } from "@upstash/redis";

// ─── Redis Client ───────────────────────────────────────────────────────────

function createRedis(): Redis | null {
  const url = process.env.UPSTASH_REDIS_REST_URL;
  const token = process.env.UPSTASH_REDIS_REST_TOKEN;

  if (url && token) {
    return new Redis({ url, token });
  }

  // Development / CI — no Redis available, rate limiting will be disabled
  return null;
}

const redis = createRedis();

/** Whether rate limiting is active (Redis configured). */
export const rateLimitEnabled = redis !== null;

// ─── Limiter factory ────────────────────────────────────────────────────────

function createLimiter(
  maxRequests: number,
  window: Duration,
  prefix: string,
): Ratelimit | null {
  if (!redis) return null;
  return new Ratelimit({
    redis,
    limiter: Ratelimit.slidingWindow(maxRequests, window),
    prefix,
    analytics: false,
  });
}

// ─── Rate Limit Tiers ───────────────────────────────────────────────────────

/** Standard API: 60 req/min per IP */
export const standardLimiter = createLimiter(60, "60 s", "rl:standard");

/** Auth endpoints: 10 req/min per IP (brute-force protection) */
export const authLimiter = createLimiter(10, "60 s", "rl:auth");

/** Search / heavy endpoints: 30 req/min per IP */
export const searchLimiter = createLimiter(30, "60 s", "rl:search");

/** Health endpoint: generous (used by monitoring) — 120 req/min */
export const healthLimiter = createLimiter(120, "60 s", "rl:health");

/** Authenticated user: 120 req/min per user ID */
export const authenticatedLimiter = createLimiter(120, "60 s", "rl:user");

// ─── Tier Type + Selector ───────────────────────────────────────────────────

export type RateLimitTier =
  | "standard"
  | "auth"
  | "search"
  | "health"
  | "authenticated";

export function getLimiter(tier: RateLimitTier): Ratelimit | null {
  switch (tier) {
    case "auth":
      return authLimiter;
    case "search":
      return searchLimiter;
    case "health":
      return healthLimiter;
    case "authenticated":
      return authenticatedLimiter;
    default:
      return standardLimiter;
  }
}

// ─── Tier Resolver ──────────────────────────────────────────────────────────

/** Map a request pathname to the appropriate rate limit tier. */
export function resolveRateLimitTier(pathname: string): RateLimitTier {
  if (
    pathname.startsWith("/auth/callback") ||
    pathname.includes("/login") ||
    pathname.includes("/signup")
  ) {
    return "auth";
  }
  if (pathname.startsWith("/api/health")) {
    return "health";
  }
  if (pathname.includes("/search") || pathname.includes("rpc/search")) {
    return "search";
  }
  return "standard";
}

// ─── JWT User-ID Extraction ─────────────────────────────────────────────────

/**
 * Extract user ID (sub claim) from a Bearer JWT without full verification.
 * This is safe for rate limiting — actual auth verification happens elsewhere.
 * Returns null if no valid JWT is present.
 */
export function extractUserIdFromJWT(
  authHeader: string | null,
): string | null {
  if (!authHeader?.startsWith("Bearer ")) return null;

  try {
    const token = authHeader.slice(7);
    const parts = token.split(".");
    if (parts.length !== 3) return null;

    const payload = JSON.parse(atob(parts[1]));
    return typeof payload.sub === "string" ? payload.sub : null;
  } catch {
    return null;
  }
}
