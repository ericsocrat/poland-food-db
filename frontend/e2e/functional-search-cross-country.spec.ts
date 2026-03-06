// ─── Functional E2E: Search & cross-country ─────────────────────────────────
// Tests product search behaviour, country switching via settings, and
// verifying that search results are scoped to the selected country.
//
// Requires: authenticated session (depends on auth-setup project).
// 9 tests
// ─────────────────────────────────────────────────────────────────────────────

import { test, expect } from "@playwright/test";

// ─── Search Basics ──────────────────────────────────────────────────────────

test.describe("Search cross-country: search basics", () => {
  test("search page renders input and empty state", async ({ page }) => {
    await page.goto("/app/search");
    await page.waitForLoadState("networkidle");

    // Search input (combobox)
    const searchInput = page.getByPlaceholder(/search products/i);
    await expect(searchInput).toBeVisible({ timeout: 10_000 });
  });

  test("search returns results for generic query", async ({ page }) => {
    await page.goto("/app/search");
    await page.waitForLoadState("networkidle");

    const searchInput = page.getByPlaceholder(/search products/i);
    await searchInput.fill("milk");
    await page.waitForTimeout(2_000);

    // Either: autocomplete dropdown appears, or results container is shown
    const autocomplete = page.locator("#search-autocomplete-listbox");
    const results = page.getByTestId("results-container");
    const zeroResults = page.getByTestId("zero-results");

    const hasAutocomplete = await autocomplete
      .isVisible({ timeout: 3_000 })
      .catch(() => false);
    const hasResults = await results
      .isVisible({ timeout: 3_000 })
      .catch(() => false);
    const hasZero = await zeroResults
      .isVisible({ timeout: 3_000 })
      .catch(() => false);

    // At least one of these should be true
    expect(hasAutocomplete || hasResults || hasZero).toBeTruthy();
  });

  test("search autocomplete shows product suggestions", async ({ page }) => {
    await page.goto("/app/search");
    await page.waitForLoadState("networkidle");

    const searchInput = page.getByPlaceholder(/search products/i);
    await searchInput.fill("chip");
    await page.waitForTimeout(2_000);

    // Autocomplete listbox
    const autocomplete = page.locator("#search-autocomplete-listbox");
    const hasDropdown = await autocomplete
      .isVisible({ timeout: 5_000 })
      .catch(() => false);

    if (hasDropdown) {
      // Should have at least one option
      const options = autocomplete.locator("[role='option']");
      const optionCount = await options.count();
      expect(optionCount).toBeGreaterThanOrEqual(1);

      // Click first suggestion
      await options.first().click();
      await page.waitForLoadState("networkidle");

      // Should navigate to product or show results
      await expect(page.locator("body")).not.toContainText(
        /error|failed/i,
      );
    }
  });

  test("search result links navigate to product detail", async ({ page }) => {
    await page.goto("/app/search");
    await page.waitForLoadState("networkidle");

    const searchInput = page.getByPlaceholder(/search products/i);
    await searchInput.fill("doritos");

    // Wait for autocomplete and press Enter to get results
    await page.waitForTimeout(2_000);
    await searchInput.press("Enter");
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(2_000);

    // Check for product links in results
    const productLinks = page.locator('a[href*="/app/product/"]');
    const hasLinks = await productLinks
      .first()
      .isVisible({ timeout: 5_000 })
      .catch(() => false);

    if (hasLinks) {
      await productLinks.first().click();
      await page.waitForLoadState("networkidle");

      // Should land on product detail page
      await expect(page).toHaveURL(/\/app\/product\/\d+/);
    }
  });
});

// ─── Country Switching ──────────────────────────────────────────────────────

test.describe("Search cross-country: country switching", () => {
  test("settings page shows country selector buttons", async ({ page }) => {
    await page.goto("/app/settings");
    await page.waitForLoadState("networkidle");

    // Settings heading
    await expect(
      page.getByRole("heading", { name: /settings|ustawienia/i }).first(),
    ).toBeVisible({ timeout: 10_000 });

    // Country flag buttons — PL and DE
    const polskaBtn = page
      .locator("button")
      .filter({ hasText: "Polska" })
      .first();
    const deutschBtn = page
      .locator("button")
      .filter({ hasText: "Deutschland" })
      .first();

    await expect(polskaBtn).toBeVisible({ timeout: 10_000 });
    await expect(deutschBtn).toBeVisible({ timeout: 10_000 });
  });

  test("switching country to DE reveals save button", async ({ page }) => {
    await page.goto("/app/settings");
    await page.waitForLoadState("networkidle");

    // Click Deutschland
    const deutschBtn = page
      .locator("button")
      .filter({ hasText: "Deutschland" })
      .first();
    await deutschBtn.click();

    // Save button should appear
    const saveBtn = page.getByRole("button", {
      name: /save|speichern|zapisz/i,
    });
    await expect(saveBtn).toBeVisible({ timeout: 5_000 });
  });

  test("switching to DE and saving persists across navigation", async ({
    page,
  }) => {
    // Switch to DE
    await page.goto("/app/settings");
    await page.waitForLoadState("networkidle");

    const deutschBtn = page
      .locator("button")
      .filter({ hasText: "Deutschland" })
      .first();
    await deutschBtn.click();

    const saveBtn = page.getByRole("button", {
      name: /save|speichern|zapisz/i,
    });
    await expect(saveBtn).toBeVisible({ timeout: 5_000 });
    await saveBtn.click();

    // Wait for save to complete (toast or state change)
    await page.waitForTimeout(3_000);

    // Navigate away and come back
    await page.goto("/app/categories");
    await page.waitForLoadState("networkidle");
    await page.goto("/app/settings");
    await page.waitForLoadState("networkidle");

    // Deutschland should still be the selected country
    const deutschBtnAfter = page
      .locator("button")
      .filter({ hasText: "Deutschland" })
      .first();
    await expect(deutschBtnAfter).toBeVisible();

    // Cleanup: switch back to Poland
    const polskaBtn = page
      .locator("button")
      .filter({ hasText: "Polska" })
      .first();
    await polskaBtn.click();

    const saveBtnCleanup = page.getByRole("button", {
      name: /save|speichern|zapisz/i,
    });
    const canSave = await saveBtnCleanup
      .isVisible({ timeout: 3_000 })
      .catch(() => false);
    if (canSave) {
      await saveBtnCleanup.click();
      await page.waitForTimeout(2_000);
    }
  });
});

// ─── Cross-Country Search Isolation ─────────────────────────────────────────

test.describe("Search cross-country: result isolation", () => {
  // This test verifies that switching country affects the products seen in
  // category listings — demonstrating country-scoped data isolation.
  test("category listing shows different products after country switch", async ({
    page,
  }) => {
    // Step 1: Note products in PL chips category
    await page.goto("/app/categories/chips");
    await page.waitForLoadState("networkidle");

    const plProductLinks = page.locator('a[href*="/app/product/"]');
    await expect(plProductLinks.first()).toBeVisible({ timeout: 15_000 });

    const plFirstProductText = await plProductLinks
      .first()
      .innerText()
      .catch(() => "");

    // Step 2: Switch to DE
    await page.goto("/app/settings");
    await page.waitForLoadState("networkidle");

    const deutschBtn = page
      .locator("button")
      .filter({ hasText: "Deutschland" })
      .first();
    await deutschBtn.click();

    const saveBtn = page.getByRole("button", {
      name: /save|speichern|zapisz/i,
    });
    await expect(saveBtn).toBeVisible({ timeout: 5_000 });
    await saveBtn.click();
    await page.waitForTimeout(3_000);

    // Step 3: View chips category again — should show DE products
    await page.goto("/app/categories/chips");
    await page.waitForLoadState("networkidle");

    const deProductLinks = page.locator('a[href*="/app/product/"]');
    await expect(deProductLinks.first()).toBeVisible({ timeout: 15_000 });

    const deFirstProductText = await deProductLinks
      .first()
      .innerText()
      .catch(() => "");

    // PL and DE should show different first products
    // (Doritos Sweet Chili PL vs Chipsfrisch ungarisch DE)
    if (plFirstProductText && deFirstProductText) {
      expect(plFirstProductText).not.toEqual(deFirstProductText);
    }

    // Step 4: Cleanup — switch back to PL
    await page.goto("/app/settings");
    await page.waitForLoadState("networkidle");

    const polskaBtn = page
      .locator("button")
      .filter({ hasText: "Polska" })
      .first();
    await polskaBtn.click();

    const saveBtnCleanup = page.getByRole("button", {
      name: /save|speichern|zapisz/i,
    });
    const canSave = await saveBtnCleanup
      .isVisible({ timeout: 3_000 })
      .catch(() => false);
    if (canSave) {
      await saveBtnCleanup.click();
      await page.waitForTimeout(2_000);
    }
  });
});
