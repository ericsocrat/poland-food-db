// ─── Toast System — Typed wrapper around Sonner ─────────────────────────────
// Provides `showToast()` with i18n key resolution, rate limiting (dedupe by
// messageKey within 2s, max 3 per 10s window), and correct `aria-live` per type.
//
// Usage:
//   import { showToast } from "@/lib/toast";
//   showToast({ type: "success", messageKey: "lists.created" });
//   showToast({ type: "error", messageKey: "common.error", descriptionKey: "common.errorDescription" });
//   showToast({ type: "success", message: "✓ Chips Lay's" }); // raw string, no i18n

import { toast, type ExternalToast } from "sonner";
import { translate } from "@/lib/i18n";
import { useLanguageStore } from "@/stores/language-store";

// ─── Types ──────────────────────────────────────────────────────────────────

export type ToastType = "success" | "error" | "warning" | "info";

interface BaseToastOptions {
  /** Toast variant — determines color, icon, aria-live, and default duration. */
  type: ToastType;
  /** Optional i18n description key shown as secondary text. */
  descriptionKey?: string;
  /** Interpolation params for descriptionKey. */
  descriptionParams?: Record<string, string | number>;
  /** Override default duration (ms). */
  duration?: number;
  /** Optional CTA action button. */
  action?: { label: string; onClick: () => void };
}

interface I18nToastOptions extends BaseToastOptions {
  /** i18n key for the toast message — resolved via the current language. */
  messageKey: string;
  /** Interpolation params for messageKey. */
  messageParams?: Record<string, string | number>;
  message?: never;
}

interface RawToastOptions extends BaseToastOptions {
  /** Raw string message (already resolved). */
  message: string;
  messageKey?: never;
  messageParams?: never;
}

export type ToastOptions = I18nToastOptions | RawToastOptions;

// ─── Default durations per type ─────────────────────────────────────────────

const DEFAULT_DURATIONS: Record<ToastType, number> = {
  success: 5000,
  error: 8000,
  warning: 6000,
  info: 5000,
};

// ─── Rate limiter ───────────────────────────────────────────────────────────

/** Timestamps of recent fires per dedup key. */
const recentByKey = new Map<string, number>();

/** Timestamps of all fires in the rolling window. */
const windowTimestamps: number[] = [];

/** Dedupe window: same key within 2s → skip. */
const DEDUPE_WINDOW_MS = 2000;

/** Rolling window: max 3 toasts per 10s. */
const RATE_WINDOW_MS = 10_000;
const RATE_MAX = 3;

/**
 * Returns `true` if the toast should be suppressed by rate limiting.
 * Exported for testing.
 */
export function isRateLimited(dedupKey: string): boolean {
  const now = Date.now();

  // 1. Dedupe: same key within 2s → suppress
  const lastFire = recentByKey.get(dedupKey);
  if (lastFire !== undefined && now - lastFire < DEDUPE_WINDOW_MS) {
    return true;
  }

  // 2. Rolling window: max 3 in 10s → suppress
  // Evict stale entries
  while (windowTimestamps.length > 0 && now - windowTimestamps[0] > RATE_WINDOW_MS) {
    windowTimestamps.shift();
  }
  if (windowTimestamps.length >= RATE_MAX) {
    return true;
  }

  return false;
}

/** Record a fire for rate-limiting bookkeeping. */
function recordFire(dedupKey: string): void {
  const now = Date.now();
  recentByKey.set(dedupKey, now);
  windowTimestamps.push(now);

  // Lazy cleanup of old dedup entries
  if (recentByKey.size > 50) {
    for (const [key, ts] of recentByKey) {
      if (now - ts > DEDUPE_WINDOW_MS) recentByKey.delete(key);
    }
  }
}

/** Reset rate limiter state — used in tests. */
export function resetRateLimiter(): void {
  recentByKey.clear();
  windowTimestamps.length = 0;
}

// ─── Public API ─────────────────────────────────────────────────────────────

/**
 * Show a toast notification with type-appropriate styling, i18n, and rate limiting.
 *
 * @example
 * ```ts
 * showToast({ type: "success", messageKey: "lists.created" });
 * showToast({ type: "error", message: error.message });
 * showToast({
 *   type: "info",
 *   messageKey: "compare.saved",
 *   action: { label: "View", onClick: () => router.push("/compare/saved") },
 * });
 * ```
 */
export function showToast(options: ToastOptions): void {
  const { type, descriptionKey, descriptionParams, duration, action } = options;

  // Resolve message
  const language = useLanguageStore.getState().language;
  const message =
    "messageKey" in options && options.messageKey
      ? translate(language, options.messageKey, options.messageParams)
      : (options as RawToastOptions).message;

  // Dedupe key: prefer messageKey for i18n toasts, fall back to raw message
  const dedupKey =
    "messageKey" in options && options.messageKey ? options.messageKey : message;

  // Rate limiting
  if (isRateLimited(dedupKey)) return;
  recordFire(dedupKey);

  // Resolve optional description
  const description = descriptionKey
    ? translate(language, descriptionKey, descriptionParams)
    : undefined;

  // Build Sonner options
  const sonarOpts: ExternalToast = {
    description,
    duration: duration ?? DEFAULT_DURATIONS[type],
  };

  if (action) {
    sonarOpts.action = {
      label: action.label,
      onClick: action.onClick,
    };
  }

  // Dispatch to the correct Sonner function
  switch (type) {
    case "success":
      toast.success(message, sonarOpts);
      break;
    case "error":
      toast.error(message, sonarOpts);
      break;
    case "warning":
      toast.warning(message, sonarOpts);
      break;
    case "info":
      toast.info(message, sonarOpts);
      break;
  }
}
