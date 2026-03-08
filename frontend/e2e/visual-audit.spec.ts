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
// Output: docs/screenshots/audit/{desktop,mobile}/

import { test, type Page } from "@playwright/test";
import fs from "node:fs";
import path from "node:path";

/* ── Constants ───────────────────────────────────────────────────────────── */

const AUDIT_ROOT = path.resolve(__dirname, "../../docs/screenshots/audit");
const DESKTOP_DIR = path.join(AUDIT_ROOT, "desktop");
const MOBILE_DIR = path.join(AUDIT_ROOT, "mobile");

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
  await page.waitForTimeout(800);
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

async function waitFor(page: Page, selector: string, timeout = 8000) {
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

  test("Learn Hub (mobile)", async ({ page }) => {
    await page.goto("/learn");
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "P08-learn-hub-mobile.png");
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
    await page.goto("/app/product/5900820002176");
    await waitFor(page, '[data-testid="product-profile"]');
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A07-product-detail-dairy.png");
  });

  test("A08 — Product Detail (Chips product)", async ({ page }) => {
    await page.goto("/app/product/5900617043375");
    await waitFor(page, '[data-testid="product-profile"]');
    await stabilizePage(page);
    await capture(page, DESKTOP_DIR, "A08-product-detail-chips.png");
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

  test("M02 — Categories (mobile)", async ({ page }) => {
    await page.goto("/app/categories");
    await waitFor(page, '[data-testid="category-grid"]');
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A03-categories-mobile.png");
  });

  test("M03 — Category Detail (mobile)", async ({ page }) => {
    await page.goto("/app/categories/dairy");
    await waitFor(page, '[data-testid="product-list"]');
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A04-category-dairy-mobile.png");
  });

  test("M04 — Product Detail (mobile)", async ({ page }) => {
    await page.goto("/app/product/5900820002176");
    await waitFor(page, '[data-testid="product-profile"]');
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A07-product-detail-mobile.png");
  });

  test("M05 — Search results (mobile)", async ({ page }) => {
    await page.goto("/app/search?q=mleko");
    await waitFor(page, '[data-testid="search-results"]');
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A10-search-results-mobile.png");
  });

  test("M06 — Scan (mobile)", async ({ page }) => {
    await page.goto("/app/scan");
    await waitFor(page, '[data-testid="scan-page"]');
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A12-scan-mobile.png");
  });

  test("M07 — Lists (mobile)", async ({ page }) => {
    await page.goto("/app/lists");
    await waitFor(page, '[data-testid="lists-page"]');
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A16-lists-mobile.png");
  });

  test("M08 — Compare (mobile)", async ({ page }) => {
    await page.goto("/app/compare");
    await waitFor(page, '[data-testid="comparison-grid"]');
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A17-compare-mobile.png");
  });

  test("M09 — Settings (mobile)", async ({ page }) => {
    await page.goto("/app/settings");
    await waitFor(page, '[data-testid="settings-page"]');
    await stabilizePage(page);
    await capture(page, MOBILE_DIR, "A20-settings-mobile.png");
  });

  test("M10 — Navigation drawer (mobile)", async ({ page }) => {
    await page.goto("/app");
    await waitFor(page, '[data-testid="dashboard"]');
    // Open the "More" drawer
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
   §4  CLEANUP
   ════════════════════════════════════════════════════════════════════════ */

test.describe("Cleanup", () => {
  test("Remove test user", async () => {
    await cleanupTestUser();
  });
});
