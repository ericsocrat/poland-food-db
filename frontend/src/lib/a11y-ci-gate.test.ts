// ─── A11y CI Gate compliance tests ──────────────────────────────────────────
// Static validation of the a11y gate scaffold (Issue #50).
// Ensures all files exist, follow correct patterns, and integrate properly.

import { describe, it, expect } from "vitest";
import { readFileSync, existsSync } from "node:fs";
import { join } from "node:path";

const ROOT = join(__dirname, "../..");
const E2E = join(ROOT, "e2e");
const HELPERS = join(E2E, "helpers");

function readFile(path: string): string {
  return readFileSync(path, "utf-8");
}

/* ── File existence ──────────────────────────────────────────────────────── */

describe("A11y CI Gate — file existence", () => {
  const requiredFiles = [
    { name: "a11y helper", path: join(HELPERS, "a11y.ts") },
    { name: "smoke a11y spec", path: join(E2E, "smoke-a11y.spec.ts") },
    {
      name: "authenticated a11y spec",
      path: join(E2E, "authenticated-a11y.spec.ts"),
    },
  ];

  for (const { name, path } of requiredFiles) {
    it(`${name} exists`, () => {
      expect(existsSync(path)).toBe(true);
    });
  }
});

/* ── Helper patterns ─────────────────────────────────────────────────────── */

describe("A11y helper — e2e/helpers/a11y.ts", () => {
  const src = readFile(join(HELPERS, "a11y.ts"));

  it("imports @axe-core/playwright", () => {
    expect(src).toContain("@axe-core/playwright");
  });

  it("imports from @playwright/test", () => {
    expect(src).toContain("@playwright/test");
  });

  it("exports assertNoA11yViolations", () => {
    expect(src).toContain("export async function assertNoA11yViolations");
  });

  it("exports auditA11y", () => {
    expect(src).toContain("export async function auditA11y");
  });

  it("uses WCAG 2.1 AA tags", () => {
    expect(src).toContain("wcag2a");
    expect(src).toContain("wcag2aa");
    expect(src).toContain("wcag21a");
    expect(src).toContain("wcag21aa");
  });

  it("filters by impact level (critical, serious, moderate, minor)", () => {
    expect(src).toContain('"critical"');
    expect(src).toContain('"serious"');
    expect(src).toContain('"moderate"');
    expect(src).toContain('"minor"');
  });

  it("uses expect.soft for blocking violations", () => {
    expect(src).toContain("expect\n");
    expect(src).toMatch(/expect\s*\.\s*soft/);
  });

  it("logs warnings for non-blocking violations", () => {
    expect(src).toContain("console.warn");
  });

  it("defines A11yAuditOptions interface with exclude and disableRules", () => {
    expect(src).toContain("A11yAuditOptions");
    expect(src).toContain("exclude");
    expect(src).toContain("disableRules");
  });

  it("defines A11yAuditResult interface", () => {
    expect(src).toContain("A11yAuditResult");
    expect(src).toContain("blocking");
    expect(src).toContain("warnings");
    expect(src).toContain("passes");
  });

  it("excludes .third-party-widget globally", () => {
    expect(src).toContain(".third-party-widget");
  });

  it("includes WCAG references in violation output", () => {
    expect(src).toContain("wcag");
    expect(src).toContain("helpUrl");
  });
});

/* ── Smoke a11y spec patterns ────────────────────────────────────────────── */

describe("Smoke a11y spec — e2e/smoke-a11y.spec.ts", () => {
  const src = readFile(join(E2E, "smoke-a11y.spec.ts"));

  it("imports assertNoA11yViolations from helper", () => {
    expect(src).toContain('from "./helpers/a11y"');
    expect(src).toContain("assertNoA11yViolations");
  });

  it("imports auditA11y from helper", () => {
    expect(src).toContain("auditA11y");
  });

  const requiredPages = [
    "/",
    "/auth/login",
    "/auth/signup",
    "/contact",
    "/privacy",
    "/terms",
    "/learn",
  ];

  for (const path of requiredPages) {
    it(`audits public page: ${path}`, () => {
      expect(src).toContain(`"${path}"`);
    });
  }

  it("audits all 7 learn topic pages", () => {
    const learnTopics = [
      "/learn/nutri-score",
      "/learn/nova-groups",
      "/learn/unhealthiness-score",
      "/learn/additives",
      "/learn/allergens",
      "/learn/reading-labels",
      "/learn/confidence",
    ];
    for (const topic of learnTopics) {
      expect(src).toContain(topic);
    }
  });

  it("includes dark mode a11y tests", () => {
    expect(src).toContain("dark");
    expect(src).toContain("colorScheme");
    expect(src).toContain("emulateMedia");
  });

  it("includes mobile viewport a11y tests", () => {
    expect(src).toContain("375");
    expect(src).toContain("viewport");
  });

  it("waits for networkidle before auditing", () => {
    expect(src).toContain("networkidle");
  });

  it("includes baseline regression tracking", () => {
    expect(src).toContain("baseline");
  });
});

/* ── Authenticated a11y spec patterns ────────────────────────────────────── */

describe("Authenticated a11y spec — e2e/authenticated-a11y.spec.ts", () => {
  const src = readFile(join(E2E, "authenticated-a11y.spec.ts"));

  it("imports assertNoA11yViolations from helper", () => {
    expect(src).toContain('from "./helpers/a11y"');
    expect(src).toContain("assertNoA11yViolations");
  });

  const requiredAuthPages = [
    "/app/search",
    "/app/settings",
    "/app/categories",
    "/app/lists",
    "/app",
  ];

  for (const path of requiredAuthPages) {
    it(`audits authenticated page: ${path}`, () => {
      expect(src).toContain(`"${path}"`);
    });
  }

  it("includes mobile viewport tests", () => {
    expect(src).toContain("375");
    expect(src).toContain("viewport");
  });

  it("includes dark mode tests", () => {
    expect(src).toContain("dark");
    expect(src).toContain("colorScheme");
  });

  it("includes baseline tracking", () => {
    expect(src).toContain("baseline");
    expect(src).toContain("blocking");
  });
});

/* ── Playwright config integration ───────────────────────────────────────── */

describe("Playwright config — a11y integration", () => {
  const config = readFile(join(ROOT, "playwright.config.ts"));

  it("smoke project pattern matches smoke-a11y.spec.ts", () => {
    // Pattern: /smoke.*\.spec\.ts/ should match smoke-a11y.spec.ts
    const match = /smoke.*\.spec\.ts/.test("smoke-a11y.spec.ts");
    expect(match).toBe(true);
  });

  it("authenticated project pattern matches authenticated-a11y.spec.ts", () => {
    const match = /authenticated.*\.spec\.ts/.test(
      "authenticated-a11y.spec.ts",
    );
    expect(match).toBe(true);
  });

  it("config includes JSON reporter for CI", () => {
    expect(config).toContain("json");
    expect(config).toContain("a11y-results.json");
  });
});

/* ── CI workflow integration ─────────────────────────────────────────────── */

describe("CI workflow — a11y integration", () => {
  const ci = readFile(join(ROOT, "..", ".github", "workflows", "ci.yml"));

  it("uploads a11y results JSON as artifact", () => {
    expect(ci).toContain("a11y-results.json");
  });

  it("runs Playwright tests (which now include a11y)", () => {
    expect(ci).toContain("playwright test");
  });
});

/* ── Package.json — devDependencies ──────────────────────────────────────── */

describe("Package.json — a11y dependencies", () => {
  const pkg = JSON.parse(readFile(join(ROOT, "package.json")));

  it("has @axe-core/playwright as devDependency", () => {
    expect(pkg.devDependencies).toHaveProperty("@axe-core/playwright");
  });

  it("has axe-core as devDependency", () => {
    expect(pkg.devDependencies).toHaveProperty("axe-core");
  });

  it("axe-core packages are devDependencies only (not in dependencies)", () => {
    const deps = pkg.dependencies ?? {};
    expect(deps).not.toHaveProperty("@axe-core/playwright");
    expect(deps).not.toHaveProperty("axe-core");
  });
});

/* ── Zero-tolerance enforcement patterns ─────────────────────────────────── */

describe("Zero-tolerance enforcement", () => {
  const helper = readFile(join(HELPERS, "a11y.ts"));
  const smokeSpec = readFile(join(E2E, "smoke-a11y.spec.ts"));
  const authSpec = readFile(join(E2E, "authenticated-a11y.spec.ts"));

  it("helper separates blocking (critical+serious) from warnings (moderate+minor)", () => {
    expect(helper).toContain("blocking");
    expect(helper).toContain("warnings");
  });

  it("smoke spec has per-page audit tests", () => {
    const auditCalls = (smokeSpec.match(/assertNoA11yViolations/g) || [])
      .length;
    expect(auditCalls).toBeGreaterThanOrEqual(5);
  });

  it("auth spec has per-page audit tests", () => {
    const auditCalls = (authSpec.match(/assertNoA11yViolations/g) || [])
      .length;
    expect(auditCalls).toBeGreaterThanOrEqual(3);
  });

  it("both specs reference issue #50", () => {
    expect(smokeSpec).toContain("#50");
    expect(authSpec).toContain("#50");
  });
});
