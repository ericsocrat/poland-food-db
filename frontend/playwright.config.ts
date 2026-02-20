import { defineConfig, devices } from "@playwright/test";

// Auth e2e tests require SUPABASE_SERVICE_ROLE_KEY to provision test users.
// When the key is not set, only smoke tests run (no auth coverage).
const HAS_AUTH = !!process.env.SUPABASE_SERVICE_ROLE_KEY;

/* ── Project definitions ─────────────────────────────────────────────────── */

const smokeProject = {
  name: "smoke",
  testMatch: /smoke.*\.spec\.ts/,
  use: { ...devices["Desktop Chrome"] },
};

const authSetupProject = {
  name: "auth-setup",
  testMatch: /auth\.setup\.ts/,
  use: { ...devices["Desktop Chrome"] },
};

const authenticatedProject = {
  name: "authenticated",
  testMatch: /authenticated.*\.spec\.ts/,
  dependencies: ["auth-setup"],
  use: {
    ...devices["Desktop Chrome"],
    storageState: "e2e/.auth/user.json",
  },
};

const projects = HAS_AUTH
  ? [authSetupProject, smokeProject, authenticatedProject]
  : [smokeProject];

/* ── Config ──────────────────────────────────────────────────────────────── */

export default defineConfig({
  testDir: "./e2e",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: process.env.CI
    ? [
        ["list"],
        ["html", { open: "never" }],
        ["json", { outputFile: "test-results/a11y-results.json" }],
      ]
    : "html",

  /* Hard cap so the suite never hangs indefinitely */
  globalTimeout: 600_000,
  /* Per-test timeout */
  timeout: 30_000,

  expect: {
    /* Give client-side hydration enough time in CI */
    timeout: 10_000,
    /* Visual regression screenshot comparison thresholds (Issue #70) */
    toHaveScreenshot: {
      maxDiffPixelRatio: 0.01, // 1% pixel tolerance
      animations: "disabled",
      threshold: 0.2, // Per-pixel color sensitivity
    },
  },

  /* Snapshot path template for visual regression baselines (Issue #70) */
  snapshotPathTemplate:
    "{testDir}/__screenshots__/{testFilePath}/{arg}{ext}",

  ...(HAS_AUTH && { globalTeardown: "./e2e/global-teardown" }),

  use: {
    baseURL: "http://localhost:3000",
    trace: "on-first-retry",
    screenshot: "only-on-failure",
    actionTimeout: 10_000,
    navigationTimeout: 15_000,
  },

  projects,

  /* CI starts its own dev server; locally you must run `npm run dev` first.
     The webServer block caused hangs when a stale Node process held port 3000
     without actually serving — Playwright's "plugin setup" waited forever. */
  ...(process.env.CI && {
    webServer: {
      command: "npm run dev -- --port 3000",
      url: "http://localhost:3000",
      reuseExistingServer: false,
      timeout: 60_000,
    },
  }),
});
