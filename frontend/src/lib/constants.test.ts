import { describe, it, expect } from "vitest";
import {
  COUNTRIES,
  ALLERGEN_TAGS,
  DIET_OPTIONS,
  SCORE_BANDS,
  NUTRI_COLORS,
} from "@/lib/constants";

describe("COUNTRIES", () => {
  it("contains at least Poland and Germany", () => {
    const codes = COUNTRIES.map((c) => c.code);
    expect(codes).toContain("PL");
    expect(codes).toContain("DE");
  });

  it("each country has required fields", () => {
    for (const country of COUNTRIES) {
      expect(country.code).toBeTruthy();
      expect(country.name).toBeTruthy();
      expect(country.native).toBeTruthy();
      expect(country.flag).toBeTruthy();
    }
  });
});

describe("ALLERGEN_TAGS", () => {
  it("has 14 EU allergens", () => {
    expect(ALLERGEN_TAGS).toHaveLength(14);
  });

  it("each allergen has tag and label", () => {
    for (const allergen of ALLERGEN_TAGS) {
      expect(allergen.tag).toMatch(/^en:/);
      expect(allergen.label.length).toBeGreaterThan(0);
    }
  });
});

describe("DIET_OPTIONS", () => {
  it("includes none, vegetarian, vegan", () => {
    const values = DIET_OPTIONS.map((d) => d.value);
    expect(values).toEqual(["none", "vegetarian", "vegan"]);
  });
});

describe("SCORE_BANDS", () => {
  it("has all four bands", () => {
    expect(Object.keys(SCORE_BANDS)).toEqual([
      "low",
      "moderate",
      "high",
      "very_high",
    ]);
  });

  it("each band has label, color, and bg", () => {
    for (const band of Object.values(SCORE_BANDS)) {
      expect(band.label).toBeTruthy();
      expect(band.color).toMatch(/^text-/);
      expect(band.bg).toMatch(/^bg-/);
    }
  });
});

describe("NUTRI_COLORS", () => {
  it("has entries for A through E", () => {
    for (const grade of ["A", "B", "C", "D", "E"]) {
      expect(NUTRI_COLORS[grade]).toBeTruthy();
    }
  });
});
