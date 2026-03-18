// ─── Relative Time Formatting ───────────────────────────────────────────────
// Formats a Date into a human-readable relative string ("2 min ago", "1h ago").
// Falls back to a short absolute date for anything older than 7 days.

const MINUTE = 60;
const HOUR = 3600;
const DAY = 86400;

/**
 * Returns a short relative timestamp string for the given date.
 * - < 1 min → "just now"
 * - < 60 min → "Xm ago"
 * - < 24 h → "Xh ago"
 * - < 7 d → "Xd ago"
 * - ≥ 7 d → short locale date (e.g. "Mar 5")
 */
export function formatRelativeTime(date: Date, now: Date = new Date()): string {
  const diffSec = Math.max(0, Math.floor((now.getTime() - date.getTime()) / 1000));

  if (diffSec < MINUTE) return "just now";
  if (diffSec < HOUR) return `${Math.floor(diffSec / MINUTE)}m ago`;
  if (diffSec < DAY) return `${Math.floor(diffSec / HOUR)}h ago`;
  if (diffSec < DAY * 7) return `${Math.floor(diffSec / DAY)}d ago`;

  return date.toLocaleDateString(undefined, { month: "short", day: "numeric" });
}
