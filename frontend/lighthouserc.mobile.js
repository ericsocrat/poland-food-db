/**
 * Lighthouse CI — Mobile Configuration
 *
 * Runs Lighthouse against representative pages with mobile throttling.
 * Uses a puppeteer login script for authenticated routes.
 *
 * Budget thresholds:
 *   Performance ≥ 85, Accessibility ≥ 95, Best Practices ≥ 90,
 *   PWA ≥ 90, CLS < 0.1
 *
 * @see https://github.com/ericsocrat/poland-food-db/issues/177
 */

const QA_PRODUCT_ID = process.env.QA_PRODUCT_ID ?? "1";

module.exports = {
  ci: {
    collect: {
      url: [
        "http://localhost:3000/auth/login",
        "http://localhost:3000/app",
        `http://localhost:3000/app/product/${QA_PRODUCT_ID}`,
      ],
      numberOfRuns: 3,
      puppeteerScript: "./tests/quality/lighthouse-auth.js",
      puppeteerLaunchOptions: {
        args: ["--no-sandbox", "--disable-gpu"],
      },
      settings: {
        preset: "perf",
        chromeFlags: "--no-sandbox --headless --disable-gpu",
        throttling: {
          cpuSlowdownMultiplier: 4,
          requestLatencyMs: 150,
          downloadThroughputKbps: 1600,
          uploadThroughputKbps: 750,
        },
        // Suppress noisy audits that vary across CI runners
        skipAudits: ["uses-http2"],
      },
    },
    assert: {
      assertions: {
        "categories:performance": ["error", { minScore: 0.85 }],
        "categories:accessibility": ["error", { minScore: 0.95 }],
        "categories:best-practices": ["error", { minScore: 0.9 }],
        "categories:pwa": ["error", { minScore: 0.9 }],
        "cumulative-layout-shift": ["error", { maxNumericValue: 0.1 }],
      },
    },
    upload: {
      target: "filesystem",
      outputDir: "lighthouse-reports",
    },
  },
};
