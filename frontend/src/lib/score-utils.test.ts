import { describe, it, expect } from "vitest";
import { getScoreBand, getAllBands } from "@/lib/score-utils";

// ─── getScoreBand — 5-band mapping ─────────────────────────────────────────

describe("getScoreBand", () => {
  // ─── Green band (1–20) ──────────────────────────────────────────────────

  it("maps score 1 to green band", () => {
    const result = getScoreBand(1);
    expect(result).toEqual({
      band: "green",
      label: "Low",
      color: "var(--color-score-green)",
      bgColor: "bg-score-green/10",
      textColor: "text-score-green-text",
    });
  });

  it("maps score 10 to green band", () => {
    expect(getScoreBand(10)?.band).toBe("green");
  });

  it("maps score 20 to green band (upper boundary)", () => {
    expect(getScoreBand(20)?.band).toBe("green");
    expect(getScoreBand(20)?.label).toBe("Low");
  });

  // ─── Yellow band (21–40) ────────────────────────────────────────────────

  it("maps score 21 to yellow band (lower boundary)", () => {
    expect(getScoreBand(21)?.band).toBe("yellow");
    expect(getScoreBand(21)?.label).toBe("Moderate");
  });

  it("maps score 30 to yellow band", () => {
    expect(getScoreBand(30)?.band).toBe("yellow");
  });

  it("maps score 40 to yellow band (upper boundary)", () => {
    expect(getScoreBand(40)?.band).toBe("yellow");
  });

  // ─── Orange band (41–60) ────────────────────────────────────────────────

  it("maps score 41 to orange band (lower boundary)", () => {
    expect(getScoreBand(41)?.band).toBe("orange");
    expect(getScoreBand(41)?.label).toBe("High");
  });

  it("maps score 50 to orange band", () => {
    expect(getScoreBand(50)?.band).toBe("orange");
  });

  it("maps score 60 to orange band (upper boundary)", () => {
    expect(getScoreBand(60)?.band).toBe("orange");
  });

  // ─── Red band (61–80) ──────────────────────────────────────────────────

  it("maps score 61 to red band (lower boundary)", () => {
    expect(getScoreBand(61)?.band).toBe("red");
    expect(getScoreBand(61)?.label).toBe("Very High");
  });

  it("maps score 70 to red band", () => {
    expect(getScoreBand(70)?.band).toBe("red");
  });

  it("maps score 80 to red band (upper boundary)", () => {
    expect(getScoreBand(80)?.band).toBe("red");
  });

  // ─── Dark red band (81–100) ─────────────────────────────────────────────

  it("maps score 81 to darkred band (lower boundary)", () => {
    expect(getScoreBand(81)?.band).toBe("darkred");
    expect(getScoreBand(81)?.label).toBe("Extreme");
  });

  it("maps score 90 to darkred band", () => {
    expect(getScoreBand(90)?.band).toBe("darkred");
  });

  it("maps score 100 to darkred band (upper boundary)", () => {
    expect(getScoreBand(100)?.band).toBe("darkred");
  });

  // ─── Invalid / edge cases ──────────────────────────────────────────────

  it("returns null for score 0 (below valid range)", () => {
    expect(getScoreBand(0)).toBeNull();
  });

  it("returns null for score 101 (above valid range)", () => {
    expect(getScoreBand(101)).toBeNull();
  });

  it("returns null for NaN", () => {
    expect(getScoreBand(NaN)).toBeNull();
  });

  it("returns null for null score", () => {
    expect(getScoreBand(null)).toBeNull();
  });

  it("returns null for undefined score", () => {
    expect(getScoreBand(undefined)).toBeNull();
  });

  it("returns null for negative score", () => {
    expect(getScoreBand(-5)).toBeNull();
  });

  it("returns null for Infinity", () => {
    expect(getScoreBand(Infinity)).toBeNull();
  });

  // ─── Return shape verification ─────────────────────────────────────────

  it("returns all required keys", () => {
    const result = getScoreBand(50);
    expect(result).toHaveProperty("band");
    expect(result).toHaveProperty("label");
    expect(result).toHaveProperty("color");
    expect(result).toHaveProperty("bgColor");
    expect(result).toHaveProperty("textColor");
  });

  it("returns CSS variable for color", () => {
    const result = getScoreBand(50);
    expect(result?.color).toMatch(/^var\(--color-score-/);
  });

  it("returns Tailwind bg class for bgColor", () => {
    const result = getScoreBand(50);
    expect(result?.bgColor).toMatch(/^bg-score-/);
  });

  it("returns Tailwind text class for textColor", () => {
    const result = getScoreBand(50);
    expect(result?.textColor).toMatch(/^text-score-/);
  });
});

// ─── getAllBands ─────────────────────────────────────────────────────────────

describe("getAllBands", () => {
  it("returns exactly 5 bands", () => {
    expect(getAllBands()).toHaveLength(5);
  });

  it("returns bands in order: green → darkred", () => {
    const bands = getAllBands().map((b) => b.band);
    expect(bands).toEqual(["green", "yellow", "orange", "red", "darkred"]);
  });

  it("each band has all required keys", () => {
    for (const band of getAllBands()) {
      expect(band).toHaveProperty("band");
      expect(band).toHaveProperty("label");
      expect(band).toHaveProperty("color");
      expect(band).toHaveProperty("bgColor");
      expect(band).toHaveProperty("textColor");
    }
  });

  it("returns immutable array", () => {
    const a = getAllBands();
    const b = getAllBands();
    expect(a).toEqual(b);
  });
});
