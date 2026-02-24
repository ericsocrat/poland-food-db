/**
 * Quality Gate — Network Helper
 *
 * Shared utilities for reliable page-load waits used by audit runners.
 *
 * @see https://github.com/ericsocrat/poland-food-db/issues/175
 */

import type { Page } from "@playwright/test";

/**
 * Wait until the page network is idle **or** fall back to a
 * `domcontentloaded` + static timeout if the networkidle strategy
 * exceeds the budget.
 *
 * Playwright's `networkidle` can hang on long-polling / SSE
 * connections, so we treat it as best-effort.
 *
 * @param page       Playwright Page handle.
 * @param timeout    Timeout (ms) for the networkidle attempt — default 8 s.
 * @param fallbackMs Fixed wait after domcontentloaded fallback — default 2 s.
 */
export async function waitForStable(
  page: Page,
  timeout = 8_000,
  fallbackMs = 2_000
): Promise<void> {
  try {
    await page.waitForLoadState("networkidle", { timeout });
  } catch {
    // networkidle timed out — fall back to a generous static wait
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(fallbackMs);
  }
}

/**
 * Wait for a specific `data-testid` element to become visible,
 * with a configurable timeout.
 *
 * @returns `true` if the element appeared, `false` on timeout.
 */
export async function waitForTestId(
  page: Page,
  testId: string,
  timeout = 10_000
): Promise<boolean> {
  try {
    await page.getByTestId(testId).first().waitFor({
      state: "visible",
      timeout,
    });
    return true;
  } catch {
    return false;
  }
}
