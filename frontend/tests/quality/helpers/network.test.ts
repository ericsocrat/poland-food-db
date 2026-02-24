/**
 * Unit tests for the network helper module.
 *
 * Uses Vitest mocks to simulate Playwright Page behaviour.
 */

import { describe, it, expect, vi } from "vitest";
import type { Page, Locator } from "@playwright/test";
import { waitForStable, waitForTestId } from "../helpers/network";

/* ── helpers ─────────────────────────────────────────────────────────────── */

function createMockPage(overrides: Partial<Page> = {}): Page {
  return {
    waitForLoadState: vi.fn().mockResolvedValue(undefined),
    waitForTimeout: vi.fn().mockResolvedValue(undefined),
    getByTestId: vi.fn(),
    ...overrides,
  } as unknown as Page;
}

function createMockLocator(visible: boolean): Locator {
  return {
    first: vi.fn().mockReturnValue({
      waitFor: visible
        ? vi.fn().mockResolvedValue(undefined)
        : vi.fn().mockRejectedValue(new Error("Timeout")),
    }),
  } as unknown as Locator;
}

/* ── waitForStable ───────────────────────────────────────────────────────── */

describe("waitForStable", () => {
  it("resolves via networkidle when available", async () => {
    const page = createMockPage();
    await waitForStable(page);

    expect(page.waitForLoadState).toHaveBeenCalledWith("networkidle", {
      timeout: 8_000,
    });
  });

  it("falls back to domcontentloaded + timeout when networkidle throws", async () => {
    const page = createMockPage({
      waitForLoadState: vi
        .fn()
        .mockRejectedValueOnce(new Error("Timeout"))
        .mockResolvedValue(undefined),
    } as unknown as Partial<Page>);

    await waitForStable(page, 1_000, 500);

    expect(page.waitForLoadState).toHaveBeenCalledWith("networkidle", {
      timeout: 1_000,
    });
    expect(page.waitForLoadState).toHaveBeenCalledWith("domcontentloaded");
    expect(page.waitForTimeout).toHaveBeenCalledWith(500);
  });

  it("uses custom timeout and fallback values", async () => {
    const page = createMockPage({
      waitForLoadState: vi
        .fn()
        .mockRejectedValueOnce(new Error("Timeout"))
        .mockResolvedValue(undefined),
    } as unknown as Partial<Page>);

    await waitForStable(page, 5_000, 3_000);

    expect(page.waitForLoadState).toHaveBeenCalledWith("networkidle", {
      timeout: 5_000,
    });
    expect(page.waitForTimeout).toHaveBeenCalledWith(3_000);
  });
});

/* ── waitForTestId ───────────────────────────────────────────────────────── */

describe("waitForTestId", () => {
  it("returns true when the element appears", async () => {
    const locator = createMockLocator(true);
    const page = createMockPage({
      getByTestId: vi.fn().mockReturnValue(locator),
    } as unknown as Partial<Page>);

    const result = await waitForTestId(page, "tab-bar");
    expect(result).toBe(true);
  });

  it("returns false when the element does not appear in time", async () => {
    const locator = createMockLocator(false);
    const page = createMockPage({
      getByTestId: vi.fn().mockReturnValue(locator),
    } as unknown as Partial<Page>);

    const result = await waitForTestId(page, "missing-element", 1_000);
    expect(result).toBe(false);
  });

  it("passes the correct timeout to waitFor", async () => {
    const waitForFn = vi.fn().mockResolvedValue(undefined);
    const locator = {
      first: vi.fn().mockReturnValue({ waitFor: waitForFn }),
    } as unknown as Locator;
    const page = createMockPage({
      getByTestId: vi.fn().mockReturnValue(locator),
    } as unknown as Partial<Page>);

    await waitForTestId(page, "tab-bar", 5_000);
    expect(waitForFn).toHaveBeenCalledWith({
      state: "visible",
      timeout: 5_000,
    });
  });
});
