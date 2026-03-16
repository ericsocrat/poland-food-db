// ─── Scanner Error Taxonomy — #889 Phase 1 ─────────────────────────────────
// Classifies camera/scanner errors into actionable types for telemetry
// and user-facing error messages.

/** All possible scanner error types. */
export type ScannerErrorType =
  | "permission-denied"
  | "no-camera"
  | "not-readable"
  | "overconstrained"
  | "stream-ended"
  | "library-load"
  | "unknown";

/**
 * Classify a caught error into a ScannerErrorType.
 *
 * Uses the Error.name when available, falling back to message matching
 * for non-standard browser implementations.
 */
export function classifyScannerError(err: unknown): ScannerErrorType {
  if (!err) return "unknown";

  const name =
    err instanceof Error
      ? err.name
      : typeof err === "object" && err !== null && "name" in err
        ? String((err as { name: unknown }).name)
        : "";

  const message =
    err instanceof Error
      ? err.message
      : typeof err === "object" && err !== null && "message" in err
        ? String((err as { message: unknown }).message)
        : String(err);

  // Permission denied by user or policy
  if (
    name === "NotAllowedError" ||
    name === "PermissionDeniedError" ||
    message.includes("Permission denied")
  ) {
    return "permission-denied";
  }

  // Camera hardware not readable (in use by another app, etc.)
  if (name === "NotReadableError" || name === "TrackStartError") {
    return "not-readable";
  }

  // Constraints cannot be satisfied (e.g., facingMode not available)
  if (name === "OverconstrainedError") {
    return "overconstrained";
  }

  // Dynamic import of @zxing/library failed
  if (name === "TypeError" && message.includes("import")) {
    return "library-load";
  }

  return "unknown";
}

/**
 * Map ScannerErrorType → i18n message key.
 *
 * These keys live under the `scannerError` namespace in messages/*.json.
 */
export function getErrorMessageKey(errorType: ScannerErrorType): string {
  const keys: Record<ScannerErrorType, string> = {
    "permission-denied": "scannerError.permissionDenied",
    "no-camera": "scannerError.noCamera",
    "not-readable": "scannerError.notReadable",
    overconstrained: "scannerError.overconstrained",
    "stream-ended": "scannerError.streamEnded",
    "library-load": "scannerError.libraryLoad",
    unknown: "scannerError.unknown",
  };
  return keys[errorType];
}

/**
 * Extract a short browser summary string from the user agent.
 * Returns something like "Chrome 120" or "Safari 17" — no raw UA.
 */
export function getBrowserSummary(): string {
  if (typeof navigator === "undefined") return "unknown";
  const ua = navigator.userAgent;
  // Order matters — check more specific strings first
  const browsers: [RegExp, string][] = [
    [/Edg\/(\d+)/, "Edge"],
    [/OPR\/(\d+)/, "Opera"],
    [/SamsungBrowser\/(\d+)/, "Samsung"],
    [/Firefox\/(\d+)/, "Firefox"],
    [/Chrome\/(\d+)/, "Chrome"],
    [/Version\/(\d+)[^ ]* Safari/, "Safari"],
  ];
  for (const [regex, name] of browsers) {
    const match = ua.match(regex);
    if (match) return `${name} ${match[1]}`;
  }
  return "other";
}

/**
 * Detect facing mode from a MediaStreamTrack's settings.
 * Returns "environment", "user", or "unknown".
 */
export function getFacingMode(
  track: MediaStreamTrack | undefined,
): "environment" | "user" | "unknown" {
  if (!track) return "unknown";
  const settings = track.getSettings();
  if (settings.facingMode === "environment" || settings.facingMode === "user") {
    return settings.facingMode;
  }
  return "unknown";
}
