// ─── Visual regression tests — Public pages (smoke) ─────────────────────────
// Captures baseline screenshots for public (unauthenticated) pages in
// both light and dark themes at desktop and mobile viewports.
//
// Issue #70 — Visual Regression Baseline
// Total: 6 pages × 2 themes × 2 viewports = 24 baselines

import { test } from "@playwright/test";
import {
  assertScreenshot,
  buildTestMatrix,
  type PageConfig,
} from "./helpers/visual";

/* ── Pages under test ────────────────────────────────────────────────────── */

const PUBLIC_PAGES: PageConfig[] = [
  {
    name: "landing",
    path: "/",
    mask: [],
  },
  {
    name: "login",
    path: "/auth/login",
    mask: [],
  },
  {
    name: "signup",
    path: "/auth/signup",
    mask: [],
  },
  {
    name: "contact",
    path: "/contact",
    mask: [],
  },
  {
    name: "privacy",
    path: "/privacy",
    mask: [],
  },
  {
    name: "terms",
    path: "/terms",
    mask: [],
  },
];

/* ── Generate test matrix ────────────────────────────────────────────────── */

const matrix = buildTestMatrix(PUBLIC_PAGES);

test.describe("Visual regression — Public pages", () => {
  for (const entry of matrix) {
    test(entry.testName, async ({ page }) => {
      await page.goto(entry.page.path);

      // Wait for a specific selector if specified
      if (entry.page.waitFor) {
        await page.waitForSelector(entry.page.waitFor);
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
