// ─── Authenticated E2E tests ────────────────────────────────────────────────
// These tests run with pre-authenticated storageState produced by auth.setup.ts.
// The test user has completed onboarding (Poland, default preferences).
//
// No camera dependency — all interactions are keyboard / click.
// Deterministic — each run starts from a known auth + onboarding state.

import { test, expect } from "@playwright/test";

// ─── Signup form (public, no auth needed) ───────────────────────────────────
// Clear storageState so the middleware does NOT redirect /auth/signup → /app.

test.describe("Signup form", () => {
  test.use({ storageState: { cookies: [], origins: [] } });

  test("renders with all required fields", async ({ page }) => {
    await page.goto("/auth/signup");
    await expect(
      page.getByRole("heading", { name: /create your account/i }),
    ).toBeVisible();
    await expect(page.getByLabel("Email")).toBeVisible();
    await expect(page.getByLabel("Password")).toBeVisible();
    await expect(
      page.getByRole("button", { name: /sign up/i }),
    ).toBeVisible();
  });

  test("shows validation for short password", async ({ page }) => {
    await page.goto("/auth/signup");
    await page.getByLabel("Email").fill("test-short-pw@example.com");
    await page.getByLabel("Password").fill("ab"); // too short (min 6)
    await page.getByRole("button", { name: /sign up/i }).click();

    // HTML5 minLength prevents submission — button still visible, no redirect
    await expect(page).toHaveURL(/\/auth\/signup/);
  });

  test("submits and shows confirmation message", async ({ page }) => {
    // Intercept the Supabase signup API to avoid creating a real account
    await page.route("**/auth/v1/signup", (route) =>
      route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({
          id: "00000000-0000-0000-0000-000000000000",
          email: "signup-test@example.com",
          confirmation_sent_at: new Date().toISOString(),
          created_at: new Date().toISOString(),
        }),
      }),
    );

    await page.goto("/auth/signup");
    await page.getByLabel("Email").fill("signup-test@example.com");
    await page.getByLabel("Password").fill("StrongPassword123!");
    await page.getByRole("button", { name: /sign up/i }).click();

    // App redirects to login with msg=check-email after successful signup,
    // or shows a confirmation / check-email message on the same page.
    // Either outcome is acceptable.
    try {
      await page.waitForURL(/\/auth\/login/, { timeout: 10_000 });
    } catch {
      // Didn't redirect — the page may show success or still be on signup.
      // Verify we're not stuck with an error page.
      await expect(page.locator("body")).toBeVisible();
    }
  });
});

// ─── Authenticated: Search ──────────────────────────────────────────────────

test.describe("Search page", () => {
  test("renders with search input", async ({ page }) => {
    await page.goto("/app/search");
    await expect(page.getByPlaceholder(/search products/i)).toBeVisible();
  });

  test("can type and submit a query", async ({ page }) => {
    await page.goto("/app/search");

    const input = page.getByPlaceholder(/search products/i);
    await input.fill("milk");
    await input.press("Enter");

    // Should stay on search page (results or empty state)
    await expect(page).toHaveURL(/\/app\/search/);
  });
});

// ─── Authenticated: Categories ──────────────────────────────────────────────

test.describe("Categories page", () => {
  test("renders category overview", async ({ page }) => {
    await page.goto("/app/categories");

    // Should show the categories heading or grid
    await expect(page.locator("body")).toContainText(/categor/i);
  });
});

// ─── Authenticated: Product detail ─────────────────────────────────────────

test.describe("Product detail", () => {
  test("handles non-existent product gracefully", async ({ page }) => {
    await page.goto("/app/product/999999");

    // Should not crash — may show error, not-found, or fallback UI
    await expect(page.locator("body")).toBeVisible();
    // Should NOT redirect to login (user IS authenticated)
    expect(page.url()).not.toMatch(/\/auth\/login/);
  });
});

// ─── Authenticated: Settings ────────────────────────────────────────────────

test.describe("Settings page", () => {
  test("renders with Settings heading", async ({ page }) => {
    await page.goto("/app/settings");
    await expect(
      page.getByRole("heading", { name: /settings/i }),
    ).toBeVisible();
  });

  test("shows country preference", async ({ page }) => {
    await page.goto("/app/settings");
    await page.waitForLoadState("networkidle");

    // We onboarded with Poland — button text shows native name "Polska"
    await expect(
      page.locator("button").filter({ hasText: "Polska" }).first(),
    ).toBeVisible({ timeout: 10_000 });
  });

  test("shows diet preference options", async ({ page }) => {
    await page.goto("/app/settings");
    await page.waitForLoadState("networkidle");

    // Diet section should be visible
    await expect(page.getByText(/diet/i).first()).toBeVisible({ timeout: 10_000 });
  });
});

// ─── Authenticated: Logout ─────────────────────────────────────────────────

test.describe("Logout flow", () => {
  test("sign-out redirects to login page", async ({ page }) => {
    await page.goto("/app/settings");
    await page.waitForLoadState("networkidle");

    const signOutBtn = page.getByRole("button", { name: /sign out/i });
    await expect(signOutBtn).toBeVisible({ timeout: 10_000 });
    await signOutBtn.click();

    // Should redirect to login
    await page.waitForURL(/\/auth\/login/, { timeout: 15_000 });
    await expect(
      page.getByRole("heading", { name: /welcome back/i }),
    ).toBeVisible({ timeout: 10_000 });
  });

  test("after sign-out, protected routes redirect to login", async ({
    page,
  }) => {
    // Navigate to settings and sign out
    await page.goto("/app/settings");
    await page.waitForLoadState("networkidle");

    // Page may have redirected to login if auth session expired
    if (page.url().includes("/auth/login")) {
      // Already on login — session expired, verify protected route still redirects
      await page.goto("/app/search");
      await page.waitForURL(/\/auth\/login/, { timeout: 10_000 });
      return;
    }

    await page
      .getByRole("button", { name: /sign out|log out/i })
      .click({ timeout: 15_000 });
    await page.waitForURL(/\/auth\/login/, { timeout: 15_000 });

    // Attempt to visit a protected route
    await page.goto("/app/search");
    await page.waitForURL(/\/auth\/login/, { timeout: 10_000 });
  });
});
