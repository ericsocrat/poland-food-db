// ─── A11y audit: authenticated pages ────────────────────────────────────────
// Automated WCAG 2.1 AA compliance gate for auth-required routes.
// Requires SUPABASE_SERVICE_ROLE_KEY (runs only when auth E2E is enabled).
// Uses pre-authenticated storageState from auth.setup.ts.
//
// Critical + Serious violations → build failure (zero-tolerance).
// Moderate + Minor violations → console warnings.
//
// Issue #50 — A11y CI Gate
// Named authenticated-* to match the "authenticated" Playwright project pattern.

import { test, expect } from "@playwright/test";
import { assertNoA11yViolations, auditA11y } from "./helpers/a11y";

/* ── Auth-required routes to audit ───────────────────────────────────────── */

const AUTH_PAGES = [
  { name: "Search", path: "/app/search" },
  { name: "Settings", path: "/app/settings" },
  { name: "Categories", path: "/app/categories" },
  { name: "Lists", path: "/app/lists" },
  { name: "Dashboard", path: "/app" },
];

/* ── Per-page WCAG audits ────────────────────────────────────────────────── */

test.describe("A11y audit — authenticated pages", () => {
  for (const { name, path } of AUTH_PAGES) {
    test(`${name} (${path}) passes WCAG 2.1 AA audit`, async ({ page }) => {
      await page.goto(path);
      await page.waitForLoadState("networkidle");
      await assertNoA11yViolations(page);
    });
  }
});

/* ── Mobile viewport for authenticated pages ─────────────────────────────── */

test.describe("A11y audit — authenticated mobile", () => {
  test.use({ viewport: { width: 375, height: 812 } });

  test("search page passes a11y on mobile", async ({ page }) => {
    await page.goto("/app/search");
    await page.waitForLoadState("networkidle");
    await assertNoA11yViolations(page);
  });

  test("dashboard passes a11y on mobile", async ({ page }) => {
    await page.goto("/app");
    await page.waitForLoadState("networkidle");
    await assertNoA11yViolations(page);
  });
});

/* ── Dark mode for authenticated pages ───────────────────────────────────── */

test.describe("A11y audit — authenticated dark mode", () => {
  test("search page passes a11y in dark mode", async ({ page }) => {
    await page.emulateMedia({ colorScheme: "dark" });
    await page.goto("/app/search");
    await page.waitForLoadState("networkidle");
    await assertNoA11yViolations(page);
  });
});

/* ── Baseline regression tracking ────────────────────────────────────────── */

test.describe("A11y audit — authenticated baseline", () => {
  test("search page zero blocking violations", async ({ page }) => {
    await page.goto("/app/search");
    await page.waitForLoadState("networkidle");
    const result = await auditA11y(page);

    console.log(
      `A11y baseline (search) — blocking: ${result.blocking.length}, warnings: ${result.warnings.length}, passes: ${result.passes}`,
    );

    expect(result.blocking).toHaveLength(0);
  });
});
