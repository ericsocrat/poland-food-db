import { test, expect } from "@playwright/test";

// ─── Smoke tests: verify pages load without crashes ─────────────────────────

test.describe("Public pages", () => {
  test("landing page renders hero", async ({ page }) => {
    await page.goto("/");
    await expect(page.locator("text=healthier choices")).toBeVisible();
    await expect(page.locator('a[href="/auth/signup"]').first()).toBeVisible();
    await expect(page.locator('a[href="/auth/login"]').first()).toBeVisible();
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
  test("dashboard redirects to login", async ({ page }) => {
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
