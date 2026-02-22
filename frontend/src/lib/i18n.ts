// ─── i18n: translation hook & utilities ─────────────────────────────────────
// Provides useTranslation() which reads the current language from the Zustand
// store and returns a `t()` function for looking up translated strings.
//
// Design choices:
//  - Static imports for en/pl (small dictionaries, always needed).
//  - Dot-notation key lookup: t("nav.home"), t("common.pageOf", { page: 1, pages: 5 }).
//  - Falls back to English if key missing in target language.
//  - Dev-mode warning for missing keys.
//  - Pure function `translate()` exported for non-hook contexts (tests, SSR).

import { useCallback, useMemo } from "react";
import { useLanguageStore, type SupportedLanguage } from "@/stores/language-store";
import en from "@/../messages/en.json";
import pl from "@/../messages/pl.json";

// ─── Types ──────────────────────────────────────────────────────────────────

/** Nested JSON dictionary shape. */
type MessageDictionary = Record<string, unknown>;

/** Interpolation parameters: `{ page: 1, pages: 5 }` → replaces `{page}`, `{pages}`. */
type InterpolationParams = Record<string, string | number>;

// ─── Dictionary registry ───────────────────────────────────────────────────

const DICTIONARIES: Record<string, MessageDictionary> = {
  en: en as MessageDictionary,
  pl: pl as MessageDictionary,
};

// ─── Internal helpers ───────────────────────────────────────────────────────

/**
 * Walk a dot-separated key path into a nested object.
 * Returns `undefined` if any segment is missing.
 */
function resolve(dict: MessageDictionary, key: string): string | undefined {
  const parts = key.split(".");
  let current: unknown = dict;

  for (const part of parts) {
    if (current === null || current === undefined || typeof current !== "object") {
      return undefined;
    }
    current = (current as Record<string, unknown>)[part];
  }

  return typeof current === "string" ? current : undefined;
}

/**
 * Replace `{param}` placeholders with provided values.
 */
function interpolate(template: string, params?: InterpolationParams): string {
  if (!params) return template;
  return template.replaceAll(/\{(\w+)\}/g, (_, key: string) => {
    const value = params[key];
    return value === undefined ? `{${key}}` : String(value);
  });
}

// ─── Public API ─────────────────────────────────────────────────────────────

/**
 * Pure translation function — usable outside React components.
 *
 * @param language - Target language code.
 * @param key      - Dot-separated key, e.g. "nav.home".
 * @param params   - Optional interpolation params.
 * @returns Translated string, English fallback, or the key itself.
 */
export function translate(
  language: SupportedLanguage,
  key: string,
  params?: InterpolationParams,
): string {
  const dict = DICTIONARIES[language];

  // Try target language
  const value = dict ? resolve(dict, key) : undefined;
  if (value !== undefined) {
    return interpolate(value, params);
  }

  // Fallback to English
  if (language !== "en") {
    const fallback = resolve(DICTIONARIES.en, key);
    if (fallback !== undefined) {
      if (process.env.NODE_ENV === "development") {
        console.warn(`[i18n] Missing ${language} translation: "${key}" — using English fallback`);
      }
      return interpolate(fallback, params);
    }
  }

  // Key not found in any dictionary
  if (process.env.NODE_ENV === "development") {
    console.warn(`[i18n] Missing translation key: "${key}"`);
  }
  return humanizeKey(key);
}

/**
 * Convert a dot-separated i18n key into a human-readable fallback.
 *
 * Instead of showing raw keys like "recipes.items.overnight_oats.title"
 * to end users, extract the last meaningful segment and title-case it.
 * E.g. "recipes.items.overnight_oats.title" → "Overnight Oats"
 *      "nav.home" → "Home"
 *      "common.retry" → "Retry"
 *
 * @internal Exported for testing only.
 */
export function humanizeKey(key: string): string {
  const segments = key.split(".");
  // Use the second-to-last segment if the last is a generic word like "title"/"description"
  const GENERIC_SUFFIXES = new Set(["title", "description", "label", "placeholder", "name"]);
  let raw = segments.at(-1) ?? key;
  if (GENERIC_SUFFIXES.has(raw) && segments.length >= 2) {
    raw = segments.at(-2) ?? raw;
  }
  // Convert snake_case / kebab-case to Title Case
  return raw
    .replaceAll(/[-_]/g, " ")
    .replaceAll(/\b\w/g, (c) => c.toUpperCase());
}

/**
 * React hook for translations.
 *
 * @returns `{ t, language }` where `t(key, params?)` returns the translated string.
 *
 * @example
 * ```tsx
 * const { t } = useTranslation();
 * return <h1>{t("dashboard.title")}</h1>;
 * // With interpolation:
 * <p>{t("common.pageOf", { page: 1, pages: 5 })}</p>
 * ```
 */
export function useTranslation() {
  const language = useLanguageStore((s) => s.language);

  const t = useCallback(
    (key: string, params?: InterpolationParams) => translate(language, key, params),
    [language],
  );

  return useMemo(() => ({ t, language }), [t, language]);
}
