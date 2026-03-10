// ─── Visual Audit Suite ─────────────────────────────────────────────────────
// Comprehensive visual audit of ALL pages — captures desktop + mobile screenshots
// of every route for UX quality evaluation.
//
// Usage:
//   # Start dev server against LOCAL Supabase, then:
//   $env:CAPTURE_SCREENSHOTS="true"
//   $env:NEXT_PUBLIC_SUPABASE_URL="http://127.0.0.1:54321"
//   $env:SUPABASE_SERVICE_ROLE_KEY="<local-service-role-key>"
//   npx playwright test visual-audit --project=screenshots
//
// Output: docs/screenshots/audit/{desktop,mobile,dark-desktop,dark-mobile}/
// Issues: #431, #794 (Expansion)

import { test, type Page } from "@playwright/test";
import fs from "node:fs";
import path from "node:path";

/* ── Constants ───────────────────────────────────────────────────────────── */

const AUDIT_ROOT = path.resolve(__dirname, "../../docs/screenshots/audit");
const DESKTOP_DIR = path.join(AUDIT_ROOT, "desktop");
const MOBILE_DIR = path.join(AUDIT_ROOT, "mobile");
const DARK_DESKTOP_DIR = path.join(AUDIT_ROOT, "dark-desktop");
const DARK_MOBILE_DIR = path.join(AUDIT_ROOT, "dark-mobile");

const DESKTOP_VIEWPORT = { width: 1440, height: 900 };
const MOBILE_VIEWPORT = { width: 390, height: 844 };

const TEST_EMAIL = "visual-audit@test.tryvit.local";
const TEST_PASSWORD = "VisualAudit2026!";

/* ── Helpers ─────────────────────────────────────────────────────────────── */

function ensureDir(dir: string) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}

async function stabilizePage(page: Page) {
  await page.waitForLoadState("networkidle").catch(() => {});
  await page.addStyleTag({
    content: `*, *::before, *::after {
      animation-duration: 0s !important;
      animation-delay: 0s !important;
      transition-duration: 0s !important;
      transition-delay: 0s !important;
    }`,
  });
  await page.waitForTimeout(2000);
}

async function capture(
  page: Page,
  dir: string,
  filename: string,
  fullPage = true,
) {
  ensureDir(dir);
  const filepath = path.join(dir, filename);
  await page.screenshot({ path: filepath, fullPage, animations: "disabled" });
  // eslint-disable-next-line no-console
  console.log(`  📸 ${filepath}`);
}

async function waitFor(page: Page, selector: string, timeout = 15000) {
  try {
    await page.waitForSelector(selector, { timeout });
  } catch {
    // proceed with whatever state is visible
  }
}

/* ── Auth ────────────────────────────────────────────────────────────────── */

let testUserId: string | null = null;

function getSupabaseConfig() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!url || !key) {
    throw new Error(
      "Missing NEXT_PUBLIC_SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY.\n" +
        "Set these env vars to your LOCAL Supabase instance.",
    );
  }
  return { url, key };
}

async function provisionTestUser(): Promise<string> {
  if (testUserId) return testUserId;
  const { url, key } = getSupabaseConfig();
  const headers = {
    apikey: key,
    Authorization: `Bearer ${key}`,
    "Content-Type": "application/json",
  };

  // Check existing
  const listRes = await fetch(`${url}/auth/v1/admin/users`, { headers });
  const list = await listRes.json();
  const existing = list.users?.find(
    (u: { email: string }) => u.email === TEST_EMAIL,
  );
  if (existing) {
    testUserId = existing.id;
  } else {
    const createRes = await fetch(`${url}/auth/v1/admin/users`, {
      method: "POST",
      headers,
      body: JSON.stringify({
        email: TEST_EMAIL,
        password: TEST_PASSWORD,
        email_confirm: true,
      }),
    });
    if (createRes.status === 422) {
      const retryList = await fetch(`${url}/auth/v1/admin/users`, { headers });
      const retryData = await retryList.json();
      const found = retryData.users?.find(
        (u: { email: string }) => u.email === TEST_EMAIL,
      );
      if (found) testUserId = found.id;
    } else if (createRes.ok) {
      const userData = await createRes.json();
      testUserId = userData.id;
    } else {
      const err = await createRes.text();
      throw new Error(`Failed to create user: ${createRes.status} ${err}`);
    }
  }

  // Pre-create preferences (skip onboarding)
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

async function signInViaUI(page: Page) {
  await page.goto("/auth/login");
  await page.waitForLoadState("networkidle").catch(() => {});
  await page.getByLabel("Email").fill(TEST_EMAIL);
  await page.getByLabel("Password", { exact: true }).fill(TEST_PASSWORD);
  await page.getByRole("button", { name: "Sign In" }).click();
  await page.waitForURL(/\/(app|onboarding)/, { timeout: 30_000 });

  if (page.url().includes("/onboarding")) {
    const skipBtn = page.getByTestId("onboarding-skip-all");
    if (await skipBtn.isVisible().catch(() => false)) {
      await skipBtn.click();
      await page.waitForURL(/\/app/, { timeout: 10_000 });
    }
  }
}

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
    // best effort
  }
}

// Serial mode — shared auth state
test.describe.configure({ mode: "serial" });
test.setTimeout(90_000);

/* ════════════════════════════════════════════════════════════════════════════
   §1  PUBLIC PAGES — No auth required
   ════════════════════════════════════════════════════════════════════════ */

test.describe("PUBLIC pages — Desktop", () => {
  test.beforeEach(async ({ page }) => {
    await page.setViewportSize(DESKTOP_VIEWPORT);
    await page.emulateMedia({ colorScheme: "light", reducedMotion: "reduce" });
  });

  test("Landing page (/)", async ({ page }) => {
    await page.goto("/");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "P01-landing.png");
  });

  test("Login (/auth/login)", async ({ page }) => {
    await page.goto("/auth/login");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "P02-login.png");
  });

  test("Signup (/auth/signup)", async ({ page }) => {
    await page.goto("/auth/signup");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "P03-signup.png");
  });

  test("Contact (/contact)", async ({ page }) => {
    await page.goto("/contact");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "P04-contact.png");
  });

  test("Privacy (/privacy)", async ({ page }) => {
    await page.goto("/privacy");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "P05-privacy.png");
  });

  test("Terms (/terms)", async ({ page }) => {
    await page.goto("/terms");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "P06-terms.png");
  });

  test("Offline (/offline)", async ({ page }) => {
    await page.goto("/offline");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "P07-offline.png");
  });

  test("Learn Hub (/learn)", async ({ page }) => {
    await page.goto("/learn");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "P08-learn-hub.png");
  });

  test("Learn — TryVit Score", async ({ page }) => {
    await page.goto("/learn/tryvit-score");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "P09-learn-tryvit-score.png");
  });

  test("Learn — Nutri-Score", async ({ page }) => {
    await page.goto("/learn/nutri-score");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "P10-learn-nutriscore.png");
  });

  test("Learn — Confidence", async ({ page }) => {
    await page.goto("/learn/confidence");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "P11-learn-confidence.png");
  });

  test("Learn — Allergens", async ({ page }) => {
    await page.goto("/learn/allergens");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "P12-learn-allergens.png");
  });

  test("Learn — NOVA Groups", async ({ page }) => {
    await page.goto("/learn/nova-groups");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "P13-learn-nova.png");
  });

  test("Learn — Additives", async ({ page }) => {
    await page.goto("/learn/additives");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "P14-learn-additives.png");
  });

  test("Learn — Reading Labels", async ({ page }) => {
    await page.goto("/learn/reading-labels");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "P15-learn-reading-labels.png");
  });
});

test.describe("PUBLIC pages — Mobile", () => {
  test.beforeEach(async ({ page }) => {
    await page.setViewportSize(MOBILE_VIEWPORT);
    await page.emulateMedia({ colorScheme: "light", reducedMotion: "reduce" });
  });

  test("Landing page (mobile)", async ({ page }) => {
    await page.goto("/");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "P01-landing-mobile.png");
  });

  test("Login (mobile)", async ({ page }) => {
    await page.goto("/auth/login");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "P02-login-mobile.png");
  });

  test("Signup (mobile)", async ({ page }) => {
    await page.goto("/auth/signup");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "P03-signup-mobile.png");
  });

  test("Contact (mobile)", async ({ page }) => {
    await page.goto("/contact");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "P04-contact-mobile.png");
  });

  test("Privacy (mobile)", async ({ page }) => {
    await page.goto("/privacy");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "P05-privacy-mobile.png");
  });

  test("Terms (mobile)", async ({ page }) => {
    await page.goto("/terms");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "P06-terms-mobile.png");
  });

  test("Offline (mobile)", async ({ page }) => {
    await page.goto("/offline");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "P07-offline-mobile.png");
  });

  test("Learn Hub (mobile)", async ({ page }) => {
    await page.goto("/learn");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "P08-learn-hub-mobile.png");
  });

  test("Learn — TryVit Score (mobile)", async ({ page }) => {
    await page.goto("/learn/tryvit-score");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "P09-learn-tryvit-score-mobile.png");
  });

  test("Learn — Nutri-Score (mobile)", async ({ page }) => {
    await page.goto("/learn/nutri-score");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "P10-learn-nutriscore-mobile.png");
  });

  test("Learn — Confidence (mobile)", async ({ page }) => {
    await page.goto("/learn/confidence");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "P11-learn-confidence-mobile.png");
  });

  test("Learn — Allergens (mobile)", async ({ page }) => {
    await page.goto("/learn/allergens");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "P12-learn-allergens-mobile.png");
  });

  test("Learn — NOVA Groups (mobile)", async ({ page }) => {
    await page.goto("/learn/nova-groups");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "P13-learn-nova-mobile.png");
  });

  test("Learn — Additives (mobile)", async ({ page }) => {
    await page.goto("/learn/additives");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "P14-learn-additives-mobile.png");
  });

  test("Learn — Reading Labels (mobile)", async ({ page }) => {
    await page.goto("/learn/reading-labels");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "P15-learn-reading-labels-mobile.png");
  });
});

/* ════════════════════════════════════════════════════════════════════════════
   §2  AUTHENTICATED PAGES — Core app features
   ════════════════════════════════════════════════════════════════════════ */

test.describe("AUTHENTICATED pages — Desktop", () => {
  test.beforeEach(async ({ page }) => {
    await provisionTestUser();
    await page.setViewportSize(DESKTOP_VIEWPORT);
    await page.emulateMedia({ colorScheme: "light", reducedMotion: "reduce" });
    await signInViaUI(page);
  });

  // ── Dashboard & Navigation ──

  test("A01 — Home Dashboard (/app)", async ({ page }) => {
    await page.goto("/app");
    await waitFor(page, '[data-testid="dashboard"]');
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A01-dashboard.png");
  });

  test("A02 — Onboarding (/onboarding)", async ({ page }) => {
    await page.goto("/onboarding");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A02-onboarding.png");
  });

  // ── Categories ──

  test("A03 — Categories Grid (/app/categories)", async ({ page }) => {
    await page.goto("/app/categories");
    await waitFor(page, '[data-testid="category-grid"]');
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A03-categories.png");
  });

  test("A04 — Category Detail — Dairy", async ({ page }) => {
    await page.goto("/app/categories/dairy");
    await waitFor(page, '[data-testid="product-list"]');
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A04-category-dairy.png");
  });

  test("A05 — Category Detail — Chips", async ({ page }) => {
    await page.goto("/app/categories/chips");
    await waitFor(page, '[data-testid="product-list"]');
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A05-category-chips.png");
  });

  test("A06 — Category Detail — Drinks", async ({ page }) => {
    await page.goto("/app/categories/drinks");
    await waitFor(page, '[data-testid="product-list"]');
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A06-category-drinks.png");
  });

  // ── Product Detail ──

  test("A07 — Product Detail (Dairy product)", async ({ page }) => {
    await page.goto("/app/product/628");
    await waitFor(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A07-product-detail-dairy.png");
  });

  test("A08 — Product Detail (Chips product)", async ({ page }) => {
    await page.goto("/app/product/626");
    await waitFor(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A08-product-detail-chips.png");
  });

  // ── Product Tabs — E. Wedel Czekolada Tiramisu (44 ingredients, richly detailed) ──

  test("A08a — Product Tabs — Overview (E. Wedel)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitFor(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitFor(page, '[data-testid="tab-bar"]');
    await page.waitForTimeout(500);
    await capture(page, DESKTOP_DIR, "A08a-product-overview-wedel.png");
  });

  test("A08b — Product Tabs — Nutrition (E. Wedel)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitFor(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitFor(page, '[data-testid="tab-bar"]');
    await page.locator("#tab-nutrition").click();
    await page.waitForTimeout(1500);
    await capture(page, DESKTOP_DIR, "A08b-product-nutrition-wedel.png");
  });

  test("A08c — Product Tabs — Alternatives (E. Wedel)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitFor(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitFor(page, '[data-testid="tab-bar"]');
    await page.locator("#tab-alternatives").click();
    await page.waitForTimeout(1500);
    await capture(page, DESKTOP_DIR, "A08c-product-alternatives-wedel.png");
  });

  test("A08d — Product Tabs — Scoring (E. Wedel)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitFor(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitFor(page, '[data-testid="tab-bar"]');
    await page.locator("#tab-scoring").click();
    await page.waitForTimeout(1500);
    await capture(page, DESKTOP_DIR, "A08d-product-scoring-wedel.png");
  });

  // ── Search ──

  test("A09 — Search empty (/app/search)", async ({ page }) => {
    await page.goto("/app/search");
    await waitFor(page, '[data-testid="search-input"]');
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A09-search-empty.png");
  });

  test("A10 — Search with results", async ({ page }) => {
    await page.goto("/app/search?q=jogurt");
    await waitFor(page, '[data-testid="search-results"]');
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A10-search-results.png");
  });

  test("A11 — Saved Searches (/app/search/saved)", async ({ page }) => {
    await page.goto("/app/search/saved");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A11-saved-searches.png");
  });

  // ── Scan ──

  test("A12 — Barcode Scanner (/app/scan)", async ({ page }) => {
    await page.goto("/app/scan");
    await waitFor(page, '[data-testid="scan-page"]');
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A12-scan.png");
  });

  test("A13 — Scan History (/app/scan/history)", async ({ page }) => {
    await page.goto("/app/scan/history");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A13-scan-history.png");
  });

  test("A14 — Submit Product (/app/scan/submit)", async ({ page }) => {
    await page.goto("/app/scan/submit");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A14-scan-submit.png");
  });

  test("A15 — My Submissions (/app/scan/submissions)", async ({ page }) => {
    await page.goto("/app/scan/submissions");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A15-scan-submissions.png");
  });

  // ── Lists ──

  test("A16 — Product Lists (/app/lists)", async ({ page }) => {
    await page.goto("/app/lists");
    await waitFor(page, '[data-testid="lists-page"]');
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A16-lists.png");
  });

  // ── Compare ──

  test("A17 — Compare (/app/compare)", async ({ page }) => {
    await page.goto("/app/compare");
    await waitFor(page, '[data-testid="comparison-grid"]');
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A17-compare.png");
  });

  test("A18 — Saved Comparisons (/app/compare/saved)", async ({ page }) => {
    await page.goto("/app/compare/saved");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A18-compare-saved.png");
  });

  // ── Other Features ──

  test("A19 — Watchlist (/app/watchlist)", async ({ page }) => {
    await page.goto("/app/watchlist");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A19-watchlist.png");
  });

  test("A20 — Settings (/app/settings)", async ({ page }) => {
    await page.goto("/app/settings");
    await waitFor(page, '[data-testid="settings-page"]');
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A20-settings.png");
  });

  test("A21 — Achievements (/app/achievements)", async ({ page }) => {
    await page.goto("/app/achievements");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A21-achievements.png");
  });

  test("A22 — Recipes (/app/recipes)", async ({ page }) => {
    await page.goto("/app/recipes");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A22-recipes.png");
  });

  test("A23 — Image Search (/app/image-search)", async ({ page }) => {
    await page.goto("/app/image-search");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A23-image-search.png");
  });

  // ── Admin ──

  test("A24 — Admin Submissions (/app/admin/submissions)", async ({ page }) => {
    await page.goto("/app/admin/submissions");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A24-admin-submissions.png");
  });

  test("A25 — Admin Metrics (/app/admin/metrics)", async ({ page }) => {
    await page.goto("/app/admin/metrics");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A25-admin-metrics.png");
  });

  test("A26 — Admin Monitoring (/app/admin/monitoring)", async ({ page }) => {
    await page.goto("/app/admin/monitoring");
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A26-admin-monitoring.png");
  });
});

/* ════════════════════════════════════════════════════════════════════════════
   §3  AUTHENTICATED PAGES — Mobile
   ════════════════════════════════════════════════════════════════════════ */

test.describe("AUTHENTICATED pages — Mobile", () => {
  test.beforeEach(async ({ page }) => {
    await provisionTestUser();
    await page.setViewportSize(MOBILE_VIEWPORT);
    await page.emulateMedia({ colorScheme: "light", reducedMotion: "reduce" });
    await signInViaUI(page);
  });

  test("M01 — Home Dashboard (mobile)", async ({ page }) => {
    await page.goto("/app");
    await waitFor(page, '[data-testid="dashboard"]');
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A01-dashboard-mobile.png");
  });

  test("M02 — Onboarding (mobile)", async ({ page }) => {
    await page.goto("/onboarding");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A02-onboarding-mobile.png");
  });

  test("M03 — Categories (mobile)", async ({ page }) => {
    await page.goto("/app/categories");
    await waitFor(page, '[data-testid="category-grid"]');
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A03-categories-mobile.png");
  });

  test("M04 — Category Detail — Dairy (mobile)", async ({ page }) => {
    await page.goto("/app/categories/dairy");
    await waitFor(page, '[data-testid="product-list"]');
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A04-category-dairy-mobile.png");
  });

  test("M05 — Category Detail — Chips (mobile)", async ({ page }) => {
    await page.goto("/app/categories/chips");
    await waitFor(page, '[data-testid="product-list"]');
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A05-category-chips-mobile.png");
  });

  test("M06 — Category Detail — Drinks (mobile)", async ({ page }) => {
    await page.goto("/app/categories/drinks");
    await waitFor(page, '[data-testid="product-list"]');
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A06-category-drinks-mobile.png");
  });

  test("M07 — Product Detail — Dairy (mobile)", async ({ page }) => {
    await page.goto("/app/product/628");
    await waitFor(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A07-product-detail-mobile.png");
  });

  test("M08 — Product Detail — Chips (mobile)", async ({ page }) => {
    await page.goto("/app/product/626");
    await waitFor(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A08-product-detail-chips-mobile.png");
  });

  // ── Product Tabs — E. Wedel (mobile) ──

  test("M08a — Product Tabs — Overview (E. Wedel mobile)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitFor(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitFor(page, '[data-testid="tab-bar"]');
    await page.waitForTimeout(500);
    await capture(page, MOBILE_DIR, "A08a-product-overview-wedel-mobile.png");
  });

  test("M08b — Product Tabs — Nutrition (E. Wedel mobile)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitFor(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitFor(page, '[data-testid="tab-bar"]');
    await page.locator("#tab-nutrition").click();
    await page.waitForTimeout(1500);
    await capture(page, MOBILE_DIR, "A08b-product-nutrition-wedel-mobile.png");
  });

  test("M08c — Product Tabs — Alternatives (E. Wedel mobile)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitFor(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitFor(page, '[data-testid="tab-bar"]');
    await page.locator("#tab-alternatives").click();
    await page.waitForTimeout(1500);
    await capture(page, MOBILE_DIR, "A08c-product-alternatives-wedel-mobile.png");
  });

  test("M08d — Product Tabs — Scoring (E. Wedel mobile)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitFor(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitFor(page, '[data-testid="tab-bar"]');
    await page.locator("#tab-scoring").click();
    await page.waitForTimeout(1500);
    await capture(page, MOBILE_DIR, "A08d-product-scoring-wedel-mobile.png");
  });

  test("M09 — Search empty (mobile)", async ({ page }) => {
    await page.goto("/app/search");
    await waitFor(page, '[data-testid="search-input"]');
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A09-search-empty-mobile.png");
  });

  test("M10 — Search results (mobile)", async ({ page }) => {
    await page.goto("/app/search?q=jogurt");
    await waitFor(page, '[data-testid="search-results"]');
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A10-search-results-mobile.png");
  });

  test("M11 — Saved Searches (mobile)", async ({ page }) => {
    await page.goto("/app/search/saved");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A11-saved-searches-mobile.png");
  });

  test("M12 — Scan (mobile)", async ({ page }) => {
    await page.goto("/app/scan");
    await waitFor(page, '[data-testid="scan-page"]');
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A12-scan-mobile.png");
  });

  test("M13 — Scan History (mobile)", async ({ page }) => {
    await page.goto("/app/scan/history");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A13-scan-history-mobile.png");
  });

  test("M14 — Submit Product (mobile)", async ({ page }) => {
    await page.goto("/app/scan/submit");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A14-scan-submit-mobile.png");
  });

  test("M15 — My Submissions (mobile)", async ({ page }) => {
    await page.goto("/app/scan/submissions");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A15-scan-submissions-mobile.png");
  });

  test("M16 — Lists (mobile)", async ({ page }) => {
    await page.goto("/app/lists");
    await waitFor(page, '[data-testid="lists-page"]');
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A16-lists-mobile.png");
  });

  test("M17 — Compare (mobile)", async ({ page }) => {
    await page.goto("/app/compare");
    await waitFor(page, '[data-testid="comparison-grid"]');
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A17-compare-mobile.png");
  });

  test("M18 — Saved Comparisons (mobile)", async ({ page }) => {
    await page.goto("/app/compare/saved");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A18-compare-saved-mobile.png");
  });

  test("M19 — Watchlist (mobile)", async ({ page }) => {
    await page.goto("/app/watchlist");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A19-watchlist-mobile.png");
  });

  test("M20 — Settings (mobile)", async ({ page }) => {
    await page.goto("/app/settings");
    await waitFor(page, '[data-testid="settings-page"]');
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A20-settings-mobile.png");
  });

  test("M21 — Achievements (mobile)", async ({ page }) => {
    await page.goto("/app/achievements");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A21-achievements-mobile.png");
  });

  test("M22 — Recipes (mobile)", async ({ page }) => {
    await page.goto("/app/recipes");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A22-recipes-mobile.png");
  });

  test("M23 — Image Search (mobile)", async ({ page }) => {
    await page.goto("/app/image-search");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A23-image-search-mobile.png");
  });

  test("M24 — Admin Submissions (mobile)", async ({ page }) => {
    await page.goto("/app/admin/submissions");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A24-admin-submissions-mobile.png");
  });

  test("M25 — Admin Metrics (mobile)", async ({ page }) => {
    await page.goto("/app/admin/metrics");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A25-admin-metrics-mobile.png");
  });

  test("M26 — Admin Monitoring (mobile)", async ({ page }) => {
    await page.goto("/app/admin/monitoring");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A26-admin-monitoring-mobile.png");
  });

  test("M27 — Navigation drawer (mobile)", async ({ page }) => {
    await page.goto("/app");
    await waitFor(page, '[data-testid="dashboard"]');
    const moreBtn = page.locator(
      '[data-testid="nav-more"], button:has-text("More"), [aria-label="More"]',
    );
    if (await moreBtn.isVisible().catch(() => false)) {
      await moreBtn.click();
      await page.waitForTimeout(500);
    }
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A27-nav-drawer-mobile.png");
  });
});

/* ════════════════════════════════════════════════════════════════════════════
   §4  PUBLIC PAGES — Dark Desktop
   ════════════════════════════════════════════════════════════════════════ */

test.describe("PUBLIC pages — Dark Desktop", () => {
  test.beforeEach(async ({ page }) => {
    await page.setViewportSize(DESKTOP_VIEWPORT);
    await page.emulateMedia({ colorScheme: "dark", reducedMotion: "reduce" });
  });

  test("Landing page (dark)", async ({ page }) => {
    await page.goto("/");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "P01-landing-dark.png");
  });

  test("Login (dark)", async ({ page }) => {
    await page.goto("/auth/login");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "P02-login-dark.png");
  });

  test("Signup (dark)", async ({ page }) => {
    await page.goto("/auth/signup");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "P03-signup-dark.png");
  });

  test("Contact (dark)", async ({ page }) => {
    await page.goto("/contact");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "P04-contact-dark.png");
  });

  test("Privacy (dark)", async ({ page }) => {
    await page.goto("/privacy");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "P05-privacy-dark.png");
  });

  test("Terms (dark)", async ({ page }) => {
    await page.goto("/terms");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "P06-terms-dark.png");
  });

  test("Offline (dark)", async ({ page }) => {
    await page.goto("/offline");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "P07-offline-dark.png");
  });

  test("Learn Hub (dark)", async ({ page }) => {
    await page.goto("/learn");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "P08-learn-hub-dark.png");
  });

  test("Learn — TryVit Score (dark)", async ({ page }) => {
    await page.goto("/learn/tryvit-score");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "P09-learn-tryvit-score-dark.png");
  });

  test("Learn — Nutri-Score (dark)", async ({ page }) => {
    await page.goto("/learn/nutri-score");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "P10-learn-nutriscore-dark.png");
  });

  test("Learn — Confidence (dark)", async ({ page }) => {
    await page.goto("/learn/confidence");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "P11-learn-confidence-dark.png");
  });

  test("Learn — Allergens (dark)", async ({ page }) => {
    await page.goto("/learn/allergens");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "P12-learn-allergens-dark.png");
  });

  test("Learn — NOVA Groups (dark)", async ({ page }) => {
    await page.goto("/learn/nova-groups");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "P13-learn-nova-dark.png");
  });

  test("Learn — Additives (dark)", async ({ page }) => {
    await page.goto("/learn/additives");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "P14-learn-additives-dark.png");
  });

  test("Learn — Reading Labels (dark)", async ({ page }) => {
    await page.goto("/learn/reading-labels");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "P15-learn-reading-labels-dark.png");
  });
});

/* ════════════════════════════════════════════════════════════════════════════
   §5  PUBLIC PAGES — Dark Mobile
   ════════════════════════════════════════════════════════════════════════ */

test.describe("PUBLIC pages — Dark Mobile", () => {
  test.beforeEach(async ({ page }) => {
    await page.setViewportSize(MOBILE_VIEWPORT);
    await page.emulateMedia({ colorScheme: "dark", reducedMotion: "reduce" });
  });

  test("Landing page (dark mobile)", async ({ page }) => {
    await page.goto("/");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "P01-landing-dark-mobile.png");
  });

  test("Login (dark mobile)", async ({ page }) => {
    await page.goto("/auth/login");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "P02-login-dark-mobile.png");
  });

  test("Signup (dark mobile)", async ({ page }) => {
    await page.goto("/auth/signup");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "P03-signup-dark-mobile.png");
  });

  test("Contact (dark mobile)", async ({ page }) => {
    await page.goto("/contact");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "P04-contact-dark-mobile.png");
  });

  test("Privacy (dark mobile)", async ({ page }) => {
    await page.goto("/privacy");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "P05-privacy-dark-mobile.png");
  });

  test("Terms (dark mobile)", async ({ page }) => {
    await page.goto("/terms");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "P06-terms-dark-mobile.png");
  });

  test("Offline (dark mobile)", async ({ page }) => {
    await page.goto("/offline");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "P07-offline-dark-mobile.png");
  });

  test("Learn Hub (dark mobile)", async ({ page }) => {
    await page.goto("/learn");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "P08-learn-hub-dark-mobile.png");
  });

  test("Learn — TryVit Score (dark mobile)", async ({ page }) => {
    await page.goto("/learn/tryvit-score");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "P09-learn-tryvit-score-dark-mobile.png");
  });

  test("Learn — Nutri-Score (dark mobile)", async ({ page }) => {
    await page.goto("/learn/nutri-score");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "P10-learn-nutriscore-dark-mobile.png");
  });

  test("Learn — Confidence (dark mobile)", async ({ page }) => {
    await page.goto("/learn/confidence");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "P11-learn-confidence-dark-mobile.png");
  });

  test("Learn — Allergens (dark mobile)", async ({ page }) => {
    await page.goto("/learn/allergens");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "P12-learn-allergens-dark-mobile.png");
  });

  test("Learn — NOVA Groups (dark mobile)", async ({ page }) => {
    await page.goto("/learn/nova-groups");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "P13-learn-nova-dark-mobile.png");
  });

  test("Learn — Additives (dark mobile)", async ({ page }) => {
    await page.goto("/learn/additives");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "P14-learn-additives-dark-mobile.png");
  });

  test("Learn — Reading Labels (dark mobile)", async ({ page }) => {
    await page.goto("/learn/reading-labels");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "P15-learn-reading-labels-dark-mobile.png");
  });
});

/* ════════════════════════════════════════════════════════════════════════════
   §6  AUTHENTICATED PAGES — Dark Desktop
   ════════════════════════════════════════════════════════════════════════ */

test.describe("AUTHENTICATED pages — Dark Desktop", () => {
  test.beforeEach(async ({ page }) => {
    await provisionTestUser();
    await page.setViewportSize(DESKTOP_VIEWPORT);
    await page.emulateMedia({ colorScheme: "dark", reducedMotion: "reduce" });
    await signInViaUI(page);
  });

  test("D01 — Home Dashboard (dark)", async ({ page }) => {
    await page.goto("/app");
    await waitFor(page, '[data-testid="dashboard"]');
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "A01-dashboard-dark.png");
  });

  test("D02 — Onboarding (dark)", async ({ page }) => {
    await page.goto("/onboarding");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "A02-onboarding-dark.png");
  });

  test("D03 — Categories Grid (dark)", async ({ page }) => {
    await page.goto("/app/categories");
    await waitFor(page, '[data-testid="category-grid"]');
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "A03-categories-dark.png");
  });

  test("D04 — Category Detail — Dairy (dark)", async ({ page }) => {
    await page.goto("/app/categories/dairy");
    await waitFor(page, '[data-testid="product-list"]');
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "A04-category-dairy-dark.png");
  });

  test("D05 — Category Detail — Chips (dark)", async ({ page }) => {
    await page.goto("/app/categories/chips");
    await waitFor(page, '[data-testid="product-list"]');
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "A05-category-chips-dark.png");
  });

  test("D06 — Category Detail — Drinks (dark)", async ({ page }) => {
    await page.goto("/app/categories/drinks");
    await waitFor(page, '[data-testid="product-list"]');
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "A06-category-drinks-dark.png");
  });

  test("D07 — Product Detail — Dairy (dark)", async ({ page }) => {
    await page.goto("/app/product/628");
    await waitFor(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "A07-product-detail-dairy-dark.png");
  });

  test("D08 — Product Detail — Chips (dark)", async ({ page }) => {
    await page.goto("/app/product/626");
    await waitFor(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "A08-product-detail-chips-dark.png");
  });

  // ── Product Tabs — E. Wedel (dark) ──

  test("D08a — Product Tabs — Overview (E. Wedel dark)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitFor(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitFor(page, '[data-testid="tab-bar"]');
    await page.waitForTimeout(500);
    await capture(page, DARK_DESKTOP_DIR, "A08a-product-overview-wedel-dark.png");
  });

  test("D08b — Product Tabs — Nutrition (E. Wedel dark)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitFor(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitFor(page, '[data-testid="tab-bar"]');
    await page.locator("#tab-nutrition").click();
    await page.waitForTimeout(1500);
    await capture(page, DARK_DESKTOP_DIR, "A08b-product-nutrition-wedel-dark.png");
  });

  test("D08c — Product Tabs — Alternatives (E. Wedel dark)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitFor(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitFor(page, '[data-testid="tab-bar"]');
    await page.locator("#tab-alternatives").click();
    await page.waitForTimeout(1500);
    await capture(page, DARK_DESKTOP_DIR, "A08c-product-alternatives-wedel-dark.png");
  });

  test("D08d — Product Tabs — Scoring (E. Wedel dark)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitFor(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitFor(page, '[data-testid="tab-bar"]');
    await page.locator("#tab-scoring").click();
    await page.waitForTimeout(1500);
    await capture(page, DARK_DESKTOP_DIR, "A08d-product-scoring-wedel-dark.png");
  });

  test("D09 — Search empty (dark)", async ({ page }) => {
    await page.goto("/app/search");
    await waitFor(page, '[data-testid="search-input"]');
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "A09-search-empty-dark.png");
  });

  test("D10 — Search with results (dark)", async ({ page }) => {
    await page.goto("/app/search?q=jogurt");
    await waitFor(page, '[data-testid="search-results"]');
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "A10-search-results-dark.png");
  });

  test("D11 — Saved Searches (dark)", async ({ page }) => {
    await page.goto("/app/search/saved");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "A11-saved-searches-dark.png");
  });

  test("D12 — Barcode Scanner (dark)", async ({ page }) => {
    await page.goto("/app/scan");
    await waitFor(page, '[data-testid="scan-page"]');
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "A12-scan-dark.png");
  });

  test("D13 — Scan History (dark)", async ({ page }) => {
    await page.goto("/app/scan/history");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "A13-scan-history-dark.png");
  });

  test("D14 — Submit Product (dark)", async ({ page }) => {
    await page.goto("/app/scan/submit");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "A14-scan-submit-dark.png");
  });

  test("D15 — My Submissions (dark)", async ({ page }) => {
    await page.goto("/app/scan/submissions");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "A15-scan-submissions-dark.png");
  });

  test("D16 — Product Lists (dark)", async ({ page }) => {
    await page.goto("/app/lists");
    await waitFor(page, '[data-testid="lists-page"]');
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "A16-lists-dark.png");
  });

  test("D17 — Compare (dark)", async ({ page }) => {
    await page.goto("/app/compare");
    await waitFor(page, '[data-testid="comparison-grid"]');
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "A17-compare-dark.png");
  });

  test("D18 — Saved Comparisons (dark)", async ({ page }) => {
    await page.goto("/app/compare/saved");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "A18-compare-saved-dark.png");
  });

  test("D19 — Watchlist (dark)", async ({ page }) => {
    await page.goto("/app/watchlist");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "A19-watchlist-dark.png");
  });

  test("D20 — Settings (dark)", async ({ page }) => {
    await page.goto("/app/settings");
    await waitFor(page, '[data-testid="settings-page"]');
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "A20-settings-dark.png");
  });

  test("D21 — Achievements (dark)", async ({ page }) => {
    await page.goto("/app/achievements");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "A21-achievements-dark.png");
  });

  test("D22 — Recipes (dark)", async ({ page }) => {
    await page.goto("/app/recipes");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "A22-recipes-dark.png");
  });

  test("D23 — Image Search (dark)", async ({ page }) => {
    await page.goto("/app/image-search");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "A23-image-search-dark.png");
  });

  test("D24 — Admin Submissions (dark)", async ({ page }) => {
    await page.goto("/app/admin/submissions");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "A24-admin-submissions-dark.png");
  });

  test("D25 — Admin Metrics (dark)", async ({ page }) => {
    await page.goto("/app/admin/metrics");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "A25-admin-metrics-dark.png");
  });

  test("D26 — Admin Monitoring (dark)", async ({ page }) => {
    await page.goto("/app/admin/monitoring");
    await stabilizePage(page);
    await capture(page, DARK_DESKTOP_DIR, "A26-admin-monitoring-dark.png");
  });
});

/* ════════════════════════════════════════════════════════════════════════════
   §7  AUTHENTICATED PAGES — Dark Mobile
   ════════════════════════════════════════════════════════════════════════ */

test.describe("AUTHENTICATED pages — Dark Mobile", () => {
  test.beforeEach(async ({ page }) => {
    await provisionTestUser();
    await page.setViewportSize(MOBILE_VIEWPORT);
    await page.emulateMedia({ colorScheme: "dark", reducedMotion: "reduce" });
    await signInViaUI(page);
  });

  test("DM01 — Home Dashboard (dark mobile)", async ({ page }) => {
    await page.goto("/app");
    await waitFor(page, '[data-testid="dashboard"]');
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "A01-dashboard-dark-mobile.png");
  });

  test("DM02 — Onboarding (dark mobile)", async ({ page }) => {
    await page.goto("/onboarding");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "A02-onboarding-dark-mobile.png");
  });

  test("DM03 — Categories (dark mobile)", async ({ page }) => {
    await page.goto("/app/categories");
    await waitFor(page, '[data-testid="category-grid"]');
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "A03-categories-dark-mobile.png");
  });

  test("DM04 — Category Detail — Dairy (dark mobile)", async ({ page }) => {
    await page.goto("/app/categories/dairy");
    await waitFor(page, '[data-testid="product-list"]');
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "A04-category-dairy-dark-mobile.png");
  });

  test("DM05 — Category Detail — Chips (dark mobile)", async ({ page }) => {
    await page.goto("/app/categories/chips");
    await waitFor(page, '[data-testid="product-list"]');
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "A05-category-chips-dark-mobile.png");
  });

  test("DM06 — Category Detail — Drinks (dark mobile)", async ({ page }) => {
    await page.goto("/app/categories/drinks");
    await waitFor(page, '[data-testid="product-list"]');
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "A06-category-drinks-dark-mobile.png");
  });

  test("DM07 — Product Detail — Dairy (dark mobile)", async ({ page }) => {
    await page.goto("/app/product/628");
    await waitFor(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "A07-product-detail-dairy-dark-mobile.png");
  });

  test("DM08 — Product Detail — Chips (dark mobile)", async ({ page }) => {
    await page.goto("/app/product/626");
    await waitFor(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "A08-product-detail-chips-dark-mobile.png");
  });

  // ── Product Tabs — E. Wedel (dark mobile) ──

  test("DM08a — Product Tabs — Overview (E. Wedel dark mobile)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitFor(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitFor(page, '[data-testid="tab-bar"]');
    await page.waitForTimeout(500);
    await capture(page, DARK_MOBILE_DIR, "A08a-product-overview-wedel-dark-mobile.png");
  });

  test("DM08b — Product Tabs — Nutrition (E. Wedel dark mobile)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitFor(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitFor(page, '[data-testid="tab-bar"]');
    await page.locator("#tab-nutrition").click();
    await page.waitForTimeout(1500);
    await capture(page, DARK_MOBILE_DIR, "A08b-product-nutrition-wedel-dark-mobile.png");
  });

  test("DM08c — Product Tabs — Alternatives (E. Wedel dark mobile)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitFor(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitFor(page, '[data-testid="tab-bar"]');
    await page.locator("#tab-alternatives").click();
    await page.waitForTimeout(1500);
    await capture(page, DARK_MOBILE_DIR, "A08c-product-alternatives-wedel-dark-mobile.png");
  });

  test("DM08d — Product Tabs — Scoring (E. Wedel dark mobile)", async ({ page }) => {
    await page.goto("/app/product/1180");
    await waitFor(page, '[data-testid="quick-summary"]');
    await stabilizePage(page);
    await page.locator('[data-testid="toggle-analysis"]').click();
    await waitFor(page, '[data-testid="tab-bar"]');
    await page.locator("#tab-scoring").click();
    await page.waitForTimeout(1500);
    await capture(page, DARK_MOBILE_DIR, "A08d-product-scoring-wedel-dark-mobile.png");
  });

  test("DM09 — Search empty (dark mobile)", async ({ page }) => {
    await page.goto("/app/search");
    await waitFor(page, '[data-testid="search-input"]');
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "A09-search-empty-dark-mobile.png");
  });

  test("DM10 — Search results (dark mobile)", async ({ page }) => {
    await page.goto("/app/search?q=jogurt");
    await waitFor(page, '[data-testid="search-results"]');
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "A10-search-results-dark-mobile.png");
  });

  test("DM11 — Saved Searches (dark mobile)", async ({ page }) => {
    await page.goto("/app/search/saved");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "A11-saved-searches-dark-mobile.png");
  });

  test("DM12 — Scan (dark mobile)", async ({ page }) => {
    await page.goto("/app/scan");
    await waitFor(page, '[data-testid="scan-page"]');
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "A12-scan-dark-mobile.png");
  });

  test("DM13 — Scan History (dark mobile)", async ({ page }) => {
    await page.goto("/app/scan/history");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "A13-scan-history-dark-mobile.png");
  });

  test("DM14 — Submit Product (dark mobile)", async ({ page }) => {
    await page.goto("/app/scan/submit");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "A14-scan-submit-dark-mobile.png");
  });

  test("DM15 — My Submissions (dark mobile)", async ({ page }) => {
    await page.goto("/app/scan/submissions");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "A15-scan-submissions-dark-mobile.png");
  });

  test("DM16 — Lists (dark mobile)", async ({ page }) => {
    await page.goto("/app/lists");
    await waitFor(page, '[data-testid="lists-page"]');
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "A16-lists-dark-mobile.png");
  });

  test("DM17 — Compare (dark mobile)", async ({ page }) => {
    await page.goto("/app/compare");
    await waitFor(page, '[data-testid="comparison-grid"]');
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "A17-compare-dark-mobile.png");
  });

  test("DM18 — Saved Comparisons (dark mobile)", async ({ page }) => {
    await page.goto("/app/compare/saved");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "A18-compare-saved-dark-mobile.png");
  });

  test("DM19 — Watchlist (dark mobile)", async ({ page }) => {
    await page.goto("/app/watchlist");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "A19-watchlist-dark-mobile.png");
  });

  test("DM20 — Settings (dark mobile)", async ({ page }) => {
    await page.goto("/app/settings");
    await waitFor(page, '[data-testid="settings-page"]');
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "A20-settings-dark-mobile.png");
  });

  test("DM21 — Achievements (dark mobile)", async ({ page }) => {
    await page.goto("/app/achievements");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "A21-achievements-dark-mobile.png");
  });

  test("DM22 — Recipes (dark mobile)", async ({ page }) => {
    await page.goto("/app/recipes");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "A22-recipes-dark-mobile.png");
  });

  test("DM23 — Image Search (dark mobile)", async ({ page }) => {
    await page.goto("/app/image-search");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "A23-image-search-dark-mobile.png");
  });

  test("DM24 — Admin Submissions (dark mobile)", async ({ page }) => {
    await page.goto("/app/admin/submissions");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "A24-admin-submissions-dark-mobile.png");
  });

  test("DM25 — Admin Metrics (dark mobile)", async ({ page }) => {
    await page.goto("/app/admin/metrics");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "A25-admin-metrics-dark-mobile.png");
  });

  test("DM26 — Admin Monitoring (dark mobile)", async ({ page }) => {
    await page.goto("/app/admin/monitoring");
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "A26-admin-monitoring-dark-mobile.png");
  });

  test("DM27 — Navigation drawer (dark mobile)", async ({ page }) => {
    await page.goto("/app");
    await waitFor(page, '[data-testid="dashboard"]');
    const moreBtn = page.locator(
      '[data-testid="nav-more"], button:has-text("More"), [aria-label="More"]',
    );
    if (await moreBtn.isVisible().catch(() => false)) {
      await moreBtn.click();
      await page.waitForTimeout(500);
    }
    await stabilizePage(page);
    await capture(page, DARK_MOBILE_DIR, "A27-nav-drawer-dark-mobile.png");
  });
});

/* ════════════════════════════════════════════════════════════════════════════
   §8  CLEANUP
   ════════════════════════════════════════════════════════════════════════ */

test.describe("Cleanup", () => {
  test("Remove test user", async () => {
    await cleanupTestUser();
  });
});
