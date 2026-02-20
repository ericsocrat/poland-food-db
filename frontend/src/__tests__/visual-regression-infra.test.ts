/**
 * Meta-tests for the visual regression infrastructure.
 * Validates that helpers, config, and test files are correctly wired.
 *
 * Issue #70 — Visual Regression Baseline
 */

import { describe, it, expect } from "vitest";
import * as fs from "node:fs";
import * as path from "node:path";

/* ── Helper module ───────────────────────────────────────────────────────── */

describe("Visual regression helper (e2e/helpers/visual.ts)", () => {
  it("helper file exists", () => {
    const helperPath = path.resolve(__dirname, "../../e2e/helpers/visual.ts");
    expect(fs.existsSync(helperPath)).toBe(true);
  });

  it("exports assertScreenshot function", async () => {
    // Dynamic import of the TypeScript source isn't possible in Vitest
    // without the E2E tsconfig, so we verify the file content instead.
    const helperPath = path.resolve(__dirname, "../../e2e/helpers/visual.ts");
    const content = fs.readFileSync(helperPath, "utf-8");

    expect(content).toContain("export async function assertScreenshot");
    expect(content).toContain("export function buildTestMatrix");
    expect(content).toContain("export const VIEWPORTS");
    expect(content).toContain("export const THEMES");
  });

  it("assertScreenshot sets viewport and color scheme", () => {
    const helperPath = path.resolve(__dirname, "../../e2e/helpers/visual.ts");
    const content = fs.readFileSync(helperPath, "utf-8");

    expect(content).toContain("setViewportSize");
    expect(content).toContain("emulateMedia");
    expect(content).toContain("colorScheme");
    expect(content).toContain("reducedMotion");
  });

  it("VIEWPORTS includes desktop and mobile", () => {
    const helperPath = path.resolve(__dirname, "../../e2e/helpers/visual.ts");
    const content = fs.readFileSync(helperPath, "utf-8");

    // Desktop: 1280×720
    expect(content).toContain("1280");
    expect(content).toContain("720");
    // Mobile: 375×812
    expect(content).toContain("375");
    expect(content).toContain("812");
  });

  it("THEMES includes light and dark", () => {
    const helperPath = path.resolve(__dirname, "../../e2e/helpers/visual.ts");
    const content = fs.readFileSync(helperPath, "utf-8");

    expect(content).toContain('"light"');
    expect(content).toContain('"dark"');
  });

  it("masks dynamic content to prevent false diffs", () => {
    const helperPath = path.resolve(__dirname, "../../e2e/helpers/visual.ts");
    const content = fs.readFileSync(helperPath, "utf-8");

    expect(content).toContain("mask");
    expect(content).toContain("maskLocators");
  });
});

/* ── Playwright config ───────────────────────────────────────────────────── */

describe("Playwright config (visual regression)", () => {
  it("playwright.config.ts exists", () => {
    const configPath = path.resolve(__dirname, "../../playwright.config.ts");
    expect(fs.existsSync(configPath)).toBe(true);
  });

  it("config includes toHaveScreenshot settings", () => {
    const configPath = path.resolve(__dirname, "../../playwright.config.ts");
    const content = fs.readFileSync(configPath, "utf-8");

    expect(content).toContain("toHaveScreenshot");
    expect(content).toContain("maxDiffPixelRatio");
    expect(content).toContain("animations");
  });

  it("config includes snapshotPathTemplate for __screenshots__", () => {
    const configPath = path.resolve(__dirname, "../../playwright.config.ts");
    const content = fs.readFileSync(configPath, "utf-8");

    expect(content).toContain("snapshotPathTemplate");
    expect(content).toContain("__screenshots__");
  });

  it("config gates visual projects behind VISUAL_REGRESSION env var", () => {
    const configPath = path.resolve(__dirname, "../../playwright.config.ts");
    const content = fs.readFileSync(configPath, "utf-8");

    expect(content).toContain("VISUAL_REGRESSION");
    expect(content).toContain("visual-smoke");
    expect(content).toContain("visual-authenticated");
  });

  it("smoke project excludes visual specs via negative lookahead", () => {
    const configPath = path.resolve(__dirname, "../../playwright.config.ts");
    const content = fs.readFileSync(configPath, "utf-8");

    // Smoke project uses negative lookahead to exclude visual tests
    expect(content).toMatch(/smoke\(\?!.*visual\)/);
  });
});

/* ── Test files ──────────────────────────────────────────────────────────── */

describe("Visual regression test files", () => {
  it("smoke-visual.spec.ts exists", () => {
    const specPath = path.resolve(
      __dirname,
      "../../e2e/smoke-visual.spec.ts",
    );
    expect(fs.existsSync(specPath)).toBe(true);
  });

  it("authenticated-visual.spec.ts exists", () => {
    const specPath = path.resolve(
      __dirname,
      "../../e2e/authenticated-visual.spec.ts",
    );
    expect(fs.existsSync(specPath)).toBe(true);
  });

  it("smoke-visual covers public pages in both themes", () => {
    const specPath = path.resolve(
      __dirname,
      "../../e2e/smoke-visual.spec.ts",
    );
    const content = fs.readFileSync(specPath, "utf-8");

    // Public pages
    expect(content).toContain("landing");
    expect(content).toContain("login");
    expect(content).toContain("signup");
    expect(content).toContain("contact");
    expect(content).toContain("privacy");
    expect(content).toContain("terms");

    // Uses buildTestMatrix (which covers both themes + both viewports)
    expect(content).toContain("buildTestMatrix");
  });

  it("authenticated-visual covers all required app pages", () => {
    const specPath = path.resolve(
      __dirname,
      "../../e2e/authenticated-visual.spec.ts",
    );
    const content = fs.readFileSync(specPath, "utf-8");

    // Issue #70 required pages
    expect(content).toContain("dashboard");
    expect(content).toContain("search");
    expect(content).toContain("product");
    expect(content).toContain("compare");
    expect(content).toContain("settings");
    expect(content).toContain("categories");
    expect(content).toContain("lists");

    // Uses buildTestMatrix
    expect(content).toContain("buildTestMatrix");
  });

  it("authenticated-visual masks dynamic content", () => {
    const specPath = path.resolve(
      __dirname,
      "../../e2e/authenticated-visual.spec.ts",
    );
    const content = fs.readFileSync(specPath, "utf-8");

    // Common dynamic elements must be masked
    expect(content).toContain("timestamp");
    expect(content).toContain("avatar");
    expect(content).toContain("user-email");
  });
});

/* ── .gitattributes ──────────────────────────────────────────────────────── */

describe(".gitattributes (screenshot baselines)", () => {
  it(".gitattributes marks screenshots as binary", () => {
    const gaPath = path.resolve(__dirname, "../../.gitattributes");
    expect(fs.existsSync(gaPath)).toBe(true);

    const content = fs.readFileSync(gaPath, "utf-8");
    expect(content).toContain("__screenshots__");
    expect(content).toContain("binary");
  });
});
