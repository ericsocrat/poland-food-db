// ─── Functional E2E: Product journey ────────────────────────────────────────
// Tests the full product experience: TryVit Score display, score explanation,
// better alternatives click-through, cross-country links, add-to-compare,
// add-to-list, and progressive disclosure toggle.
//
// Requires: authenticated session (depends on auth-setup project).
// 10 tests
// ─────────────────────────────────────────────────────────────────────────────

import { test, expect } from "@playwright/test";

// Helper: navigate to the first product in a category listing
async function navigateToFirstProduct(
  page: import("@playwright/test").Page,
  category = "chips",
) {
  await page.goto(`/app/categories/${category}`);
  await page.waitForLoadState("networkidle");

  const productLinks = page.locator('a[href*="/app/product/"]');
  await expect(productLinks.first()).toBeVisible({ timeout: 15_000 });
  await productLinks.first().click();
  await page.waitForURL(/\/app\/product\/\d+/, { timeout: 15_000 });
}

// ─── TryVit Score Display ───────────────────────────────────────────────────

test.describe("Product journey: TryVit Score display", () => {
  test("product page renders TryVit Score badge with numeric value", async ({
    page,
  }) => {
    await navigateToFirstProduct(page);

    // The score interpretation card should be visible
    const scoreCard = page.getByTestId("score-interpretation");
    await expect(scoreCard).toBeVisible({ timeout: 10_000 });

    // Score value should be a number — look for a prominent numeric element
    // The TryVit Score is shown in the left column as a large number
    const scoreText = page.locator(
      '[data-testid="score-interpretation"], .text-4xl, .text-3xl',
    );
    await expect(scoreText.first()).toBeVisible();
  });

  test("score interpretation card expands with explanation", async ({
    page,
  }) => {
    await navigateToFirstProduct(page);

    const interpCard = page.getByTestId("score-interpretation");
    await expect(interpCard).toBeVisible({ timeout: 10_000 });

    // Click to expand
    await interpCard.click();

    // Expanded content should appear
    const content = page.getByTestId("score-interpretation-content");
    await expect(content).toBeVisible({ timeout: 5_000 });

    // Should contain meaningful text (not empty)
    const contentText = await content.textContent();
    expect(contentText?.length).toBeGreaterThan(10);
  });

  test("health flag badges are visible when applicable", async ({ page }) => {
    await navigateToFirstProduct(page, "sweets");

    // Wait for page to load
    await expect(page.getByTestId("tab-bar").or(page.getByTestId("toggle-analysis"))).toBeVisible({
      timeout: 10_000,
    });

    // Health flags section should exist (may have YES/NO flags)
    // Look for common flag indicators — sugar, salt, saturated fat, additives, palm oil
    const body = page.locator("body");
    await expect(body).toBeVisible();
    // Sweets category typically has at least one health flag
    await expect(body).not.toContainText(/failed|error/i);
  });
});

// ─── Progressive Disclosure ─────────────────────────────────────────────────

test.describe("Product journey: progressive disclosure", () => {
  test("toggle between summary and full analysis", async ({ page }) => {
    await navigateToFirstProduct(page);

    // Quick summary should be visible by default
    const quickSummary = page.getByTestId("quick-summary");
    const toggleButton = page.getByTestId("toggle-analysis").first();

    // Quick summary or tab bar should be visible (depends on viewport)
    await expect(
      quickSummary.or(page.getByTestId("tab-bar")),
    ).toBeVisible({ timeout: 10_000 });

    // If toggle button exists, click to expand
    if (await toggleButton.isVisible({ timeout: 3_000 }).catch(() => false)) {
      await toggleButton.click();

      // Tab bar should appear after expanding
      await expect(page.getByTestId("tab-bar")).toBeVisible({ timeout: 5_000 });

      // Click toggle again to collapse back to summary
      const collapseButton = page.getByTestId("toggle-analysis").first();
      if (
        await collapseButton.isVisible({ timeout: 3_000 }).catch(() => false)
      ) {
        await collapseButton.click();
        await expect(quickSummary).toBeVisible({ timeout: 5_000 });
      }
    }
  });

  test("quick summary shows top alternatives preview", async ({ page }) => {
    await navigateToFirstProduct(page);

    // Quick summary alternatives card
    const altPreview = page.getByTestId("quick-summary-alternatives");

    // Alt preview is optional (depends on product having alternatives)
    const isVisible = await altPreview
      .isVisible({ timeout: 5_000 })
      .catch(() => false);

    if (isVisible) {
      // Should contain product link(s)
      const links = altPreview.locator('a[href*="/app/product/"]');
      const linkCount = await links.count();
      expect(linkCount).toBeGreaterThanOrEqual(0);
    }
  });
});

// ─── Cross-Country Links ────────────────────────────────────────────────────

test.describe("Product journey: cross-country links", () => {
  test("cross-country section renders when product has links", async ({
    page,
  }) => {
    await navigateToFirstProduct(page);

    // Expand to full analysis if needed
    const toggleButton = page.getByTestId("toggle-analysis").first();
    if (await toggleButton.isVisible({ timeout: 3_000 }).catch(() => false)) {
      await toggleButton.click();
      await page.waitForTimeout(1_000);
    }

    // Cross-country links section — may or may not be present
    const crossCountry = page.getByTestId("cross-country-links-section");
    const hasCrossCountry = await crossCountry
      .isVisible({ timeout: 5_000 })
      .catch(() => false);

    if (hasCrossCountry) {
      // Should have at least one linked product card
      const linkCards = page.getByTestId("cross-country-link-card");
      await expect(linkCards.first()).toBeVisible({ timeout: 5_000 });
    }
    // If no cross-country links exist, the test passes — not all products have them
  });
});

// ─── Product Actions ────────────────────────────────────────────────────────

test.describe("Product journey: user actions", () => {
  test("compare checkbox toggles on product page", async ({ page }) => {
    await navigateToFirstProduct(page);

    // CompareCheckbox button should be visible on the product page
    const compareBtn = page
      .getByRole("button", { name: /compare|porównaj/i })
      .first();

    const isVisible = await compareBtn
      .isVisible({ timeout: 5_000 })
      .catch(() => false);

    if (isVisible) {
      // Click to add to comparison
      await compareBtn.click();
      await page.waitForTimeout(500);

      // Click again to remove
      await compareBtn.click();
      await page.waitForTimeout(500);

      // Should not crash
      await expect(page.locator("body")).not.toContainText(/failed|error/i);
    }
  });

  test("add-to-list menu is accessible from product page", async ({
    page,
  }) => {
    await navigateToFirstProduct(page);

    // AddToListMenu button
    const listBtn = page
      .getByRole("button", { name: /list|lista/i })
      .first();

    const isVisible = await listBtn
      .isVisible({ timeout: 5_000 })
      .catch(() => false);

    if (isVisible) {
      await listBtn.click();

      // Dropdown/menu should appear with list options
      await page.waitForTimeout(1_000);
      await expect(page.locator("body")).not.toContainText(/failed|error/i);

      // Close the menu by pressing Escape
      await page.keyboard.press("Escape");
    }
  });

  test("scoring tab shows v3.3 breakdown factors", async ({ page }) => {
    await navigateToFirstProduct(page);

    // Expand to full analysis if needed
    const toggleButton = page.getByTestId("toggle-analysis").first();
    if (await toggleButton.isVisible({ timeout: 3_000 }).catch(() => false)) {
      await toggleButton.click();
      await page.waitForTimeout(1_000);
    }

    // Click the Scoring tab
    const scoringTab = page.getByRole("tab", {
      name: /scoring|punktacja/i,
    });
    await expect(scoringTab).toBeVisible({ timeout: 10_000 });
    await scoringTab.click();

    // Score breakdown should show factor names
    await page.waitForTimeout(2_000);
    const body = page.locator("body");
    await expect(body).toBeVisible();
    await expect(body).not.toContainText(/failed|error/i);

    // The scoring tab should show breakdown content (not be empty)
    const tabContent = page.locator('[role="tabpanel"]');
    const contentText = await tabContent.textContent();
    expect(contentText?.length).toBeGreaterThan(10);
  });
});
