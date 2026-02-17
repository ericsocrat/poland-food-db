/**
 * Recent-searches — localStorage-backed recent search history.
 *
 * Privacy: searches never leave the device.
 * - Max entries: 10 (FIFO).
 * - All operations wrapped in try/catch for private-browsing safety.
 * - Clearing/corruption → silent reset.
 */

const STORAGE_KEY = "fooddb:recent-searches";
const MAX_ENTRIES = 10;

// ─── Public API ─────────────────────────────────────────────────────────────

/** Read recent searches from localStorage (most recent first). */
export function getRecentSearches(): string[] {
  if (globalThis.localStorage === undefined) return [];
  try {
    const raw = globalThis.localStorage.getItem(STORAGE_KEY);
    if (!raw) return [];
    const parsed: unknown = JSON.parse(raw);
    if (!Array.isArray(parsed)) return [];
    return parsed.filter((v): v is string => typeof v === "string");
  } catch {
    return [];
  }
}

/**
 * Add a search query to the top of recent searches.
 * Deduplicates (moves existing entry to front) and trims to MAX_ENTRIES.
 */
export function addRecentSearch(query: string): void {
  if (globalThis.localStorage === undefined) return;
  const trimmed = query.trim();
  if (trimmed.length === 0) return;
  try {
    const prev = getRecentSearches().filter((s) => s !== trimmed);
    const next = [trimmed, ...prev].slice(0, MAX_ENTRIES);
    globalThis.localStorage.setItem(STORAGE_KEY, JSON.stringify(next));
  } catch {
    // Quota exceeded or private browsing — silently fail
  }
}

/** Remove a single entry from recent searches. */
export function removeRecentSearch(query: string): void {
  if (globalThis.localStorage === undefined) return;
  try {
    const next = getRecentSearches().filter((s) => s !== query);
    globalThis.localStorage.setItem(STORAGE_KEY, JSON.stringify(next));
  } catch {
    // Silently fail
  }
}

/** Clear all recent searches. */
export function clearRecentSearches(): void {
  if (globalThis.localStorage === undefined) return;
  try {
    globalThis.localStorage.removeItem(STORAGE_KEY);
  } catch {
    // Silently fail
  }
}

/** Exported constants for testing. */
export const RECENT_SEARCHES_KEY = STORAGE_KEY;
export const RECENT_SEARCHES_MAX = MAX_ENTRIES;
