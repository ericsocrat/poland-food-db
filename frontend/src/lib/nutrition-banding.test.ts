import { describe, it, expect } from "vitest";
import {
  getNutritionBand,
  NUTRITION_THRESHOLDS,
  BENEFICIAL_NUTRIENTS,
  type NutritionBand,
} from "./nutrition-banding";

// ─── Threshold constant assertions ──────────────────────────────────────────

describe("NUTRITION_THRESHOLDS", () => {
  it("defines thresholds for all expected nutrients", () => {
    const expected = [
      "total_fat",
      "saturated_fat",
      "sugars",
      "salt",
      "fibre",
      "fiber",
      "protein",
    ];
    for (const nutrient of expected) {
      expect(NUTRITION_THRESHOLDS[nutrient]).toBeDefined();
      expect(NUTRITION_THRESHOLDS[nutrient].low).toBeGreaterThan(0);
      expect(NUTRITION_THRESHOLDS[nutrient].high).toBeGreaterThan(
        NUTRITION_THRESHOLDS[nutrient].low,
      );
    }
  });

  it("fibre and fiber have identical thresholds", () => {
    expect(NUTRITION_THRESHOLDS.fibre).toEqual(NUTRITION_THRESHOLDS.fiber);
  });

  // EU Regulation 1924/2006 reference thresholds
  it("fibre high threshold is 6g (EU Reg 1924/2006 'high fibre')", () => {
    expect(NUTRITION_THRESHOLDS.fibre.high).toBe(6);
  });

  it("total_fat thresholds match FSA guidance (low ≤3g, high ≥17.5g)", () => {
    expect(NUTRITION_THRESHOLDS.total_fat).toEqual({ low: 3, high: 17.5 });
  });
});

describe("BENEFICIAL_NUTRIENTS", () => {
  it("includes fibre, fiber, and protein", () => {
    expect(BENEFICIAL_NUTRIENTS.has("fibre")).toBe(true);
    expect(BENEFICIAL_NUTRIENTS.has("fiber")).toBe(true);
    expect(BENEFICIAL_NUTRIENTS.has("protein")).toBe(true);
  });

  it("does not include harmful nutrients", () => {
    expect(BENEFICIAL_NUTRIENTS.has("sugars")).toBe(false);
    expect(BENEFICIAL_NUTRIENTS.has("salt")).toBe(false);
    expect(BENEFICIAL_NUTRIENTS.has("total_fat")).toBe(false);
    expect(BENEFICIAL_NUTRIENTS.has("saturated_fat")).toBe(false);
  });
});

// ─── getNutritionBand: edge cases ───────────────────────────────────────────

describe("getNutritionBand", () => {
  // ── Null / undefined / zero / negative → "none" ─────────────────────
  it("returns 'none' for null value", () => {
    expect(getNutritionBand("sugars", null)).toBe("none");
  });

  it("returns 'none' for undefined value", () => {
    expect(getNutritionBand("sugars", undefined)).toBe("none");
  });

  it("returns 'none' for 0g (core bug: was returning 'low' or 'high')", () => {
    expect(getNutritionBand("sugars", 0)).toBe("none");
    expect(getNutritionBand("fibre", 0)).toBe("none");
    expect(getNutritionBand("total_fat", 0)).toBe("none");
    expect(getNutritionBand("salt", 0)).toBe("none");
    expect(getNutritionBand("saturated_fat", 0)).toBe("none");
    expect(getNutritionBand("protein", 0)).toBe("none");
  });

  it("returns 'none' for negative values", () => {
    expect(getNutritionBand("sugars", -1)).toBe("none");
    expect(getNutritionBand("fibre", -0.5)).toBe("none");
  });

  it("returns 'none' for unknown nutrient key", () => {
    expect(getNutritionBand("unknown_nutrient", 50)).toBe("none");
    expect(getNutritionBand("", 10)).toBe("none");
  });

  // ── Total fat: low ≤3, medium 3–17.5, high ≥17.5 ───────────────────

  describe("total_fat", () => {
    it("below low threshold → 'low'", () => {
      expect(getNutritionBand("total_fat", 1)).toBe("low");
      expect(getNutritionBand("total_fat", 2.5)).toBe("low");
    });

    it("exact low threshold (3g) → 'low'", () => {
      expect(getNutritionBand("total_fat", 3)).toBe("low");
    });

    it("between thresholds → 'medium'", () => {
      expect(getNutritionBand("total_fat", 3.1)).toBe("medium");
      expect(getNutritionBand("total_fat", 10)).toBe("medium");
      expect(getNutritionBand("total_fat", 17.4)).toBe("medium");
    });

    it("exact high threshold (17.5g) → 'high'", () => {
      expect(getNutritionBand("total_fat", 17.5)).toBe("high");
    });

    it("above high threshold → 'high'", () => {
      expect(getNutritionBand("total_fat", 18)).toBe("high");
      expect(getNutritionBand("total_fat", 50)).toBe("high");
    });
  });

  // ── Saturated fat: low ≤1.5, medium 1.5–5, high ≥5 ─────────────────

  describe("saturated_fat", () => {
    it("below low threshold → 'low'", () => {
      expect(getNutritionBand("saturated_fat", 0.5)).toBe("low");
    });

    it("exact low threshold (1.5g) → 'low'", () => {
      expect(getNutritionBand("saturated_fat", 1.5)).toBe("low");
    });

    it("between thresholds → 'medium'", () => {
      expect(getNutritionBand("saturated_fat", 2)).toBe("medium");
      expect(getNutritionBand("saturated_fat", 4.9)).toBe("medium");
    });

    it("exact high threshold (5g) → 'high'", () => {
      expect(getNutritionBand("saturated_fat", 5)).toBe("high");
    });

    it("above high threshold → 'high'", () => {
      expect(getNutritionBand("saturated_fat", 7)).toBe("high");
    });
  });

  // ── Sugars: low ≤5, medium 5–22.5, high ≥22.5 ──────────────────────

  describe("sugars", () => {
    it("below low threshold → 'low'", () => {
      expect(getNutritionBand("sugars", 2)).toBe("low");
    });

    it("exact low threshold (5g) → 'low'", () => {
      expect(getNutritionBand("sugars", 5)).toBe("low");
    });

    it("between thresholds → 'medium'", () => {
      expect(getNutritionBand("sugars", 10)).toBe("medium");
      expect(getNutritionBand("sugars", 22.4)).toBe("medium");
    });

    it("exact high threshold (22.5g) → 'high'", () => {
      expect(getNutritionBand("sugars", 22.5)).toBe("high");
    });

    it("above high threshold → 'high'", () => {
      expect(getNutritionBand("sugars", 30)).toBe("high");
    });
  });

  // ── Salt: low ≤0.3, medium 0.3–1.5, high ≥1.5 ─────────────────────

  describe("salt", () => {
    it("below low threshold → 'low'", () => {
      expect(getNutritionBand("salt", 0.1)).toBe("low");
    });

    it("exact low threshold (0.3g) → 'low'", () => {
      expect(getNutritionBand("salt", 0.3)).toBe("low");
    });

    it("between thresholds → 'medium'", () => {
      expect(getNutritionBand("salt", 0.5)).toBe("medium");
      expect(getNutritionBand("salt", 1.4)).toBe("medium");
    });

    it("exact high threshold (1.5g) → 'high'", () => {
      expect(getNutritionBand("salt", 1.5)).toBe("high");
    });

    it("above high threshold → 'high'", () => {
      expect(getNutritionBand("salt", 2.5)).toBe("high");
    });
  });

  // ── Fibre: low ≤3, medium 3–6, high ≥6 (EU Reg 1924/2006) ─────────

  describe("fibre", () => {
    it("below low threshold → 'low'", () => {
      expect(getNutritionBand("fibre", 1)).toBe("low");
    });

    it("exact low threshold (3g) → 'low'", () => {
      expect(getNutritionBand("fibre", 3)).toBe("low");
    });

    it("between thresholds → 'medium'", () => {
      expect(getNutritionBand("fibre", 4)).toBe("medium");
      expect(getNutritionBand("fibre", 5.9)).toBe("medium");
    });

    it("exact high threshold (6g) → 'high' (EU 'high fibre' claim)", () => {
      expect(getNutritionBand("fibre", 6)).toBe("high");
    });

    it("above high threshold → 'high'", () => {
      expect(getNutritionBand("fibre", 10)).toBe("high");
    });
  });

  // ── Fiber (US spelling alias) ───────────────────────────────────────

  describe("fiber (US spelling)", () => {
    it("matches fibre thresholds exactly", () => {
      expect(getNutritionBand("fiber", 1)).toBe("low");
      expect(getNutritionBand("fiber", 4)).toBe("medium");
      expect(getNutritionBand("fiber", 8)).toBe("high");
      expect(getNutritionBand("fiber", 0)).toBe("none");
      expect(getNutritionBand("fiber", null)).toBe("none");
    });
  });

  // ── Protein: low ≤8, medium 8–16, high ≥16 ─────────────────────────

  describe("protein", () => {
    it("below low threshold → 'low'", () => {
      expect(getNutritionBand("protein", 3)).toBe("low");
    });

    it("exact low threshold (8g) → 'low'", () => {
      expect(getNutritionBand("protein", 8)).toBe("low");
    });

    it("between thresholds → 'medium'", () => {
      expect(getNutritionBand("protein", 12)).toBe("medium");
      expect(getNutritionBand("protein", 15.9)).toBe("medium");
    });

    it("exact high threshold (16g) → 'high'", () => {
      expect(getNutritionBand("protein", 16)).toBe("high");
    });

    it("above high threshold → 'high'", () => {
      expect(getNutritionBand("protein", 25)).toBe("high");
    });
  });

  // ── Very large values ───────────────────────────────────────────────

  it("handles very large values as 'high'", () => {
    expect(getNutritionBand("sugars", 999)).toBe("high");
    expect(getNutritionBand("total_fat", 100)).toBe("high");
  });

  // ── Tiny positive values ────────────────────────────────────────────

  it("tiny positive values (0.01g) are classified, not 'none'", () => {
    const band = getNutritionBand("salt", 0.01);
    expect(band).not.toBe("none");
    expect(band).toBe("low"); // 0.01 ≤ 0.3
  });

  // ── Type safety: band return type ───────────────────────────────────

  it("always returns a valid NutritionBand value", () => {
    const validBands: NutritionBand[] = ["none", "low", "medium", "high"];
    const testCases = [
      getNutritionBand("sugars", null),
      getNutritionBand("sugars", 0),
      getNutritionBand("sugars", 2),
      getNutritionBand("sugars", 10),
      getNutritionBand("sugars", 30),
      getNutritionBand("unknown", 50),
    ];
    for (const result of testCases) {
      expect(validBands).toContain(result);
    }
  });
});
