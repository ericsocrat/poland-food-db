import { describe, it, expect } from "vitest";
import { nutriScoreLabel } from "./nutri-label";

describe("nutriScoreLabel", () => {
  it.each(["A", "B", "C", "D", "E"])("passes through valid grade %s", (g) => {
    expect(nutriScoreLabel(g)).toBe(g);
  });

  it.each(["a", "b", "c", "d", "e"])(
    "normalises lowercase grade %s to uppercase",
    (g) => {
      expect(nutriScoreLabel(g)).toBe(g.toUpperCase());
    },
  );

  it('maps "NOT-APPLICABLE" to default fallback "N/A"', () => {
    expect(nutriScoreLabel("NOT-APPLICABLE")).toBe("N/A");
  });

  it("maps unknown values to default fallback", () => {
    expect(nutriScoreLabel("UNKNOWN")).toBe("N/A");
    expect(nutriScoreLabel("X")).toBe("N/A");
  });

  it("uses custom fallback when provided", () => {
    expect(nutriScoreLabel("NOT-APPLICABLE", "Not Rated")).toBe("Not Rated");
    expect(nutriScoreLabel("NOT-APPLICABLE", "?")).toBe("?");
  });

  it("returns fallback for null", () => {
    expect(nutriScoreLabel(null)).toBe("N/A");
  });

  it("returns fallback for undefined", () => {
    expect(nutriScoreLabel(undefined)).toBe("N/A");
  });

  it("returns fallback for empty string", () => {
    expect(nutriScoreLabel("")).toBe("N/A");
  });
});
