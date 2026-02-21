/**
 * OCR Privacy — Image data cleanup and privacy utilities.
 * Issue #55 — Image Search v0
 *
 * Re-exports releaseImageData from image-policy/enforcement.ts (single source
 * of truth) and adds OCR-specific privacy helpers like the consent flag.
 */

export { releaseImageData } from "@/lib/image-policy/enforcement";

/* ── Consent persistence ──────────────────────────────────────────────────── */

const CONSENT_KEY = "fooddb:image-search-privacy-accepted";

/**
 * Check if the user has previously accepted the image search privacy notice.
 * Returns `true` on the server (SSR) to avoid hydration mismatch — actual
 * gating happens in an effect.
 */
export function hasPrivacyConsent(): boolean {
  if (globalThis.window === undefined) return true;
  return localStorage.getItem(CONSENT_KEY) === "1";
}

/** Record that the user accepted the privacy notice. */
export function acceptPrivacyConsent(): void {
  if (globalThis.window === undefined) return;
  localStorage.setItem(CONSENT_KEY, "1");
}

/** Clear consent (for testing or settings reset). */
export function revokePrivacyConsent(): void {
  if (globalThis.window === undefined) return;
  localStorage.removeItem(CONSENT_KEY);
}
