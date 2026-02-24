/**
 * Quality Gate — Screenshot Helper
 *
 * Shared utility for taking and organising full-page screenshots
 * produced by the mobile and desktop audit runners.
 *
 * @see https://github.com/ericsocrat/poland-food-db/issues/175
 */

import type { Page } from "@playwright/test";
import fs from "fs";
import path from "path";

const BASE_DIR = path.join("qa_screenshots", "latest");

/** ISO-ish timestamp for screenshot filenames: `YYYYMMDD_HHmmss` */
export function getTimestamp(): string {
  const now = new Date();
  const pad = (n: number) => String(n).padStart(2, "0");
  return `${now.getFullYear()}${pad(now.getMonth() + 1)}${pad(now.getDate())}_${pad(now.getHours())}${pad(now.getMinutes())}${pad(now.getSeconds())}`;
}

/**
 * Delete and recreate the screenshot directory for a viewport so
 * every run starts from a clean slate.
 */
export async function cleanScreenshotDir(
  viewport: "mobile" | "desktop"
): Promise<void> {
  const dir = path.join(BASE_DIR, viewport);
  if (fs.existsSync(dir)) {
    fs.rmSync(dir, { recursive: true });
  }
  fs.mkdirSync(dir, { recursive: true });
}

/**
 * Capture a full-page screenshot and save it with a deterministic name.
 *
 * @returns The absolute path to the saved screenshot file.
 */
export async function takeScreenshot(
  page: Page,
  viewport: "mobile" | "desktop",
  label: string
): Promise<string> {
  const timestamp = getTimestamp();
  const sanitizedLabel = label.replace(/[^a-z0-9_-]/gi, "-");
  const filename = `${timestamp}_${viewport}_${sanitizedLabel}.png`;
  const filepath = path.join(BASE_DIR, viewport, filename);
  await page.screenshot({ path: filepath, fullPage: true });
  return filepath;
}
