// ─── Nutri-Score display-label utility ──────────────────────────────────────
// Centralised mapping so raw DB values like "NOT-APPLICABLE" never leak to UI.

const VALID_GRADES = new Set(["A", "B", "C", "D", "E"]);

/**
 * Convert a raw nutri_score value into a user-friendly display label.
 *
 * - Valid grades (A–E) pass through unchanged.
 * - "NOT-APPLICABLE" returns `notApplicableFallback` (category exempt).
 * - "UNKNOWN" and any other value returns `fallback` (data missing).
 *
 * @param raw  The raw nutri_score value from the database
 * @param fallback  What to show for UNKNOWN / unrecognised values (default: "N/A")
 * @param notApplicableFallback  What to show for NOT-APPLICABLE (defaults to `fallback`)
 */
export function nutriScoreLabel(
  raw: string | null | undefined,
  fallback = "N/A",
  notApplicableFallback?: string,
): string {
  if (!raw) return fallback;
  const upper = raw.toUpperCase();
  if (VALID_GRADES.has(upper)) return upper;
  if (upper === "NOT-APPLICABLE") return notApplicableFallback ?? fallback;
  return fallback;
}
