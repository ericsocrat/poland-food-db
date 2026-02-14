// ─── Middleware: auth enforcement only ───────────────────────────────────────
// Checks if user is logged in. Does NOT check onboarding_complete.
// Onboarding redirect happens in /app/layout.tsx (server component).
//
// Public routes: /, /contact, /privacy, /terms, /auth/*
// Everything else requires a valid session.

import { NextRequest, NextResponse } from "next/server";
import { createMiddlewareClient } from "@/lib/supabase/middleware";

const PUBLIC_PATHS = new Set([
  "/",
  "/contact",
  "/privacy",
  "/terms",
]);

function isPublicPath(pathname: string): boolean {
  return (
    PUBLIC_PATHS.has(pathname) ||
    pathname.startsWith("/auth/")
  );
}

export async function middleware(request: NextRequest) {
  const response = NextResponse.next({ request });
  const supabase = createMiddlewareClient(request, response);

  // Refresh session token (important for @supabase/ssr)
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { pathname } = request.nextUrl;

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
    // Match all paths except static files and API routes
    // eslint-disable-next-line no-useless-escape -- Next.js requires a plain string literal for static analysis
    "/((?!api|_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
};
