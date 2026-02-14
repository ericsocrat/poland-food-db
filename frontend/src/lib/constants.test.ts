import { describe, it, expect } from "vitest";
import {
  COUNTRIES,
  ALLERGEN_TAGS,
  DIET_OPTIONS,
  SCORE_BANDS,
  NUTRI_COLORS,
  HEALTH_CONDITIONS,
  WARNING_SEVERITY,
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

describe("HEALTH_CONDITIONS", () => {
  it("has 7 conditions", () => {
    expect(HEALTH_CONDITIONS).toHaveLength(7);
  });

  it("each condition has value, label, and icon", () => {
    for (const condition of HEALTH_CONDITIONS) {
      expect(condition.value).toBeTruthy();
      expect(condition.label).toBeTruthy();
      expect(condition.icon).toBeTruthy();
    }
  });

  it("includes diabetes and celiac_disease", () => {
    const values = HEALTH_CONDITIONS.map((c) => c.value);
    expect(values).toContain("diabetes");
    expect(values).toContain("celiac_disease");
  });
});

describe("WARNING_SEVERITY", () => {
  it("has critical, high, and moderate levels", () => {
    expect(Object.keys(WARNING_SEVERITY)).toEqual(["critical", "high", "moderate"]);
  });

  it("each level has label, color, bg, and border", () => {
    for (const level of Object.values(WARNING_SEVERITY)) {
      expect(level.label).toBeTruthy();
      expect(level.color).toMatch(/^text-/);
      expect(level.bg).toMatch(/^bg-/);
      expect(level.border).toMatch(/^border-/);
    }
  });
});
