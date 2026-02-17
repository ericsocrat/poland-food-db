import { test, expect } from "@playwright/test";

// ─── Responsive layout e2e tests ────────────────────────────────────────────
// Issue #59: Verify no horizontal overflow at key breakpoints.
// These are public-page-only tests (no auth required).

const VIEWPORTS = [
  { name: "320px (iPhone SE)", width: 320, height: 568 },
  { name: "375px (iPhone)", width: 375, height: 812 },
  { name: "768px (tablet)", width: 768, height: 1024 },
  { name: "1024px (laptop)", width: 1024, height: 768 },
  { name: "1440px (desktop)", width: 1440, height: 900 },
] as const;

const PUBLIC_PAGES = ["/", "/auth/login", "/auth/signup", "/contact"];

for (const viewport of VIEWPORTS) {
  test.describe(`No horizontal overflow at ${viewport.name}`, () => {
    test.use({ viewport: { width: viewport.width, height: viewport.height } });

    for (const path of PUBLIC_PAGES) {
      test(`${path} has no horizontal scroll`, async ({ page }) => {
        await page.goto(path, { waitUntil: "networkidle" });
        const scrollWidth = await page.evaluate(
          () => document.documentElement.scrollWidth,
        );
        const innerWidth = await page.evaluate(() => window.innerWidth);
        expect(scrollWidth).toBeLessThanOrEqual(innerWidth);
      });
    }
  });
}

test.describe("Landing page responsive behavior", () => {
  test("mobile layout at 375px", async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 812 });
    await page.goto("/");
    // Should still render hero and CTAs
    await expect(page.locator("text=healthier choices")).toBeVisible();
    await expect(page.locator('a[href="/auth/signup"]').first()).toBeVisible();
  });

  test("desktop layout at 1440px", async ({ page }) => {
    await page.setViewportSize({ width: 1440, height: 900 });
    await page.goto("/");
    await expect(page.locator("text=healthier choices")).toBeVisible();
  });
});

test.describe("Header responsive behavior", () => {
  test("header renders and has appropriate height on mobile", async ({
    page,
  }) => {
    await page.setViewportSize({ width: 375, height: 812 });
    await page.goto("/");
    const header = page.locator("header").first();
    await expect(header).toBeVisible();
    const box = await header.boundingBox();
    expect(box).not.toBeNull();
    // Header should be reasonably sized (not collapsed)
    expect(box!.height).toBeGreaterThanOrEqual(40);
    expect(box!.height).toBeLessThanOrEqual(80);
  });
});

test.describe("Footer responsive behavior", () => {
  test("footer renders at all viewports", async ({ page }) => {
    for (const viewport of VIEWPORTS) {
      await page.setViewportSize({
        width: viewport.width,
        height: viewport.height,
      });
      await page.goto("/");
      const footer = page.locator("footer").first();
      await expect(footer).toBeVisible();
    }
  });
});
