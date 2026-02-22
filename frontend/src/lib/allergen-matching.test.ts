import { describe, it, expect } from "vitest";
import {
  matchProductAllergens,
  ALLERGEN_ICONS,
  type ProductAllergenData,
} from "./allergen-matching";

// ─── matchProductAllergens ──────────────────────────────────────────────────

describe("matchProductAllergens", () => {
  // ── Empty / undefined inputs ────────────────────────────────────────────

  it("returns empty array when productAllergens is undefined", () => {
    expect(matchProductAllergens(undefined, ["en:milk"], true)).toEqual([]);
  });

  it("returns empty array when userAvoidAllergens is empty", () => {
    const data: ProductAllergenData = {
      contains: ["en:milk"],
      traces: [],
    };
    expect(matchProductAllergens(data, [], true)).toEqual([]);
  });

  it("returns empty array when there are no matching allergens", () => {
    const data: ProductAllergenData = {
      contains: ["en:gluten"],
      traces: ["en:eggs"],
    };
    expect(matchProductAllergens(data, ["en:milk"], true)).toEqual([]);
  });

  // ── Contains matching ─────────────────────────────────────────────────

  it("returns 'contains' warnings for matching allergens", () => {
    const data: ProductAllergenData = {
      contains: ["en:milk", "en:gluten"],
      traces: [],
    };
    const result = matchProductAllergens(data, ["en:milk"], false);

    expect(result).toHaveLength(1);
    expect(result[0]).toEqual({
      tag: "en:milk",
      label: "Milk / Dairy",
      icon: "🥛",
      type: "contains",
    });
  });

  it("matches multiple contains allergens", () => {
    const data: ProductAllergenData = {
      contains: ["en:milk", "en:gluten", "en:eggs"],
      traces: [],
    };
    const result = matchProductAllergens(
      data,
      ["en:milk", "en:eggs"],
      false,
    );

    expect(result).toHaveLength(2);
    expect(result.map((w) => w.tag)).toEqual(["en:eggs", "en:milk"]);
    expect(result.every((w) => w.type === "contains")).toBe(true);
  });

  // ── Traces matching ───────────────────────────────────────────────────

  it("ignores traces when treatMayContainAsUnsafe is false", () => {
    const data: ProductAllergenData = {
      contains: [],
      traces: ["en:milk"],
    };
    const result = matchProductAllergens(data, ["en:milk"], false);

    expect(result).toEqual([]);
  });

  it("returns 'traces' warnings when treatMayContainAsUnsafe is true", () => {
    const data: ProductAllergenData = {
      contains: [],
      traces: ["en:milk"],
    };
    const result = matchProductAllergens(data, ["en:milk"], true);

    expect(result).toHaveLength(1);
    expect(result[0]).toEqual({
      tag: "en:milk",
      label: "Milk / Dairy",
      icon: "🥛",
      type: "traces",
    });
  });

  // ── Deduplication ─────────────────────────────────────────────────────

  it("avoids duplicates when tag appears in both contains and traces", () => {
    const data: ProductAllergenData = {
      contains: ["en:milk"],
      traces: ["en:milk"],
    };
    const result = matchProductAllergens(data, ["en:milk"], true);

    expect(result).toHaveLength(1);
    expect(result[0].type).toBe("contains");
  });

  // ── Sorting ───────────────────────────────────────────────────────────

  it("sorts contains before traces", () => {
    const data: ProductAllergenData = {
      contains: ["en:gluten"],
      traces: ["en:eggs"],
    };
    const result = matchProductAllergens(
      data,
      ["en:gluten", "en:eggs"],
      true,
    );

    expect(result).toHaveLength(2);
    expect(result[0].type).toBe("contains");
    expect(result[1].type).toBe("traces");
  });

  it("sorts alphabetically within same type", () => {
    const data: ProductAllergenData = {
      contains: ["en:milk", "en:eggs", "en:gluten"],
      traces: [],
    };
    const result = matchProductAllergens(
      data,
      ["en:milk", "en:eggs", "en:gluten"],
      false,
    );

    expect(result.map((w) => w.tag)).toEqual([
      "en:eggs",
      "en:gluten",
      "en:milk",
    ]);
  });

  // ── Unknown tags (fallback label/icon) ────────────────────────────────

  it("uses fallback label and icon for unknown allergen tags", () => {
    const data: ProductAllergenData = {
      contains: ["en:some-unknown-allergen"],
      traces: [],
    };
    const result = matchProductAllergens(
      data,
      ["en:some-unknown-allergen"],
      false,
    );

    expect(result).toHaveLength(1);
    expect(result[0].label).toBe("Some Unknown Allergen");
    expect(result[0].icon).toBe("⚠️");
  });

  // ── All 14 EU allergens have icons ────────────────────────────────────

  it("provides icons for all 14 EU allergens", () => {
    const expected = [
      "en:gluten",
      "en:milk",
      "en:eggs",
      "en:nuts",
      "en:peanuts",
      "en:soybeans",
      "en:fish",
      "en:crustaceans",
      "en:celery",
      "en:mustard",
      "en:sesame-seeds",
      "en:sulphur-dioxide-and-sulphites",
      "en:lupin",
      "en:molluscs",
    ];

    for (const tag of expected) {
      expect(ALLERGEN_ICONS[tag]).toBeDefined();
      expect(ALLERGEN_ICONS[tag]).not.toBe("⚠️");
    }
  });
});
