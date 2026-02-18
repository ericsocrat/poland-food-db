// ─── Unit tests for OG image helper functions ────────────────────────────────
// Tests the pure functions exported from opengraph-image.tsx.
// The full image generation is an integration concern (needs edge runtime).

import { getScoreColor, getScoreBandLabel, truncate } from "./opengraph-image";

describe("opengraph-image helpers", () => {
  /* ── getScoreColor ─────────────────────────────────────────────────────── */
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

  /* ── getScoreBandLabel ─────────────────────────────────────────────────── */
  describe("getScoreBandLabel", () => {
    it.each([
      ["low", "Low Risk"],
      ["moderate", "Moderate Risk"],
      ["high", "High Risk"],
      ["very_high", "Very High Risk"],
      ["unknown", ""],
    ])("band '%s' → '%s'", (band: string, expected: string) => {
      expect(getScoreBandLabel(band)).toBe(expected);
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
});
