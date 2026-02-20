// ─── Visual regression screenshot helper ────────────────────────────────────
// Shared utility for deterministic screenshot comparison across light/dark
// themes and viewport sizes.
//
// Issue #70 — Visual Regression Baseline

import type { Page } from "@playwright/test";
import { expect } from "@playwright/test";

/* ── Types ───────────────────────────────────────────────────────────────── */

export interface ScreenshotOptions {
  /** Descriptive name used in the screenshot filename */
  name: string;
  /** Playwright page instance */
  page: Page;
  /** Color scheme to emulate. @default "light" */
  theme?: "light" | "dark";
  /** Viewport size override. @default { width: 1280, height: 720 } */
  viewport?: { width: number; height: number };
  /** CSS selectors to mask (e.g., dynamic content like timestamps) */
  mask?: string[];
  /** Max allowed pixel difference ratio (0–1). @default 0.01 (1%) */
  maxDiffPixelRatio?: number;
  /** Whether to take a full-page screenshot. @default false */
  fullPage?: boolean;
}

/* ── Predefined viewports ────────────────────────────────────────────────── */

export const VIEWPORTS = {
  desktop: { width: 1280, height: 720 },
  mobile: { width: 375, height: 812 },
} as const;

export type ViewportName = keyof typeof VIEWPORTS;

/* ── Predefined themes ───────────────────────────────────────────────────── */

export const THEMES = ["light", "dark"] as const;
export type ThemeName = (typeof THEMES)[number];

/* ── Core screenshot assertion ───────────────────────────────────────────── */

/**
 * Takes a deterministic screenshot and compares against baseline.
 *
 * - Sets viewport size
 * - Emulates color scheme (light/dark)
 * - Disables animations via `prefers-reduced-motion: reduce`
 * - Waits for network idle + DOM stability
 * - Masks dynamic content to avoid false positives
 *
 * On first run with no baseline, the screenshot is created as the baseline.
 * Subsequent runs compare against the stored baseline.
 */
export async function assertScreenshot(options: ScreenshotOptions) {
  const {
    name,
    page,
    theme = "light",
    viewport = VIEWPORTS.desktop,
    mask = [],
    maxDiffPixelRatio = 0.01,
    fullPage = false,
  } = options;

  // Set viewport
  await page.setViewportSize(viewport);

  // Set color scheme + disable animations for deterministic screenshots
  await page.emulateMedia({
    colorScheme: theme,
    reducedMotion: "reduce",
  });

  // Wait for fonts and images to load
  await page.waitForLoadState("networkidle");

  // Brief pause for any CSS transitions to settle
  await page.waitForTimeout(300);

  // Build mask locators from CSS selectors
  const maskLocators = mask.map((sel) => page.locator(sel));

  // Construct deterministic filename:
  // e.g. "home-light-1280x720.png"
  const screenshotName = `${name}-${theme}-${viewport.width}x${viewport.height}.png`;

  await expect(page).toHaveScreenshot(screenshotName, {
    maxDiffPixelRatio,
    mask: maskLocators,
    animations: "disabled",
    fullPage,
  });
}

/* ── Batch helper ────────────────────────────────────────────────────────── */

export interface PageConfig {
  /** Page name (used in screenshot filename) */
  name: string;
  /** Route to navigate to */
  path: string;
  /** CSS selectors to mask (dynamic content) */
  mask?: string[];
  /** Wait for this selector before taking screenshot */
  waitFor?: string;
}

/**
 * Generates a matrix of test configurations for all combinations
 * of pages × themes × viewports.
 */
export function buildTestMatrix(pages: PageConfig[]) {
  const matrix: Array<{
    page: PageConfig;
    theme: ThemeName;
    viewportName: ViewportName;
    viewport: { width: number; height: number };
    testName: string;
  }> = [];

  for (const pageConfig of pages) {
    for (const theme of THEMES) {
      for (const [viewportName, viewport] of Object.entries(VIEWPORTS)) {
        matrix.push({
          page: pageConfig,
          theme,
          viewportName: viewportName as ViewportName,
          viewport,
          testName: `${pageConfig.name} — ${theme} — ${viewportName}`,
        });
      }
    }
  }

  return matrix;
}
