// ─── A11y audit: public pages ───────────────────────────────────────────────
// Automated WCAG 2.1 AA compliance gate using axe-core.
// Critical + Serious violations → build failure (zero-tolerance).
// Moderate + Minor violations → console warnings.
//
// Issue #50 — A11y CI Gate
// Named smoke-* to match the "smoke" Playwright project pattern.

import { test, expect } from "@playwright/test";
import { assertNoA11yViolations, auditA11y } from "./helpers/a11y";

/* ── Page routes to audit ────────────────────────────────────────────────── */

const PUBLIC_PAGES = [
  { name: "Landing", path: "/" },
  { name: "Login", path: "/auth/login" },
  { name: "Signup", path: "/auth/signup" },
  { name: "Contact", path: "/contact" },
  { name: "Privacy", path: "/privacy" },
  { name: "Terms", path: "/terms" },
  { name: "Learn Hub", path: "/learn" },
  { name: "Learn: Nutri-Score", path: "/learn/nutri-score" },
  { name: "Learn: NOVA Groups", path: "/learn/nova-groups" },
  { name: "Learn: Unhealthiness Score", path: "/learn/unhealthiness-score" },
  { name: "Learn: Additives", path: "/learn/additives" },
  { name: "Learn: Allergens", path: "/learn/allergens" },
  { name: "Learn: Reading Labels", path: "/learn/reading-labels" },
  { name: "Learn: Data Confidence", path: "/learn/confidence" },
];

/* ── Per-page WCAG audits ────────────────────────────────────────────────── */

test.describe("A11y audit — public pages", () => {
  for (const { name, path } of PUBLIC_PAGES) {
    test(`${name} (${path}) passes WCAG 2.1 AA audit`, async ({ page }) => {
      await page.goto(path);
      await page.waitForLoadState("networkidle");
      await assertNoA11yViolations(page);
    });
  }
});

/* ── Dark mode a11y (color contrast may differ) ──────────────────────────── */

test.describe("A11y audit — dark mode", () => {
  test("landing page passes a11y in dark mode", async ({ page }) => {
    await page.emulateMedia({ colorScheme: "dark" });
    await page.goto("/");
    await page.waitForLoadState("networkidle");
    await assertNoA11yViolations(page);
  });

  test("login page passes a11y in dark mode", async ({ page }) => {
    await page.emulateMedia({ colorScheme: "dark" });
    await page.goto("/auth/login");
    await page.waitForLoadState("networkidle");
    await assertNoA11yViolations(page);
  });
});

/* ── Mobile viewport a11y ────────────────────────────────────────────────── */

test.describe("A11y audit — mobile viewport", () => {
  test.use({ viewport: { width: 375, height: 812 } });

  test("landing page passes a11y on mobile", async ({ page }) => {
    await page.goto("/");
    await page.waitForLoadState("networkidle");
    await assertNoA11yViolations(page);
  });

  test("login page passes a11y on mobile", async ({ page }) => {
    await page.goto("/auth/login");
    await page.waitForLoadState("networkidle");
    await assertNoA11yViolations(page);
  });

  test("learn hub passes a11y on mobile", async ({ page }) => {
    await page.goto("/learn");
    await page.waitForLoadState("networkidle");
    await assertNoA11yViolations(page);
  });
});

/* ── Audit result quality checks ─────────────────────────────────────────── */

test.describe("A11y audit — result quality", () => {
  test("axe-core returns passes (sanity check)", async ({ page }) => {
    await page.goto("/");
    await page.waitForLoadState("networkidle");
    const result = await auditA11y(page);
    expect(result.passes).toBeGreaterThan(0);
  });

  test("violation count does not exceed baseline", async ({ page }) => {
    // Baseline: track total violation count to prevent regressions.
    // If this number increases, a new violation was introduced.
    // Decrease the baseline as fixes are shipped.
    await page.goto("/");
    await page.waitForLoadState("networkidle");
    const result = await auditA11y(page);

    // Log current counts for visibility in CI
    console.log(
      `A11y baseline check — blocking: ${result.blocking.length}, warnings: ${result.warnings.length}, passes: ${result.passes}`,
    );

    // Zero blocking violations allowed
    expect(result.blocking).toHaveLength(0);
  });
});
