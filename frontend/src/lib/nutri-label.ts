// ─── Nutri-Score display-label utility ──────────────────────────────────────
// Centralised mapping so raw DB values like "NOT-APPLICABLE" never leak to UI.

const VALID_GRADES = new Set(["A", "B", "C", "D", "E"]);

/**
 * Convert a raw nutri_score value into a user-friendly display label.
 *
 * - Valid grades (A–E) pass through unchanged.
 * - "NOT-APPLICABLE" and any other unknown value become `fallback`.
 *
 * @param raw  The raw nutri_score value from the database
 * @param fallback  What to show for non-standard values (default: "N/A")
 */
export function nutriScoreLabel(
  raw: string | null | undefined,
  fallback = "N/A",
): string {
  if (!raw) return fallback;
  const upper = raw.toUpperCase();
  return VALID_GRADES.has(upper) ? upper : fallback;
}
