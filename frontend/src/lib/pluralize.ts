// ─── Pluralization Utilities ─────────────────────────────────────────────────
//
// Lightweight pluralization for English (2-form) and Polish (3-form).
// Used both standalone in components and indirectly via the i18n interpolation
// engine (`{count|singular|plural}` syntax in translation values).
//
// Polish plural rules (CLDR):
//   one  → count === 1
//   few  → count % 10 ∈ {2,3,4} AND count % 100 ∉ {12,13,14}
//   many → everything else (includes 0, 5–21, 25–31, …)
//
// Reference: https://www.unicode.org/cldr/charts/latest/supplemental/language_plural_rules.html
// ─────────────────────────────────────────────────────────────────────────────

/**
 * English (2-form) pluralization.
 *
 * @example pluralize(1, "ingredient", "ingredients") → "1 ingredient"
 * @example pluralize(5, "ingredient", "ingredients") → "5 ingredients"
 */
export function pluralize(
  count: number,
  singular: string,
  plural: string,
): string {
  return `${count} ${count === 1 ? singular : plural}`;
}

/**
 * Polish (3-form) pluralization.
 *
 * @example pluralizePl(1, "składnik", "składniki", "składników") → "1 składnik"
 * @example pluralizePl(3, "składnik", "składniki", "składników") → "3 składniki"
 * @example pluralizePl(5, "składnik", "składniki", "składników") → "5 składników"
 */
export function pluralizePl(
  count: number,
  one: string,
  few: string,
  many: string,
): string {
  return `${count} ${selectPolishForm(count, one, few, many)}`;
}

/**
 * Select the correct Polish plural form WITHOUT prepending the count.
 * Exported for use by the i18n interpolation engine.
 */
export function selectPolishForm(
  count: number,
  one: string,
  few: string,
  many: string,
): string {
  if (count === 1) return one;
  const mod10 = Math.abs(count) % 10;
  const mod100 = Math.abs(count) % 100;
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return few;
  return many;
}
