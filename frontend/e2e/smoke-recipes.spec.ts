import { test, expect } from "@playwright/test";

// ─── Recipes E2E Tests (#53, #54) — Smoke ───────────────────────────────────
// Verifies recipes page navigation structure exists and is accessible.

test.describe("Recipes — Navigation", () => {
  test("recipes page redirects unauthenticated users to login", async ({
    page,
  }) => {
    const response = await page.goto("/app/recipes");

    // Should redirect to auth/login (middleware enforcement)
    expect(page.url()).toContain("/auth/login");
    expect(response?.status()).toBeLessThan(400);
  });

  test("recipe detail page redirects unauthenticated users to login", async ({
    page,
  }) => {
    const response = await page.goto("/app/recipes/overnight-oats");

    // Should redirect to auth/login (middleware enforcement)
    expect(page.url()).toContain("/auth/login");
    expect(response?.status()).toBeLessThan(400);
  });

  test("landing page renders without errors", async ({ page }) => {
    const response = await page.goto("/");
    expect(response?.status()).toBeLessThan(400);
  });
});
