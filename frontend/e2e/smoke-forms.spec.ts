import { test, expect } from "@playwright/test";

// ─── Form Validation UX E2E Tests ──────────────────────────────────────────
// Issue #69: Verify forms have proper structure, labels, required attributes,
// and native validation behavior on public auth pages.

test.describe("Login form validation UX", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/auth/login");
  });

  test("has properly labeled email and password fields", async ({ page }) => {
    const emailLabel = page.locator('label[for="email"]');
    const passwordLabel = page.locator('label[for="password"]');

    await expect(emailLabel).toBeVisible();
    await expect(passwordLabel).toBeVisible();

    const emailInput = page.locator("#email");
    const passwordInput = page.locator("#password");

    await expect(emailInput).toHaveAttribute("type", "email");
    await expect(passwordInput).toHaveAttribute("type", "password");
  });

  test("email and password fields are required", async ({ page }) => {
    const emailInput = page.locator("#email");
    const passwordInput = page.locator("#password");

    await expect(emailInput).toHaveAttribute("required", "");
    await expect(passwordInput).toHaveAttribute("required", "");
  });

  test("submit button is present and has correct type", async ({ page }) => {
    const submit = page.locator('button[type="submit"]');
    await expect(submit).toBeVisible();
    await expect(submit).toHaveAttribute("type", "submit");
  });

  test("tab order follows logical flow: email → password → submit", async ({
    page,
  }) => {
    const emailInput = page.locator("#email");
    await emailInput.focus();
    await expect(emailInput).toBeFocused();

    await page.keyboard.press("Tab");
    await expect(page.locator("#password")).toBeFocused();

    await page.keyboard.press("Tab");
    await expect(page.locator('button[type="submit"]')).toBeFocused();
  });

  test("empty form submission is blocked by native validation", async ({
    page,
  }) => {
    const submit = page.locator('button[type="submit"]');
    await submit.click();

    // Page should NOT navigate (form blocked by required validation)
    await expect(page).toHaveURL(/\/auth\/login/);
  });
});

test.describe("Signup form validation UX", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/auth/signup");
  });

  test("has properly labeled email and password fields", async ({ page }) => {
    const emailLabel = page.locator('label[for="email"]');
    const passwordLabel = page.locator('label[for="password"]');

    await expect(emailLabel).toBeVisible();
    await expect(passwordLabel).toBeVisible();
  });

  test("email and password fields are required", async ({ page }) => {
    await expect(page.locator("#email")).toHaveAttribute("required", "");
    await expect(page.locator("#password")).toHaveAttribute("required", "");
  });

  test("password has minLength constraint", async ({ page }) => {
    const passwordInput = page.locator("#password");
    await expect(passwordInput).toHaveAttribute("minlength", "6");
  });

  test("password shows placeholder with length hint", async ({ page }) => {
    const passwordInput = page.locator("#password");
    const placeholder = await passwordInput.getAttribute("placeholder");
    expect(placeholder).toBeTruthy();
    // Placeholder hints at minimum length requirement
    expect(placeholder?.toLowerCase()).toContain("6");
  });

  test("empty form submission is blocked by native validation", async ({
    page,
  }) => {
    const submit = page.locator('button[type="submit"]');
    await submit.click();

    // Page should NOT navigate
    await expect(page).toHaveURL(/\/auth\/signup/);
  });

  test("form has accessible structure with heading", async ({ page }) => {
    const heading = page.locator("h1");
    await expect(heading).toBeVisible();
    const text = await heading.textContent();
    expect(text?.length).toBeGreaterThan(0);
  });
});
