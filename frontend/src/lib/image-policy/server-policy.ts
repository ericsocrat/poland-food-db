// ─── Server-Side Image Policy — SCAFFOLD (not active in v0) ──────────────────
// All image processing in v0 is client-side only.
// This scaffold defines the policy framework for future server-side features
// (e.g., product photo submissions, community contributions).
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Server-side image retention policy.
 *
 * NOT ACTIVE IN v0 — all processing is client-side.
 * Activating this requires:
 *   1. Supabase Storage bucket creation
 *   2. RLS policies for the bucket
 *   3. Scheduled cleanup job (pg_cron or Edge Function)
 *   4. EXIF stripping middleware
 *   5. User consent flow updates
 */
export const SERVER_IMAGE_POLICY = {
  /** Maximum retention period for uploaded images (days) */
  maxRetentionDays: 30,

  /** Maximum image file size in bytes (5 MB) */
  maxFileSizeBytes: 5 * 1024 * 1024,

  /** Allowed MIME types for uploads */
  allowedMimeTypes: ["image/jpeg", "image/png", "image/webp"] as const,

  /** Strip EXIF metadata (location, device info) before storage */
  stripExif: true,

  /** Resize images to maximum dimension (px) before storage */
  maxDimensionPx: 1920,

  /** Supabase Storage bucket name */
  bucket: "product-images",

  /** Automatic cleanup job schedule */
  cleanupSchedule: "daily" as const,

  /** Require explicit user consent for each upload */
  requireConsent: true,
} as const;

/**
 * Validates an image file against the server policy.
 * Returns an array of validation errors (empty = valid).
 *
 * NOT ACTIVE IN v0.
 */
export function validateImageForUpload(file: File): string[] {
  const errors: string[] = [];

  if (file.size > SERVER_IMAGE_POLICY.maxFileSizeBytes) {
    const maxMB = SERVER_IMAGE_POLICY.maxFileSizeBytes / (1024 * 1024);
    errors.push(`File size exceeds ${maxMB}MB limit`);
  }

  const allowed = SERVER_IMAGE_POLICY.allowedMimeTypes as readonly string[];
  if (!allowed.includes(file.type)) {
    errors.push(
      `File type "${file.type}" not allowed. Accepted: ${allowed.join(", ")}`,
    );
  }

  return errors;
}
