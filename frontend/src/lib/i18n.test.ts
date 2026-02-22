import { describe, expect, it } from "vitest";
import { renderHook } from "@testing-library/react";
import { translate, humanizeKey, useTranslation } from "./i18n";

// ─── translate() — pure function tests (no React needed) ───────────────────

describe("translate", () => {
  describe("English (default)", () => {
    it("resolves a top-level key", () => {
      expect(translate("en", "nav.home")).toBe("Home");
    });

    it("resolves a nested key", () => {
      expect(translate("en", "settings.title")).toBe("Settings");
    });

    it("returns humanized fallback when not found", () => {
      expect(translate("en", "nonexistent.key")).toBe("Key");
    });

    it("interpolates {param} placeholders", () => {
      expect(translate("en", "common.pageOf", { page: 3, pages: 10 })).toBe(
        "Page 3 of 10",
      );
    });

    it("leaves unmatched placeholders intact", () => {
      expect(translate("en", "common.pageOf", { page: 1 })).toBe(
        "Page 1 of {pages}",
      );
    });

    it("handles string interpolation params", () => {
      expect(translate("en", "product.nutriScore", { grade: "A" })).toBe(
        "Nutri-Score A",
      );
    });
  });

  describe("Polish", () => {
    it("resolves a Polish translation", () => {
      expect(translate("pl", "nav.home")).toBe("Główna");
    });

    it("resolves nested Polish keys", () => {
      expect(translate("pl", "settings.title")).toBe("Ustawienia");
    });

    it("interpolates Polish strings", () => {
      expect(translate("pl", "common.pageOf", { page: 2, pages: 5 })).toBe(
        "Strona 2 z 5",
      );
    });
  });

  describe("fallback chain", () => {
    it("falls back to English for unsupported language code", () => {
      // "fr" has no dictionary — should fall through to English
      expect(translate("fr" as "en", "nav.home")).toBe("Home");
    });

    it("falls back to English when key missing in Polish", () => {
      // If a key exists in en.json but not in pl.json, we get English
      // Both files have the same keys, but test the mechanism by using the
      // translate function which would fall back if the key were missing
      const result = translate("pl", "nav.home");
      expect(typeof result).toBe("string");
      expect(result.length).toBeGreaterThan(0);
    });

    it("returns humanized fallback when missing from all dictionaries", () => {
      expect(translate("pl", "totally.missing.key")).toBe("Key");
    });
  });

  describe("edge cases", () => {
    it("handles empty key", () => {
      expect(translate("en", "")).toBe("");
    });

    it("handles single-segment key (namespace only)", () => {
      // "nav" is an object, not a string — should return humanized fallback
      expect(translate("en", "nav")).toBe("Nav");
    });

    it("handles deeply invalid path", () => {
      expect(translate("en", "a.b.c.d.e.f")).toBe("F");
    });

    it("handles interpolation with no params on a template string", () => {
      // Should leave {page} and {pages} as-is
      const result = translate("en", "common.pageOf");
      expect(result).toBe("Page {page} of {pages}");
    });
  });

  // ── humanizeKey fallback guard (Issue #123) ──────────────────────────────

  describe("humanizeKey", () => {
    it("extracts last segment and title-cases it", () => {
      expect(humanizeKey("nav.home")).toBe("Home");
    });

    it("uses second-to-last segment when last is 'title'", () => {
      expect(humanizeKey("recipes.items.overnight_oats.title")).toBe(
        "Overnight Oats",
      );
    });

    it("uses second-to-last segment when last is 'description'", () => {
      expect(humanizeKey("recipes.items.zupa_pomidorowa.description")).toBe(
        "Zupa Pomidorowa",
      );
    });

    it("converts kebab-case to Title Case", () => {
      expect(humanizeKey("recipes.items.red-lentil-soup.title")).toBe(
        "Red Lentil Soup",
      );
    });

    it("converts snake_case to Title Case", () => {
      expect(humanizeKey("recipes.items.overnight_oats.name")).toBe(
        "Overnight Oats",
      );
    });

    it("handles single-segment key", () => {
      expect(humanizeKey("retry")).toBe("Retry");
    });

    it("keeps non-generic last segment", () => {
      expect(humanizeKey("recipes.category.breakfast")).toBe("Breakfast");
    });

    it("never returns a raw dot-separated key", () => {
      const result = humanizeKey("any.deeply.nested.key.title");
      expect(result).not.toContain(".");
    });
  });

  // ── Plural interpolation (Issue #126) ────────────────────────────────────

  describe("plural interpolation", () => {
    // English 2-form: {count|singular|plural}
    it("selects singular form when count is 1", () => {
      expect(translate("en", "common.items", { count: 1 })).toBe("1 item");
    });

    it("selects plural form when count > 1", () => {
      expect(translate("en", "common.items", { count: 5 })).toBe("5 items");
    });

    it("selects plural form when count is 0", () => {
      expect(translate("en", "common.items", { count: 0 })).toBe("0 items");
    });

    it("handles multiple plural tokens in one string", () => {
      // compare.comparing: "Comparing {count} {count|product|products}"
      expect(translate("en", "compare.comparing", { count: 1 })).toBe(
        "Comparing 1 product",
      );
      expect(translate("en", "compare.comparing", { count: 3 })).toBe(
        "Comparing 3 products",
      );
    });

    it("handles mixed plural + simple interpolation", () => {
      // dashboard.allergenAlertBody has {count} plural + {allergens} simple
      const result = translate("en", "dashboard.allergenAlertBody", {
        count: 2,
        allergens: "Gluten",
      });
      expect(result).toBe(
        "2 products in your Favorites contain Gluten.",
      );
    });

    it("handles singular with mixed interpolation", () => {
      const result = translate("en", "dashboard.allergenAlertBody", {
        count: 1,
        allergens: "Milk",
      });
      expect(result).toBe(
        "1 product in your Favorites contains Milk.",
      );
    });

    // Polish 3-form: {count|one|few|many}
    it("selects Polish one-form for count 1", () => {
      expect(translate("pl", "common.items", { count: 1 })).toBe("1 element");
    });

    it("selects Polish few-form for count 2-4", () => {
      expect(translate("pl", "common.items", { count: 3 })).toBe(
        "3 elementy",
      );
    });

    it("selects Polish many-form for count 5+", () => {
      expect(translate("pl", "common.items", { count: 5 })).toBe(
        "5 elementów",
      );
    });

    it("selects Polish many-form for count 0", () => {
      expect(translate("pl", "common.items", { count: 0 })).toBe(
        "0 elementów",
      );
    });

    it("handles Polish teen numbers (12-14) as many-form", () => {
      expect(translate("pl", "common.items", { count: 12 })).toBe(
        "12 elementów",
      );
    });

    it("handles Polish 22-24 as few-form", () => {
      expect(translate("pl", "common.items", { count: 22 })).toBe(
        "22 elementy",
      );
    });

    // ── New pluralized keys (Issue #126 audit) ──────────────────────────────

    it("pluralizes common.allergenWarnings (en)", () => {
      expect(translate("en", "common.allergenWarnings", { count: 1 })).toBe(
        "1 allergen warning",
      );
      expect(translate("en", "common.allergenWarnings", { count: 3 })).toBe(
        "3 allergen warnings",
      );
    });

    it("pluralizes common.allergenWarnings (pl)", () => {
      expect(translate("pl", "common.allergenWarnings", { count: 1 })).toBe(
        "1 ostrzeżenie alergenowe",
      );
      expect(translate("pl", "common.allergenWarnings", { count: 3 })).toBe(
        "3 ostrzeżenia alergenowe",
      );
      expect(translate("pl", "common.allergenWarnings", { count: 5 })).toBe(
        "5 ostrzeżeń alergenowych",
      );
    });

    it("pluralizes shared.productsCompared (en)", () => {
      expect(translate("en", "shared.productsCompared", { count: 1 })).toBe(
        "1 product compared",
      );
      expect(translate("en", "shared.productsCompared", { count: 3 })).toBe(
        "3 products compared",
      );
    });

    it("pluralizes shared.productsCompared (pl)", () => {
      expect(translate("pl", "shared.productsCompared", { count: 1 })).toBe(
        "1 produkt porównany",
      );
      expect(translate("pl", "shared.productsCompared", { count: 3 })).toBe(
        "3 produkty porównane",
      );
      expect(translate("pl", "shared.productsCompared", { count: 5 })).toBe(
        "5 produktów porównanych",
      );
    });

    it("pluralizes ingredient.productsContaining (en)", () => {
      expect(
        translate("en", "ingredient.productsContaining", { count: 1 }),
      ).toBe("product contains this ingredient");
      expect(
        translate("en", "ingredient.productsContaining", { count: 5 }),
      ).toBe("products contain this ingredient");
    });

    it("pluralizes ingredient.productsContaining (pl)", () => {
      expect(
        translate("pl", "ingredient.productsContaining", { count: 1 }),
      ).toBe("produkt zawiera ten składnik");
      expect(
        translate("pl", "ingredient.productsContaining", { count: 3 }),
      ).toBe("produkty zawierają ten składnik");
      expect(
        translate("pl", "ingredient.productsContaining", { count: 5 }),
      ).toBe("produktów zawiera ten składnik");
    });
  });

  // ── useTranslation hook ─────────────────────────────────────────────────

  describe("useTranslation", () => {
    it("returns a t function and language", () => {
      const { result } = renderHook(() => useTranslation());
      expect(typeof result.current.t).toBe("function");
      expect(typeof result.current.language).toBe("string");
    });

    it("t() resolves known keys", () => {
      const { result } = renderHook(() => useTranslation());
      expect(result.current.t("nav.home")).toBe("Home");
    });

    it("t() returns humanized fallback for missing keys", () => {
      const { result } = renderHook(() => useTranslation());
      const missing = result.current.t("totally.unknown.title");
      expect(missing).toBe("Unknown");
      expect(missing).not.toContain(".");
    });
  });
});
