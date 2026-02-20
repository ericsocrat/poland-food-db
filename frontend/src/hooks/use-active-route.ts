"use client";

// ─── useActiveRoute — centralized route matching for navigation ──────────────
// Returns the key of the currently active primary nav route.
// Used by Navigation bottom bar and any component that needs to know
// which section of the app the user is in.

import { usePathname } from "next/navigation";
import { useMemo } from "react";

// ---------------------------------------------------------------------------
// Route definitions
// ---------------------------------------------------------------------------

/** Primary navigation routes in match order (most specific first). */
const PRIMARY_ROUTES = [
  { key: "search", prefix: "/app/search" },
  { key: "scan", prefix: "/app/scan" },
  { key: "lists", prefix: "/app/lists" },
  { key: "watchlist", prefix: "/app/watchlist" },
  { key: "settings", prefix: "/app/settings" },
  { key: "compare", prefix: "/app/compare" },
  { key: "categories", prefix: "/app/categories" },
] as const;

export type PrimaryRouteKey =
  | (typeof PRIMARY_ROUTES)[number]["key"]
  | "home"
  | null;

// ---------------------------------------------------------------------------
// Hook
// ---------------------------------------------------------------------------

/**
 * Returns the key of the active primary navigation route, or "home" for
 * the dashboard, or null for pages that don't match any primary route
 * (e.g. /app/product/42).
 */
export function useActiveRoute(): PrimaryRouteKey {
  const pathname = usePathname();

  return useMemo(() => {
    for (const route of PRIMARY_ROUTES) {
      if (pathname.startsWith(route.prefix)) return route.key;
    }
    if (pathname === "/app") return "home";
    return null;
  }, [pathname]);
}
