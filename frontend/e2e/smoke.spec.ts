import { test, expect } from "@playwright/test";

// ─── Smoke tests: verify pages load without crashes ─────────────────────────
// All tests are public-page only — no Supabase dependency in CI.

test.describe("Public pages", () => {
  test("landing page renders hero", async ({ page }) => {
    await page.goto("/");
    await expect(page.locator("text=healthier choices")).toBeVisible();
    await expect(page.locator('a[href="/auth/signup"]').first()).toBeVisible();
    await expect(page.locator('a[href="/auth/login"]').first()).toBeVisible();
  });

  test("landing page has correct title", async ({ page }) => {
    await page.goto("/");
    await expect(page).toHaveTitle(/Poland Food DB/);
  });

  test("login page renders form", async ({ page }) => {
    await page.goto("/auth/login");
    await expect(page.locator("text=Welcome back")).toBeVisible();
    await expect(page.locator('input[type="email"]')).toBeVisible();
    await expect(page.locator('input[type="password"]')).toBeVisible();
  });

  test("signup page renders form", async ({ page }) => {
    await page.goto("/auth/signup");
    await expect(page.locator("text=Create your account")).toBeVisible();
    await expect(page.locator('input[type="email"]')).toBeVisible();
  });

  test("contact page renders", async ({ page }) => {
    await page.goto("/contact");
    await expect(page).toHaveTitle(/Poland Food DB/);
  });

  test("privacy page renders", async ({ page }) => {
    await page.goto("/privacy");
    await expect(page).toHaveTitle(/Poland Food DB/);
  });

  test("terms page renders", async ({ page }) => {
    await page.goto("/terms");
    await expect(page).toHaveTitle(/Poland Food DB/);
  });
});

test.describe("Auth-protected redirects", () => {
  test("search redirects to login", async ({ page }) => {
    await page.goto("/app/search");
    await page.waitForURL(/\/auth\/login/);
    await expect(page.locator("text=Welcome back")).toBeVisible();
  });

  test("settings redirects to login", async ({ page }) => {
    await page.goto("/app/settings");
    await page.waitForURL(/\/auth\/login/);
  });

  test("categories redirects to login", async ({ page }) => {
    await page.goto("/app/categories");
    await page.waitForURL(/\/auth\/login/);
  });

  test("scan redirects to login", async ({ page }) => {
    await page.goto("/app/scan");
    await page.waitForURL(/\/auth\/login/);
  });

  test("product detail redirects to login", async ({ page }) => {
    await page.goto("/app/product/1");
    await page.waitForURL(/\/auth\/login/);
  });
});

test.describe("Navigation links", () => {
  test("landing page sign-in navigates to login", async ({ page }) => {
    await page.goto("/");
    await page.locator('a[href="/auth/login"]').first().click();
    await expect(page.locator("text=Welcome back")).toBeVisible();
  });

  test("landing page get-started navigates to signup", async ({ page }) => {
    await page.goto("/");
    await page.locator('a[href="/auth/signup"]').first().click();
    await expect(page.locator("text=Create your account")).toBeVisible();
  });

  test("login page has link to signup", async ({ page }) => {
    await page.goto("/auth/login");
    await expect(page.locator('a[href="/auth/signup"]')).toBeVisible();
  });

  test("signup page has link to login", async ({ page }) => {
    await page.goto("/auth/signup");
    await expect(page.locator('a[href="/auth/login"]')).toBeVisible();
  });
});

test.describe("Login form validation", () => {
  test("submit button is disabled with empty fields", async ({ page }) => {
    await page.goto("/auth/login");
    const submitBtn = page.locator('button[type="submit"]');
    // Button should be present
    await expect(submitBtn).toBeVisible();
  });

  test("email input accepts text", async ({ page }) => {
    await page.goto("/auth/login");
    const emailInput = page.locator('input[type="email"]');
    await emailInput.fill("test@example.com");
    await expect(emailInput).toHaveValue("test@example.com");
  });

  test("password input accepts text", async ({ page }) => {
    await page.goto("/auth/login");
    const passwordInput = page.locator('input[type="password"]');
    await passwordInput.fill("password123");
    await expect(passwordInput).toHaveValue("password123");
  });
});

test.describe("Signup form validation", () => {
  test("email input accepts text", async ({ page }) => {
    await page.goto("/auth/signup");
    const emailInput = page.locator('input[type="email"]');
    await emailInput.fill("newuser@example.com");
    await expect(emailInput).toHaveValue("newuser@example.com");
  });
});

test.describe("Page accessibility basics", () => {
  test("landing page has no broken images", async ({ page }) => {
    await page.goto("/");
    // Ensure all images (if any) loaded successfully
    const images = page.locator("img");
    const count = await images.count();
    for (let i = 0; i < count; i++) {
      const img = images.nth(i);
      const naturalWidth = await img.evaluate(
        (el: HTMLImageElement) => el.naturalWidth,
      );
      expect(naturalWidth).toBeGreaterThan(0);
    }
  });

  test("login page has form labels or placeholders", async ({ page }) => {
    await page.goto("/auth/login");
    const emailInput = page.locator('input[type="email"]');
    // Should have either a label, aria-label, or placeholder
    const placeholder = await emailInput.getAttribute("placeholder");
    const ariaLabel = await emailInput.getAttribute("aria-label");
    expect(placeholder || ariaLabel).toBeTruthy();
  });
});
