/**
 * Lighthouse CI Budget — Configuration Validation Tests
 *
 * Verifies that both mobile and desktop Lighthouse CI configs
 * are structurally correct, have matching URLs, enforce the
 * required budget thresholds, and align with the route manifest.
 *
 * @see https://github.com/ericsocrat/tryvit/issues/177
 */

import { describe, expect, it } from "vitest";
import { getLighthouseRoutes } from "./routes";

/* ── Load configs ────────────────────────────────────────────────────────── */

// eslint-disable-next-line @typescript-eslint/no-require-imports
const mobileConfig = require("../../lighthouserc.mobile.js");
// eslint-disable-next-line @typescript-eslint/no-require-imports
const desktopConfig = require("../../lighthouserc.desktop.js");

/* ── Helpers ─────────────────────────────────────────────────────────────── */

function getUrls(config: { ci: { collect: { url: string[] } } }): string[] {
  return config.ci.collect.url;
}

function getAssertions(
  config: Record<string, unknown>
): Record<string, unknown> {
  return (config as { ci: { assert: { assertions: Record<string, unknown> } } })
    .ci.assert.assertions;
}

function getSettings(config: Record<string, unknown>): Record<string, unknown> {
  return (config as { ci: { collect: { settings: Record<string, unknown> } } })
    .ci.collect.settings;
}

/* ── Structure Tests ─────────────────────────────────────────────────────── */

describe("Lighthouse CI Configuration", () => {
  describe("Mobile config structure", () => {
    it("has ci.collect.url array", () => {
      expect(Array.isArray(getUrls(mobileConfig))).toBe(true);
      expect(getUrls(mobileConfig).length).toBeGreaterThanOrEqual(3);
    });

    it("runs 3 times per URL for stability", () => {
      expect(mobileConfig.ci.collect.numberOfRuns).toBe(3);
    });

    it("starts the server automatically", () => {
      expect(mobileConfig.ci.collect.startServerCommand).toBe(
        "cd frontend && npm run start -- -p 3000"
      );
      expect(mobileConfig.ci.collect.startServerReadyPattern).toBe(
        "Ready in"
      );
      expect(mobileConfig.ci.collect.startServerReadyTimeout).toBe(30000);
    });

    it("uses puppeteer auth script", () => {
      expect(mobileConfig.ci.collect.puppeteerScript).toBe(
        "./frontend/tests/quality/lighthouse-auth.js"
      );
    });

    it("uses mobile formFactor", () => {
      expect(getSettings(mobileConfig).formFactor).toBe("mobile");
    });

    it("runs only performance, accessibility, and best-practices categories", () => {
      expect(getSettings(mobileConfig).onlyCategories).toEqual([
        "performance",
        "accessibility",
        "best-practices",
      ]);
    });

    it("applies simulated throttling", () => {
      const throttling = getSettings(mobileConfig).throttling as Record<
        string,
        number
      >;
      expect(throttling.cpuSlowdownMultiplier).toBe(4);
      expect(throttling.requestLatencyMs).toBe(150);
      expect(throttling.downloadThroughputKbps).toBe(1600);
      expect(throttling.uploadThroughputKbps).toBe(750);
    });

    it("saves reports to filesystem", () => {
      expect(mobileConfig.ci.upload.target).toBe("filesystem");
      expect(mobileConfig.ci.upload.outputDir).toBe("lighthouse-reports");
    });
  });

  describe("Desktop config structure", () => {
    it("has ci.collect.url array", () => {
      expect(Array.isArray(getUrls(desktopConfig))).toBe(true);
      expect(getUrls(desktopConfig).length).toBeGreaterThanOrEqual(3);
    });

    it("runs 3 times per URL for stability", () => {
      expect(desktopConfig.ci.collect.numberOfRuns).toBe(3);
    });

    it("starts the server automatically", () => {
      expect(desktopConfig.ci.collect.startServerCommand).toBe(
        "cd frontend && npm run start -- -p 3000"
      );
      expect(desktopConfig.ci.collect.startServerReadyPattern).toBe(
        "Ready in"
      );
      expect(desktopConfig.ci.collect.startServerReadyTimeout).toBe(30000);
    });

    it("uses puppeteer auth script", () => {
      expect(desktopConfig.ci.collect.puppeteerScript).toBe(
        "./frontend/tests/quality/lighthouse-auth.js"
      );
    });

    it("uses desktop formFactor", () => {
      expect(getSettings(desktopConfig).formFactor).toBe("desktop");
    });

    it("runs only performance, accessibility, and best-practices categories", () => {
      expect(getSettings(desktopConfig).onlyCategories).toEqual([
        "performance",
        "accessibility",
        "best-practices",
      ]);
    });

    it("configures desktop screen emulation", () => {
      const screen = getSettings(desktopConfig).screenEmulation as Record<string, unknown>;
      expect(screen.mobile).toBe(false);
      expect(screen.width).toBe(1350);
      expect(screen.height).toBe(940);
    });

    it("does NOT apply simulated mobile throttling", () => {
      const throttling = getSettings(desktopConfig).throttling;
      expect(throttling).toBeUndefined();
    });

    it("saves reports to filesystem", () => {
      expect(desktopConfig.ci.upload.target).toBe("filesystem");
      expect(desktopConfig.ci.upload.outputDir).toBe("lighthouse-reports");
    });
  });

  /* ── URL Alignment ───────────────────────────────────────────────────── */

  describe("URL alignment", () => {
    it("mobile and desktop configs audit the same URLs", () => {
      expect(getUrls(mobileConfig)).toEqual(getUrls(desktopConfig));
    });

    it("URLs match the route manifest lighthouse routes", () => {
      const lighthouseRoutes = getLighthouseRoutes();
      const configUrls = getUrls(mobileConfig).map((url: string) =>
        new URL(url).pathname
      );
      const manifestPaths = lighthouseRoutes.map((r) => r.path);

      // Every manifest lighthouse route should be in the config
      for (const path of manifestPaths) {
        expect(configUrls).toContain(path);
      }
      // Every config URL should be in the manifest
      for (const path of configUrls) {
        expect(manifestPaths).toContain(path);
      }
    });

    it("audits exactly 3 representative pages", () => {
      expect(getUrls(mobileConfig).length).toBe(3);
    });
  });

  /* ── Budget Enforcement ──────────────────────────────────────────────── */

  describe("Mobile budgets", () => {
    const assertions = getAssertions(mobileConfig);

    it("enforces performance >= 0.85", () => {
      expect(assertions["categories:performance"]).toEqual([
        "error",
        { minScore: 0.85 },
      ]);
    });

    it("enforces accessibility >= 0.95", () => {
      expect(assertions["categories:accessibility"]).toEqual([
        "error",
        { minScore: 0.95 },
      ]);
    });

    it("enforces best-practices >= 0.90", () => {
      expect(assertions["categories:best-practices"]).toEqual([
        "error",
        { minScore: 0.9 },
      ]);
    });

    it("enforces CLS < 0.1", () => {
      expect(assertions["cumulative-layout-shift"]).toEqual([
        "error",
        { maxNumericValue: 0.1 },
      ]);
    });

    it("all assertions use error level (not warn)", () => {
      for (const [, value] of Object.entries(assertions)) {
        expect((value as [string, unknown])[0]).toBe("error");
      }
    });
  });

  describe("Desktop budgets", () => {
    const assertions = getAssertions(desktopConfig);

    it("enforces performance >= 0.90 (stricter than mobile)", () => {
      expect(assertions["categories:performance"]).toEqual([
        "error",
        { minScore: 0.9 },
      ]);
    });

    it("enforces accessibility >= 0.95", () => {
      expect(assertions["categories:accessibility"]).toEqual([
        "error",
        { minScore: 0.95 },
      ]);
    });

    it("enforces best-practices >= 0.90", () => {
      expect(assertions["categories:best-practices"]).toEqual([
        "error",
        { minScore: 0.9 },
      ]);
    });

    it("enforces CLS < 0.1", () => {
      expect(assertions["cumulative-layout-shift"]).toEqual([
        "error",
        { maxNumericValue: 0.1 },
      ]);
    });

    it("all assertions use error level (not warn)", () => {
      for (const [, value] of Object.entries(assertions)) {
        expect((value as [string, unknown])[0]).toBe("error");
      }
    });
  });
});
