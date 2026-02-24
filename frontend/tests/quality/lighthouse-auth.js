/**
 * Lighthouse CI — Puppeteer Authentication Script
 *
 * Logs in before Lighthouse runs so authenticated routes
 * (dashboard, product detail) are accessible. Lighthouse CI
 * calls this script once and reuses the browser session with
 * cookies for all subsequent URL collections.
 *
 * Environment variables:
 *   QA_TEST_EMAIL    — login email   (required for auth routes)
 *   QA_TEST_PASSWORD — login password (required for auth routes)
 *
 * If credentials are not set, the script skips login gracefully.
 * Non-auth routes (e.g., /auth/login) will still be audited.
 *
 * @see https://github.com/ericsocrat/poland-food-db/issues/177
 */

/* eslint-disable @typescript-eslint/no-require-imports */

const LOGIN_URL = "http://localhost:3000/auth/login";

module.exports = async (browser) => {
  const email = process.env.QA_TEST_EMAIL;
  const password = process.env.QA_TEST_PASSWORD;

  // Skip login if credentials are not provided — non-auth routes still work
  if (!email || !password) {
    // eslint-disable-next-line no-console
    console.log(
      "[lighthouse-auth] QA_TEST_EMAIL / QA_TEST_PASSWORD not set — skipping login"
    );
    return;
  }

  const page = await browser.newPage();

  try {
    await page.goto(LOGIN_URL, { waitUntil: "networkidle0", timeout: 30000 });

    // Fill in the login form (selectors match LoginForm.tsx)
    await page.type("#email", email);
    await page.type("#password", password);
    await page.click('[type="submit"]');

    // Wait for navigation to complete (redirect to /app after login)
    await page.waitForNavigation({
      waitUntil: "networkidle0",
      timeout: 15000,
    });

    // eslint-disable-next-line no-console
    console.log("[lighthouse-auth] Successfully logged in");
  } catch (err) {
    // eslint-disable-next-line no-console
    console.warn("[lighthouse-auth] Login failed:", err.message);
  } finally {
    await page.close();
  }
};
