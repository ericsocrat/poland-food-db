// ─── Playwright auth setup project ──────────────────────────────────────────
// Creates a test user via Supabase Admin API, logs in through the UI, completes
// onboarding, and saves browser storageState for downstream test projects.
//
// Skipped automatically when SUPABASE_SERVICE_ROLE_KEY is not set.

import { test as setup, expect } from "@playwright/test";
import {
  TEST_EMAIL,
  TEST_PASSWORD,
  ensureTestUser,
} from "./helpers/test-user";

const AUTH_STATE_PATH = "e2e/.auth/user.json";

setup("create user and authenticate via UI", async ({ page }) => {
  // ── 1. Provision test user ────────────────────────────────────────────────
  await ensureTestUser();

  // ── 2. Login via the UI ───────────────────────────────────────────────────
  await page.goto("/auth/login");
  await page.getByLabel("Email").fill(TEST_EMAIL);
  await page.getByLabel("Password").fill(TEST_PASSWORD);
  await page.getByRole("button", { name: "Sign In" }).click();

  // After login the user has no preferences → redirected to onboarding wizard
  await page.waitForURL(/\/(app\/search|onboarding)/, {
    timeout: 15_000,
  });

  // ── 3. Complete onboarding (if needed) ────────────────────────────────────
  if (page.url().includes("/onboarding")) {
    // Click "Skip — go to app" on the Welcome step
    await page.getByTestId("onboarding-skip-all").click();

    // Should land on /app/search
    await page.waitForURL(/\/app\/search/, { timeout: 10_000 });
  }

  // ── 4. Verify we're authenticated ─────────────────────────────────────────
  await expect(page).toHaveURL(/\/app\/search/);

  // ── 5. Persist auth cookies for dependent test projects ───────────────────
  await page.context().storageState({ path: AUTH_STATE_PATH });
});
