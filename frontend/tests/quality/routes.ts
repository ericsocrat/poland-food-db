/**
 * Quality Gate — Route Manifest
 *
 * Single source of truth for every auditable route in the application.
 * Consumed by mobile/desktop audit runners, Lighthouse CI, and the
 * invariant engine.  All quality-gate tests import routes from here
 * instead of hardcoding paths.
 *
 * @see https://github.com/ericsocrat/poland-food-db/issues/172
 */

import { FIXTURES } from "./fixtures";

/* ── Types ───────────────────────────────────────────────────────────────── */

export interface RouteEntry {
  /** URL path (may include query string) */
  path: string;
  /** Human-readable label for screenshots and reports */
  label: string;
  /** Whether a valid Supabase session is required */
  requiresAuth: boolean;
  /** Tab IDs available on the page (audit runners cycle through these) */
  hasTabs?: string[];
  /** Which quality-gate modes should include this route */
  tags: ("smoke" | "full" | "lighthouse")[];
  /** Route should only be tested on mobile viewports */
  mobileOnly?: boolean;
  /** Route should only be tested on desktop viewports */
  desktopOnly?: boolean;
}

/* ── Route Manifest ──────────────────────────────────────────────────────── */

export const ROUTES: RouteEntry[] = [
  /* ════ CORE — smoke + full ════════════════════════════════════════════════ */
  {
    path: "/auth/login",
    label: "login",
    requiresAuth: false,
    tags: ["smoke", "full", "lighthouse"],
  },
  {
    path: "/",
    label: "landing",
    requiresAuth: false,
    tags: ["smoke", "full"],
  },
  {
    path: "/app",
    label: "dashboard",
    requiresAuth: true,
    tags: ["smoke", "full", "lighthouse"],
  },
  {
    path: "/app/search?q=mleko",
    label: "search-mleko",
    requiresAuth: true,
    tags: ["smoke", "full"],
  },
  {
    path: "/app/categories",
    label: "categories",
    requiresAuth: true,
    tags: ["smoke", "full"],
  },
  {
    path: `/app/categories/${FIXTURES.categorySlug}`,
    label: "category-detail",
    requiresAuth: true,
    tags: ["smoke", "full"],
  },
  {
    path: `/app/product/${FIXTURES.productId}`,
    label: "product-detail",
    requiresAuth: true,
    tags: ["smoke", "full", "lighthouse"],
    hasTabs: ["overview", "nutrition", "scoring", "alternatives"],
  },
  {
    path: "/app/settings",
    label: "settings",
    requiresAuth: true,
    tags: ["smoke", "full"],
  },
  {
    path: "/privacy",
    label: "privacy",
    requiresAuth: false,
    tags: ["smoke", "full"],
  },

  /* ════ EXTENDED — full only ═══════════════════════════════════════════════ */

  // Auth
  {
    path: "/auth/signup",
    label: "signup",
    requiresAuth: false,
    tags: ["full"],
  },

  // Onboarding
  {
    path: "/onboarding",
    label: "onboarding",
    requiresAuth: true,
    tags: ["full"],
  },
  {
    path: "/onboarding/region",
    label: "onboarding-region",
    requiresAuth: true,
    tags: ["full"],
  },
  {
    path: "/onboarding/preferences",
    label: "onboarding-preferences",
    requiresAuth: true,
    tags: ["full"],
  },

  // Search
  {
    path: "/app/search/saved",
    label: "saved-searches",
    requiresAuth: true,
    tags: ["full"],
  },

  // Products & Ingredients
  {
    path: `/app/ingredient/${FIXTURES.ingredientId}`,
    label: "ingredient-detail",
    requiresAuth: true,
    tags: ["full"],
  },

  // Scan
  {
    path: "/app/scan",
    label: "scan",
    requiresAuth: true,
    tags: ["full"],
  },
  {
    path: "/app/scan/submit",
    label: "scan-submit",
    requiresAuth: true,
    tags: ["full"],
  },
  {
    path: "/app/scan/submissions",
    label: "scan-submissions",
    requiresAuth: true,
    tags: ["full"],
  },
  {
    path: "/app/scan/history",
    label: "scan-history",
    requiresAuth: true,
    tags: ["full"],
  },

  // Recipes
  {
    path: "/app/recipes",
    label: "recipes",
    requiresAuth: true,
    tags: ["full"],
  },

  // Lists & Watchlist
  {
    path: "/app/lists",
    label: "lists",
    requiresAuth: true,
    tags: ["full"],
  },
  {
    path: "/app/watchlist",
    label: "watchlist",
    requiresAuth: true,
    tags: ["full"],
  },

  // Compare
  {
    path: "/app/compare",
    label: "compare",
    requiresAuth: true,
    tags: ["full"],
  },
  {
    path: "/app/compare/saved",
    label: "compare-saved",
    requiresAuth: true,
    tags: ["full"],
  },

  // Image Search
  {
    path: "/app/image-search",
    label: "image-search",
    requiresAuth: true,
    tags: ["full"],
  },

  // Achievements
  {
    path: "/app/achievements",
    label: "achievements",
    requiresAuth: true,
    tags: ["full"],
  },

  // Admin
  {
    path: "/app/admin/monitoring",
    label: "admin-monitoring",
    requiresAuth: true,
    tags: ["full"],
    desktopOnly: true,
  },
  {
    path: "/app/admin/submissions",
    label: "admin-submissions",
    requiresAuth: true,
    tags: ["full"],
    desktopOnly: true,
  },
  {
    path: "/app/admin/metrics",
    label: "admin-metrics",
    requiresAuth: true,
    tags: ["full"],
    desktopOnly: true,
  },

  /* ════ PUBLIC — full only (no auth) ═══════════════════════════════════════ */

  {
    path: "/contact",
    label: "contact",
    requiresAuth: false,
    tags: ["full"],
  },
  {
    path: "/terms",
    label: "terms",
    requiresAuth: false,
    tags: ["full"],
  },
  {
    path: "/offline",
    label: "offline",
    requiresAuth: false,
    tags: ["full"],
  },

  // Learn hub
  {
    path: "/learn",
    label: "learn",
    requiresAuth: false,
    tags: ["full"],
  },
  {
    path: "/learn/nutri-score",
    label: "learn-nutriscore",
    requiresAuth: false,
    tags: ["full"],
  },
  {
    path: "/learn/nova-groups",
    label: "learn-nova",
    requiresAuth: false,
    tags: ["full"],
  },
  {
    path: "/learn/allergens",
    label: "learn-allergens",
    requiresAuth: false,
    tags: ["full"],
  },
  {
    path: "/learn/unhealthiness-score",
    label: "learn-score",
    requiresAuth: false,
    tags: ["full"],
  },
  {
    path: "/learn/confidence",
    label: "learn-confidence",
    requiresAuth: false,
    tags: ["full"],
  },
  {
    path: "/learn/reading-labels",
    label: "learn-reading-labels",
    requiresAuth: false,
    tags: ["full"],
  },
  {
    path: "/learn/additives",
    label: "learn-additives",
    requiresAuth: false,
    tags: ["full"],
  },
];

/* ── Helpers ─────────────────────────────────────────────────────────────── */

/** Returns routes tagged for the given audit mode. */
export function getRoutes(mode: "smoke" | "full"): RouteEntry[] {
  return ROUTES.filter((r) => r.tags.includes(mode));
}

/** Returns routes tagged for Lighthouse CI auditing. */
export function getLighthouseRoutes(): RouteEntry[] {
  return ROUTES.filter((r) => r.tags.includes("lighthouse"));
}
