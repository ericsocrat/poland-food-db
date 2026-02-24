/**
 * Quality Gate 4/9 — Mobile Audit Runner
 *
 * Playwright spec that visits every route from the route manifest at
 * iPhone 14 viewport (390 × 844) and applies the invariant engine.
 * Product pages additionally cycle through all tabs.
 *
 * Screenshots are saved to `qa_screenshots/latest/mobile/`.
 *
 * Run on CI via the `quality-mobile` Playwright project or locally:
 *
 *   QA_MODE_LEVEL=smoke npx playwright test --project quality-mobile
 *
 * @see https://github.com/ericsocrat/poland-food-db/issues/175
 */

import { test, expect } from "@playwright/test";
import { getRoutes } from "./routes";
import {
  setupErrorCollectors,
  assertNoErrors,
  runInvariantsForRoute,
} from "./invariants";
import { cleanScreenshotDir, takeScreenshot } from "./helpers/screenshot";
import { waitForStable } from "./helpers/network";

/* ── Config ──────────────────────────────────────────────────────────────── */

/** Audit mode: `smoke` visits ~9 routes, `full` visits all ~40. */
const MODE = (process.env.QA_MODE_LEVEL ?? "smoke") as "smoke" | "full";

/* ── Setup ───────────────────────────────────────────────────────────────── */

test.beforeAll(async () => {
  await cleanScreenshotDir("mobile");
});

/* ── Route tests ─────────────────────────────────────────────────────────── */

const routes = getRoutes(MODE).filter((r) => !r.desktopOnly);

for (const route of routes) {
  test(`mobile audit — ${route.label}`, async ({ page }) => {
    // ── Attach error collectors ───────────────────────────────────────────
    const collectors = setupErrorCollectors(page);

    // ── Navigate ──────────────────────────────────────────────────────────
    const response = await page.goto(route.path, {
      waitUntil: "domcontentloaded",
    });
    expect(response?.ok() ?? false, `Navigation to ${route.path} failed`).toBe(
      true
    );
    await waitForStable(page);

    // ── Run invariant checks ──────────────────────────────────────────────
    await runInvariantsForRoute(page, route.path, {
      isMobile: true,
      isProductPage: route.path.includes("/product/"),
      isRecipesPage: route.path.includes("/recipes"),
      isSettingsPage: route.path.includes("/settings"),
      isAdminPage: route.path.includes("/admin"),
    });

    // ── Screenshot: default state ─────────────────────────────────────────
    await takeScreenshot(page, "mobile", route.label);

    // ── Tab cycling for product pages ─────────────────────────────────────
    if (route.hasTabs?.length) {
      for (const tabId of route.hasTabs) {
        const tabLocator = page.getByTestId("tab-bar").getByText(tabId, {
          exact: false,
        });

        // Some tabs may not exist yet (feature in progress) — skip gracefully.
        if ((await tabLocator.count()) === 0) continue;

        await tabLocator.click();
        await waitForStable(page, 4_000);

        // Re-run invariants for the new tab content
        await runInvariantsForRoute(page, `${route.path}#tab-${tabId}`, {
          isMobile: true,
          isProductPage: true,
          isRecipesPage: false,
          isSettingsPage: false,
          isAdminPage: false,
        });

        await takeScreenshot(page, "mobile", `${route.label}_tab-${tabId}`);
      }
    }

    // ── Assert no errors accumulated ──────────────────────────────────────
    assertNoErrors(collectors, route.path);
  });
}
