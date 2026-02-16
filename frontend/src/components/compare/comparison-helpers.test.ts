import { describe, expect, it } from "vitest";
import type { CompareProduct } from "@/lib/types";
import {
  fmtUnit,
  fmtStr,
  filterNumericEntries,
  findExtreme,
  getWinnerIndex,
  getBestWorst,
  getProductWarnings,
  getCellHighlightClass,
} from "./comparison-helpers";

// ─── Stub factory ───────────────────────────────────────────────────────────

function makeProduct(
  overrides: Partial<CompareProduct> = {},
): CompareProduct {
  return {
    product_id: 1,
    ean: null,
    product_name: "Test",
    brand: "Brand",
    category: "chips",
    category_display: "Chips",
    category_icon: "🍟",
    unhealthiness_score: 50,
    score_band: "mid" as CompareProduct["score_band"],
    nutri_score: "C" as CompareProduct["nutri_score"],
    nova_group: "3",
    processing_risk: "medium",
    calories: 200,
    total_fat_g: 10,
    saturated_fat_g: 3,
    trans_fat_g: null,
    carbs_g: 25,
    sugars_g: 5,
    fibre_g: 2,
    protein_g: 3,
    salt_g: 0.5,
    high_salt: false,
    high_sugar: false,
    high_sat_fat: false,
    high_additive_load: false,
    additives_count: 0,
    ingredient_count: 5,
    allergen_count: 0,
    allergen_tags: null,
    trace_tags: null,
    confidence: "high",
    data_completeness_pct: 100,
    ...overrides,
  };
}

// ─── fmtUnit ────────────────────────────────────────────────────────────────

describe("fmtUnit", () => {
  it("formats a number with unit", () => {
    expect(fmtUnit(42, "g")).toBe("42 g");
  });

  it("formats zero with unit", () => {
    expect(fmtUnit(0, "kcal")).toBe("0 kcal");
  });

  it("returns default fallback for null", () => {
    expect(fmtUnit(null, "g")).toBe("—");
  });

  it("uses custom fallback", () => {
    expect(fmtUnit(null, "g", "N/A")).toBe("N/A");
  });

  it("formats a string value with unit", () => {
    expect(fmtUnit("high", "")).toBe("high ");
  });
});

// ─── fmtStr ─────────────────────────────────────────────────────────────────

describe("fmtStr", () => {
  it("formats a number as string", () => {
    expect(fmtStr(42)).toBe("42");
  });

  it("returns the string as-is", () => {
    expect(fmtStr("hello")).toBe("hello");
  });

  it("returns default fallback for null", () => {
    expect(fmtStr(null)).toBe("—");
  });

  it("uses custom fallback", () => {
    expect(fmtStr(null, "N/A")).toBe("N/A");
  });

  it("formats zero", () => {
    expect(fmtStr(0)).toBe("0");
  });
});

// ─── filterNumericEntries ───────────────────────────────────────────────────

describe("filterNumericEntries", () => {
  it("collects numeric values with indices", () => {
    expect(filterNumericEntries([10, null, 30])).toEqual([
      { idx: 0, val: 10 },
      { idx: 2, val: 30 },
    ]);
  });

  it("returns empty array for all nulls", () => {
    expect(filterNumericEntries([null, null])).toEqual([]);
  });

  it("returns empty array for empty input", () => {
    expect(filterNumericEntries([])).toEqual([]);
  });

  it("includes zero values", () => {
    expect(filterNumericEntries([0, null, 5])).toEqual([
      { idx: 0, val: 0 },
      { idx: 2, val: 5 },
    ]);
  });

  it("handles all numeric values", () => {
    expect(filterNumericEntries([1, 2, 3])).toEqual([
      { idx: 0, val: 1 },
      { idx: 1, val: 2 },
      { idx: 2, val: 3 },
    ]);
  });
});

// ─── findExtreme ────────────────────────────────────────────────────────────

describe("findExtreme", () => {
  const entries = [
    { idx: 0, val: 10 },
    { idx: 1, val: 5 },
    { idx: 2, val: 20 },
  ];

  it("finds minimum", () => {
    expect(findExtreme(entries, "min")).toEqual({ idx: 1, val: 5 });
  });

  it("finds maximum", () => {
    expect(findExtreme(entries, "max")).toEqual({ idx: 2, val: 20 });
  });

  it("returns only element for single-entry array", () => {
    const single = [{ idx: 0, val: 42 }];
    expect(findExtreme(single, "min")).toEqual({ idx: 0, val: 42 });
    expect(findExtreme(single, "max")).toEqual({ idx: 0, val: 42 });
  });

  it("returns first occurrence when values are equal", () => {
    const tied = [
      { idx: 0, val: 7 },
      { idx: 1, val: 7 },
    ];
    expect(findExtreme(tied, "min")).toEqual({ idx: 0, val: 7 });
  });
});

// ─── getWinnerIndex ─────────────────────────────────────────────────────────

describe("getWinnerIndex", () => {
  it("returns index of product with lowest score", () => {
    const products = [
      makeProduct({ unhealthiness_score: 70 }),
      makeProduct({ unhealthiness_score: 30 }),
      makeProduct({ unhealthiness_score: 50 }),
    ];
    expect(getWinnerIndex(products)).toBe(1);
  });

  it("returns 0 when first product is best", () => {
    const products = [
      makeProduct({ unhealthiness_score: 10 }),
      makeProduct({ unhealthiness_score: 90 }),
    ];
    expect(getWinnerIndex(products)).toBe(0);
  });

  it("returns first occurrence on tie", () => {
    const products = [
      makeProduct({ unhealthiness_score: 50 }),
      makeProduct({ unhealthiness_score: 50 }),
    ];
    expect(getWinnerIndex(products)).toBe(0);
  });
});

// ─── getBestWorst ───────────────────────────────────────────────────────────

describe("getBestWorst", () => {
  it("returns null for 'none' direction", () => {
    expect(getBestWorst([10, 20, 30], "none")).toBeNull();
  });

  it("lower-is-better: best = min, worst = max", () => {
    expect(getBestWorst([30, 10, 20], "lower")).toEqual({
      bestIdx: 1,
      worstIdx: 0,
    });
  });

  it("higher-is-better: best = max, worst = min", () => {
    expect(getBestWorst([30, 10, 20], "higher")).toEqual({
      bestIdx: 0,
      worstIdx: 1,
    });
  });

  it("returns null when all values are equal", () => {
    expect(getBestWorst([5, 5, 5], "lower")).toBeNull();
  });

  it("returns null when fewer than 2 non-null values", () => {
    expect(getBestWorst([null, 10, null], "lower")).toBeNull();
  });

  it("returns null for single value", () => {
    expect(getBestWorst([10], "lower")).toBeNull();
  });

  it("returns null for empty array", () => {
    expect(getBestWorst([], "lower")).toBeNull();
  });

  it("skips nulls and ranks the rest", () => {
    expect(getBestWorst([null, 10, 20], "lower")).toEqual({
      bestIdx: 1,
      worstIdx: 2,
    });
  });
});

// ─── getProductWarnings ─────────────────────────────────────────────────────

describe("getProductWarnings", () => {
  it("returns empty array when no flags set", () => {
    expect(getProductWarnings(makeProduct())).toEqual([]);
  });

  it("returns salt flag", () => {
    const warnings = getProductWarnings(makeProduct({ high_salt: true }));
    expect(warnings).toEqual(["🧂 High Salt"]);
  });

  it("returns sugar flag", () => {
    const warnings = getProductWarnings(makeProduct({ high_sugar: true }));
    expect(warnings).toEqual(["🍬 High Sugar"]);
  });

  it("returns sat fat flag", () => {
    const warnings = getProductWarnings(makeProduct({ high_sat_fat: true }));
    expect(warnings).toEqual(["🧈 High Sat Fat"]);
  });

  it("returns additive flag", () => {
    const warnings = getProductWarnings(
      makeProduct({ high_additive_load: true }),
    );
    expect(warnings).toEqual(["⚗️ Additives"]);
  });

  it("returns all flags in order", () => {
    const p = makeProduct({
      high_salt: true,
      high_sugar: true,
      high_sat_fat: true,
      high_additive_load: true,
    });
    expect(getProductWarnings(p)).toEqual([
      "🧂 High Salt",
      "🍬 High Sugar",
      "🧈 High Sat Fat",
      "⚗️ Additives",
    ]);
  });

  it("returns subset of flags", () => {
    const p = makeProduct({ high_sugar: true, high_additive_load: true });
    expect(getProductWarnings(p)).toEqual(["🍬 High Sugar", "⚗️ Additives"]);
  });
});

// ─── getCellHighlightClass ──────────────────────────────────────────────────

describe("getCellHighlightClass", () => {
  const ranking = { bestIdx: 1, worstIdx: 2 };

  it("returns best class for best index", () => {
    expect(getCellHighlightClass(1, ranking, 0)).toBe(
      "bg-green-50 text-green-700 font-semibold",
    );
  });

  it("returns worst class for worst index", () => {
    expect(getCellHighlightClass(2, ranking, 0)).toBe(
      "bg-red-50 text-red-600",
    );
  });

  it("returns winner class when index matches winner", () => {
    expect(getCellHighlightClass(0, ranking, 0)).toBe("bg-green-50/30");
  });

  it("returns empty string for non-special index", () => {
    expect(getCellHighlightClass(3, ranking, 0)).toBe("");
  });

  it("returns winner class when ranking is null", () => {
    expect(getCellHighlightClass(0, null, 0)).toBe("bg-green-50/30");
  });

  it("returns empty string when ranking is null and not winner", () => {
    expect(getCellHighlightClass(1, null, 0)).toBe("");
  });

  it("best takes priority over winner", () => {
    // Index 1 is both best and winner → should get best class
    expect(getCellHighlightClass(1, ranking, 1)).toBe(
      "bg-green-50 text-green-700 font-semibold",
    );
  });
});
