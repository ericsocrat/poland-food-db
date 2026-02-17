import fs from "node:fs";
import path from "node:path";
import { describe, expect, it } from "vitest";
import en from "@/../messages/en.json";
import pl from "@/../messages/pl.json";

// ─── Message dictionary parity tests ────────────────────────────────────────
// Ensures en.json and pl.json have identical key structures so no translation
// keys are missing or extra.  Also dynamically discovers ALL *.json files in
// messages/ and verifies each matches en.json keys exactly — hard fail in dev.

type NestedObject = Record<string, unknown>;

/** Recursively collect all dot-separated keys from a nested object. */
function collectKeys(obj: NestedObject, prefix = ""): string[] {
  const keys: string[] = [];
  for (const [key, value] of Object.entries(obj)) {
    const fullKey = prefix ? `${prefix}.${key}` : key;
    if (value && typeof value === "object" && !Array.isArray(value)) {
      keys.push(...collectKeys(value as NestedObject, fullKey));
    } else {
      keys.push(fullKey);
    }
  }
  return keys.sort();
}

/** Discover all *.json locale files in messages/ directory. */
function discoverLocaleFiles(): { locale: string; filePath: string }[] {
  const messagesDir = path.resolve(__dirname, "../../../messages");
  if (!fs.existsSync(messagesDir)) return [];
  return fs
    .readdirSync(messagesDir)
    .filter((f) => f.endsWith(".json") && f !== "en.json")
    .map((f) => ({ locale: f.replace(".json", ""), filePath: path.join(messagesDir, f) }));
}

describe("i18n message dictionaries", () => {
  const enKeys = collectKeys(en as NestedObject);
  const plKeys = collectKeys(pl as NestedObject);

  it("en.json has at least 100 translation keys", () => {
    expect(enKeys.length).toBeGreaterThanOrEqual(100);
  });

  it("pl.json has at least 100 translation keys", () => {
    expect(plKeys.length).toBeGreaterThanOrEqual(100);
  });

  it("en.json and pl.json have identical key sets", () => {
    const missingInPl = enKeys.filter((k) => !plKeys.includes(k));
    const extraInPl = plKeys.filter((k) => !enKeys.includes(k));

    if (missingInPl.length > 0 || extraInPl.length > 0) {
      const msg = [
        missingInPl.length > 0
          ? `Missing in pl.json:\n  ${missingInPl.join("\n  ")}`
          : "",
        extraInPl.length > 0
          ? `Extra in pl.json:\n  ${extraInPl.join("\n  ")}`
          : "",
      ]
        .filter(Boolean)
        .join("\n\n");
      expect.fail(msg);
    }
  });

  it("all en.json leaf values are non-empty strings", () => {
    for (const key of enKeys) {
      const value = key
        .split(".")
        .reduce<unknown>(
          (obj, k) => (obj as NestedObject)?.[k],
          en as NestedObject,
        );
      expect(value, `en.json key "${key}" should be a non-empty string`).toSatisfy(
        (v: unknown) => typeof v === "string" && v.length > 0,
      );
    }
  });

  it("all pl.json leaf values are non-empty strings", () => {
    for (const key of plKeys) {
      const value = key
        .split(".")
        .reduce<unknown>(
          (obj, k) => (obj as NestedObject)?.[k],
          pl as NestedObject,
        );
      expect(value, `pl.json key "${key}" should be a non-empty string`).toSatisfy(
        (v: unknown) => typeof v === "string" && v.length > 0,
      );
    }
  });

  it("pl.json values differ from en.json for locale-specific keys", () => {
    // At minimum, the nav items should be translated
    const keysToCheck = ["nav.home", "nav.search", "nav.scan", "nav.lists", "nav.settings"];
    for (const key of keysToCheck) {
      const enVal = key
        .split(".")
        .reduce<unknown>(
          (obj, k) => (obj as NestedObject)?.[k],
          en as NestedObject,
        );
      const plVal = key
        .split(".")
        .reduce<unknown>(
          (obj, k) => (obj as NestedObject)?.[k],
          pl as NestedObject,
        );
      expect(plVal, `pl.json "${key}" should differ from en.json`).not.toBe(enVal);
    }
  });

  it("interpolation placeholders are preserved in Polish translations", () => {
    // Check that keys with {param} in English also have the same {param} in Polish
    const paramRegex = /\{(\w+)\}/g;
    for (const key of enKeys) {
      const enVal = key
        .split(".")
        .reduce<unknown>(
          (obj, k) => (obj as NestedObject)?.[k],
          en as NestedObject,
        ) as string;
      const plVal = key
        .split(".")
        .reduce<unknown>(
          (obj, k) => (obj as NestedObject)?.[k],
          pl as NestedObject,
        ) as string;

      const enParams = [...enVal.matchAll(paramRegex)].map((m) => m[1]).sort();
      const plParams = [...plVal.matchAll(paramRegex)].map((m) => m[1]).sort();

      if (enParams.length > 0) {
        expect(plParams, `pl.json "${key}" should have same {params} as en.json`).toEqual(
          enParams,
        );
      }
    }
  });

  // ─── Tooltip content coverage (#46) ───────────────────────────────────────
  // Ensure all required tooltip namespaces and keys exist in both locales
  // with proper content (not just non-empty strings).

  const REQUIRED_TOOLTIP_NAMESPACES = [
    "tooltip.nutriScore",
    "tooltip.nova",
    "tooltip.score",
    "tooltip.confidence",
    "tooltip.concern",
    "tooltip.allergen",
    "tooltip.nutrient",
    "tooltip.warning",
    "tooltip.scoreBreakdown",
  ] as const;

  const REQUIRED_TOOLTIP_KEYS = [
    // Nutri-Score grades
    "tooltip.nutriScore.A",
    "tooltip.nutriScore.B",
    "tooltip.nutriScore.C",
    "tooltip.nutriScore.D",
    "tooltip.nutriScore.E",
    "tooltip.nutriScore.unknown",
    "tooltip.nutriScore.learnMore",
    // NOVA groups
    "tooltip.nova.1",
    "tooltip.nova.2",
    "tooltip.nova.3",
    "tooltip.nova.4",
    // Score bands
    "tooltip.score.green",
    "tooltip.score.yellow",
    "tooltip.score.orange",
    "tooltip.score.red",
    "tooltip.score.darkred",
    // Confidence
    "tooltip.confidence.high",
    "tooltip.confidence.medium",
    "tooltip.confidence.low",
    // Concern tiers
    "tooltip.concern.0",
    "tooltip.concern.1",
    "tooltip.concern.2",
    "tooltip.concern.3",
    // Allergen statuses
    "tooltip.allergen.present",
    "tooltip.allergen.traces",
    "tooltip.allergen.free",
    // Nutrient traffic light
    "tooltip.nutrient.low",
    "tooltip.nutrient.medium",
    "tooltip.nutrient.high",
    // Warning thresholds
    "tooltip.warning.highSugar",
    "tooltip.warning.highSalt",
    "tooltip.warning.highFat",
    "tooltip.warning.highSatFat",
    // Score breakdown UI
    "tooltip.scoreBreakdown.title",
    "tooltip.scoreBreakdown.error",
    "tooltip.scoreBreakdown.rank",
    "tooltip.scoreBreakdown.categoryAvg",
  ] as const;

  it("en.json contains all required tooltip namespaces", () => {
    for (const ns of REQUIRED_TOOLTIP_NAMESPACES) {
      const tooltipKeys = enKeys.filter((k) => k.startsWith(`${ns}.`));
      expect(
        tooltipKeys.length,
        `en.json should have keys under "${ns}"`,
      ).toBeGreaterThan(0);
    }
  });

  it("pl.json contains all required tooltip namespaces", () => {
    for (const ns of REQUIRED_TOOLTIP_NAMESPACES) {
      const tooltipKeys = plKeys.filter((k) => k.startsWith(`${ns}.`));
      expect(
        tooltipKeys.length,
        `pl.json should have keys under "${ns}"`,
      ).toBeGreaterThan(0);
    }
  });

  it("all required tooltip keys exist in en.json", () => {
    const missing = REQUIRED_TOOLTIP_KEYS.filter((k) => !enKeys.includes(k));
    if (missing.length > 0) {
      expect.fail(
        `Missing required tooltip keys in en.json:\n  ${missing.join("\n  ")}`,
      );
    }
  });

  it("all required tooltip keys exist in pl.json", () => {
    const missing = REQUIRED_TOOLTIP_KEYS.filter((k) => !plKeys.includes(k));
    if (missing.length > 0) {
      expect.fail(
        `Missing required tooltip keys in pl.json:\n  ${missing.join("\n  ")}`,
      );
    }
  });

  it("en.json and pl.json have identical tooltip key sets", () => {
    const enTooltipKeys = enKeys.filter((k) => k.startsWith("tooltip."));
    const plTooltipKeys = plKeys.filter((k) => k.startsWith("tooltip."));
    const missingInPl = enTooltipKeys.filter((k) => !plTooltipKeys.includes(k));
    const extraInPl = plTooltipKeys.filter((k) => !enTooltipKeys.includes(k));

    if (missingInPl.length > 0 || extraInPl.length > 0) {
      const msg = [
        missingInPl.length > 0
          ? `Tooltip keys missing in pl.json:\n  ${missingInPl.join("\n  ")}`
          : "",
        extraInPl.length > 0
          ? `Extra tooltip keys in pl.json:\n  ${extraInPl.join("\n  ")}`
          : "",
      ]
        .filter(Boolean)
        .join("\n\n");
      expect.fail(msg);
    }
  });

  it("no tooltip key is an empty string in en.json", () => {
    const tooltipKeys = enKeys.filter((k) => k.startsWith("tooltip."));
    for (const key of tooltipKeys) {
      const value = key
        .split(".")
        .reduce<unknown>(
          (obj, k) => (obj as NestedObject)?.[k],
          en as NestedObject,
        );
      expect(
        value,
        `en.json tooltip key "${key}" should be a non-empty string`,
      ).toSatisfy((v: unknown) => typeof v === "string" && v.length > 0);
    }
  });

  it("no tooltip key is an empty string in pl.json", () => {
    const tooltipKeys = plKeys.filter((k) => k.startsWith("tooltip."));
    for (const key of tooltipKeys) {
      const value = key
        .split(".")
        .reduce<unknown>(
          (obj, k) => (obj as NestedObject)?.[k],
          pl as NestedObject,
        );
      expect(
        value,
        `pl.json tooltip key "${key}" should be a non-empty string`,
      ).toSatisfy((v: unknown) => typeof v === "string" && v.length > 0);
    }
  });

  it("tooltip.warning keys use {value} interpolation in both locales", () => {
    const warningKeys = REQUIRED_TOOLTIP_KEYS.filter((k) =>
      k.startsWith("tooltip.warning."),
    );
    for (const key of warningKeys) {
      const enVal = key
        .split(".")
        .reduce<unknown>(
          (obj, k) => (obj as NestedObject)?.[k],
          en as NestedObject,
        ) as string;
      const plVal = key
        .split(".")
        .reduce<unknown>(
          (obj, k) => (obj as NestedObject)?.[k],
          pl as NestedObject,
        ) as string;

      expect(enVal, `en.json "${key}" should contain {value}`).toContain("{value}");
      expect(plVal, `pl.json "${key}" should contain {value}`).toContain("{value}");
    }
  });

  // ─── Dynamic locale parity (hard fail for any new language file) ────────
  // If someone adds de.json (or any other locale), every key in en.json must
  // exist in that file and vice-versa.  Missing or extra keys → test failure.
  const localeFiles = discoverLocaleFiles();
  for (const { locale, filePath } of localeFiles) {
    // Skip pl.json — already checked exhaustively above
    if (locale === "pl") continue;

    describe(`${locale}.json parity with en.json`, () => {
      const raw = JSON.parse(fs.readFileSync(filePath, "utf-8")) as NestedObject;
      const localeKeys = collectKeys(raw);

      it(`${locale}.json has identical key set to en.json`, () => {
        const missing = enKeys.filter((k) => !localeKeys.includes(k));
        const extra = localeKeys.filter((k) => !enKeys.includes(k));

        if (missing.length > 0 || extra.length > 0) {
          const msg = [
            missing.length > 0
              ? `Missing in ${locale}.json:\n  ${missing.join("\n  ")}`
              : "",
            extra.length > 0
              ? `Extra in ${locale}.json:\n  ${extra.join("\n  ")}`
              : "",
          ]
            .filter(Boolean)
            .join("\n\n");
          expect.fail(msg);
        }
      });

      it(`all ${locale}.json leaf values are non-empty strings`, () => {
        for (const key of localeKeys) {
          const value = key
            .split(".")
            .reduce<unknown>(
              (obj, k) => (obj as NestedObject)?.[k],
              raw,
            );
          expect(
            value,
            `${locale}.json key "${key}" should be a non-empty string`,
          ).toSatisfy((v: unknown) => typeof v === "string" && v.length > 0);
        }
      });

      it(`${locale}.json preserves interpolation placeholders from en.json`, () => {
        const paramRegex = /\{(\w+)\}/g;
        for (const key of enKeys) {
          if (!localeKeys.includes(key)) continue;
          const enVal = key
            .split(".")
            .reduce<unknown>(
              (obj, k) => (obj as NestedObject)?.[k],
              en as NestedObject,
            ) as string;
          const localeVal = key
            .split(".")
            .reduce<unknown>(
              (obj, k) => (obj as NestedObject)?.[k],
              raw,
            ) as string;

          const enParams = [...enVal.matchAll(paramRegex)].map((m) => m[1]).sort();
          const localeParams = [...localeVal.matchAll(paramRegex)].map((m) => m[1]).sort();

          if (enParams.length > 0) {
            expect(
              localeParams,
              `${locale}.json "${key}" should have same {params} as en.json`,
            ).toEqual(enParams);
          }
        }
      });
    });
  }
});
