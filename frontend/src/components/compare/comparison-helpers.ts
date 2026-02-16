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
    return "bg-green-50 text-green-700 font-semibold";
  if (idx === ranking?.worstIdx) return "bg-red-50 text-red-600";
  if (idx === winnerIdx) return "bg-green-50/30";
  return "";
}
