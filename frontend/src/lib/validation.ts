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
 * Returns true if `code` is a valid EAN‑8, UPC‑A (12), or EAN‑13 string.
 */
export function isValidEan(code: string): boolean {
  return /^\d{8}$|^\d{12,13}$/.test(code);
}

/**
 * Compute the GS1 check digit for an EAN-8, UPC-A, or EAN-13 barcode.
 * Pass the full code (including check digit position) or just the payload digits.
 * Returns the expected check digit (0–9).
 */
export function computeEanCheckDigit(digits: string): number {
  const stripped = digits.replace(/\D/g, "");
  // Use up to 12 (EAN-13) or 7 (EAN-8) payload digits
  const payload = stripped.length >= 12 ? stripped.slice(0, 12) : stripped.slice(0, 7);
  let sum = 0;
  const isEan13 = payload.length >= 12;
  for (let i = 0; i < payload.length; i++) {
    const digit = Number(payload[i]);
    // EAN-13/UPC-A: positions 0,2,4… weight 1; positions 1,3,5… weight 3
    // EAN-8: positions 0,2,4,6 weight 3; positions 1,3,5 weight 1
    const weight = isEan13 ? (i % 2 === 0 ? 1 : 3) : (i % 2 === 0 ? 3 : 1);
    sum += digit * weight;
  }
  return (10 - (sum % 10)) % 10;
}

/**
 * Validate the check digit of a full EAN-8, UPC-A, or EAN-13 barcode.
 * Returns true if the last digit matches the computed check digit.
 */
export function isValidEanChecksum(code: string): boolean {
  if (!/^\d{8}$|^\d{12,13}$/.test(code)) return false;
  const expected = computeEanCheckDigit(code);
  return Number(code[code.length - 1]) === expected;
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
