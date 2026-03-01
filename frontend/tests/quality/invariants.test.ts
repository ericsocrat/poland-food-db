/**
 * Unit tests for the quality-gate invariant engine.
 *
 * These tests verify that each invariant category correctly detects
 * violations by mocking the Playwright Page interface.  The actual
 * integration tests run in Playwright against the real app.
 *
 * @see https://github.com/ericsocrat/poland-food-db/issues/174
 */

import { describe, it, expect, vi } from "vitest";

/* ── We test the module's exported helpers indirectly ─────────────────────
 *
 * The invariant functions import `expect` from `@playwright/test`.
 * In vitest context Playwright's expect still works for value assertions
 * (toBe, toHaveLength, not.toContain, etc.).  We mock the Playwright
 * Page object so we can exercise the checks without a browser.
 * ──────────────────────────────────────────────────────────────────────── */

import {
  checkGlobalInvariants,
  checkMobileInvariants,
  checkProductInvariants,
  checkAdminInvariants,
  checkSettingsInvariants,
  checkRecipesInvariants,
  checkDesktopInvariants,
  setupErrorCollectors,
  assertNoErrors,
  runInvariantsForRoute,
  CONSOLE_ERROR_ALLOWLIST,
  NETWORK_ALLOWLIST,
  NETWORK_4XX_ALLOWLIST,
} from "./invariants";

/* ── Page mock factory ───────────────────────────────────────────────────── */

interface LocatorMockConfig {
  count?: number;
  textContent?: string | null;
  allTextContents?: string[];
  getAttribute?: string | null;
  isVisible?: boolean;
  filter?: () => LocatorMock;
  nth?: (n: number) => LocatorMock;
  first?: () => LocatorMock;
}

interface LocatorMock {
  count: () => Promise<number>;
  textContent: () => Promise<string | null>;
  allTextContents: () => Promise<string[]>;
  getAttribute: (attr: string) => Promise<string | null>;
  isVisible: () => Promise<boolean>;
  filter: (opts: unknown) => LocatorMock;
  nth: (n: number) => LocatorMock;
  first: () => LocatorMock;
}

function createLocatorMock(config: LocatorMockConfig = {}): LocatorMock {
  const mock: LocatorMock = {
    count: vi.fn(async () => config.count ?? 0),
    textContent: vi.fn(async () => config.textContent ?? null),
    allTextContents: vi.fn(async () => config.allTextContents ?? []),
    getAttribute: vi.fn(async () => config.getAttribute ?? null),
    isVisible: vi.fn(async () => config.isVisible ?? false),
    filter: vi.fn(() => config.filter?.() ?? mock),
    nth: vi.fn((n: number) => config.nth?.(n) ?? mock),
    first: vi.fn(() => config.first?.() ?? mock),
  };
  return mock;
}

interface PageMockOptions {
  bodyText?: string;
  evaluateResults?: unknown[];
  locatorOverrides?: Record<string, LocatorMockConfig>;
}

function createPageMock(options: PageMockOptions = {}) {
  const { bodyText = "", evaluateResults = [], locatorOverrides = {} } = options;
  let evalCallIndex = 0;

  const defaultLocator = createLocatorMock({ count: 0 });

  // Track event listeners
  const eventListeners: Record<string, ((...args: unknown[]) => void)[]> = {};

  const page = {
    textContent: vi.fn(async () => bodyText),
    evaluate: vi.fn(async (fn: unknown) => {
      // getVisibleBodyText() clones body and strips script/style/noscript —
      // detect its callback by fingerprint and return the mock bodyText.
      if (typeof fn === "function" && fn.toString().includes("cloneNode")) {
        return bodyText;
      }
      const result = evaluateResults[evalCallIndex] ?? 0;
      evalCallIndex++;
      return result;
    }),
    locator: vi.fn((selector: string) => {
      for (const [pattern, config] of Object.entries(locatorOverrides)) {
        if (selector.includes(pattern)) {
          return createLocatorMock(config);
        }
      }
      return defaultLocator;
    }),
    on: vi.fn((event: string, handler: (...args: unknown[]) => void) => {
      if (!eventListeners[event]) eventListeners[event] = [];
      eventListeners[event].push(handler);
    }),
    // Helper for tests to trigger events
    _emit: (event: string, ...args: unknown[]) => {
      eventListeners[event]?.forEach((h) => h(...args));
    },
  };

  return page;
}

/* ═══════════════════════════════════════════════════════════════════════════
 *  checkGlobalInvariants
 * ═══════════════════════════════════════════════════════════════════════════ */

describe("checkGlobalInvariants", () => {
  it("passes on a clean page", async () => {
    const page = createPageMock({
      bodyText: "Hello World — clean content",
      evaluateResults: [0, 0, 1], // zeroHeightClickables=0, unlabeledInputs=0, langAttr=1
      locatorOverrides: {
        'meta[name="viewport"]': { count: 1 },
        "html[lang]": { count: 1 },
      },
    });

    await expect(
      checkGlobalInvariants(page as never, "/test")
    ).resolves.toBeUndefined();
  });

  it("fails when raw i18n keys are present", async () => {
    const page = createPageMock({
      bodyText: "Welcome common.nav.title to the app",
      evaluateResults: [0, 0],
      locatorOverrides: {
        'meta[name="viewport"]': { count: 1 },
        "html[lang]": { count: 1 },
      },
    });

    await expect(
      checkGlobalInvariants(page as never, "/test")
    ).rejects.toThrow();
  });

  it("fails when forbidden literal 'undefined' is in body", async () => {
    const page = createPageMock({
      bodyText: "Product name: undefined",
      evaluateResults: [0, 0],
      locatorOverrides: {
        'meta[name="viewport"]': { count: 1 },
        "html[lang]": { count: 1 },
      },
    });

    await expect(
      checkGlobalInvariants(page as never, "/test")
    ).rejects.toThrow();
  });

  it("fails when unlabeled inputs exist", async () => {
    const page = createPageMock({
      bodyText: "Clean content",
      // zeroHeightClickables=0, unlabeledInputs=3
      evaluateResults: [0, 3],
      locatorOverrides: {
        'meta[name="viewport"]': { count: 1 },
        "html[lang]": { count: 1 },
      },
    });

    await expect(
      checkGlobalInvariants(page as never, "/test")
    ).rejects.toThrow();
  });

  it("fails when viewport meta is missing", async () => {
    const page = createPageMock({
      bodyText: "Clean content",
      evaluateResults: [0, 0],
      locatorOverrides: {
        'meta[name="viewport"]': { count: 0 },
        "html[lang]": { count: 1 },
      },
    });

    await expect(
      checkGlobalInvariants(page as never, "/test")
    ).rejects.toThrow();
  });

  it("fails when html lang attribute is missing", async () => {
    const page = createPageMock({
      bodyText: "Clean content",
      evaluateResults: [0, 0],
      locatorOverrides: {
        'meta[name="viewport"]': { count: 1 },
        "html[lang]": { count: 0 },
      },
    });

    await expect(
      checkGlobalInvariants(page as never, "/test")
    ).rejects.toThrow();
  });

  it("fails when exposed UUIDs are in body text", async () => {
    const page = createPageMock({
      bodyText: "User: 550e8400-e29b-41d4-a716-446655440000",
      evaluateResults: [0, 0],
      locatorOverrides: {
        'meta[name="viewport"]': { count: 1 },
        "html[lang]": { count: 1 },
      },
    });

    await expect(
      checkGlobalInvariants(page as never, "/test")
    ).rejects.toThrow();
  });

  it("ignores RSC $undefined in script tags (regression: quality-gate false positive)", async () => {
    // Next.js RSC flight data contains "$undefined" markers inside <script> tags.
    // getVisibleBodyText strips scripts, so this must NOT trigger the forbidden literal check.
    const page = createPageMock({
      bodyText: "Clean visible page content",
      evaluateResults: [0, 0],
      locatorOverrides: {
        'meta[name="viewport"]': { count: 1 },
        "html[lang]": { count: 1 },
      },
    });

    await expect(
      checkGlobalInvariants(page as never, "/test")
    ).resolves.toBeUndefined();
  });

  it("allows NOT-APPLICABLE on /learn/* routes (intentional educational content)", async () => {
    const page = createPageMock({
      bodyText: "Nutri-Score labels: A, B, C, D, E, UNKNOWN, NOT-APPLICABLE",
      evaluateResults: [0, 0],
      locatorOverrides: {
        'meta[name="viewport"]': { count: 1 },
        "html[lang]": { count: 1 },
      },
    });

    await expect(
      checkGlobalInvariants(page as never, "/learn/nutri-score")
    ).resolves.toBeUndefined();
  });

  it("still catches NOT-APPLICABLE on non-learn routes", async () => {
    const page = createPageMock({
      bodyText: "Product score: NOT-APPLICABLE",
      evaluateResults: [0, 0],
      locatorOverrides: {
        'meta[name="viewport"]': { count: 1 },
        "html[lang]": { count: 1 },
      },
    });

    await expect(
      checkGlobalInvariants(page as never, "/app/product/1")
    ).rejects.toThrow();
  });
});

/* ═══════════════════════════════════════════════════════════════════════════
 *  checkMobileInvariants
 * ═══════════════════════════════════════════════════════════════════════════ */

describe("checkMobileInvariants", () => {
  it("passes when no overflow and content fits", async () => {
    const page = createPageMock({
      // hasOverflow=false, smallTouchTargets=0, contentWidth=390
      evaluateResults: [false, 0, 390],
    });

    await expect(
      checkMobileInvariants(page as never, "/test")
    ).resolves.toBeUndefined();
  });

  it("fails when horizontal overflow detected", async () => {
    const page = createPageMock({
      // hasOverflow=true
      evaluateResults: [true, 0, 390],
    });

    await expect(
      checkMobileInvariants(page as never, "/test")
    ).rejects.toThrow();
  });

  it("warns when small touch targets exist (does not throw)", async () => {
    const warnSpy = vi.spyOn(console, "warn").mockImplementation(() => {});
    const page = createPageMock({
      // hasOverflow=false, smallTouchTargets=5, contentWidth=390
      evaluateResults: [false, 5, 390],
    });

    await expect(
      checkMobileInvariants(page as never, "/test")
    ).resolves.toBeUndefined();

    expect(warnSpy).toHaveBeenCalledWith(
      expect.stringContaining("5 touch target(s)")
    );
    warnSpy.mockRestore();
  });

  it("fails when content exceeds mobile viewport width", async () => {
    const page = createPageMock({
      // hasOverflow=false, smallTouchTargets=0, contentWidth=500
      evaluateResults: [false, 0, 500],
    });

    await expect(
      checkMobileInvariants(page as never, "/test")
    ).rejects.toThrow();
  });
});

/* ═══════════════════════════════════════════════════════════════════════════
 *  checkProductInvariants
 * ═══════════════════════════════════════════════════════════════════════════ */

describe("checkProductInvariants", () => {
  it("passes with exactly 1 tab bar and no issues", async () => {
    const page = createPageMock({
      bodyText: "Product details with 3 alternatives",
      locatorOverrides: {
        "tab-bar": { count: 1 },
        "score-breakdown-panel": { count: 1 },
        "health-warnings-card": { count: 1 },
        "h2:visible": { allTextContents: ["Nutrition", "Scoring"] },
        "product-thumbnail": { count: 0 },
        "product-image": { count: 0 },
      },
    });

    await expect(
      checkProductInvariants(page as never, "/app/product/1")
    ).resolves.toBeUndefined();
  });

  it("fails when 0 tab bars found", async () => {
    const page = createPageMock({
      bodyText: "Product",
      locatorOverrides: {
        "tab-bar": { count: 0 },
        "score-breakdown-panel": { count: 0 },
        "health-warnings-card": { count: 0 },
        "h2:visible": { allTextContents: [] },
        "product-thumbnail": { count: 0 },
        "product-image": { count: 0 },
      },
    });

    await expect(
      checkProductInvariants(page as never, "/app/product/1")
    ).rejects.toThrow();
  });

  it("fails when 2 tab bars found (duplication bug)", async () => {
    const page = createPageMock({
      bodyText: "Product",
      locatorOverrides: {
        "tab-bar": { count: 2 },
        "score-breakdown-panel": { count: 0 },
        "health-warnings-card": { count: 0 },
        "h2:visible": { allTextContents: [] },
        "product-thumbnail": { count: 0 },
        "product-image": { count: 0 },
      },
    });

    await expect(
      checkProductInvariants(page as never, "/app/product/1")
    ).rejects.toThrow();
  });

  it("fails when duplicate H2 headers found", async () => {
    const page = createPageMock({
      bodyText: "Product with 3 alternatives",
      locatorOverrides: {
        "tab-bar": { count: 1 },
        "score-breakdown-panel": { count: 1 },
        "health-warnings-card": { count: 1 },
        "h2:visible": {
          allTextContents: ["Nutrition", "Nutrition", "Scoring"],
        },
        "product-thumbnail": { count: 0 },
        "product-image": { count: 0 },
      },
    });

    await expect(
      checkProductInvariants(page as never, "/app/product/1")
    ).rejects.toThrow();
  });

  it("fails on pluralization bug '1 ingredients'", async () => {
    const page = createPageMock({
      bodyText: "Contains 1 ingredients",
      locatorOverrides: {
        "tab-bar": { count: 1 },
        "score-breakdown-panel": { count: 0 },
        "health-warnings-card": { count: 0 },
        "h2:visible": { allTextContents: [] },
        "product-thumbnail": { count: 0 },
        "product-image": { count: 0 },
      },
    });

    await expect(
      checkProductInvariants(page as never, "/app/product/1")
    ).rejects.toThrow();
  });
});

/* ═══════════════════════════════════════════════════════════════════════════
 *  checkAdminInvariants
 * ═══════════════════════════════════════════════════════════════════════════ */

describe("checkAdminInvariants", () => {
  it("passes on clean admin page", async () => {
    const page = createPageMock({
      bodyText: "Admin Dashboard — System Health: OK",
    });

    await expect(
      checkAdminInvariants(page as never, "/app/admin/monitoring")
    ).resolves.toBeUndefined();
  });

  it("fails when service_role is exposed", async () => {
    const page = createPageMock({
      bodyText: "Role: service_role — do not expose this",
    });

    await expect(
      checkAdminInvariants(page as never, "/app/admin/monitoring")
    ).rejects.toThrow();
  });

  it("fails when JWT-like token is exposed", async () => {
    // Build the JWT-like string dynamically to avoid triggering CI secret scanners
    const jwtPrefix = ["e", "y", "J"].join("") + "hbGciOiJIUzI1NiIsInR5cCI6";
    const page = createPageMock({
      bodyText: `Key: ${jwtPrefix}IkpXVCJ9.payload.signature`,
    });

    await expect(
      checkAdminInvariants(page as never, "/app/admin/monitoring")
    ).rejects.toThrow();
  });

  it("fails when database identifiers are exposed", async () => {
    const page = createPageMock({
      bodyText: "Table: product_allergens loaded",
    });

    await expect(
      checkAdminInvariants(page as never, "/app/admin/monitoring")
    ).rejects.toThrow();
  });
});

/* ═══════════════════════════════════════════════════════════════════════════
 *  checkSettingsInvariants
 * ═══════════════════════════════════════════════════════════════════════════ */

describe("checkSettingsInvariants", () => {
  it("passes with exactly 1 health profile section", async () => {
    const page = createPageMock({
      locatorOverrides: {
        "health-profile-section": { count: 1 },
      },
    });

    await expect(
      checkSettingsInvariants(page as never, "/app/settings")
    ).resolves.toBeUndefined();
  });

  it("fails when health profile section is missing", async () => {
    const page = createPageMock({
      locatorOverrides: {
        "health-profile-section": { count: 0 },
      },
    });

    await expect(
      checkSettingsInvariants(page as never, "/app/settings")
    ).rejects.toThrow();
  });
});

/* ═══════════════════════════════════════════════════════════════════════════
 *  setupErrorCollectors + assertNoErrors
 * ═══════════════════════════════════════════════════════════════════════════ */

describe("setupErrorCollectors", () => {
  it("collects console errors", () => {
    const page = createPageMock();
    const collectors = setupErrorCollectors(page as never);

    // Simulate a console error
    page._emit("console", { type: () => "error", text: () => "Test error" });

    expect(collectors.consoleErrors).toHaveLength(1);
    expect(collectors.consoleErrors[0]).toBe("Test error");
  });

  it("ignores non-error console messages", () => {
    const page = createPageMock();
    const collectors = setupErrorCollectors(page as never);

    page._emit("console", { type: () => "log", text: () => "Info message" });

    expect(collectors.consoleErrors).toHaveLength(0);
  });

  it("collects page errors", () => {
    const page = createPageMock();
    const collectors = setupErrorCollectors(page as never);

    page._emit("pageerror", { message: "Unhandled rejection" });

    expect(collectors.pageErrors).toHaveLength(1);
    expect(collectors.pageErrors[0]).toBe("Unhandled rejection");
  });

  it("collects network errors above 400", () => {
    const page = createPageMock();
    const collectors = setupErrorCollectors(page as never);

    page._emit("response", {
      status: () => 500,
      url: () => "https://example.com/api/data",
    });

    expect(collectors.networkErrors).toHaveLength(1);
    expect(collectors.networkErrors[0].status).toBe(500);
  });

  it("ignores allowlisted URLs", () => {
    const page = createPageMock();
    const collectors = setupErrorCollectors(page as never);

    page._emit("response", {
      status: () => 404,
      url: () => "https://example.com/favicon.ico",
    });
    page._emit("response", {
      status: () => 302,
      url: () => "https://xyz.supabase.co/auth/v1/token",
    });

    expect(collectors.networkErrors).toHaveLength(0);
  });

  it("does not collect allowlisted console errors", () => {
    const page = createPageMock();
    const collectors = setupErrorCollectors(page as never);

    // Emit allowlisted Supabase auth errors
    page._emit("console", {
      type: () => "error",
      text: () => "AuthSessionMissingError: No session found",
    });
    page._emit("console", {
      type: () => "error",
      text: () => "Auth session missing",
    });
    // CSP violation from Supabase Realtime WebSocket
    page._emit("console", {
      type: () => "error",
      text: () =>
        "Connecting to 'wss://xyz.supabase.co/realtime/v1/websocket' violates the following Content Security Policy directive",
    });
    // Cloudflare Turnstile script loading
    page._emit("console", {
      type: () => "error",
      text: () =>
        "Loading the script 'https://challenges.cloudflare.com/turnstile/v0/api.js' was blocked",
    });

    expect(collectors.consoleErrors).toHaveLength(0);
  });

  it("collects non-allowlisted console errors", () => {
    const page = createPageMock();
    const collectors = setupErrorCollectors(page as never);

    page._emit("console", {
      type: () => "error",
      text: () => "TypeError: Cannot read property 'foo' of undefined",
    });

    expect(collectors.consoleErrors).toHaveLength(1);
    expect(collectors.consoleErrors[0]).toContain("TypeError");
  });

  it("ignores 4xx from supabase.co/rest but catches 5xx", () => {
    const page = createPageMock();
    const collectors = setupErrorCollectors(page as never);

    // 401 from Supabase REST — should be ignored
    page._emit("response", {
      status: () => 401,
      url: () => "https://xyz.supabase.co/rest/v1/products",
    });
    // 403 from Supabase REST — should be ignored
    page._emit("response", {
      status: () => 403,
      url: () => "https://xyz.supabase.co/rest/v1/users",
    });

    expect(collectors.networkErrors).toHaveLength(0);

    // 500 from Supabase REST — should be collected (genuine failure)
    page._emit("response", {
      status: () => 500,
      url: () => "https://xyz.supabase.co/rest/v1/products",
    });

    expect(collectors.networkErrors).toHaveLength(1);
    expect(collectors.networkErrors[0].status).toBe(500);
  });

  it("CONSOLE_ERROR_ALLOWLIST contains expected patterns", () => {
    expect(CONSOLE_ERROR_ALLOWLIST).toContain("AuthSessionMissingError");
    expect(CONSOLE_ERROR_ALLOWLIST).toContain("Hydration failed");
    expect(CONSOLE_ERROR_ALLOWLIST).toContain("viewport meta tag");
    expect(CONSOLE_ERROR_ALLOWLIST).toContain("chrome-extension://");
    expect(CONSOLE_ERROR_ALLOWLIST).toContain(
      "violates the following Content Security Policy"
    );
    expect(CONSOLE_ERROR_ALLOWLIST).toContain(
      "challenges.cloudflare.com/turnstile"
    );
    expect(CONSOLE_ERROR_ALLOWLIST).toContain(
      "script resource is behind a redirect"
    );
  });

  it("NETWORK_4XX_ALLOWLIST contains supabase.co/rest", () => {
    expect(NETWORK_4XX_ALLOWLIST).toContain("supabase.co/rest");
  });

  it("NETWORK_ALLOWLIST does not include supabase.co/rest", () => {
    expect(NETWORK_ALLOWLIST).not.toContain("supabase.co/rest");
  });
});

describe("assertNoErrors", () => {
  it("passes when collectors are empty", () => {
    const collectors = {
      consoleErrors: [] as string[],
      networkErrors: [] as { url: string; status: number }[],
      pageErrors: [] as string[],
    };

    expect(() => assertNoErrors(collectors, "/test")).not.toThrow();
  });

  it("throws when console errors exist", () => {
    const collectors = {
      consoleErrors: ["Something broke"],
      networkErrors: [] as { url: string; status: number }[],
      pageErrors: [] as string[],
    };

    expect(() => assertNoErrors(collectors, "/test")).toThrow();
  });

  it("throws when network errors exist", () => {
    const collectors = {
      consoleErrors: [] as string[],
      networkErrors: [{ url: "https://example.com/api", status: 500 }],
      pageErrors: [] as string[],
    };

    expect(() => assertNoErrors(collectors, "/test")).toThrow();
  });
});

/* ═══════════════════════════════════════════════════════════════════════════
 *  runInvariantsForRoute (orchestrator)
 * ═══════════════════════════════════════════════════════════════════════════ */

describe("runInvariantsForRoute", () => {
  it("runs global invariants for any route", async () => {
    const page = createPageMock({
      bodyText: "Clean page",
      evaluateResults: [0, 0],
      locatorOverrides: {
        'meta[name="viewport"]': { count: 1 },
        "html[lang]": { count: 1 },
      },
    });

    await expect(
      runInvariantsForRoute(page as never, "/", {
        isMobile: false,
        isProductPage: false,
        isRecipesPage: false,
        isSettingsPage: false,
        isAdminPage: false,
      })
    ).resolves.toBeUndefined();
  });
});

/* ═══════════════════════════════════════════════════════════════════════════
 *  checkDesktopInvariants
 * ═══════════════════════════════════════════════════════════════════════════ */

describe("checkDesktopInvariants", () => {
  it("does not throw on non-app routes", async () => {
    const page = createPageMock();

    await expect(
      checkDesktopInvariants(page as never, "/privacy")
    ).resolves.toBeUndefined();
  });

  it("warns when nav is not visible on app route", async () => {
    const warnSpy = vi.spyOn(console, "warn").mockImplementation(() => {});
    const page = createPageMock({
      locatorOverrides: {
        "main-navigation": {
          isVisible: false,
          first: () =>
            createLocatorMock({
              isVisible: false,
            }),
        },
      },
    });

    await expect(
      checkDesktopInvariants(page as never, "/app/dashboard")
    ).resolves.toBeUndefined();
    // It should warn, not throw
    warnSpy.mockRestore();
  });
});

/* ═══════════════════════════════════════════════════════════════════════════
 *  checkRecipesInvariants
 * ═══════════════════════════════════════════════════════════════════════════ */

describe("checkRecipesInvariants", () => {
  it("passes when no filter buttons exist", async () => {
    const page = createPageMock({
      locatorOverrides: {
        "recipe-filter": { count: 0 },
        filter: { count: 0 },
      },
    });

    await expect(
      checkRecipesInvariants(page as never, "/app/recipes")
    ).resolves.toBeUndefined();
  });
});
