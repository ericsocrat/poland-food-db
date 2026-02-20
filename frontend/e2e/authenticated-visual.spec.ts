// ─── Visual regression tests — Authenticated pages ──────────────────────────
// Captures baseline screenshots for auth-protected app pages in both
// light and dark themes at desktop and mobile viewports.
//
// Issue #70 — Visual Regression Baseline
// Total: 7 pages × 2 themes × 2 viewports = 28 baselines
//
// These tests require SUPABASE_SERVICE_ROLE_KEY to be set (auth-setup
// must run first to provision a test user with stored session state).

import { test } from "@playwright/test";
import {
  assertScreenshot,
  buildTestMatrix,
  type PageConfig,
} from "./helpers/visual";

/* ── Dynamic content masks ───────────────────────────────────────────────── */

// CSS selectors for content that changes between runs (timestamps,
// user-specific data, dynamic counts). Masked to prevent false diffs.
const COMMON_MASKS = [
  '[data-testid="timestamp"]',
  '[data-testid="avatar"]',
  '[data-testid="user-email"]',
  "time",
];

/* ── Pages under test ────────────────────────────────────────────────────── */

const APP_PAGES: PageConfig[] = [
  {
    name: "dashboard",
    path: "/app",
    mask: [...COMMON_MASKS, '[data-testid="greeting"]'],
    waitFor: '[data-testid="dashboard"]',
  },
  {
    name: "search",
    path: "/app/search?q=mleko",
    mask: [...COMMON_MASKS, '[data-testid="result-count"]'],
    waitFor: '[data-testid="search-results"]',
  },
  {
    name: "product",
    path: "/app/product/5900617043375",
    mask: [...COMMON_MASKS, '[data-testid="updated-at"]'],
    waitFor: '[data-testid="product-profile"]',
  },
  {
    name: "compare",
    path: "/app/compare",
    mask: COMMON_MASKS,
  },
  {
    name: "settings",
    path: "/app/settings",
    mask: [...COMMON_MASKS, '[data-testid="user-email"]'],
    waitFor: '[data-testid="settings-page"]',
  },
  {
    name: "categories",
    path: "/app/categories",
    mask: [...COMMON_MASKS, '[data-testid="product-count"]'],
  },
  {
    name: "lists-empty",
    path: "/app/lists",
    mask: COMMON_MASKS,
  },
];

/* ── Generate test matrix ────────────────────────────────────────────────── */

const matrix = buildTestMatrix(APP_PAGES);

test.describe("Visual regression — Authenticated pages", () => {
  for (const entry of matrix) {
    test(entry.testName, async ({ page }) => {
      await page.goto(entry.page.path);

      // Wait for a specific selector if specified (indicates page loaded)
      if (entry.page.waitFor) {
        await page.waitForSelector(entry.page.waitFor, { timeout: 15_000 });
      }

      await assertScreenshot({
        name: entry.page.name,
        page,
        theme: entry.theme,
        viewport: entry.viewport,
        mask: entry.page.mask,
      });
    });
  }
});
