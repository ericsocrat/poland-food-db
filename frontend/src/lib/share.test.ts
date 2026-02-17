import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { shareProduct, shareUrl } from "./share";

// ─── Mock toast ─────────────────────────────────────────────────────────────

vi.mock("@/lib/toast", () => ({
  showToast: vi.fn(),
}));

import { showToast } from "@/lib/toast";

// ─── Helpers ────────────────────────────────────────────────────────────────

const MOCK_PRODUCT = {
  product_name: "Skyr Naturalny",
  brand: "Piątnica",
  unhealthiness_score: 9,
  product_id: 42,
};

beforeEach(() => {
  vi.clearAllMocks();
  // Default origin
  Object.defineProperty(window, "location", {
    value: { origin: "https://food.test" },
    writable: true,
  });
});

afterEach(() => {
  // Remove share/canShare mocks
  Object.defineProperty(navigator, "share", { value: undefined, writable: true, configurable: true });
  Object.defineProperty(navigator, "canShare", { value: undefined, writable: true, configurable: true });
});

// ─── shareProduct ───────────────────────────────────────────────────────────

describe("shareProduct", () => {
  it("calls navigator.share when available", async () => {
    const shareFn = vi.fn().mockResolvedValue(undefined);
    Object.defineProperty(navigator, "share", { value: shareFn, writable: true, configurable: true });
    Object.defineProperty(navigator, "canShare", {
      value: () => true,
      writable: true,
      configurable: true,
    });

    await shareProduct(MOCK_PRODUCT);

    expect(shareFn).toHaveBeenCalledWith(
      expect.objectContaining({
        title: "Skyr Naturalny — Health Score 9/100",
        url: "https://food.test/app/product/42",
      }),
    );
  });

  it("falls back to clipboard when share is unavailable", async () => {
    Object.defineProperty(navigator, "share", { value: undefined, writable: true, configurable: true });
    const writeText = vi.fn().mockResolvedValue(undefined);
    Object.defineProperty(navigator, "clipboard", {
      value: { writeText },
      writable: true,
      configurable: true,
    });

    await shareProduct(MOCK_PRODUCT);

    expect(writeText).toHaveBeenCalledWith("https://food.test/app/product/42");
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ type: "success", messageKey: "export.linkCopied" }),
    );
  });

  it("falls back to clipboard when canShare returns false", async () => {
    const shareFn = vi.fn();
    Object.defineProperty(navigator, "share", { value: shareFn, writable: true, configurable: true });
    Object.defineProperty(navigator, "canShare", {
      value: () => false,
      writable: true,
      configurable: true,
    });
    const writeText = vi.fn().mockResolvedValue(undefined);
    Object.defineProperty(navigator, "clipboard", {
      value: { writeText },
      writable: true,
      configurable: true,
    });

    await shareProduct(MOCK_PRODUCT);

    expect(shareFn).not.toHaveBeenCalled();
    expect(writeText).toHaveBeenCalled();
  });

  it("falls back to clipboard when share throws (non-abort)", async () => {
    const shareFn = vi.fn().mockRejectedValue(new Error("share failed"));
    Object.defineProperty(navigator, "share", { value: shareFn, writable: true, configurable: true });
    Object.defineProperty(navigator, "canShare", {
      value: () => true,
      writable: true,
      configurable: true,
    });
    const writeText = vi.fn().mockResolvedValue(undefined);
    Object.defineProperty(navigator, "clipboard", {
      value: { writeText },
      writable: true,
      configurable: true,
    });

    await shareProduct(MOCK_PRODUCT);

    expect(writeText).toHaveBeenCalled();
  });

  it("silently returns when user aborts share sheet", async () => {
    const err = new DOMException("user dismissed", "AbortError");
    const shareFn = vi.fn().mockRejectedValue(err);
    Object.defineProperty(navigator, "share", { value: shareFn, writable: true, configurable: true });
    Object.defineProperty(navigator, "canShare", {
      value: () => true,
      writable: true,
      configurable: true,
    });

    await shareProduct(MOCK_PRODUCT);

    // Should NOT fall back to clipboard
    expect(showToast).not.toHaveBeenCalled();
  });
});

// ─── shareUrl ───────────────────────────────────────────────────────────────

describe("shareUrl", () => {
  it("calls navigator.share for URLs", async () => {
    const shareFn = vi.fn().mockResolvedValue(undefined);
    Object.defineProperty(navigator, "share", { value: shareFn, writable: true, configurable: true });

    await shareUrl("https://food.test/list/abc", "My List");

    expect(shareFn).toHaveBeenCalledWith(
      expect.objectContaining({
        title: "My List",
        url: "https://food.test/list/abc",
      }),
    );
  });

  it("falls back to clipboard for URLs", async () => {
    Object.defineProperty(navigator, "share", { value: undefined, writable: true, configurable: true });
    const writeText = vi.fn().mockResolvedValue(undefined);
    Object.defineProperty(navigator, "clipboard", {
      value: { writeText },
      writable: true,
      configurable: true,
    });

    await shareUrl("https://food.test/list/abc");

    expect(writeText).toHaveBeenCalledWith("https://food.test/list/abc");
  });
});
