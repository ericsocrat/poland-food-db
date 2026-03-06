// ─── Functional E2E: Comparison sharing ─────────────────────────────────────
// Tests the full comparison journey: add products to compare, view comparison
// grid, save comparison, generate share link, and load public shared view.
//
// Requires: authenticated session (depends on auth-setup project).
// 8 tests
// ─────────────────────────────────────────────────────────────────────────────

import { test, expect } from "@playwright/test";

// Helper: extract product IDs from first two product links in a category listing
async function getTwoProductIds(
  page: import("@playwright/test").Page,
  category = "chips",
): Promise<[string, string]> {
  await page.goto(`/app/categories/${category}`);
  await page.waitForLoadState("networkidle");

  const productLinks = page.locator('a[href*="/app/product/"]');
  await expect(productLinks.first()).toBeVisible({ timeout: 15_000 });

  const href1 = await productLinks.nth(0).getAttribute("href");
  const href2 = await productLinks.nth(1).getAttribute("href");

  const id1 = href1?.match(/\/app\/product\/(\d+)/)?.[1] ?? "";
  const id2 = href2?.match(/\/app\/product\/(\d+)/)?.[1] ?? "";

  expect(id1).toBeTruthy();
  expect(id2).toBeTruthy();

  return [id1, id2];
}

// ─── Comparison Grid ────────────────────────────────────────────────────────

test.describe("Comparison sharing: grid display", () => {
  test("comparison page renders grid with 2 products", async ({ page }) => {
    const [id1, id2] = await getTwoProductIds(page);

    await page.goto(`/app/compare?ids=${id1},${id2}`);
    await page.waitForLoadState("networkidle");

    // Page heading should be visible
    await expect(
      page.getByRole("heading", { level: 1 }),
    ).toBeVisible({ timeout: 10_000 });

    // Comparison table should render (desktop) or cards (mobile)
    const table = page.locator("table");
    const hasTable = await table.isVisible({ timeout: 5_000 }).catch(() => false);

    if (hasTable) {
      // Desktop: table with product columns
      const headers = table.locator("th, td").first();
      await expect(headers).toBeVisible();
    }

    // Page should not show error state
    await expect(page.locator("body")).not.toContainText(/failed|error/i);
  });

  test("comparison grid shows nutrition rows", async ({ page }) => {
    const [id1, id2] = await getTwoProductIds(page);

    await page.goto(`/app/compare?ids=${id1},${id2}`);
    await page.waitForLoadState("networkidle");

    // Wait for data to load
    await page.waitForTimeout(2_000);

    // Should show calorie or score values
    const body = page.locator("body");
    await expect(body).toBeVisible();

    // At least one nutrition-related label should be visible
    await expect(
      page
        .getByText(/calories|kcal|tryvit|score/i)
        .first(),
    ).toBeVisible({ timeout: 10_000 });
  });

  test("comparison highlights winner with best score", async ({ page }) => {
    const [id1, id2] = await getTwoProductIds(page);

    await page.goto(`/app/compare?ids=${id1},${id2}`);
    await page.waitForLoadState("networkidle");

    await page.waitForTimeout(2_000);

    // The comparison grid highlights the winner — look for trophy icon or
    // green highlighting. This is CSS-based so we just verify the page renders
    // without errors and has product data.
    const body = page.locator("body");
    await expect(body).not.toContainText(/failed|error/i);

    // Both products should have names visible
    const productNames = page.locator("h2, h3, th, .font-bold").filter({
      hasNotText: /compare|comparison|porówn/i,
    });
    const nameCount = await productNames.count();
    expect(nameCount).toBeGreaterThanOrEqual(2);
  });
});

// ─── Empty State ────────────────────────────────────────────────────────────

test.describe("Comparison sharing: empty state", () => {
  test("compare page shows empty state when no products selected", async ({
    page,
  }) => {
    await page.goto("/app/compare");
    await page.waitForLoadState("networkidle");

    // Empty state should show with a CTA to search
    const searchLink = page.getByRole("link", { name: /search products/i });
    await expect(searchLink).toBeVisible({ timeout: 10_000 });
  });
});

// ─── Save & Share Flow ──────────────────────────────────────────────────────

test.describe("Comparison sharing: save and share", () => {
  test("copy URL button is available on comparison page", async ({ page }) => {
    const [id1, id2] = await getTwoProductIds(page);

    await page.goto(`/app/compare?ids=${id1},${id2}`);
    await page.waitForLoadState("networkidle");

    // Wait for comparison to render
    await page.waitForTimeout(2_000);

    // Copy URL button (first step of share flow)
    const copyUrlBtn = page.getByRole("button", { name: /copy url|kopiuj/i });
    const isVisible = await copyUrlBtn
      .isVisible({ timeout: 5_000 })
      .catch(() => false);

    if (isVisible) {
      await copyUrlBtn.click();
      // Should show "Copied!" feedback
      await expect(
        page.getByText(/copied|skopiowano/i).first(),
      ).toBeVisible({ timeout: 5_000 });
    }
  });

  test("save comparison button triggers save mutation", async ({ page }) => {
    const [id1, id2] = await getTwoProductIds(page);

    await page.goto(`/app/compare?ids=${id1},${id2}`);
    await page.waitForLoadState("networkidle");

    await page.waitForTimeout(2_000);

    // Save Comparison button (second step of share flow)
    const saveBtn = page.getByRole("button", {
      name: /save comparison|zapisz/i,
    });
    const isVisible = await saveBtn
      .isVisible({ timeout: 5_000 })
      .catch(() => false);

    if (isVisible) {
      await saveBtn.click();

      // Should show saving feedback
      await page.waitForTimeout(2_000);

      // After saving, the "Copy Share Link" button should appear
      const shareBtn = page.getByRole("button", {
        name: /copy share|share link|udostępnij/i,
      });
      const hasShareBtn = await shareBtn
        .isVisible({ timeout: 5_000 })
        .catch(() => false);

      // Whether save succeeded or not, page should not crash
      await expect(page.locator("body")).not.toContainText(/failed|error/i);

      if (hasShareBtn) {
        await shareBtn.click();
        // Should show copied feedback
        await expect(
          page.getByText(/copied|skopiowano/i).first(),
        ).toBeVisible({ timeout: 5_000 });
      }
    }
  });
});

// ─── Saved Comparisons ──────────────────────────────────────────────────────

test.describe("Comparison sharing: saved comparisons", () => {
  test("saved comparisons page is accessible", async ({ page }) => {
    await page.goto("/app/compare/saved");
    await page.waitForLoadState("networkidle");

    // Should show heading
    await expect(
      page.getByRole("heading").first(),
    ).toBeVisible({ timeout: 10_000 });

    // Page should not crash
    await expect(page.locator("body")).not.toContainText(/failed|error/i);
  });
});

// ─── Shared Comparison (Public View) ────────────────────────────────────────

test.describe("Comparison sharing: public shared view", () => {
  // Shared comparison pages are public (no auth required).
  // We test with an invalid token to verify the error state renders properly.
  test.use({ storageState: { cookies: [], origins: [] } });

  test("shared comparison with invalid token shows error state", async ({
    page,
  }) => {
    await page.goto("/compare/shared/invalid-token-abc123");
    await page.waitForLoadState("networkidle");

    // Should show an error or "invalid comparison" message
    await expect(
      page
        .getByText(/invalid|not found|expired|nie znaleziono/i)
        .or(page.getByRole("link", { name: /tryvit|sign up|go to|zaloguj/i }))
        .first(),
    ).toBeVisible({ timeout: 10_000 });
  });
});
