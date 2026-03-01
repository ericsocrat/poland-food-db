/**
 * Quality Gate — Invariant Engine
 *
 * Reusable library of deterministic DOM / network / console checks
 * that the mobile and desktop audit runners call on every route.
 * This is the core intelligence of the quality gate — every audit
 * imports from here instead of reinventing assertions.
 *
 * 32 + invariant checks across 7 categories:
 *   Global (16) · Mobile (3) · Desktop (1) · Product (7) ·
 *   Recipes (1) · Settings (1) · Admin (3)
 *
 * @see https://github.com/ericsocrat/poland-food-db/issues/174
 */

import { type Page, expect } from "@playwright/test";

/* ── Types ───────────────────────────────────────────────────────────────── */

export interface InvariantResult {
  check: string;
  passed: boolean;
  message?: string;
}

export interface ErrorCollectors {
  consoleErrors: string[];
  networkErrors: { url: string; status: number }[];
  pageErrors: string[];
}

export interface RunInvariantsOptions {
  isMobile: boolean;
  isProductPage: boolean;
  isRecipesPage: boolean;
  isSettingsPage: boolean;
  isAdminPage: boolean;
}

/* ── Helpers ──────────────────────────────────────────────────────────────── */

/**
 * Returns visible text content from the page body, excluding script,
 * style, and noscript elements.  This prevents false positives from
 * Next.js RSC flight data ("$undefined" markers) and inline JSON-LD.
 */
async function getVisibleBodyText(page: Page): Promise<string> {
  return page.evaluate(() => {
    const clone = document.body.cloneNode(true) as HTMLElement;
    clone
      .querySelectorAll("script, style, noscript")
      .forEach((el) => el.remove());
    return clone.textContent ?? "";
  });
}

/* ── i18n namespace pattern ──────────────────────────────────────────────── */

const I18N_KEY_PATTERN =
  /\b(nav|common|toast|onboarding|search|product|categories|compare|lists|settings|scan|admin|learn|recipes|achievements)\.[a-z_]+\.[a-z_]+/g;

/* ── Forbidden literals that should never appear in rendered UI ───────── */

const FORBIDDEN_LITERALS = [
  "eu_ri",
  "NOT-APPLICABLE",
  "undefined",
  "NaN",
  "[object Object]",
];

/**
 * Route-specific exclusions for forbidden literals.
 * Some literals are intentionally displayed on educational / learn pages.
 */
const FORBIDDEN_LITERAL_ROUTE_EXCLUSIONS: Record<string, string[]> = {
  // /learn/nutri-score legitimately shows "NOT-APPLICABLE" as a Nutri-Score label
  "/learn/": ["NOT-APPLICABLE"],
};

/* ── Critical singleton data-testid values ─────────────────────────────── */

const UNIQUE_TEST_IDS = [
  "health-profile-section",
  "score-breakdown-panel",
  "tab-bar",
  "main-navigation",
];

/* ── Network error allowlist ─────────────────────────────────────────────── */

export const NETWORK_ALLOWLIST = [
  "/auth/callback",
  "supabase.co/auth",
  "favicon",
  "/sw.js",
];

/**
 * URLs where 4xx is expected (e.g. unauthenticated Supabase REST calls).
 * 5xx from these URLs will still fail the audit.
 */
export const NETWORK_4XX_ALLOWLIST = [
  "supabase.co/rest",
];

/* ── Console error allowlist ────────────────────────────────────────────── */

/**
 * In CI, missing Supabase env vars indicate a real misconfiguration and
 * must NOT be silenced.  Locally the env may not be set, so we allowlist.
 */
const IS_CI =
  typeof process !== "undefined" &&
  !!process.env.CI &&
  (process.env.CI === "true" || process.env.CI === "1");

/**
 * Benign console.error patterns that should not fail a quality audit.
 * These arise from expected conditions (e.g. no auth session on public
 * pages, client-side analytics, React strict mode double-renders).
 */
export const CONSOLE_ERROR_ALLOWLIST = [
  // Supabase auth — expected on public pages without a session
  "AuthSessionMissingError",
  "Auth session missing",
  "Invalid Refresh Token",
  "refresh_token_not_found",
  // Supabase client init when URL is empty/invalid:
  // In CI, treat missing Supabase env as a hard failure (do NOT allowlist).
  // In local/dev runs, allowlist to avoid noisy audits when env is not set.
  ...(!IS_CI ? ["supabaseUrl is required", "supabaseKey is required"] : []),
  // React hydration mismatch (non-critical in audit context)
  "Hydration failed",
  "Text content does not match",
  "There was an error while hydrating",
  // Next.js metadata / viewport warnings
  "viewport meta tag",
  // Browser extensions injecting errors
  "chrome-extension://",
  "moz-extension://",
  // Content Security Policy violations from Supabase Realtime WebSocket
  "violates the following Content Security Policy",
  // Cloudflare Turnstile script loading blocked by CSP
  "challenges.cloudflare.com/turnstile",
  // Service worker / script redirect errors in CI (CDN redirect artifact)
  "script resource is behind a redirect",
];

/* ═══════════════════════════════════════════════════════════════════════════
 *  GLOBAL INVARIANTS (all routes) — 16 checks
 * ═══════════════════════════════════════════════════════════════════════════ */

export async function checkGlobalInvariants(
  page: Page,
  route: string
): Promise<void> {
  const bodyText = await getVisibleBodyText(page);

  // 1 — No raw i18n keys
  const rawKeys = bodyText.match(I18N_KEY_PATTERN) ?? [];
  expect(
    rawKeys,
    `Raw i18n keys found on ${route}: ${rawKeys.join(", ")}`
  ).toHaveLength(0);

  // 2–6 — No forbidden literals
  for (const literal of FORBIDDEN_LITERALS) {
    // Skip literals that are intentionally displayed on certain routes
    const excluded = Object.entries(FORBIDDEN_LITERAL_ROUTE_EXCLUSIONS).some(
      ([prefix, exclusions]) =>
        route.startsWith(prefix) && exclusions.includes(literal)
    );
    if (excluded) continue;

    expect(
      bodyText,
      `Forbidden literal "${literal}" found on ${route}`
    ).not.toContain(literal);
  }

  // 7 — No empty buttons (must have text OR aria-label)
  const emptyButtons = await page
    .locator("button:not([aria-label])")
    .filter({ hasNotText: /.+/ })
    .count();
  expect(
    emptyButtons,
    `${emptyButtons} empty button(s) without text or aria-label on ${route}`
  ).toBe(0);

  // 8 — No empty links (must have text OR aria-label)
  const emptyLinks = await page
    .locator('a:not([aria-label]):not([aria-hidden="true"])')
    .filter({ hasNotText: /.+/ })
    .count();
  expect(
    emptyLinks,
    `${emptyLinks} empty link(s) without text or aria-label on ${route}`
  ).toBe(0);

  // 9 — No missing alt on images
  const imgNoAlt = await page
    .locator('img:not([alt]):not([role="presentation"])')
    .count();
  expect(
    imgNoAlt,
    `${imgNoAlt} image(s) missing alt attribute on ${route}`
  ).toBe(0);

  // 10 — No zero-height clickable elements (excludes hidden/display:none)
  const zeroHeightClickables = await page.evaluate(() => {
    const clickables = document.querySelectorAll(
      'a, button, [role="button"]'
    );
    return Array.from(clickables).filter((el) => {
      const rect = el.getBoundingClientRect();
      if (rect.height > 0) return false;
      // Exclude elements intentionally hidden from visual layout
      const style = window.getComputedStyle(el);
      if (
        style.display === "none" ||
        style.visibility === "hidden" ||
        style.opacity === "0" ||
        (el as HTMLElement).offsetParent === null
      )
        return false;
      // Exclude elements inside aria-hidden containers
      if (el.closest('[aria-hidden="true"]') || el.closest("[hidden]"))
        return false;
      return true;
    }).length;
  });
  expect(
    zeroHeightClickables,
    `${zeroHeightClickables} zero-height clickable(s) on ${route}`
  ).toBe(0);

  // 11 — No exposed UUIDs in visible text
  const uuidPattern =
    /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/gi;
  const exposedUuids = bodyText.match(uuidPattern) ?? [];
  expect(
    exposedUuids,
    `Exposed UUID(s) in UI on ${route}: ${exposedUuids.slice(0, 3).join(", ")}`
  ).toHaveLength(0);

  // 12 — No duplicate critical singleton components
  for (const testId of UNIQUE_TEST_IDS) {
    const count = await page.locator(`[data-testid="${testId}"]`).count();
    expect(
      count,
      `Duplicate data-testid="${testId}" on ${route}: found ${count}`
    ).toBeLessThanOrEqual(1);
  }

  // 13 — No visible placeholder banners
  const placeholders = await page
    .locator('[data-testid="placeholder-banner"]:visible')
    .count();
  expect(
    placeholders,
    `Visible placeholder banner(s) on ${route}`
  ).toBe(0);

  // 14 — Viewport meta tag present
  const viewportMeta = await page
    .locator('meta[name="viewport"]')
    .count();
  expect(
    viewportMeta,
    `Missing <meta name="viewport"> on ${route}`
  ).toBeGreaterThanOrEqual(1);

  // 15 — No form inputs without accessible labels
  const unlabeledInputs = await page.evaluate(() => {
    const inputs = document.querySelectorAll(
      'input:not([type="hidden"]):not([aria-label]):not([aria-labelledby]):not([title])'
    );
    return Array.from(inputs).filter((input) => {
      const el = input as HTMLElement;
      // Skip inputs that are not in the visual layout
      const style = window.getComputedStyle(input);
      if (
        style.display === "none" ||
        style.visibility === "hidden" ||
        style.opacity === "0" ||
        el.offsetParent === null
      )
        return false;
      // Skip "visually hidden" inputs (1×1px trick used by Radix UI / shadcn)
      const rect = el.getBoundingClientRect();
      if (rect.width < 4 || rect.height < 4) return false;
      // Skip inputs inside hidden containers
      if (
        input.closest('[aria-hidden="true"]') ||
        input.closest("[hidden]")
      )
        return false;
      // Skip inputs wrapped inside a <label> element (implicit labeling)
      if (input.closest("label")) return false;
      // Check for explicit label[for="id"] association
      const id = input.getAttribute("id");
      if (!id) return true;
      return !document.querySelector(`label[for="${id}"]`);
    }).length;
  });
  expect(
    unlabeledInputs,
    `${unlabeledInputs} input(s) without accessible label on ${route}`
  ).toBe(0);

  // 16 — Document language attribute present
  const langAttr = await page.locator("html[lang]").count();
  expect(
    langAttr,
    `Missing lang attribute on <html> on ${route}`
  ).toBe(1);
}

/* ═══════════════════════════════════════════════════════════════════════════
 *  MOBILE INVARIANTS — 3 checks
 * ═══════════════════════════════════════════════════════════════════════════ */

export async function checkMobileInvariants(
  page: Page,
  route: string
): Promise<void> {
  // 17 — No horizontal overflow
  const hasOverflow = await page.evaluate(
    () =>
      document.documentElement.scrollWidth >
      document.documentElement.clientWidth
  );
  expect(
    hasOverflow,
    `Horizontal overflow detected on mobile route ${route}`
  ).toBe(false);

  // 18 — Touch-target size audit (warn-only, not hard-fail)
  const smallTouchTargets = await page.evaluate(() => {
    const targets = document.querySelectorAll(
      'a, button, [role="button"], [role="tab"], input, select, textarea'
    );
    return Array.from(targets).filter((el) => {
      const rect = el.getBoundingClientRect();
      return (
        rect.height > 0 &&
        rect.width > 0 &&
        (rect.height < 44 || rect.width < 44)
      );
    }).length;
  });
  if (smallTouchTargets > 0) {
    // eslint-disable-next-line no-console
    console.warn(
      `[WARN] ${smallTouchTargets} touch target(s) < 44px on mobile ${route}`
    );
  }

  // 19 — Content fits within mobile viewport
  const contentWidth = await page.evaluate(() =>
    Math.max(document.body.scrollWidth, document.body.offsetWidth)
  );
  expect(
    contentWidth,
    `Content width ${contentWidth}px exceeds viewport on mobile ${route}`
  ).toBeLessThanOrEqual(400);
}

/* ═══════════════════════════════════════════════════════════════════════════
 *  DESKTOP INVARIANTS — 1 check
 * ═══════════════════════════════════════════════════════════════════════════ */

export async function checkDesktopInvariants(
  page: Page,
  route: string
): Promise<void> {
  // 20 — Navigation visible on app routes
  if (route.startsWith("/app")) {
    const nav = await page
      .locator(
        '[data-testid="main-navigation"], [data-testid="desktop-nav"], nav'
      )
      .first()
      .isVisible()
      .catch(() => false);
    // Soft check: only warn if no nav is found (app is mobile-first PWA)
    if (!nav) {
      // eslint-disable-next-line no-console
      console.warn(
        `[WARN] No visible navigation found on desktop app route ${route}`
      );
    }
  }
}

/* ═══════════════════════════════════════════════════════════════════════════
 *  PRODUCT PAGE INVARIANTS — 7 checks
 * ═══════════════════════════════════════════════════════════════════════════ */

export async function checkProductInvariants(
  page: Page,
  route: string
): Promise<void> {
  // 21 — Exactly 1 tab bar
  const tabBars = await page
    .locator('[data-testid="tab-bar"], [role="tablist"]')
    .count();
  expect(
    tabBars,
    `Expected exactly 1 tab bar on ${route}, found ${tabBars}`
  ).toBe(1);

  // 22 — At most 1 score explanation section
  const scoreExplanations = await page
    .locator('[data-testid="score-breakdown-panel"]')
    .count();
  expect(
    scoreExplanations,
    `Expected ≤1 score explanation on ${route}, found ${scoreExplanations}`
  ).toBeLessThanOrEqual(1);

  // 23 — At most 1 health warnings section
  const healthWarnings = await page
    .locator('[data-testid="health-warnings-card"]')
    .count();
  expect(
    healthWarnings,
    `Expected ≤1 health warnings on ${route}, found ${healthWarnings}`
  ).toBeLessThanOrEqual(1);

  // 24 — No pluralization bugs ("1 ingredients", "1 alternatives")
  const bodyText = await getVisibleBodyText(page);
  const pluralBugs =
    /\b1\s+(ingredients|alternatives|products|categories|items|results)\b/gi;
  const matches = bodyText.match(pluralBugs) ?? [];
  expect(
    matches,
    `Pluralization bug on ${route}: ${matches.join(", ")}`
  ).toHaveLength(0);

  // 25 — No duplicate H2 headers in visible tab content
  const visibleH2s = await page.locator("h2:visible").allTextContents();
  const uniqueH2s = new Set(visibleH2s.map((h) => h.trim().toLowerCase()));
  expect(
    visibleH2s.length,
    `Duplicate H2 headers on ${route}: ${visibleH2s.join(" | ")}`
  ).toBe(uniqueH2s.size);

  // 26 — Product image has custom alt text (not generic)
  const productImg = page
    .locator(
      '[data-testid="product-thumbnail"] img, [data-testid="product-image"] img'
    )
    .first();
  if ((await productImg.count()) > 0) {
    const alt = await productImg.getAttribute("alt");
    expect(alt, `Product image missing alt on ${route}`).toBeTruthy();
    expect(alt, `Product image has generic alt on ${route}`).not.toBe(
      "image"
    );
  }

  // 27 — Tab navigation does not create duplicate parent sections
  // (verified by recounting tab-bar after tab switch; handled by audit runner)
}

/* ═══════════════════════════════════════════════════════════════════════════
 *  RECIPES PAGE INVARIANTS — 1 check
 * ═══════════════════════════════════════════════════════════════════════════ */

export async function checkRecipesInvariants(
  page: Page,
  route: string
): Promise<void> {
  // 28 — Filter buttons have visible labels
  const filterBtns = page.locator(
    '[data-testid*="recipe-filter"] button, [data-testid*="filter"] button'
  );
  const count = await filterBtns.count();
  for (let i = 0; i < count; i++) {
    const text = await filterBtns.nth(i).textContent();
    const ariaLabel = await filterBtns.nth(i).getAttribute("aria-label");
    expect(
      text || ariaLabel,
      `Filter button ${i} on ${route} has no label`
    ).toBeTruthy();
  }
}

/* ═══════════════════════════════════════════════════════════════════════════
 *  SETTINGS PAGE INVARIANTS — 1 check
 * ═══════════════════════════════════════════════════════════════════════════ */

export async function checkSettingsInvariants(
  page: Page,
  route: string
): Promise<void> {
  // 29 — Health Profiles section appears exactly once
  const profiles = await page
    .locator('[data-testid="health-profile-section"]')
    .count();
  expect(
    profiles,
    `Health Profiles section count on ${route}: expected 1, got ${profiles}`
  ).toBe(1);
}

/* ═══════════════════════════════════════════════════════════════════════════
 *  ADMIN PAGE INVARIANTS — 3 checks
 * ═══════════════════════════════════════════════════════════════════════════ */

export async function checkAdminInvariants(
  page: Page,
  route: string
): Promise<void> {
  const bodyText = await getVisibleBodyText(page);

  // 30 — No exposed service_role references
  expect(
    bodyText.toLowerCase(),
    `service_role reference exposed on ${route}`
  ).not.toContain("service_role");

  // 31 — No JWT-like strings (service key leak)
  const jwtPattern = /eyJ[A-Za-z0-9+/=]{20,}/;
  expect(
    bodyText,
    `JWT-like token exposed on admin page ${route}`
  ).not.toMatch(jwtPattern);

  // 32 — No exposed database identifiers
  const dbPatterns = [
    "product_allergens",
    "product_ingredient",
    "mv_product",
    "api_health_check",
  ];
  for (const pattern of dbPatterns) {
    expect(
      bodyText,
      `Database identifier "${pattern}" exposed on admin ${route}`
    ).not.toContain(pattern);
  }
}

/* ═══════════════════════════════════════════════════════════════════════════
 *  ERROR COLLECTION
 * ═══════════════════════════════════════════════════════════════════════════ */

/**
 * Attaches console / network / page-error listeners to a Playwright Page.
 * Call **before** navigation so all events are captured.
 */
export function setupErrorCollectors(page: Page): ErrorCollectors {
  const consoleErrors: string[] = [];
  const networkErrors: { url: string; status: number }[] = [];
  const pageErrors: string[] = [];

  page.on("console", (msg) => {
    if (msg.type() === "error") {
      const text = msg.text();
      const isAllowlisted = CONSOLE_ERROR_ALLOWLIST.some((pattern) =>
        text.includes(pattern)
      );
      if (!isAllowlisted) consoleErrors.push(text);
    }
  });

  page.on("pageerror", (err) => {
    const msg = err.message;
    const isAllowlisted = CONSOLE_ERROR_ALLOWLIST.some((pattern) =>
      msg.includes(pattern)
    );
    if (!isAllowlisted) pageErrors.push(msg);
  });

  page.on("response", (response) => {
    const status = response.status();
    const url = response.url();
    if (status < 400) return;

    // Fully allowlisted URLs — ignore all HTTP errors
    const isFullyAllowlisted = NETWORK_ALLOWLIST.some((pattern) =>
      url.includes(pattern)
    );
    if (isFullyAllowlisted) return;

    // 4xx-only allowlist — let 5xx through as genuine failures
    const is4xxAllowlisted =
      status < 500 &&
      NETWORK_4XX_ALLOWLIST.some((pattern) => url.includes(pattern));
    if (is4xxAllowlisted) return;

    networkErrors.push({ url, status });
  });

  return { consoleErrors, networkErrors, pageErrors };
}

/**
 * Asserts that no errors were collected during page interaction.
 * Call **after** all page actions are complete.
 */
export function assertNoErrors(
  collectors: ErrorCollectors,
  route: string
): void {
  expect(
    collectors.consoleErrors,
    `Console errors on ${route}: ${collectors.consoleErrors.join("; ")}`
  ).toHaveLength(0);
  expect(
    collectors.pageErrors,
    `Page errors on ${route}: ${collectors.pageErrors.join("; ")}`
  ).toHaveLength(0);
  expect(
    collectors.networkErrors,
    `Network errors on ${route}: ${JSON.stringify(collectors.networkErrors)}`
  ).toHaveLength(0);
}

/* ═══════════════════════════════════════════════════════════════════════════
 *  ORCHESTRATOR
 * ═══════════════════════════════════════════════════════════════════════════ */

/**
 * Runs the appropriate set of invariant checks based on the route
 * and viewport.  The audit runner calls this once per route after
 * navigation and wait-for-idle.
 */
export async function runInvariantsForRoute(
  page: Page,
  route: string,
  options: RunInvariantsOptions
): Promise<void> {
  await checkGlobalInvariants(page, route);

  if (options.isMobile) await checkMobileInvariants(page, route);
  if (!options.isMobile) await checkDesktopInvariants(page, route);
  if (options.isProductPage) await checkProductInvariants(page, route);
  if (options.isRecipesPage) await checkRecipesInvariants(page, route);
  if (options.isSettingsPage) await checkSettingsInvariants(page, route);
  if (options.isAdminPage) await checkAdminInvariants(page, route);
}
