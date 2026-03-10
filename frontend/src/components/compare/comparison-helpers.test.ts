import type { CompareProduct } from "@/lib/types";
import { describe, expect, it } from "vitest";
import {
    filterNumericEntries,
    findExtreme,
    fmtStr,
    fmtUnit,
    getBestWorst,
    getCellHighlightClass,
    getKeyDifferences,
    getProductWarnings,
    getWinnerIndex,
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
      "bg-success-bg text-success-text font-semibold",
    );
  });

  it("returns worst class for worst index", () => {
    expect(getCellHighlightClass(2, ranking, 0)).toBe(
      "bg-error-bg text-error-text",
    );
  });

  it("returns winner class when index matches winner", () => {
    expect(getCellHighlightClass(0, ranking, 0)).toBe("bg-success-bg/30");
  });

  it("returns empty string for non-special index", () => {
    expect(getCellHighlightClass(3, ranking, 0)).toBe("");
  });

  it("returns winner class when ranking is null", () => {
    expect(getCellHighlightClass(0, null, 0)).toBe("bg-success-bg/30");
  });

  it("returns empty string when ranking is null and not winner", () => {
    expect(getCellHighlightClass(1, null, 0)).toBe("");
  });

  it("best takes priority over winner", () => {
    // Index 1 is both best and winner → should get best class
    expect(getCellHighlightClass(1, ranking, 1)).toBe(
      "bg-success-bg text-success-text font-semibold",
    );
  });
});

// ─── getKeyDifferences ──────────────────────────────────────────────────────

describe("getKeyDifferences", () => {
  it("returns differences sorted by significance", () => {
    const a = makeProduct({ calories: 100, sugars_g: 5, salt_g: 0.2 });
    const b = makeProduct({ calories: 500, sugars_g: 6, salt_g: 0.3 });
    const diffs = getKeyDifferences([a, b]);

    // Calories diff = 400/600 = 0.667, sugars diff = 1/50 = 0.02, salt diff = 0.1/5 = 0.02
    expect(diffs[0].label).toBe("Calories");
    expect(diffs[0].betterIdx).toBe(0); // lower is better for calories
  });

  it("respects maxResults limit", () => {
    const a = makeProduct({
      calories: 100,
      sugars_g: 30,
      salt_g: 4,
      total_fat_g: 40,
      saturated_fat_g: 20,
      protein_g: 5,
      fibre_g: 1,
      additives_count: 8,
    });
    const b = makeProduct({
      calories: 500,
      sugars_g: 5,
      salt_g: 0.5,
      total_fat_g: 5,
      saturated_fat_g: 2,
      protein_g: 30,
      fibre_g: 10,
      additives_count: 1,
    });
    const diffs = getKeyDifferences([a, b], 3);
    expect(diffs).toHaveLength(3);
  });

  it("returns empty array when products have identical values", () => {
    const a = makeProduct();
    const b = makeProduct();
    const diffs = getKeyDifferences([a, b]);
    expect(diffs).toHaveLength(0);
  });

  it("identifies correct better index for higher-is-better nutrients", () => {
    const a = makeProduct({ protein_g: 5 });
    const b = makeProduct({ protein_g: 30 });
    const diffs = getKeyDifferences([a, b]);
    const proteinDiff = diffs.find((d) => d.label === "Protein");
    expect(proteinDiff).toBeDefined();
    expect(proteinDiff!.betterIdx).toBe(1); // higher protein is better
  });

  it("handles null values gracefully", () => {
    const a = makeProduct({ fibre_g: null as unknown as number });
    const b = makeProduct({ fibre_g: 5 });
    const diffs = getKeyDifferences([a, b]);
    // fibre should be skipped since one value is null/undefined
    const fibreDiff = diffs.find((d) => d.label === "Fibre");
    expect(fibreDiff).toBeUndefined();
  });

  it("works with 3+ products", () => {
    const a = makeProduct({ calories: 100 });
    const b = makeProduct({ calories: 300 });
    const c = makeProduct({ calories: 500 });
    const diffs = getKeyDifferences([a, b, c]);
    const calDiff = diffs.find((d) => d.label === "Calories");
    expect(calDiff).toBeDefined();
    // Max diff is 500-100=400, best is lowest
    expect(calDiff!.betterIdx).toBe(0);
    expect(calDiff!.values).toEqual([100, 300, 500]);
  });
});
