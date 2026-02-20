import { test, expect } from "@playwright/test";

// ─── Image Policy Compliance E2E Tests (#56) ────────────────────────────────
// Verifies CSP headers, privacy page content, and image upload prevention.

test.describe("Image Policy — CSP Headers", () => {
  test("CSP header is present and contains restrictive connect-src", async ({
    page,
  }) => {
    const response = await page.goto("/");
    const csp = response?.headers()["content-security-policy"] ?? "";

    // connect-src must be present and must NOT allow wildcard
    expect(csp).toContain("connect-src");
    expect(csp).not.toMatch(/connect-src\s+\*/);
  });

  test("CSP restricts form-action to self", async ({ page }) => {
    const response = await page.goto("/");
    const csp = response?.headers()["content-security-policy"] ?? "";

    expect(csp).toContain("form-action 'self'");
  });

  test("CSP includes img-src with openfoodfacts", async ({ page }) => {
    const response = await page.goto("/");
    const csp = response?.headers()["content-security-policy"] ?? "";

    expect(csp).toContain("img-src");
    expect(csp).toContain("images.openfoodfacts.org");
  });

  test("CSP includes worker-src for Tesseract WASM", async ({ page }) => {
    const response = await page.goto("/");
    const csp = response?.headers()["content-security-policy"] ?? "";

    expect(csp).toContain("worker-src");
    expect(csp).toContain("blob:");
  });
});

test.describe("Image Policy — Privacy Page", () => {
  test("privacy page has image processing section", async ({ page }) => {
    await page.goto("/privacy");

    // Check for the Image Processing heading
    await expect(
      page.getByRole("heading", { name: /Image Processing/i }),
    ).toBeVisible();
  });

  test("privacy page describes client-only processing", async ({ page }) => {
    await page.goto("/privacy");

    // Check key policy statements are visible
    await expect(
      page.getByText(/entirely on your device/i),
    ).toBeVisible();
    await expect(
      page.getByText(/NEVER uploaded to our servers/i),
    ).toBeVisible();
  });

  test("privacy page mentions GDPR legal basis", async ({ page }) => {
    await page.goto("/privacy");

    await expect(page.getByText(/GDPR Article 6/i)).toBeVisible();
  });
});
