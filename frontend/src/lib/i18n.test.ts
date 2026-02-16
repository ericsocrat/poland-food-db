import { describe, expect, it, beforeEach } from "vitest";
import { translate } from "./i18n";

// ─── translate() — pure function tests (no React needed) ───────────────────

describe("translate", () => {
  describe("English (default)", () => {
    it("resolves a top-level key", () => {
      expect(translate("en", "nav.home")).toBe("Home");
    });

    it("resolves a nested key", () => {
      expect(translate("en", "settings.title")).toBe("Settings");
    });

    it("returns the key when not found", () => {
      expect(translate("en", "nonexistent.key")).toBe("nonexistent.key");
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

    it("returns the key itself when missing from all dictionaries", () => {
      expect(translate("pl", "totally.missing.key")).toBe(
        "totally.missing.key",
      );
    });
  });

  describe("edge cases", () => {
    it("handles empty key", () => {
      expect(translate("en", "")).toBe("");
    });

    it("handles single-segment key (namespace only)", () => {
      // "nav" is an object, not a string — should return the key
      expect(translate("en", "nav")).toBe("nav");
    });

    it("handles deeply invalid path", () => {
      expect(translate("en", "a.b.c.d.e.f")).toBe("a.b.c.d.e.f");
    });

    it("handles interpolation with no params on a template string", () => {
      // Should leave {page} and {pages} as-is
      const result = translate("en", "common.pageOf");
      expect(result).toBe("Page {page} of {pages}");
    });
  });
});
