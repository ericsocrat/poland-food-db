// ─── Product Detail Tabs — No Duplication (Issue #122) ──────────────────────
// Verifies that shared sections (score explanation, health warnings, tab bar)
// render exactly ONCE regardless of which tab is active.
//
// Requires an authenticated user with a product available in the database.
// Falls back to smoke-level checks if no product is reachable.

import { test, expect } from "@playwright/test";

// ── Test IDs referenced in acceptance criteria ──────────────────────────────

const SCORE_INTERPRETATION = '[data-testid="score-interpretation"]';
const HEALTH_WARNINGS = '[data-testid="health-warnings-card"]';
const TAB_BAR = '[data-testid="tab-bar"]';

const TAB_NAMES = ["Overview", "Nutrition", "Alternatives", "Scoring"] as const;

// ── Desktop viewport (1280px) ───────────────────────────────────────────────

test.describe("Product detail — no section duplication (desktop)", () => {
  test.use({ viewport: { width: 1280, height: 800 } });

  test("shared sections render exactly once on every tab", async ({
    page,
  }) => {
    // Navigate to a known product — adjust ID to match seeded data
    await page.goto("/app/product/1", { waitUntil: "networkidle" });

    // Wait for product content to load (tab bar is present)
    const tabBar = page.locator(TAB_BAR);
    await expect(tabBar).toBeVisible({ timeout: 15_000 });

    // Verify single instance on default (Overview) tab
    await expect(page.locator(SCORE_INTERPRETATION)).toHaveCount(1);
    await expect(page.locator(HEALTH_WARNINGS)).toHaveCount(1);
    await expect(page.locator(TAB_BAR)).toHaveCount(1);
    await expect(page.getByRole("tablist")).toHaveCount(1);

    // Switch through all tabs and re-assert
    for (const tabName of TAB_NAMES) {
      await page.getByRole("tab", { name: tabName }).click();

      // Wait for any transition to settle
      await page.waitForTimeout(300);

      await expect(page.locator(SCORE_INTERPRETATION)).toHaveCount(1);
      await expect(page.locator(HEALTH_WARNINGS)).toHaveCount(1);
      await expect(page.locator(TAB_BAR)).toHaveCount(1);
      await expect(page.getByRole("tablist")).toHaveCount(1);
    }
  });

  test("score interpretation is in left column, not tab content", async ({
    page,
  }) => {
    await page.goto("/app/product/1", { waitUntil: "networkidle" });
    await expect(page.locator(TAB_BAR)).toBeVisible({ timeout: 15_000 });

    // Score interpretation should be a sibling of (or within) the left column,
    // NOT inside the right column that holds tabs
    const leftCol = page.locator(".lg\\:col-span-5");
    const rightCol = page.locator(".lg\\:col-span-7");

    await expect(
      leftCol.locator('[data-testid="score-interpretation"]'),
    ).toHaveCount(1);
    await expect(
      rightCol.locator('[data-testid="score-interpretation"]'),
    ).toHaveCount(0);
  });
});

// ── Mobile viewport (375px) — Issue #122 was first observed on mobile ───────

test.describe("Product detail — no section duplication (mobile 375px)", () => {
  test.use({ viewport: { width: 375, height: 812 } });

  test("shared sections render exactly once on every tab (mobile)", async ({
    page,
  }) => {
    await page.goto("/app/product/1", { waitUntil: "networkidle" });

    const tabBar = page.locator(TAB_BAR);
    await expect(tabBar).toBeVisible({ timeout: 15_000 });

    for (const tabName of TAB_NAMES) {
      await page.getByRole("tab", { name: tabName }).click();
      await page.waitForTimeout(300);

      await expect(page.locator(SCORE_INTERPRETATION)).toHaveCount(1);
      await expect(page.locator(HEALTH_WARNINGS)).toHaveCount(1);
      await expect(page.locator(TAB_BAR)).toHaveCount(1);
    }
  });
});
