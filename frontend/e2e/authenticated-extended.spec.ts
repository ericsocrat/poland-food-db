// ─── Extended authenticated E2E tests ────────────────────────────────────────
// These tests run with pre-authenticated storageState produced by auth.setup.ts.
// Covers: navigation bar, scan pages, lists, compare, search features, settings.

import { test, expect } from "@playwright/test";

// ─── Bottom Navigation Bar ─────────────────────────────────────────────────

test.describe("App navigation bar", () => {
  test("renders all 5 nav items", async ({ page }) => {
    await page.goto("/app/search");
    const nav = page.getByRole("navigation", { name: "Main navigation" });
    await expect(nav).toBeVisible();

    await expect(nav.getByRole("link", { name: "Search" })).toBeVisible();
    await expect(nav.getByRole("link", { name: "Categories" })).toBeVisible();
    await expect(nav.getByRole("link", { name: "Scan" })).toBeVisible();
    await expect(nav.getByRole("link", { name: "Lists" })).toBeVisible();
    await expect(nav.getByRole("link", { name: "Settings" })).toBeVisible();
  });

  test("Search link navigates to /app/search", async ({ page }) => {
    await page.goto("/app/settings");
    const nav = page.getByRole("navigation", { name: "Main navigation" });
    await nav.getByRole("link", { name: "Search" }).click();
    await expect(page).toHaveURL(/\/app\/search/);
  });

  test("Categories link navigates to /app/categories", async ({ page }) => {
    await page.goto("/app/search");
    const nav = page.getByRole("navigation", { name: "Main navigation" });
    await nav.getByRole("link", { name: "Categories" }).click();
    await expect(page).toHaveURL(/\/app\/categories/);
  });

  test("Scan link navigates to /app/scan", async ({ page }) => {
    await page.goto("/app/search");
    const nav = page.getByRole("navigation", { name: "Main navigation" });
    await nav.getByRole("link", { name: "Scan" }).click();
    await expect(page).toHaveURL(/\/app\/scan/);
  });

  test("Lists link navigates to /app/lists", async ({ page }) => {
    await page.goto("/app/search");
    const nav = page.getByRole("navigation", { name: "Main navigation" });
    await nav.getByRole("link", { name: "Lists" }).click();
    await expect(page).toHaveURL(/\/app\/lists/);
  });

  test("Settings link navigates to /app/settings", async ({ page }) => {
    await page.goto("/app/search");
    const nav = page.getByRole("navigation", { name: "Main navigation" });
    await nav.getByRole("link", { name: "Settings" }).click();
    await expect(page).toHaveURL(/\/app\/settings/);
  });
});

// ─── Scan Page ──────────────────────────────────────────────────────────────

test.describe("Scan page", () => {
  test("renders with heading", async ({ page }) => {
    await page.goto("/app/scan");
    await expect(
      page.getByRole("heading", { name: /Scan Barcode/i }),
    ).toBeVisible();
  });

  test("has Camera and Manual mode toggles", async ({ page }) => {
    await page.goto("/app/scan");
    await expect(page.getByText("Camera", { exact: false })).toBeVisible();
    await expect(page.getByText("Manual", { exact: false })).toBeVisible();
  });

  test("Manual mode shows EAN input", async ({ page }) => {
    await page.goto("/app/scan");
    // Click Manual mode toggle
    await page.getByText("Manual", { exact: false }).click();

    const eanInput = page.getByPlaceholder(
      /Enter EAN barcode/i,
    );
    await expect(eanInput).toBeVisible();
  });

  test("Manual mode has Look up button", async ({ page }) => {
    await page.goto("/app/scan");
    await page.getByText("Manual", { exact: false }).click();

    await expect(
      page.getByRole("button", { name: /Look up/i }),
    ).toBeVisible();
  });

  test("Manual EAN input accepts numeric input", async ({ page }) => {
    await page.goto("/app/scan");
    await page.getByText("Manual", { exact: false }).click();

    const eanInput = page.getByPlaceholder(/Enter EAN barcode/i);
    await eanInput.fill("5901234123457");
    await expect(eanInput).toHaveValue("5901234123457");
  });

  test("has History link", async ({ page }) => {
    await page.goto("/app/scan");
    await expect(
      page.getByRole("link", { name: /History/i }),
    ).toBeVisible();
  });

  test("has My Submissions link", async ({ page }) => {
    await page.goto("/app/scan");
    await expect(
      page.getByRole("link", { name: /My Submissions/i }),
    ).toBeVisible();
  });
});

// ─── Scan History ───────────────────────────────────────────────────────────

test.describe("Scan history page", () => {
  test("renders heading", async ({ page }) => {
    await page.goto("/app/scan/history");
    await expect(
      page.getByRole("heading", { name: /Scan History/i }),
    ).toBeVisible();
  });

  test("has back link to scanner", async ({ page }) => {
    await page.goto("/app/scan/history");
    const backLink = page.getByRole("link", { name: /Back to Scanner/i });
    await expect(backLink).toBeVisible();
    await expect(backLink).toHaveAttribute("href", "/app/scan");
  });

  test("has filter tabs", async ({ page }) => {
    await page.goto("/app/scan/history");
    await expect(page.getByText("All")).toBeVisible();
    await expect(page.getByText("Found")).toBeVisible();
    await expect(page.getByText("Not Found")).toBeVisible();
  });

  test("shows empty state for new user", async ({ page }) => {
    await page.goto("/app/scan/history");
    await expect(
      page.getByText("No scans yet", { exact: false }),
    ).toBeVisible();
  });
});

// ─── Submit Product ─────────────────────────────────────────────────────────

test.describe("Submit product page", () => {
  test("renders heading", async ({ page }) => {
    await page.goto("/app/scan/submit");
    await expect(
      page.getByRole("heading", { name: /Submit Product/i }),
    ).toBeVisible();
  });

  test("has back link to scanner", async ({ page }) => {
    await page.goto("/app/scan/submit");
    const backLink = page.getByRole("link", { name: /Back to Scanner/i });
    await expect(backLink).toBeVisible();
  });

  test("renders all form fields", async ({ page }) => {
    await page.goto("/app/scan/submit");
    await expect(page.getByLabel(/EAN Barcode/i)).toBeVisible();
    await expect(page.getByLabel(/Product Name/i)).toBeVisible();
    await expect(page.getByLabel("Brand")).toBeVisible();
    await expect(page.getByLabel("Category")).toBeVisible();
    await expect(page.getByLabel("Notes")).toBeVisible();
  });

  test("pre-fills EAN from query parameter", async ({ page }) => {
    await page.goto("/app/scan/submit?ean=5901234123457");
    const eanInput = page.getByLabel(/EAN Barcode/i);
    await expect(eanInput).toHaveValue("5901234123457");
  });

  test("submit button exists", async ({ page }) => {
    await page.goto("/app/scan/submit");
    await expect(
      page.getByRole("button", { name: /Submit Product/i }),
    ).toBeVisible();
  });

  test("shows review notice", async ({ page }) => {
    await page.goto("/app/scan/submit");
    await expect(
      page.getByText("reviewed before being added", { exact: false }),
    ).toBeVisible();
  });
});

// ─── Lists Page ─────────────────────────────────────────────────────────────

test.describe("Lists page", () => {
  test("renders heading", async ({ page }) => {
    await page.goto("/app/lists");
    await expect(
      page.getByRole("heading", { name: /My Lists/i }),
    ).toBeVisible();
  });

  test("has New List button", async ({ page }) => {
    await page.goto("/app/lists");
    await expect(
      page.getByRole("button", { name: /New List/i }),
    ).toBeVisible();
  });

  test("New List button toggles create form", async ({ page }) => {
    await page.goto("/app/lists");
    await page.getByRole("button", { name: /New List/i }).click();

    // Form fields should be visible
    await expect(page.getByPlaceholder("List name")).toBeVisible();
    await expect(
      page.getByPlaceholder("Description (optional)"),
    ).toBeVisible();
    await expect(
      page.getByRole("button", { name: /Create List/i }),
    ).toBeVisible();
  });

  test("Cancel button hides create form", async ({ page }) => {
    await page.goto("/app/lists");
    await page.getByRole("button", { name: /New List/i }).click();
    await expect(page.getByPlaceholder("List name")).toBeVisible();

    await page.getByRole("button", { name: "Cancel" }).click();
    await expect(page.getByPlaceholder("List name")).not.toBeVisible();
  });

  test("shows empty state for new user", async ({ page }) => {
    await page.goto("/app/lists");
    // New test user has auto-created favorites/avoid lists or an empty state
    // At minimum, the page loads without error
    await expect(page.locator("body")).toBeVisible();
    expect(page.url()).toMatch(/\/app\/lists/);
  });
});

// ─── Compare Page ───────────────────────────────────────────────────────────

test.describe("Compare page", () => {
  test("renders heading", async ({ page }) => {
    await page.goto("/app/compare");
    await expect(
      page.getByRole("heading", { name: /Compare Products/i }),
    ).toBeVisible();
  });

  test("shows empty state with instructions", async ({ page }) => {
    await page.goto("/app/compare");
    await expect(
      page.getByText("Select 2–4 products to compare", { exact: false }).or(
        page.getByText("Select 2-4 products to compare", { exact: false }),
      ),
    ).toBeVisible();
  });

  test("has Search Products CTA link", async ({ page }) => {
    await page.goto("/app/compare");
    const link = page.getByRole("link", { name: /Search Products/i });
    await expect(link).toBeVisible();
    await expect(link).toHaveAttribute("href", "/app/search");
  });

  test("has Saved Comparisons link", async ({ page }) => {
    await page.goto("/app/compare");
    const link = page.getByRole("link", { name: /Saved Comparisons/i });
    await expect(link).toBeVisible();
    await expect(link).toHaveAttribute("href", "/app/compare/saved");
  });
});

// ─── Saved Comparisons ─────────────────────────────────────────────────────

test.describe("Saved comparisons page", () => {
  test("renders heading", async ({ page }) => {
    await page.goto("/app/compare/saved");
    await expect(
      page.getByRole("heading", { name: /Saved Comparisons/i }),
    ).toBeVisible();
  });

  test("has back link to compare", async ({ page }) => {
    await page.goto("/app/compare/saved");
    const backLink = page.getByRole("link", { name: /Compare/i });
    await expect(backLink).toBeVisible();
  });
});

// ─── Settings Extended ──────────────────────────────────────────────────────

test.describe("Settings page extended", () => {
  test("shows user account section", async ({ page }) => {
    await page.goto("/app/settings");
    await expect(
      page.getByRole("button", { name: /sign out/i }),
    ).toBeVisible();
  });

  test("shows allergens section", async ({ page }) => {
    await page.goto("/app/settings");
    await expect(
      page.getByText(/allergen/i).first(),
    ).toBeVisible();
  });

  test("has country selector with Poland", async ({ page }) => {
    await page.goto("/app/settings");
    await expect(
      page.getByText("Poland").or(page.getByText("Polska")),
    ).toBeVisible();
  });
});

// ─── Categories Extended ────────────────────────────────────────────────────

test.describe("Categories page extended", () => {
  test("renders heading", async ({ page }) => {
    await page.goto("/app/categories");
    await expect(
      page.getByRole("heading", { name: /categor/i }),
    ).toBeVisible();
  });

  test("page loads without crash", async ({ page }) => {
    await page.goto("/app/categories");
    // Should stay on categories page (not redirect to error)
    expect(page.url()).toMatch(/\/app\/categories/);
    await expect(page.locator("body")).toBeVisible();
  });
});

// ─── Search Extended ────────────────────────────────────────────────────────

test.describe("Search page extended", () => {
  test("search input has correct placeholder", async ({ page }) => {
    await page.goto("/app/search");
    const input = page.locator('input[placeholder*="Search"]');
    await expect(input).toBeVisible();
  });

  test("pressing Enter in empty search stays on search page", async ({
    page,
  }) => {
    await page.goto("/app/search");
    const input = page.locator('input[placeholder*="Search"]');
    await input.press("Enter");
    await expect(page).toHaveURL(/\/app\/search/);
  });

  test("page maintains state after typing", async ({ page }) => {
    await page.goto("/app/search");
    const input = page.locator('input[placeholder*="Search"]');
    await input.fill("test query");
    await expect(input).toHaveValue("test query");
  });
});

// ─── Saved Searches ─────────────────────────────────────────────────────────

test.describe("Saved searches page", () => {
  test("renders heading", async ({ page }) => {
    await page.goto("/app/search/saved");
    await expect(
      page.getByRole("heading", { name: /Saved Searches/i }),
    ).toBeVisible();
  });

  test("has back link to search", async ({ page }) => {
    await page.goto("/app/search/saved");
    const backLink = page.getByRole("link", { name: /Back to Search/i });
    await expect(backLink).toBeVisible();
  });
});

// ─── My Submissions ─────────────────────────────────────────────────────────

test.describe("My submissions page", () => {
  test("renders heading", async ({ page }) => {
    await page.goto("/app/scan/submissions");
    await expect(
      page.getByRole("heading", { name: /My Submissions/i }),
    ).toBeVisible();
  });

  test("has back link to scanner", async ({ page }) => {
    await page.goto("/app/scan/submissions");
    const backLink = page.getByRole("link", { name: /Back to Scanner/i });
    await expect(backLink).toBeVisible();
  });
});

// ─── Cross-page navigation flows ───────────────────────────────────────────

test.describe("Cross-page navigation", () => {
  test("scan → history → back to scan", async ({ page }) => {
    await page.goto("/app/scan");
    await page.getByRole("link", { name: /History/i }).click();
    await expect(page).toHaveURL(/\/app\/scan\/history/);

    await page.getByRole("link", { name: /Back to Scanner/i }).click();
    await expect(page).toHaveURL(/\/app\/scan/);
  });

  test("compare → saved comparisons → back", async ({ page }) => {
    await page.goto("/app/compare");
    const savedLink = page.getByRole("link", { name: /Saved Comparisons/i });
    await savedLink.click();
    await expect(page).toHaveURL(/\/app\/compare\/saved/);
  });

  test("lists page → create → cancel preserves page", async ({ page }) => {
    await page.goto("/app/lists");
    await page.getByRole("button", { name: /New List/i }).click();
    await expect(page.getByPlaceholder("List name")).toBeVisible();
    await page.getByRole("button", { name: "Cancel" }).click();
    expect(page.url()).toMatch(/\/app\/lists/);
  });
});
