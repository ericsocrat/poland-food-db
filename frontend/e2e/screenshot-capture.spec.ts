// ─── Screenshot Capture Suite ───────────────────────────────────────────────
// Captures polished screenshots of all major app sections for documentation,
// README, and marketing materials.
//
// Issues: #404 (Epic), #430 (Desktop), #431 (Mobile + Dark Mode), #794 (Expansion)
//
// Self-contained auth: creates a test user and signs in via the UI, bypassing
// CSP restrictions (local Supabase URLs blocked by production CSP headers).
// Does NOT depend on auth-setup — the screenshots project sets bypassCSP: true.
//
// Usage:
//   # Ensure dev server running against LOCAL Supabase
//   CAPTURE_SCREENSHOTS=true npx playwright test --project=screenshots
//
// Output: docs/screenshots/{desktop,mobile,dark-mode}/
//
// Total: 16 desktop + 16 mobile + 16 dark desktop + 16 dark mobile = 64 screenshots

import { test, type Page } from "@playwright/test";
import fs from "node:fs";
import path from "node:path";

/* ── Constants ───────────────────────────────────────────────────────────── */

const SCREENSHOT_ROOT = path.resolve(__dirname, "../../docs/screenshots");

const DESKTOP_DIR = path.join(SCREENSHOT_ROOT, "desktop");
const MOBILE_DIR = path.join(SCREENSHOT_ROOT, "mobile");
const DARK_MODE_DIR = path.join(SCREENSHOT_ROOT, "dark-mode");
const DARK_MOBILE_DIR = path.join(SCREENSHOT_ROOT, "dark-mode-mobile");

const DESKTOP_VIEWPORT = { width: 1440, height: 900 };
const MOBILE_VIEWPORT = { width: 390, height: 844 };

const TEST_EMAIL = "screenshots@test.tryvit.local";
const TEST_PASSWORD = "ScreenshotTest123!";

/* ── Helper functions ────────────────────────────────────────────────────── */

function ensureDir(dir: string) {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

/**
 * Wait for the page to be fully loaded and visually stable.
 * Disables animations and waits for network idle.
 */
async function stabilizePage(page: Page) {
  await page.waitForLoadState("networkidle");
  // Disable all CSS animations/transitions for clean screenshots
  await page.addStyleTag({
    content: `
      *, *::before, *::after {
        animation-duration: 0s !important;
        animation-delay: 0s !important;
        transition-duration: 0s !important;
        transition-delay: 0s !important;
      }
    `,
  });
  // Pause for layout stabilization (data-driven pages need time to hydrate)
  await page.waitForTimeout(2000);
}

/**
 * Take a screenshot and save to the specified directory.
 */
async function captureScreenshot(
  page: Page,
  dir: string,
  filename: string,
  options: { fullPage?: boolean } = {},
) {
  ensureDir(dir);
  const filepath = path.join(dir, filename);
  await page.screenshot({
    path: filepath,
    fullPage: options.fullPage ?? false,
    animations: "disabled",
  });
  // eslint-disable-next-line no-console
  console.log(`  ✅ Captured: ${filepath}`);
}

/**
 * Attempt to wait for a test-id selector, but don't fail the test
 * if it doesn't appear — capture whatever state is visible.
 */
async function waitForOptional(page: Page, selector: string, timeout = 10_000) {
  try {
    await page.waitForSelector(selector, { timeout });
  } catch {
    // Selector didn't appear — proceed with screenshot of current state
    // eslint-disable-next-line no-console
    console.log(`  ⚠️ Selector not found (proceeding): ${selector}`);
  }
}

// Serialize all tests — screenshot capture is a utility, not a CI test.
// Serial mode avoids race conditions on shared test user.
test.describe.configure({ mode: "serial" });

// Increase overall test timeout for screenshot stabilization + SSR warmup.
test.setTimeout(60_000);

/* ── Auth: Self-contained user provisioning ──────────────────────────────── */

let testUserId: string | null = null;

function getSupabaseConfig() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!url || !key) {
    throw new Error(
      "Missing NEXT_PUBLIC_SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY",
    );
  }
  return { url, key };
}

/**
 * Ensure a test user exists. Idempotent — reuses existing user if present.
 */
async function provisionTestUser(): Promise<string> {
  if (testUserId) return testUserId;

  const { url, key } = getSupabaseConfig();
  const headers = {
    apikey: key,
    Authorization: `Bearer ${key}`,
    "Content-Type": "application/json",
  };

  // Check if user already exists
  const listRes = await fetch(`${url}/auth/v1/admin/users`, { headers });
  const listData = await listRes.json();
  const existing = listData.users?.find(
    (u: { email: string }) => u.email === TEST_EMAIL,
  );
  if (existing) {
    testUserId = existing.id;
    return testUserId;
  }

  // Create fresh user
  const createRes = await fetch(`${url}/auth/v1/admin/users`, {
    method: "POST",
    headers,
    body: JSON.stringify({
      email: TEST_EMAIL,
      password: TEST_PASSWORD,
      email_confirm: true,
    }),
  });

  // Handle race condition: another worker may have created the user
  if (createRes.status === 422) {
    const retryList = await fetch(`${url}/auth/v1/admin/users`, { headers });
    const retryData = await retryList.json();
    const found = retryData.users?.find(
      (u: { email: string }) => u.email === TEST_EMAIL,
    );
    if (found) {
      testUserId = found.id;
      return testUserId;
    }
  }

  if (!createRes.ok) {
    const err = await createRes.text();
    throw new Error(`Failed to create test user: ${createRes.status} ${err}`);
  }

  const userData = await createRes.json();
  testUserId = userData.id;

  // Pre-create preferences (skip onboarding, force English)
  await fetch(`${url}/rest/v1/user_preferences`, {
    method: "POST",
    headers: { ...headers, Prefer: "resolution=merge-duplicates" },
    body: JSON.stringify({
      user_id: testUserId,
      country: "PL",
      preferred_language: "en",
      onboarding_completed: false,
      onboarding_skipped: true,
    }),
  });

  return testUserId!;
}

/**
 * Sign in via the browser UI. Requires bypassCSP: true in the project config
 * for local Supabase URLs (blocked by production CSP connect-src).
 */
async function signInViaUI(page: Page) {
  await page.goto("/auth/login");
  await page.waitForLoadState("networkidle");
  await page.getByLabel("Email").fill(TEST_EMAIL);
  await page.getByLabel("Password", { exact: true }).fill(TEST_PASSWORD);
  await page.getByRole("button", { name: "Sign In" }).click();

  // Wait for navigation to authenticated area (longer timeout for SSR warmup)
  await page.waitForURL(/\/(app\/search|onboarding)/, { timeout: 30_000 });

  // Handle onboarding if needed
  if (page.url().includes("/onboarding")) {
    const skipBtn = page.getByTestId("onboarding-skip-all");
    if (await skipBtn.isVisible().catch(() => false)) {
      await skipBtn.click();
      await page.waitForURL(/\/app\/search/, { timeout: 10_000 });
    }
  }
}

/**
 * Clean up test user (best-effort).
 */
async function cleanupTestUser() {
  try {
    const { url, key } = getSupabaseConfig();
    const headers = {
      apikey: key,
      Authorization: `Bearer ${key}`,
    };

    const listRes = await fetch(`${url}/auth/v1/admin/users`, { headers });
    const listData = await listRes.json();
    const user = listData.users?.find(
      (u: { email: string }) => u.email === TEST_EMAIL,
    );
    if (user) {
      await fetch(`${url}/auth/v1/admin/users/${user.id}`, {
        method: "DELETE",
        headers,
      });
    }
  } catch {
    // Best-effort cleanup — don't fail tests
  }
}

/* ════════════════════════════════════════════════════════════════════════════
   §1  DESKTOP SCREENSHOTS (16) — Issue #430, #794
   ════════════════════════════════════════════════════════════════════════ */

test.describe("Desktop screenshots (1440×900)", () => {
  test.beforeEach(async ({ page }) => {
    await provisionTestUser();
    await page.setViewportSize(DESKTOP_VIEWPORT);
    await page.emulateMedia({
      colorScheme: "light",
      reducedMotion: "reduce",
    });
    await signInViaUI(page);
  });

  test("01 — Dashboard / Home", async ({ page }) => {
    await page.goto("/app");
    await waitForOptional(page, '[data-testid="dashboard"]');
    await stabilizePage(page);
    await captureScreenshot(page, DESKTOP_DIR, "01-dashboard.png");
  });

  test("02 — Category Grid", async ({ page }) => {
    await page.goto("/app/categories");
    await waitForOptional(page, '[data-testid="category-grid"]');
    await stabilizePage(page);
    await captureScreenshot(page, DESKTOP_DIR, "02-category-listing.png");
  });

  test("03 — Category Detail", async ({ page }) => {
    await page.goto("/app/categories/dairy");
    await waitForOptional(page, '[data-testid="product-list"]');
    await stabilizePage(page);
    await captureScreenshot(page, DESKTOP_DIR, "03-category-detail.png");
  });

  test("04 — Product Detail", async ({ page }) => {
    await page.goto("/app/product/628");
    await waitForOptional(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await captureScreenshot(page, DESKTOP_DIR, "04-product-detail.png");
  });

  test("05 — Score Explanation", async ({ page }) => {
    await page.goto("/app/product/626");
    await waitForOptional(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);

    // Try to open score explanation panel if available
    const scoreTab = page.locator(
      '[data-testid="tab-score"], [role="tab"]:has-text("Score")',
    );
    if (await scoreTab.isVisible().catch(() => false)) {
      await scoreTab.click();
      await page.waitForTimeout(500);
    }

    await captureScreenshot(page, DESKTOP_DIR, "05-score-explanation.png");
  });

  // ── Product Tabs — E. Wedel Czekolada Tiramisu (44 ingredients, richly detailed) ──

  test("05a — Product Tabs — Overview (E. Wedel)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitForOptional(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitForOptional(page, '[data-testid="tab-bar"]');
    await page.waitForTimeout(500);
    await captureScreenshot(page, DESKTOP_DIR, "05a-product-overview-wedel.png");
  });

  test("05b — Product Tabs — Nutrition (E. Wedel)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitForOptional(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitForOptional(page, '[data-testid="tab-bar"]');
    await page.locator("#tab-nutrition").click();
    await page.waitForTimeout(1500);
    await captureScreenshot(page, DESKTOP_DIR, "05b-product-nutrition-wedel.png");
  });

  test("05c — Product Tabs — Alternatives (E. Wedel)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitForOptional(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitForOptional(page, '[data-testid="tab-bar"]');
    await page.locator("#tab-alternatives").click();
    await page.waitForTimeout(1500);
    await captureScreenshot(page, DESKTOP_DIR, "05c-product-alternatives-wedel.png");
  });

  test("05d — Product Tabs — Scoring (E. Wedel)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitForOptional(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitForOptional(page, '[data-testid="tab-bar"]');
    await page.locator("#tab-scoring").click();
    await page.waitForTimeout(1500);
    await captureScreenshot(page, DESKTOP_DIR, "05d-product-scoring-wedel.png");
  });

  test("06 — Search Results", async ({ page }) => {
    await page.goto("/app/search?q=jogurt");
    await waitForOptional(page, '[data-testid="search-results"]');
    await stabilizePage(page);
    await captureScreenshot(page, DESKTOP_DIR, "06-search-results.png");
  });

  test("07 — Comparison Grid", async ({ page }) => {
    await page.goto("/app/compare");
    await waitForOptional(page, '[data-testid="comparison-grid"]');
    await stabilizePage(page);
    await captureScreenshot(page, DESKTOP_DIR, "07-comparison-grid.png");
  });

  test("08 — Scan History", async ({ page }) => {
    await page.goto("/app/scan");
    await waitForOptional(page, '[data-testid="scan-page"]');
    await stabilizePage(page);
    await captureScreenshot(page, DESKTOP_DIR, "08-scan-history.png");
  });

  test("09 — Product Lists", async ({ page }) => {
    await page.goto("/app/lists");
    await waitForOptional(page, '[data-testid="lists-page"]');
    await stabilizePage(page);
    await captureScreenshot(page, DESKTOP_DIR, "09-product-lists.png");
  });

  test("10 — Settings & Health Profile", async ({ page }) => {
    await page.goto("/app/settings");
    await waitForOptional(page, '[data-testid="settings-page"]');
    await stabilizePage(page);
    await captureScreenshot(page, DESKTOP_DIR, "10-settings-health.png");
  });

  test("11 — Onboarding (Country Selection)", async ({ page }) => {
    await page.goto("/onboarding");
    await page.waitForTimeout(2000);
    await stabilizePage(page);
    await captureScreenshot(page, DESKTOP_DIR, "11-onboarding-country.png");
  });

  test("12 — Admin Submissions", async ({ page }) => {
    await page.goto("/app/admin");
    await waitForOptional(page, '[data-testid="admin-panel"]');
    await stabilizePage(page);
    await captureScreenshot(page, DESKTOP_DIR, "12-admin-submissions.png");
  });
});

/* ════════════════════════════════════════════════════════════════════════════
   §2  MOBILE SCREENSHOTS (16) — Issue #431, #794
   ════════════════════════════════════════════════════════════════════════ */

test.describe("Mobile screenshots (390×844)", () => {
  test.beforeEach(async ({ page }) => {
    await provisionTestUser();
    await page.setViewportSize(MOBILE_VIEWPORT);
    await page.emulateMedia({
      colorScheme: "light",
      reducedMotion: "reduce",
    });
    await signInViaUI(page);
  });

  test("01 — Dashboard (mobile)", async ({ page }) => {
    await page.goto("/app");
    await waitForOptional(page, '[data-testid="dashboard"]');
    await stabilizePage(page);
    await captureScreenshot(page, MOBILE_DIR, "01-dashboard-mobile.png");
  });

  test("02 — Category Grid (mobile)", async ({ page }) => {
    await page.goto("/app/categories");
    await waitForOptional(page, '[data-testid="category-grid"]');
    await stabilizePage(page);
    await captureScreenshot(page, MOBILE_DIR, "02-category-grid-mobile.png");
  });

  test("03 — Category Detail (mobile)", async ({ page }) => {
    await page.goto("/app/categories/dairy");
    await waitForOptional(page, '[data-testid="product-list"]');
    await stabilizePage(page);
    await captureScreenshot(page, MOBILE_DIR, "03-category-detail-mobile.png");
  });

  test("04 — Product Detail (mobile)", async ({ page }) => {
    await page.goto("/app/product/628");
    await waitForOptional(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await captureScreenshot(page, MOBILE_DIR, "04-product-detail-mobile.png");
  });

  test("05 — Score Explanation (mobile)", async ({ page }) => {
    await page.goto("/app/product/626");
    await waitForOptional(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    const scoreTab = page.locator(
      '[data-testid="tab-score"], [role="tab"]:has-text("Score")',
    );
    if (await scoreTab.isVisible().catch(() => false)) {
      await scoreTab.click();
      await page.waitForTimeout(500);
    }
    await captureScreenshot(page, MOBILE_DIR, "05-score-explanation-mobile.png");
  });

  // ── Product Tabs — E. Wedel (mobile) ──

  test("05a — Product Tabs — Overview (E. Wedel mobile)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitForOptional(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitForOptional(page, '[data-testid="tab-bar"]');
    await page.waitForTimeout(500);
    await captureScreenshot(page, MOBILE_DIR, "05a-product-overview-wedel-mobile.png");
  });

  test("05b — Product Tabs — Nutrition (E. Wedel mobile)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitForOptional(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitForOptional(page, '[data-testid="tab-bar"]');
    await page.locator("#tab-nutrition").click();
    await page.waitForTimeout(1500);
    await captureScreenshot(page, MOBILE_DIR, "05b-product-nutrition-wedel-mobile.png");
  });

  test("05c — Product Tabs — Alternatives (E. Wedel mobile)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitForOptional(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitForOptional(page, '[data-testid="tab-bar"]');
    await page.locator("#tab-alternatives").click();
    await page.waitForTimeout(1500);
    await captureScreenshot(page, MOBILE_DIR, "05c-product-alternatives-wedel-mobile.png");
  });

  test("05d — Product Tabs — Scoring (E. Wedel mobile)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitForOptional(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitForOptional(page, '[data-testid="tab-bar"]');
    await page.locator("#tab-scoring").click();
    await page.waitForTimeout(1500);
    await captureScreenshot(page, MOBILE_DIR, "05d-product-scoring-wedel-mobile.png");
  });

  test("06 — Search Results (mobile)", async ({ page }) => {
    await page.goto("/app/search?q=jogurt");
    await waitForOptional(page, '[data-testid="search-results"]');
    await stabilizePage(page);
    await captureScreenshot(page, MOBILE_DIR, "06-search-results-mobile.png");
  });

  test("07 — Comparison Grid (mobile)", async ({ page }) => {
    await page.goto("/app/compare");
    await waitForOptional(page, '[data-testid="comparison-grid"]');
    await stabilizePage(page);
    await captureScreenshot(page, MOBILE_DIR, "07-comparison-grid-mobile.png");
  });

  test("08 — Scan History (mobile)", async ({ page }) => {
    await page.goto("/app/scan");
    await waitForOptional(page, '[data-testid="scan-page"]');
    await stabilizePage(page);
    await captureScreenshot(page, MOBILE_DIR, "08-scan-history-mobile.png");
  });

  test("09 — Product Lists (mobile)", async ({ page }) => {
    await page.goto("/app/lists");
    await waitForOptional(page, '[data-testid="lists-page"]');
    await stabilizePage(page);
    await captureScreenshot(page, MOBILE_DIR, "09-product-lists-mobile.png");
  });

  test("10 — Settings & Health Profile (mobile)", async ({ page }) => {
    await page.goto("/app/settings");
    await waitForOptional(page, '[data-testid="settings-page"]');
    await stabilizePage(page);
    await captureScreenshot(page, MOBILE_DIR, "10-settings-health-mobile.png");
  });

  test("11 — Onboarding (mobile)", async ({ page }) => {
    await page.goto("/onboarding");
    await page.waitForTimeout(2000);
    await stabilizePage(page);
    await captureScreenshot(page, MOBILE_DIR, "11-onboarding-mobile.png");
  });

  test("12 — Admin Submissions (mobile)", async ({ page }) => {
    await page.goto("/app/admin");
    await waitForOptional(page, '[data-testid="admin-panel"]');
    await stabilizePage(page);
    await captureScreenshot(page, MOBILE_DIR, "12-admin-submissions-mobile.png");
  });
});

/* ════════════════════════════════════════════════════════════════════════════
   §3  DARK MODE DESKTOP SCREENSHOTS (16) — Issue #431, #794
   ════════════════════════════════════════════════════════════════════════ */

test.describe("Dark mode screenshots (1440×900)", () => {
  test.beforeEach(async ({ page }) => {
    await provisionTestUser();
    await page.setViewportSize(DESKTOP_VIEWPORT);
    await page.emulateMedia({
      colorScheme: "dark",
      reducedMotion: "reduce",
    });
    await signInViaUI(page);
  });

  test("01 — Dashboard (dark)", async ({ page }) => {
    await page.goto("/app");
    await waitForOptional(page, '[data-testid="dashboard"]');
    await stabilizePage(page);
    await captureScreenshot(page, DARK_MODE_DIR, "01-dashboard-dark.png");
  });

  test("02 — Category Grid (dark)", async ({ page }) => {
    await page.goto("/app/categories");
    await waitForOptional(page, '[data-testid="category-grid"]');
    await stabilizePage(page);
    await captureScreenshot(page, DARK_MODE_DIR, "02-category-grid-dark.png");
  });

  test("03 — Category Detail (dark)", async ({ page }) => {
    await page.goto("/app/categories/dairy");
    await waitForOptional(page, '[data-testid="product-list"]');
    await stabilizePage(page);
    await captureScreenshot(page, DARK_MODE_DIR, "03-category-detail-dark.png");
  });

  test("04 — Product Detail (dark)", async ({ page }) => {
    await page.goto("/app/product/628");
    await waitForOptional(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await captureScreenshot(page, DARK_MODE_DIR, "04-product-detail-dark.png");
  });

  test("05 — Score Explanation (dark)", async ({ page }) => {
    await page.goto("/app/product/626");
    await waitForOptional(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    const scoreTab = page.locator(
      '[data-testid="tab-score"], [role="tab"]:has-text("Score")',
    );
    if (await scoreTab.isVisible().catch(() => false)) {
      await scoreTab.click();
      await page.waitForTimeout(500);
    }
    await captureScreenshot(page, DARK_MODE_DIR, "05-score-explanation-dark.png");
  });

  // ── Product Tabs — E. Wedel (dark) ──

  test("05a — Product Tabs — Overview (E. Wedel dark)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitForOptional(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitForOptional(page, '[data-testid="tab-bar"]');
    await page.waitForTimeout(500);
    await captureScreenshot(page, DARK_MODE_DIR, "05a-product-overview-wedel-dark.png");
  });

  test("05b — Product Tabs — Nutrition (E. Wedel dark)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitForOptional(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitForOptional(page, '[data-testid="tab-bar"]');
    await page.locator("#tab-nutrition").click();
    await page.waitForTimeout(1500);
    await captureScreenshot(page, DARK_MODE_DIR, "05b-product-nutrition-wedel-dark.png");
  });

  test("05c — Product Tabs — Alternatives (E. Wedel dark)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitForOptional(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitForOptional(page, '[data-testid="tab-bar"]');
    await page.locator("#tab-alternatives").click();
    await page.waitForTimeout(1500);
    await captureScreenshot(page, DARK_MODE_DIR, "05c-product-alternatives-wedel-dark.png");
  });

  test("05d — Product Tabs — Scoring (E. Wedel dark)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitForOptional(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitForOptional(page, '[data-testid="tab-bar"]');
    await page.locator("#tab-scoring").click();
    await page.waitForTimeout(1500);
    await captureScreenshot(page, DARK_MODE_DIR, "05d-product-scoring-wedel-dark.png");
  });

  test("06 — Search Results (dark)", async ({ page }) => {
    await page.goto("/app/search?q=jogurt");
    await waitForOptional(page, '[data-testid="search-results"]');
    await stabilizePage(page);
    await captureScreenshot(page, DARK_MODE_DIR, "06-search-results-dark.png");
  });

  test("07 — Comparison Grid (dark)", async ({ page }) => {
    await page.goto("/app/compare");
    await waitForOptional(page, '[data-testid="comparison-grid"]');
    await stabilizePage(page);
    await captureScreenshot(page, DARK_MODE_DIR, "07-comparison-dark.png");
  });

  test("08 — Scan History (dark)", async ({ page }) => {
    await page.goto("/app/scan");
    await waitForOptional(page, '[data-testid="scan-page"]');
    await stabilizePage(page);
    await captureScreenshot(page, DARK_MODE_DIR, "08-scan-history-dark.png");
  });

  test("09 — Product Lists (dark)", async ({ page }) => {
    await page.goto("/app/lists");
    await waitForOptional(page, '[data-testid="lists-page"]');
    await stabilizePage(page);
    await captureScreenshot(page, DARK_MODE_DIR, "09-product-lists-dark.png");
  });

  test("10 — Settings & Health Profile (dark)", async ({ page }) => {
    await page.goto("/app/settings");
    await waitForOptional(page, '[data-testid="settings-page"]');
    await stabilizePage(page);
    await captureScreenshot(page, DARK_MODE_DIR, "10-settings-health-dark.png");
  });

  test("11 — Onboarding (dark)", async ({ page }) => {
    await page.goto("/onboarding");
    await page.waitForTimeout(2000);
    await stabilizePage(page);
    await captureScreenshot(page, DARK_MODE_DIR, "11-onboarding-dark.png");
  });

  test("12 — Admin Submissions (dark)", async ({ page }) => {
    await page.goto("/app/admin");
    await waitForOptional(page, '[data-testid="admin-panel"]');
    await stabilizePage(page);
    await captureScreenshot(page, DARK_MODE_DIR, "12-admin-submissions-dark.png");
  });
});

/* ════════════════════════════════════════════════════════════════════════════
   §4  DARK MODE MOBILE SCREENSHOTS (16) — Issue #794
   ════════════════════════════════════════════════════════════════════════ */

test.describe("Dark mode mobile screenshots (390×844)", () => {
  test.beforeEach(async ({ page }) => {
    await provisionTestUser();
    await page.setViewportSize(MOBILE_VIEWPORT);
    await page.emulateMedia({
      colorScheme: "dark",
      reducedMotion: "reduce",
    });
    await signInViaUI(page);
  });

  test("01 — Dashboard (dark mobile)", async ({ page }) => {
    await page.goto("/app");
    await waitForOptional(page, '[data-testid="dashboard"]');
    await stabilizePage(page);
    await captureScreenshot(page, DARK_MOBILE_DIR, "01-dashboard-dark-mobile.png");
  });

  test("02 — Category Grid (dark mobile)", async ({ page }) => {
    await page.goto("/app/categories");
    await waitForOptional(page, '[data-testid="category-grid"]');
    await stabilizePage(page);
    await captureScreenshot(page, DARK_MOBILE_DIR, "02-category-grid-dark-mobile.png");
  });

  test("03 — Category Detail (dark mobile)", async ({ page }) => {
    await page.goto("/app/categories/dairy");
    await waitForOptional(page, '[data-testid="product-list"]');
    await stabilizePage(page);
    await captureScreenshot(page, DARK_MOBILE_DIR, "03-category-detail-dark-mobile.png");
  });

  test("04 — Product Detail (dark mobile)", async ({ page }) => {
    await page.goto("/app/product/628");
    await waitForOptional(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await captureScreenshot(page, DARK_MOBILE_DIR, "04-product-detail-dark-mobile.png");
  });

  test("05 — Score Explanation (dark mobile)", async ({ page }) => {
    await page.goto("/app/product/626");
    await waitForOptional(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    const scoreTab = page.locator(
      '[data-testid="tab-score"], [role="tab"]:has-text("Score")',
    );
    if (await scoreTab.isVisible().catch(() => false)) {
      await scoreTab.click();
      await page.waitForTimeout(500);
    }
    await captureScreenshot(page, DARK_MOBILE_DIR, "05-score-explanation-dark-mobile.png");
  });

  // ── Product Tabs — E. Wedel (dark mobile) ──

  test("05a — Product Tabs — Overview (E. Wedel dark mobile)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitForOptional(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitForOptional(page, '[data-testid="tab-bar"]');
    await page.waitForTimeout(500);
    await captureScreenshot(page, DARK_MOBILE_DIR, "05a-product-overview-wedel-dark-mobile.png");
  });

  test("05b — Product Tabs — Nutrition (E. Wedel dark mobile)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitForOptional(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitForOptional(page, '[data-testid="tab-bar"]');
    await page.locator("#tab-nutrition").click();
    await page.waitForTimeout(1500);
    await captureScreenshot(page, DARK_MOBILE_DIR, "05b-product-nutrition-wedel-dark-mobile.png");
  });

  test("05c — Product Tabs — Alternatives (E. Wedel dark mobile)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitForOptional(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitForOptional(page, '[data-testid="tab-bar"]');
    await page.locator("#tab-alternatives").click();
    await page.waitForTimeout(1500);
    await captureScreenshot(page, DARK_MOBILE_DIR, "05c-product-alternatives-wedel-dark-mobile.png");
  });

  test("05d — Product Tabs — Scoring (E. Wedel dark mobile)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitForOptional(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitForOptional(page, '[data-testid="tab-bar"]');
    await page.locator("#tab-scoring").click();
    await page.waitForTimeout(1500);
    await captureScreenshot(page, DARK_MOBILE_DIR, "05d-product-scoring-wedel-dark-mobile.png");
  });

  test("06 — Search Results (dark mobile)", async ({ page }) => {
    await page.goto("/app/search?q=jogurt");
    await waitForOptional(page, '[data-testid="search-results"]');
    await stabilizePage(page);
    await captureScreenshot(page, DARK_MOBILE_DIR, "06-search-results-dark-mobile.png");
  });

  test("07 — Comparison Grid (dark mobile)", async ({ page }) => {
    await page.goto("/app/compare");
    await waitForOptional(page, '[data-testid="comparison-grid"]');
    await stabilizePage(page);
    await captureScreenshot(page, DARK_MOBILE_DIR, "07-comparison-dark-mobile.png");
  });

  test("08 — Scan History (dark mobile)", async ({ page }) => {
    await page.goto("/app/scan");
    await waitForOptional(page, '[data-testid="scan-page"]');
    await stabilizePage(page);
    await captureScreenshot(page, DARK_MOBILE_DIR, "08-scan-history-dark-mobile.png");
  });

  test("09 — Product Lists (dark mobile)", async ({ page }) => {
    await page.goto("/app/lists");
    await waitForOptional(page, '[data-testid="lists-page"]');
    await stabilizePage(page);
    await captureScreenshot(page, DARK_MOBILE_DIR, "09-product-lists-dark-mobile.png");
  });

  test("10 — Settings & Health Profile (dark mobile)", async ({ page }) => {
    await page.goto("/app/settings");
    await waitForOptional(page, '[data-testid="settings-page"]');
    await stabilizePage(page);
    await captureScreenshot(page, DARK_MOBILE_DIR, "10-settings-health-dark-mobile.png");
  });

  test("11 — Onboarding (dark mobile)", async ({ page }) => {
    await page.goto("/onboarding");
    await page.waitForTimeout(2000);
    await stabilizePage(page);
    await captureScreenshot(page, DARK_MOBILE_DIR, "11-onboarding-dark-mobile.png");
  });

  test("12 — Admin Submissions (dark mobile)", async ({ page }) => {
    await page.goto("/app/admin");
    await waitForOptional(page, '[data-testid="admin-panel"]');
    await stabilizePage(page);
    await captureScreenshot(page, DARK_MOBILE_DIR, "12-admin-submissions-dark-mobile.png");
  });
});
