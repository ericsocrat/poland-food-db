// ─── Error Classifier — Categorize errors for user-facing messages ──────
// Maps raw JavaScript errors to user-meaningful categories so the
// ErrorBoundary can show appropriate illustrations and messages.

export type ErrorCategory = "network" | "auth" | "server" | "unknown";

// Patterns that indicate a network/connectivity issue
const NETWORK_PATTERNS = [
  "failed to fetch",
  "networkerror",
  "network request failed",
  "load failed",
  "net::err_",
  "econnrefused",
  "dns_probe",
  "err_internet_disconnected",
  "err_network_changed",
  "the internet connection appears to be offline",
  "a network error occurred",
  "request timed out",
  "connection timed out",
  "aborted",
] as const;

// Patterns that indicate an auth/permission issue
const AUTH_PATTERNS = [
  "jwt expired",
  "jwt",
  "not authenticated",
  "unauthorized",
  "403",
  "401",
  "auth",
  "permission denied",
  "access denied",
  "invalid login",
  "session expired",
  "refresh_token",
  "pgrst301",
] as const;

/**
 * Classify an error into a user-facing category.
 *
 * Priority: network > auth > server > unknown
 * Server errors are identified by HTTP status codes (5xx) in the message.
 */
export function classifyError(error: Error): ErrorCategory {
  const msg = error.message.toLowerCase();
  const name = error.name.toLowerCase();
  const combined = `${name} ${msg}`;

  // Network errors take priority — if you're offline, auth doesn't matter
  if (NETWORK_PATTERNS.some((p) => combined.includes(p))) {
    return "network";
  }

  // Auth/permission errors
  if (AUTH_PATTERNS.some((p) => combined.includes(p))) {
    return "auth";
  }

  // Server errors (5xx status codes in message)
  if (/\b5\d{2}\b/.test(msg) || combined.includes("internal server error")) {
    return "server";
  }

  return "unknown";
}
