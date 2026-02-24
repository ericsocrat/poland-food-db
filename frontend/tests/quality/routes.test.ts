/**
 * Unit tests for the quality-gate route manifest.
 *
 * @see https://github.com/ericsocrat/poland-food-db/issues/172
 */

import { describe, it, expect } from "vitest";
import { ROUTES, getRoutes, getLighthouseRoutes } from "./routes";
import type { RouteEntry } from "./routes";

/* ── Manifest shape ──────────────────────────────────────────────────────── */

describe("ROUTES manifest", () => {
  it("contains at least 28 routes", () => {
    expect(ROUTES.length).toBeGreaterThanOrEqual(28);
  });

  it("every route has required fields", () => {
    for (const route of ROUTES) {
      expect(route.path).toBeTruthy();
      expect(route.label).toBeTruthy();
      expect(typeof route.requiresAuth).toBe("boolean");
      expect(route.tags.length).toBeGreaterThan(0);
    }
  });

  it("every label is unique", () => {
    const labels = ROUTES.map((r) => r.label);
    expect(new Set(labels).size).toBe(labels.length);
  });

  it("every path is unique", () => {
    const paths = ROUTES.map((r) => r.path);
    expect(new Set(paths).size).toBe(paths.length);
  });

  it("tags only contain valid values", () => {
    const validTags = new Set(["smoke", "full", "lighthouse"]);
    for (const route of ROUTES) {
      for (const tag of route.tags) {
        expect(validTags.has(tag)).toBe(true);
      }
    }
  });

  it("all auth routes start with /app or /onboarding", () => {
    const authRoutes = ROUTES.filter((r) => r.requiresAuth);
    for (const route of authRoutes) {
      expect(
        route.path.startsWith("/app") || route.path.startsWith("/onboarding")
      ).toBe(true);
    }
  });

  it("admin routes are desktopOnly", () => {
    const adminRoutes = ROUTES.filter((r) =>
      r.path.startsWith("/app/admin")
    );
    expect(adminRoutes.length).toBeGreaterThan(0);
    for (const route of adminRoutes) {
      expect(route.desktopOnly).toBe(true);
    }
  });
});

/* ── getRoutes() ─────────────────────────────────────────────────────────── */

describe("getRoutes()", () => {
  it("smoke mode returns 8–12 high-value routes", () => {
    const smoke = getRoutes("smoke");
    expect(smoke.length).toBeGreaterThanOrEqual(8);
    expect(smoke.length).toBeLessThanOrEqual(12);
  });

  it("smoke routes only contain smoke-tagged entries", () => {
    const smoke = getRoutes("smoke");
    for (const route of smoke) {
      expect(route.tags).toContain("smoke");
    }
  });

  it("full mode returns all routes (≥ 28)", () => {
    const full = getRoutes("full");
    expect(full.length).toBeGreaterThanOrEqual(28);
  });

  it("full mode is a superset of smoke mode", () => {
    const smokePaths = new Set(getRoutes("smoke").map((r) => r.path));
    const fullPaths = new Set(getRoutes("full").map((r) => r.path));
    for (const path of smokePaths) {
      expect(fullPaths.has(path)).toBe(true);
    }
  });

  it("smoke includes login, dashboard, and product-detail", () => {
    const smokeLabels = getRoutes("smoke").map((r) => r.label);
    expect(smokeLabels).toContain("login");
    expect(smokeLabels).toContain("dashboard");
    expect(smokeLabels).toContain("product-detail");
  });

  it("full includes admin and learn routes", () => {
    const fullLabels = getRoutes("full").map((r) => r.label);
    expect(fullLabels).toContain("admin-monitoring");
    expect(fullLabels).toContain("learn");
  });
});

/* ── getLighthouseRoutes() ───────────────────────────────────────────────── */

describe("getLighthouseRoutes()", () => {
  it("returns at least 3 routes", () => {
    const lh = getLighthouseRoutes();
    expect(lh.length).toBeGreaterThanOrEqual(3);
  });

  it("only contains lighthouse-tagged entries", () => {
    const lh = getLighthouseRoutes();
    for (const route of lh) {
      expect(route.tags).toContain("lighthouse");
    }
  });

  it("includes login, dashboard, and product-detail", () => {
    const lhLabels = getLighthouseRoutes().map((r) => r.label);
    expect(lhLabels).toContain("login");
    expect(lhLabels).toContain("dashboard");
    expect(lhLabels).toContain("product-detail");
  });

  it("is a subset of full routes", () => {
    const fullPaths = new Set(getRoutes("full").map((r) => r.path));
    for (const route of getLighthouseRoutes()) {
      expect(fullPaths.has(route.path)).toBe(true);
    }
  });
});

/* ── Type-level checks ───────────────────────────────────────────────────── */

describe("type safety", () => {
  it("RouteEntry fields have correct types", () => {
    const sample: RouteEntry = ROUTES[0];
    expect(typeof sample.path).toBe("string");
    expect(typeof sample.label).toBe("string");
    expect(typeof sample.requiresAuth).toBe("boolean");
    expect(Array.isArray(sample.tags)).toBe(true);
  });
});
