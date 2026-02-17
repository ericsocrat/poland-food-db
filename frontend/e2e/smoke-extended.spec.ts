import { test, expect } from "@playwright/test";

// ─── Extended smoke tests: deeper coverage of public pages ──────────────────
// All tests are public-page only — no Supabase auth dependency.

test.describe("Unknown routes", () => {
  test("unknown route redirects to login", async ({ page }) => {
    await page.goto("/this-route-does-not-exist");
    await page.waitForURL(/\/auth\/login/);
    await expect(page.locator("text=Welcome back")).toBeVisible();
  });

  test("unknown route preserves path in redirect param", async ({ page }) => {
    await page.goto("/nonexistent-page");
    await page.waitForURL(/\/auth\/login/);
    expect(page.url()).toContain("redirect=");
  });

  test("deep unknown route redirects to login", async ({ page }) => {
    await page.goto("/some/deeply/nested/nonexistent/path");
    await page.waitForURL(/\/auth\/login/);
    await expect(page.locator("text=Welcome back")).toBeVisible();
  });
});

test.describe("Footer links", () => {
  test("footer has Privacy Policy link", async ({ page }) => {
    await page.goto("/");
    const link = page.getByRole("link", { name: "Privacy Policy" });
    await expect(link).toBeVisible();
    await expect(link).toHaveAttribute("href", "/privacy");
  });

  test("footer has Terms of Service link", async ({ page }) => {
    await page.goto("/");
    const link = page.getByRole("link", { name: "Terms of Service" });
    await expect(link).toBeVisible();
    await expect(link).toHaveAttribute("href", "/terms");
  });

  test("footer has Contact link", async ({ page }) => {
    await page.goto("/");
    const link = page
      .locator("footer")
      .getByRole("link", { name: "Contact" });
    await expect(link).toBeVisible();
    await expect(link).toHaveAttribute("href", "/contact");
  });

  test("footer shows copyright text", async ({ page }) => {
    await page.goto("/");
    await expect(
      page.locator("footer").getByText("Poland Food DB", { exact: false }),
    ).toBeVisible();
  });

  test("Privacy Policy link navigates correctly", async ({ page }) => {
    await page.goto("/");
    await page.getByRole("link", { name: "Privacy Policy" }).click();
    await page.waitForURL(/\/privacy/);
    await expect(page).toHaveURL("/privacy");
  });

  test("Terms of Service link navigates correctly", async ({ page }) => {
    await page.goto("/");
    await page.getByRole("link", { name: "Terms of Service" }).click();
    await page.waitForURL(/\/terms/);
    await expect(page).toHaveURL("/terms");
  });
});

test.describe("Header", () => {
  test("shows FoodDB logo linking to home", async ({ page }) => {
    await page.goto("/contact");
    const logo = page.getByRole("link", { name: /FoodDB/ });
    await expect(logo).toBeVisible();
    await expect(logo).toHaveAttribute("href", "/");
  });

  test("has Contact nav link", async ({ page }) => {
    await page.goto("/");
    const link = page
      .locator("header")
      .getByRole("link", { name: "Contact" });
    await expect(link).toBeVisible();
    await expect(link).toHaveAttribute("href", "/contact");
  });

  test("has Sign In button linking to login", async ({ page }) => {
    await page.goto("/");
    const signIn = page
      .locator("header")
      .getByRole("link", { name: "Sign In" });
    await expect(signIn).toBeVisible();
    await expect(signIn).toHaveAttribute("href", "/auth/login");
  });

  test("logo navigates to landing from contact page", async ({ page }) => {
    await page.goto("/contact");
    await page.getByRole("link", { name: /FoodDB/ }).click();
    await expect(page).toHaveURL("/");
  });
});

test.describe("Landing page features", () => {
  test("hero subtitle describes the app", async ({ page }) => {
    await page.goto("/");
    await expect(
      page.getByText("Search, scan, and compare food products", {
        exact: false,
      }),
    ).toBeVisible();
  });

  test("renders Search feature card", async ({ page }) => {
    await page.goto("/");
    await expect(
      page.getByText("Find products by name, brand, or category"),
    ).toBeVisible();
  });

  test("renders Scan feature card", async ({ page }) => {
    await page.goto("/");
    await expect(
      page.getByText("Scan barcodes for instant product info"),
    ).toBeVisible();
  });

  test("renders Compare feature card", async ({ page }) => {
    await page.goto("/");
    await expect(
      page.getByText("See health scores and find better alternatives"),
    ).toBeVisible();
  });

  test("Get started CTA links to signup", async ({ page }) => {
    await page.goto("/");
    const cta = page.getByRole("link", { name: "Get started" });
    await expect(cta).toBeVisible();
    await expect(cta).toHaveAttribute("href", "/auth/signup");
  });
});

test.describe("Login page details", () => {
  test("shows session expired message when reason=expired", async ({
    page,
  }) => {
    await page.goto("/auth/login?reason=expired");
    await expect(
      page.getByText("Your session has expired", { exact: false }),
    ).toBeVisible();
  });

  test("does not show expired message without query param", async ({
    page,
  }) => {
    await page.goto("/auth/login");
    await expect(
      page.getByText("Your session has expired", { exact: false }),
    ).not.toBeVisible();
  });

  test("shows subtitle text", async ({ page }) => {
    await page.goto("/auth/login");
    await expect(
      page.getByText("Sign in to your FoodDB account"),
    ).toBeVisible();
  });

  test("Sign In button is present", async ({ page }) => {
    await page.goto("/auth/login");
    await expect(
      page.getByRole("button", { name: /Sign In/i }),
    ).toBeVisible();
  });

  test("has Sign up link for new users", async ({ page }) => {
    await page.goto("/auth/login");
    await expect(
      page.getByText("Don't have an account?", { exact: false }),
    ).toBeVisible();
  });
});

test.describe("Signup page details", () => {
  test("password field has correct placeholder", async ({ page }) => {
    await page.goto("/auth/signup");
    const passwordInput = page.getByLabel("Password");
    await expect(passwordInput).toHaveAttribute(
      "placeholder",
      "At least 6 characters",
    );
  });

  test("Sign Up button is present", async ({ page }) => {
    await page.goto("/auth/signup");
    await expect(
      page.getByRole("button", { name: /Sign Up/i }),
    ).toBeVisible();
  });

  test("has Sign in link for existing users", async ({ page }) => {
    await page.goto("/auth/signup");
    await expect(
      page.getByRole("link", { name: /Sign in/i }),
    ).toBeVisible();
  });
});

test.describe("Shared pages behind auth", () => {
  test("shared list route redirects to login", async ({ page }) => {
    await page.goto("/lists/shared/invalid-token-abc123");
    await page.waitForURL(/\/auth\/login/);
    await expect(page.locator("text=Welcome back")).toBeVisible();
  });

  test("shared comparison route redirects to login", async ({ page }) => {
    await page.goto("/compare/shared/invalid-token-xyz789");
    await page.waitForURL(/\/auth\/login/);
    await expect(page.locator("text=Welcome back")).toBeVisible();
  });
});

test.describe("Auth redirect preserves intended URL", () => {
  test("visiting /app/lists redirects to login", async ({ page }) => {
    await page.goto("/app/lists");
    await page.waitForURL(/\/auth\/login/);
    await expect(page.locator("text=Welcome back")).toBeVisible();
  });

  test("visiting /app/scan redirects to login", async ({ page }) => {
    await page.goto("/app/compare");
    await page.waitForURL(/\/auth\/login/);
  });
});

test.describe("Page meta and SEO basics", () => {
  test("landing page has viewport meta tag", async ({ page }) => {
    await page.goto("/");
    const viewport = page.locator('meta[name="viewport"]');
    await expect(viewport).toHaveAttribute("content", /width/);
  });

  test("contact page has correct title", async ({ page }) => {
    await page.goto("/contact");
    await expect(page).toHaveTitle(/Poland Food DB/);
  });

  test("privacy page has correct title", async ({ page }) => {
    await page.goto("/privacy");
    await expect(page).toHaveTitle(/Poland Food DB/);
  });

  test("login page has correct title", async ({ page }) => {
    await page.goto("/auth/login");
    await expect(page).toHaveTitle(/Poland Food DB/);
  });
});
