import { describe, it, expect } from "vitest";
import {
  COUNTRIES,
  ALLERGEN_TAGS,
  ALLERGEN_PRESETS,
  DIET_OPTIONS,
  SCORE_BANDS,
  SCORE_5BAND_DISPLAY,
  scoreColorFromScore,
  NUTRI_COLORS,
  HEALTH_CONDITIONS,
  WARNING_SEVERITY,
  SCORE_INTERPRETATION_BANDS,
  TRAFFIC_LIGHT_NUTRIENTS,
  FEATURES,
  getScoreInterpretation,
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
      expect(allergen.tag).toBeTruthy();
      expect(allergen.tag).not.toMatch(/^en:/);
      expect(allergen.label.length).toBeGreaterThan(0);
    }
  });
});

describe("ALLERGEN_PRESETS", () => {
  it("has 4 presets: glutenFree, dairyFree, nutFree, vegan", () => {
    const keys = ALLERGEN_PRESETS.map((p) => p.key);
    expect(keys).toEqual(["glutenFree", "dairyFree", "nutFree", "vegan"]);
  });

  it("each preset references valid ALLERGEN_TAGS entries", () => {
    const validTags = ALLERGEN_TAGS.map((a) => a.tag);
    for (const preset of ALLERGEN_PRESETS) {
      for (const tag of preset.tags) {
        expect(validTags).toContain(tag);
      }
    }
  });

  it("each preset has a labelKey for i18n", () => {
    for (const preset of ALLERGEN_PRESETS) {
      expect(preset.labelKey).toMatch(/^allergenPreset\./);
    }
  });

  it("nutFree preset includes both nuts and peanuts", () => {
    const nutFree = ALLERGEN_PRESETS.find((p) => p.key === "nutFree");
    expect(nutFree?.tags).toContain("tree-nuts");
    expect(nutFree?.tags).toContain("peanuts");
  });

  it("vegan preset includes all animal-derived allergens", () => {
    const vegan = ALLERGEN_PRESETS.find((p) => p.key === "vegan");
    expect(vegan?.tags).toContain("milk");
    expect(vegan?.tags).toContain("eggs");
    expect(vegan?.tags).toContain("fish");
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

describe("scoreColorFromScore (5-band)", () => {
  it.each([
    [0, "green"],
    [10, "green"],
    [20, "green"],
    [21, "yellow"],
    [40, "yellow"],
    [41, "orange"],
    [60, "orange"],
    [61, "red"],
    [80, "red"],
    [81, "darkred"],
    [100, "darkred"],
  ] as const)("maps score %i to %s", (score, expected) => {
    expect(scoreColorFromScore(score)).toBe(expected);
  });
});

describe("SCORE_5BAND_DISPLAY", () => {
  it("has all five bands", () => {
    expect(Object.keys(SCORE_5BAND_DISPLAY)).toEqual([
      "green",
      "yellow",
      "orange",
      "red",
      "darkred",
    ]);
  });

  it("each band has color and bg using score-* tokens", () => {
    for (const band of Object.values(SCORE_5BAND_DISPLAY)) {
      expect(band.color).toMatch(/^text-score-/);
      expect(band.bg).toMatch(/^bg-score-/);
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

describe("SCORE_INTERPRETATION_BANDS", () => {
  it("has 5 bands covering 0-100 range", () => {
    expect(SCORE_INTERPRETATION_BANDS).toHaveLength(5);
    expect(SCORE_INTERPRETATION_BANDS[0].min).toBe(0);
    expect(SCORE_INTERPRETATION_BANDS[4].max).toBe(100);
  });

  it("each band has key, color, and bg", () => {
    for (const band of SCORE_INTERPRETATION_BANDS) {
      expect(band.key).toMatch(/^scoreInterpretation\./);
      expect(band.color).toMatch(/^text-/);
      expect(band.bg).toMatch(/^bg-/);
    }
  });
});

describe("getScoreInterpretation", () => {
  it("returns green band for score 15", () => {
    expect(getScoreInterpretation(15).key).toBe("scoreInterpretation.green");
  });

  it("returns yellow band for score 35", () => {
    expect(getScoreInterpretation(35).key).toBe("scoreInterpretation.yellow");
  });

  it("returns orange band for score 50", () => {
    expect(getScoreInterpretation(50).key).toBe("scoreInterpretation.orange");
  });

  it("returns red band for score 70", () => {
    expect(getScoreInterpretation(70).key).toBe("scoreInterpretation.red");
  });

  it("returns darkRed band for score 90", () => {
    expect(getScoreInterpretation(90).key).toBe("scoreInterpretation.darkRed");
  });
});

describe("TRAFFIC_LIGHT_NUTRIENTS", () => {
  it("has 4 nutrients with labelKeys", () => {
    expect(TRAFFIC_LIGHT_NUTRIENTS).toHaveLength(4);
    for (const n of TRAFFIC_LIGHT_NUTRIENTS) {
      expect(n.nutrient).toBeTruthy();
      expect(n.labelKey).toMatch(/^product\./);
    }
  });
});

describe("FEATURES", () => {
  it("has ECO_SCORE set to false by default", () => {
    expect(FEATURES.ECO_SCORE).toBe(false);
  });
});
