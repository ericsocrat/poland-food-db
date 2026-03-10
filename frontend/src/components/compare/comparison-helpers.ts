// ─── Pure comparison helpers — extracted for testability ────────────────────
// Used by ComparisonGrid.tsx. All functions are side-effect-free.

import type { CellValue, CompareProduct } from "@/lib/types";

// ─── Format helpers ─────────────────────────────────────────────────────────

/** Format a nullable value with a unit, or return fallback. */
export function fmtUnit(v: CellValue, unit: string, fallback = "—"): string {
  return v == null ? fallback : `${v} ${unit}`;
}

/** Format a nullable value as string, or return fallback. */
export function fmtStr(v: CellValue, fallback = "—"): string {
  return v == null ? fallback : String(v);
}

// ─── Ranking helpers ────────────────────────────────────────────────────────

export interface IndexedValue {
  idx: number;
  val: number;
}

/** Collect non-null numeric entries with their indices. */
export function filterNumericEntries(
  values: (number | null)[],
): IndexedValue[] {
  const result: IndexedValue[] = [];
  for (let i = 0; i < values.length; i++) {
    const v = values[i];
    if (typeof v === "number") result.push({ idx: i, val: v });
  }
  return result;
}

/** Find the min or max entry in a non-empty array. */
export function findExtreme(
  entries: IndexedValue[],
  mode: "min" | "max",
): IndexedValue {
  let result = entries[0];
  for (const entry of entries) {
    const isBetter =
      mode === "min" ? entry.val < result.val : entry.val > result.val;
    if (isBetter) result = entry;
  }
  return result;
}

/** Get the index of the product with the lowest unhealthiness score. */
export function getWinnerIndex(products: CompareProduct[]): number {
  let bestIdx = 0;
  let bestScore = products[0].unhealthiness_score;
  for (let i = 1; i < products.length; i++) {
    if (products[i].unhealthiness_score < bestScore) {
      bestScore = products[i].unhealthiness_score;
      bestIdx = i;
    }
  }
  return bestIdx;
}

/** Determine best/worst indices for a row of values. */
export function getBestWorst(
  values: (number | null)[],
  direction: "lower" | "higher" | "none",
): { bestIdx: number; worstIdx: number } | null {
  if (direction === "none") return null;

  const valid = filterNumericEntries(values);
  if (valid.length < 2) return null;

  const bestMode = direction === "lower" ? "min" : "max";
  const worstMode = direction === "lower" ? "max" : "min";
  const best = findExtreme(valid, bestMode);
  const worst = findExtreme(valid, worstMode);

  // Don't highlight if all values are equal
  if (best.val === worst.val) return null;

  return { bestIdx: best.idx, worstIdx: worst.idx };
}

/** Collect warning flags for a single product. */
export function getProductWarnings(p: CompareProduct): string[] {
  const flags: string[] = [];
  if (p.high_salt) flags.push("🧂 High Salt");
  if (p.high_sugar) flags.push("🍬 High Sugar");
  if (p.high_sat_fat) flags.push("🧈 High Sat Fat");
  if (p.high_additive_load) flags.push("⚗️ Additives");
  return flags;
}

/** Determine CSS class for a comparison cell based on ranking. */
export function getCellHighlightClass(
  idx: number,
  ranking: { bestIdx: number; worstIdx: number } | null,
  winnerIdx: number,
): string {
  if (idx === ranking?.bestIdx)
    return "bg-success-bg text-success-text font-semibold";
  if (idx === ranking?.worstIdx) return "bg-error-bg text-error-text";
  if (idx === winnerIdx) return "bg-success-bg/30";
  return "";
}

// ─── Key differences ────────────────────────────────────────────────────────

export interface KeyDifference {
  /** Row label (display name) */
  label: string;
  /** i18n key for the row label */
  labelKey: string;
  /** Raw values per product */
  values: number[];
  /** Unit suffix (e.g. "g", "kcal") */
  unit?: string;
  /** Index of the product with the better value */
  betterIdx: number;
  /** Absolute difference between best and worst */
  absoluteDiff: number;
  /** 'lower' or 'higher' — which direction is better */
  betterDirection: "lower" | "higher";
}

/** Nutrient row definition for key-differences extraction. */
interface NutrientRow {
  label: string;
  labelKey: string;
  key: keyof CompareProduct;
  betterDirection: "lower" | "higher";
  unit?: string;
  /** Maximum realistic value for normalization (per 100g) */
  ceiling: number;
}

const NUTRIENT_ROWS: NutrientRow[] = [
  { label: "Calories", labelKey: "product.caloriesLabel", key: "calories", betterDirection: "lower", unit: "kcal", ceiling: 600 },
  { label: "Total Fat", labelKey: "product.totalFat", key: "total_fat_g", betterDirection: "lower", unit: "g", ceiling: 50 },
  { label: "Saturated Fat", labelKey: "product.saturatedFat", key: "saturated_fat_g", betterDirection: "lower", unit: "g", ceiling: 25 },
  { label: "Sugars", labelKey: "product.sugars", key: "sugars_g", betterDirection: "lower", unit: "g", ceiling: 50 },
  { label: "Salt", labelKey: "product.salt", key: "salt_g", betterDirection: "lower", unit: "g", ceiling: 5 },
  { label: "Fibre", labelKey: "product.fibre", key: "fibre_g", betterDirection: "higher", unit: "g", ceiling: 15 },
  { label: "Protein", labelKey: "product.protein", key: "protein_g", betterDirection: "higher", unit: "g", ceiling: 40 },
  { label: "Additives", labelKey: "product.additives", key: "additives_count", betterDirection: "lower", ceiling: 10 },
];

/**
 * Identify the top-N most different nutrients between products.
 * Uses ceiling-normalized absolute difference to rank significance.
 * Only works with 2+ products; returns empty array otherwise.
 */
export function getKeyDifferences(
  products: CompareProduct[],
  maxResults = 5,
): KeyDifference[] {
  if (products.length < 2) return [];

  const diffs: (KeyDifference & { normalizedDiff: number })[] = [];

  for (const row of NUTRIENT_ROWS) {
    const values = products.map((p) => {
      const v = p[row.key];
      return typeof v === "number" ? v : null;
    });

    const valid = filterNumericEntries(values as (number | null)[]);
    if (valid.length < 2) continue;

    const best = findExtreme(valid, row.betterDirection === "lower" ? "min" : "max");
    const worst = findExtreme(valid, row.betterDirection === "lower" ? "max" : "min");

    const absDiff = Math.abs(best.val - worst.val);
    if (absDiff === 0) continue;

    diffs.push({
      label: row.label,
      labelKey: row.labelKey,
      values: values.map((v) => v ?? 0),
      unit: row.unit,
      betterIdx: best.idx,
      absoluteDiff: absDiff,
      betterDirection: row.betterDirection,
      normalizedDiff: absDiff / row.ceiling,
    });
  }

  diffs.sort((a, b) => b.normalizedDiff - a.normalizedDiff);
  return diffs.slice(0, maxResults).map(({ normalizedDiff: _, ...rest }) => rest);
}
