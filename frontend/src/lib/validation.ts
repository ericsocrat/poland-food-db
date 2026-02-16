// ─── Pure helpers — no framework deps, easy to unit-test ────────────────────

/**
 * Sanitize a redirect parameter to prevent open-redirect attacks.
 * Only relative paths (starting with "/" but NOT "//") are allowed.
 * Returns the fallback if the raw value is missing or invalid.
 */
export function sanitizeRedirect(
  raw: string | null | undefined,
  fallback = "/app/search",
): string {
  if (!raw) return fallback;
  if (raw.startsWith("/") && !raw.startsWith("//")) return raw;
  return fallback;
}

/**
 * Returns true if `code` is a valid EAN‑8 or EAN‑13 string.
 */
export function isValidEan(code: string): boolean {
  return /^\d{8}$|^\d{13}$/.test(code);
}

/**
 * Strip non-digit characters from a string.
 * Useful for cleaning EAN input.
 */
export function stripNonDigits(value: string): string {
  return value.replaceAll(/\D/g, "");
}

/**
 * Convert a URL-safe slug (e.g. "seafood-fish") into a display name ("seafood fish").
 */
export function formatSlug(slug: string): string {
  return slug.replaceAll("-", " ").replaceAll("_", " ");
}
