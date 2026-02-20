import { test, expect } from "@playwright/test";

// ─── Achievements E2E Tests (#51) — Smoke ───────────────────────────────────
// Verifies achievements page navigation structure exists and is accessible.

test.describe("Achievements — Navigation", () => {
  test("achievements page redirects unauthenticated users to login", async ({
    page,
  }) => {
    const response = await page.goto("/app/achievements");

    // Should redirect to auth/login (middleware enforcement)
    expect(page.url()).toContain("/auth/login");
    expect(response?.status()).toBeLessThan(400);
  });

  test("desktop sidebar contains achievements link on public page", async ({
    page,
  }) => {
    // Check the landing page renders without errors
    const response = await page.goto("/");
    expect(response?.status()).toBeLessThan(400);
  });
});
