// ─── Unit tests for comparison OG image helper functions ─────────────────────
// Tests the pure functions exported from opengraph-image.tsx.
// The full image generation is an integration concern (needs edge runtime).

import React from "react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { getScoreColor, truncate } from "./opengraph-image";

// Make React available globally for JSX in the tested module
vi.stubGlobal("React", React);

// Mock next/og — ImageResponse is used with `new`
vi.mock("next/og", () => {
  const ImageResponseMock = vi.fn().mockImplementation(function (this: Response) {
    return new Response();
  });
  return { ImageResponse: ImageResponseMock };
});

/* ── getScoreColor ─────────────────────────────────────────────────────── */
describe("comparison opengraph-image helpers", () => {
  describe("getScoreColor", () => {
    it.each([
      [0, "#22c55e"],
      [10, "#22c55e"],
      [20, "#22c55e"],
      [21, "#eab308"],
      [40, "#eab308"],
      [41, "#f97316"],
      [60, "#f97316"],
      [61, "#ef4444"],
      [80, "#ef4444"],
      [81, "#991b1b"],
      [100, "#991b1b"],
    ])("score %i → %s", (score: number, expected: string) => {
      expect(getScoreColor(score)).toBe(expected);
    });
  });

  /* ── truncate ──────────────────────────────────────────────────────────── */
  describe("truncate", () => {
    it("returns text unchanged when shorter than max", () => {
      expect(truncate("hello", 10)).toBe("hello");
    });

    it("returns text unchanged when exactly at max", () => {
      expect(truncate("hello", 5)).toBe("hello");
    });

    it("truncates with ellipsis when text exceeds max", () => {
      const result = truncate("A very long product name indeed", 15);
      expect(result).toHaveLength(15);
      expect(result).toMatch(/…$/);
    });

    it("preserves full text at boundary", () => {
      expect(truncate("abc", 3)).toBe("abc");
    });
  });

  /* ── module exports ────────────────────────────────────────────────────── */
  describe("module exports", () => {
    beforeEach(() => {
      vi.resetModules();
      vi.stubGlobal(
        "fetch",
        vi.fn().mockResolvedValue({
          arrayBuffer: () => Promise.resolve(new ArrayBuffer(8)),
        }),
      );
    });

    it("exports correct size (1200×630)", async () => {
      const mod = await import("./opengraph-image");
      expect(mod.size).toEqual({ width: 1200, height: 630 });
    });

    it("exports png content type", async () => {
      const mod = await import("./opengraph-image");
      expect(mod.contentType).toBe("image/png");
    });

    it("exports alt text for comparison", async () => {
      const mod = await import("./opengraph-image");
      expect(mod.alt).toContain("comparison");
    });

    it("exports a revalidate value", async () => {
      const mod = await import("./opengraph-image");
      expect(mod.revalidate).toBeGreaterThan(0);
    });

    it("default export is a function", async () => {
      const mod = await import("./opengraph-image");
      expect(typeof mod.default).toBe("function");
    });
  });
});
