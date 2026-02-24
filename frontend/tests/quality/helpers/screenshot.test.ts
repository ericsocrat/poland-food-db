/**
 * Unit tests for the screenshot helper module.
 *
 * These tests mock `fs` and `page.screenshot` so they run without
 * Playwright browsers or a real filesystem.
 */

import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import type { Page } from "@playwright/test";
import fs from "fs";
import path from "path";

// Mock fs before importing the module under test
vi.mock("fs", () => ({
  default: {
    existsSync: vi.fn(),
    rmSync: vi.fn(),
    mkdirSync: vi.fn(),
  },
  existsSync: vi.fn(),
  rmSync: vi.fn(),
  mkdirSync: vi.fn(),
}));

import {
  getTimestamp,
  cleanScreenshotDir,
  takeScreenshot,
} from "../helpers/screenshot";

/* ── getTimestamp ─────────────────────────────────────────────────────────── */

describe("getTimestamp", () => {
  it("returns a string in YYYYMMDD_HHmmss format", () => {
    const ts = getTimestamp();
    expect(ts).toMatch(/^\d{8}_\d{6}$/);
  });

  it("pads single-digit months and days", () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date(2026, 0, 5, 3, 7, 9)); // Jan 5, 03:07:09
    expect(getTimestamp()).toBe("20260105_030709");
    vi.useRealTimers();
  });
});

/* ── cleanScreenshotDir ──────────────────────────────────────────────────── */

describe("cleanScreenshotDir", () => {
  beforeEach(() => {
    vi.mocked(fs.existsSync).mockReset();
    vi.mocked(fs.rmSync).mockReset();
    vi.mocked(fs.mkdirSync).mockReset();
  });

  it("removes and recreates the directory when it already exists", async () => {
    vi.mocked(fs.existsSync).mockReturnValue(true);
    await cleanScreenshotDir("mobile");

    const dir = path.join("qa_screenshots", "latest", "mobile");
    expect(fs.rmSync).toHaveBeenCalledWith(dir, { recursive: true });
    expect(fs.mkdirSync).toHaveBeenCalledWith(dir, { recursive: true });
  });

  it("only creates the directory when it does not exist", async () => {
    vi.mocked(fs.existsSync).mockReturnValue(false);
    await cleanScreenshotDir("desktop");

    expect(fs.rmSync).not.toHaveBeenCalled();
    const dir = path.join("qa_screenshots", "latest", "desktop");
    expect(fs.mkdirSync).toHaveBeenCalledWith(dir, { recursive: true });
  });
});

/* ── takeScreenshot ──────────────────────────────────────────────────────── */

describe("takeScreenshot", () => {
  const mockPage = {
    screenshot: vi.fn().mockResolvedValue(Buffer.from("")),
  } as unknown as Page;

  afterEach(() => {
    vi.mocked(mockPage.screenshot).mockReset();
  });

  it("calls page.screenshot with fullPage: true", async () => {
    await takeScreenshot(mockPage, "mobile", "login");
    expect(mockPage.screenshot).toHaveBeenCalledWith(
      expect.objectContaining({ fullPage: true })
    );
  });

  it("sanitizes label characters", async () => {
    const filepath = await takeScreenshot(
      mockPage,
      "mobile",
      "category/detail"
    );
    // Forward slash should be replaced with a dash
    expect(filepath).not.toContain("/detail");
    expect(filepath).toContain("category-detail");
  });

  it("returns a path inside qa_screenshots/latest/<viewport>/", async () => {
    const filepath = await takeScreenshot(mockPage, "desktop", "home");
    expect(filepath).toContain(
      path.join("qa_screenshots", "latest", "desktop")
    );
  });

  it("includes the viewport in the filename", async () => {
    const filepath = await takeScreenshot(mockPage, "mobile", "settings");
    const basename = path.basename(filepath);
    expect(basename).toMatch(/_mobile_/);
  });
});
