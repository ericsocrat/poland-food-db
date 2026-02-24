/**
 * Lighthouse CI — Desktop Configuration
 *
 * Runs Lighthouse against representative pages with desktop preset.
 * Uses a puppeteer login script for authenticated routes.
 *
 * Budget thresholds:
 *   Performance ≥ 90, Accessibility ≥ 95, Best Practices ≥ 90,
 *   CLS < 0.1  (No PWA enforcement on desktop)
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
        preset: "desktop",
        chromeFlags: "--no-sandbox --headless --disable-gpu",
        // Desktop uses default throttling (no simulated mobile throttling)
        skipAudits: ["uses-http2"],
      },
    },
    assert: {
      assertions: {
        "categories:performance": ["error", { minScore: 0.9 }],
        "categories:accessibility": ["error", { minScore: 0.95 }],
        "categories:best-practices": ["error", { minScore: 0.9 }],
        "cumulative-layout-shift": ["error", { maxNumericValue: 0.1 }],
      },
    },
    upload: {
      target: "filesystem",
      outputDir: "lighthouse-reports",
    },
  },
};
