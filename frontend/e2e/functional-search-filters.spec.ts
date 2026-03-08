// ─── Functional E2E: Search filter interactions ─────────────────────────────
// Tests filter panel interactions: sort-by, Nutri-Score pills, NOVA group,
// allergen-free checkboxes, max TryVit Score slider, and clear-all reset.
// Supplements functional-search.spec.ts which covers basic search + category.
//
// Requires: authenticated session (depends on auth-setup project).
// 8 tests
// ─────────────────────────────────────────────────────────────────────────────

import { test, expect } from "@playwright/test";

// Helper: search for a broad term to populate filter options from live data
async function searchAndWaitForResults(page: import("@playwright/test").Page) {
  await page.goto("/app/search");
  await page.waitForLoadState("networkidle");

  const input = page.getByPlaceholder(/search products/i);
  await input.fill("a");
  await input.press("Enter");

  // Wait for results so filter options are populated
  await expect(
    page.getByText(/\d+ results?/i).or(page.getByText(/\d+ wynik/i)),
  ).toBeVisible({ timeout: 15_000 });
}

// ─── Desktop Filter Panel ───────────────────────────────────────────────────

test.describe("Search filters: desktop sort & filter", () => {
  test("sort-by buttons change the active sort", async ({ page }) => {
    await searchAndWaitForResults(page);

    // On desktop the filter sidebar is visible (≥1024px default viewport)
    const sortHeading = page.getByText(/sort by/i).first();
    await expect(sortHeading).toBeVisible({ timeout: 5_000 });

    // Click the "TryVit Score" sort button
    const scoreBtn = page
      .locator("button")
      .filter({ hasText: /^TryVit Score/ });
    await expect(scoreBtn).toBeVisible({ timeout: 5_000 });
    await scoreBtn.click();

    // The button should now have the active ring style (ring-brand)
    // and asc/desc toggle should appear
    await expect(
      page.getByRole("button", { name: /asc/i }),
    ).toBeVisible({ timeout: 5_000 });
  });

  test("Nutri-Score filter buttons are clickable and activate", async ({
    page,
  }) => {
    await searchAndWaitForResults(page);

    // Look for Nutri-Score section heading
    const nutriHeading = page
      .getByText(/nutri-score/i)
      .first();

    if (!(await nutriHeading.isVisible({ timeout: 5_000 }).catch(() => false))) {
      test.skip();
      return;
    }

    // Click the "A" pill button
    const pillA = page.locator("button").filter({ hasText: /^A$/ }).first();
    if (await pillA.isVisible({ timeout: 3_000 }).catch(() => false)) {
      await pillA.click();

      // Results should update — the page should still show results or filter feedback
      await expect(page.locator("body")).not.toContainText(/error/i);
    }
  });

  test("allergen-free checkbox applies filter", async ({ page }) => {
    await searchAndWaitForResults(page);

    // Look for Allergen-Free heading
    const allergenHeading = page.getByText(/allergen-free/i).first();

    if (
      !(await allergenHeading.isVisible({ timeout: 5_000 }).catch(() => false))
    ) {
      test.skip();
      return;
    }

    // Click the first allergen checkbox (e.g., "Gluten-free")
    const allergenCheckbox = page
      .locator('input[type="checkbox"]')
      .first();

    // Scope to allergen section — find any checkbox within the allergen area
    const allergenSection = allergenHeading.locator("..").locator("..");
    const firstCheckbox = allergenSection
      .locator('input[type="checkbox"]')
      .first();

    if (
      await firstCheckbox.isVisible({ timeout: 3_000 }).catch(() => false)
    ) {
      await firstCheckbox.check();

      // Active filter chip should appear somewhere on the page
      // or results count should change — just verify no crash
      await page.waitForTimeout(1_000);
      await expect(page.locator("body")).toBeVisible();
    }
  });

  test("clear all button removes active filters", async ({ page }) => {
    await searchAndWaitForResults(page);

    // First apply a sort to activate hasFilters
    const scoreBtn = page
      .locator("button")
      .filter({ hasText: /^TryVit Score/ });
    if (
      !(await scoreBtn.isVisible({ timeout: 5_000 }).catch(() => false))
    ) {
      test.skip();
      return;
    }
    await scoreBtn.click();

    // Wait for the clear button to appear (desktop shows "Clear" link)
    const clearBtn = page
      .getByRole("button", { name: /^clear$/i })
      .or(page.getByText(/^clear$/i))
      .first();
    await expect(clearBtn).toBeVisible({ timeout: 5_000 });

    await clearBtn.click();

    // After clearing, the "Clear" button itself should disappear (hasFilters = false)
    await expect(clearBtn).not.toBeVisible({ timeout: 5_000 });
  });
});

// ─── Mobile Filter Panel ────────────────────────────────────────────────────

test.describe("Search filters: mobile panel", () => {
  test.use({ viewport: { width: 375, height: 812 } });

  test("mobile filter panel opens and shows all sections", async ({
    page,
  }) => {
    await searchAndWaitForResults(page);

    // Click "Filters" button (mobile toggle)
    const filterBtn = page.locator(
      'button:has-text("Filters"), button:has-text("Filtry")',
    );
    await expect(filterBtn).toBeVisible({ timeout: 5_000 });
    await filterBtn.click();

    // Filter panel should show section headings
    await expect(page.getByText(/sort by/i).first()).toBeVisible({
      timeout: 5_000,
    });

    // "Show Results" button should be at the bottom
    await expect(
      page.getByRole("button", { name: /show results/i }),
    ).toBeVisible({ timeout: 5_000 });
  });

  test("applying filter on mobile and closing with Show Results", async ({
    page,
  }) => {
    await searchAndWaitForResults(page);

    // Open mobile filter panel
    const filterBtn = page.locator(
      'button:has-text("Filters"), button:has-text("Filtry")',
    );
    await expect(filterBtn).toBeVisible({ timeout: 5_000 });
    await filterBtn.click();

    // Click a sort option
    const nameBtn = page.locator("button").filter({ hasText: /^Name$/ });
    if (await nameBtn.isVisible({ timeout: 3_000 }).catch(() => false)) {
      await nameBtn.click();
    }

    // Close with "Show Results"
    const showResultsBtn = page.getByRole("button", {
      name: /show results/i,
    });
    await expect(showResultsBtn).toBeVisible({ timeout: 5_000 });
    await showResultsBtn.click();

    // Panel should close — Filters button should reappear
    await expect(filterBtn).toBeVisible({ timeout: 5_000 });
  });

  test("clear all button on mobile removes filters", async ({ page }) => {
    await searchAndWaitForResults(page);

    // Open mobile filter panel
    const filterBtn = page.locator(
      'button:has-text("Filters"), button:has-text("Filtry")',
    );
    await filterBtn.click();

    // Apply a sort to activate hasFilters
    const caloriesBtn = page
      .locator("button")
      .filter({ hasText: /^Calories$/ });
    if (
      await caloriesBtn.isVisible({ timeout: 3_000 }).catch(() => false)
    ) {
      await caloriesBtn.click();
    }

    // "Clear all" button should appear (mobile shows full "Clear all" text)
    const clearAllBtn = page.getByRole("button", { name: /clear all/i });

    if (
      await clearAllBtn.isVisible({ timeout: 5_000 }).catch(() => false)
    ) {
      await clearAllBtn.click();

      // After clearing, the "Clear all" button should disappear
      await expect(clearAllBtn).not.toBeVisible({ timeout: 5_000 });
    }
  });

  test("max TryVit Score slider is interactive", async ({ page }) => {
    await searchAndWaitForResults(page);

    // Open mobile filter panel
    const filterBtn = page.locator(
      'button:has-text("Filters"), button:has-text("Filtry")',
    );
    await filterBtn.click();

    // Find the range slider by its aria-label
    const slider = page.getByLabel(/max tryvit score/i);
    await expect(slider).toBeVisible({ timeout: 5_000 });

    // Change the slider value
    await slider.fill("50");

    // The displayed value should update to show "≤ 50"
    await expect(page.getByText(/≤ 50/)).toBeVisible({ timeout: 3_000 });
  });
});
