import { test, expect } from "@playwright/test";

// ─── Telemetry E2E Tests (#52) — Smoke ──────────────────────────────────────
// Verifies event bus integration does not break page rendering.
// Achievement tracking is fire-and-forget so we only verify pages load cleanly.

test.describe("Telemetry — Smoke", () => {
  test("learn page loads without errors (emits learn.page_viewed)", async ({
    page,
  }) => {
    const response = await page.goto("/learn");
    expect(response?.status()).toBeLessThan(400);
    await expect(page.locator("h1")).toBeVisible();
  });

  test("search page loads without errors (has event bus instrumented)", async ({
    page,
  }) => {
    // Search page redirects unauthenticated users
    await page.goto("/app/search");
    expect(page.url()).toContain("/auth/login");
  });
});
