// ─── PR Screenshots — Smart Screenshot Capture for Changed Pages ────────────
// Captures mobile + desktop screenshots ONLY for pages affected by the
// current branch's file changes. Used for both local self-review and CI
// PR verification.
//
// Self-contained auth: creates a test user and signs in via the UI, bypassing
// CSP restrictions (same pattern as screenshot-capture.spec.ts).
//
// How it determines which pages to capture:
//   1. Reads CHANGED_FILES env var (newline-separated paths, set by runner)
//   2. Falls back to `git diff --name-only main...HEAD`
//   3. Maps file paths to page URLs via page-map.ts
//
// Usage:
//   # Via local runner (recommended):
//   pwsh RUN_PR_SCREENSHOTS.ps1
//
//   # Manual:
//   PR_SCREENSHOTS=true CHANGED_FILES="frontend/src/app/app/scan/page.tsx"
//     npx playwright test --project=pr-screenshots
//
// Output: frontend/pr-screenshots/{mobile,desktop}/

import { test, type Page } from "@playwright/test";
import path from "node:path";
import fs from "node:fs";
import { getChangedPages, type PageEntry } from "./helpers/page-map";

/* ── Constants ───────────────────────────────────────────────────────────── */

const OUTPUT_ROOT = path.resolve(__dirname, "../pr-screenshots");
const MOBILE_DIR = path.join(OUTPUT_ROOT, "mobile");
const DESKTOP_DIR = path.join(OUTPUT_ROOT, "desktop");

const MOBILE_VIEWPORT = { width: 390, height: 844 };
const DESKTOP_VIEWPORT = { width: 1440, height: 900 };

const TEST_EMAIL = "pr-screenshots@test.tryvit.local";
const TEST_PASSWORD = "PrScreenshot123!";

/* ── Helper functions ────────────────────────────────────────────────────── */

function ensureDir(dir: string) {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

async function stabilizePage(page: Page) {
  await page.waitForLoadState("networkidle");
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
  await page.waitForTimeout(500);
}

async function captureScreenshot(
  page: Page,
  dir: string,
  filename: string,
) {
  ensureDir(dir);
  const filepath = path.join(dir, filename);
  await page.screenshot({
    path: filepath,
    fullPage: false,
    animations: "disabled",
  });
  // eslint-disable-next-line no-console
  console.log(`  ✅ ${filepath}`);
}

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

async function signInViaUI(page: Page) {
  await page.goto("/auth/login");
  await page.waitForLoadState("networkidle");
  await page.getByLabel("Email").fill(TEST_EMAIL);
  await page.getByLabel("Password", { exact: true }).fill(TEST_PASSWORD);
  await page.getByRole("button", { name: "Sign In" }).click();
  await page.waitForURL(/\/(app\/search|onboarding)/, { timeout: 30_000 });

  if (page.url().includes("/onboarding")) {
    const skipBtn = page.getByTestId("onboarding-skip-all");
    if (await skipBtn.isVisible().catch(() => false)) {
      await skipBtn.click();
      await page.waitForURL(/\/app\/search/, { timeout: 10_000 });
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
    // Best-effort cleanup
  }
}

/* ── Determine which pages to capture ────────────────────────────────────── */

const changedPages = getChangedPages();
const publicPages = changedPages.filter((p) => !p.auth);
const authPages = changedPages.filter((p) => p.auth);

// eslint-disable-next-line no-console
console.log(
  `\n📸 PR Screenshots: ${changedPages.length} page(s) to capture\n` +
    changedPages.map((p) => `  • ${p.label} → ${p.url}`).join("\n"),
);

// ── Tests ─────────────────────────────────────────────────────────────────

test.describe.configure({ mode: "serial" });
test.setTimeout(60_000);

/* ── Public pages (no auth needed) ───────────────────────────────────────── */

if (publicPages.length > 0) {
  test.describe("Public pages", () => {
    for (const entry of publicPages) {
      test(`${entry.label} — mobile`, async ({ page }) => {
        await page.setViewportSize(MOBILE_VIEWPORT);
        await page.goto(entry.url);
        await stabilizePage(page);
        await captureScreenshot(page, MOBILE_DIR, `${entry.label}.png`);
      });

      test(`${entry.label} — desktop`, async ({ page }) => {
        await page.setViewportSize(DESKTOP_VIEWPORT);
        await page.goto(entry.url);
        await stabilizePage(page);
        await captureScreenshot(page, DESKTOP_DIR, `${entry.label}.png`);
      });
    }
  });
}

/* ── Authenticated pages ─────────────────────────────────────────────────── */

if (authPages.length > 0) {
  test.describe("Authenticated pages", () => {
    test.beforeAll(async () => {
      await provisionTestUser();
    });

    test.afterAll(async () => {
      await cleanupTestUser();
    });

    let isSignedIn = false;

    for (const entry of authPages) {
      test(`${entry.label} — mobile`, async ({ page }) => {
        if (!isSignedIn) {
          await signInViaUI(page);
          isSignedIn = true;
        }
        await page.setViewportSize(MOBILE_VIEWPORT);
        await page.goto(entry.url);
        await stabilizePage(page);
        await captureScreenshot(page, MOBILE_DIR, `${entry.label}.png`);
      });

      test(`${entry.label} — desktop`, async ({ page }) => {
        await page.setViewportSize(DESKTOP_VIEWPORT);
        await page.goto(entry.url);
        await stabilizePage(page);
        await captureScreenshot(page, DESKTOP_DIR, `${entry.label}.png`);
      });
    }
  });
}

/* ── Skip notice ─────────────────────────────────────────────────────────── */

if (changedPages.length === 0) {
  test("No pages to screenshot (no matching file changes detected)", () => {
    // eslint-disable-next-line no-console
    console.log("ℹ️  No changed files matched any page pattern. Nothing to capture.");
  });
}
