// ─── Achievement Map — event → achievement slug mapping ──────────────────────
// Issue #52: Telemetry Mapping for Achievements
//
// Single source of truth: every event→achievement link lives here.
// Adding a new achievement trigger = add one row to the table below.

import type { AppEvent } from "./types";

export interface AchievementMapping {
  /** Which event type triggers this mapping */
  event: AppEvent["type"];
  /** Which achievement to increment */
  achievementSlug: string;
  /** How much to increment progress by */
  increment: number;
  /** Optional guard — event only counts when this returns true */
  condition?: (payload: Record<string, unknown>) => boolean;
}

/* ── Condition guards ─────────────────────────────────────────────────────── */

/** Product viewed with unhealthiness score ≤ 30 (i.e. unhealthy product). */
const isLowScoreProduct = (p: Record<string, unknown>): boolean =>
  typeof p.score === "number" && p.score <= 30;

/* ── Compact mapping builder ──────────────────────────────────────────────── */

type MappingTuple = [
  event: AppEvent["type"],
  slug: string,
  condition?: (p: Record<string, unknown>) => boolean,
];

function buildMap(entries: MappingTuple[]): AchievementMapping[] {
  return entries.map(([event, achievementSlug, condition]) => ({
    event,
    achievementSlug,
    increment: 1,
    ...(condition && { condition }),
  }));
}

/**
 * Canonical mapping of app events to achievement progress increments.
 * Covers all 16 client-trackable v1 achievements defined in Issue #51.
 *
 * Note: "all_exploration" and "all_health" are meta-achievements
 * that can only be detected server-side once all sub-achievements
 * are unlocked. They are deliberately excluded from client-side tracking.
 */
export const ACHIEVEMENT_MAP: readonly AchievementMapping[] = buildMap([
  // ── Exploration ────────────────────────────────────────────────────────
  ["product.scanned", "first_scan"],
  ["product.scanned", "scan_10"],
  ["product.scanned", "scan_50"],
  ["product.searched", "first_search"],
  ["category.viewed", "explore_5_categories"],
  // ── Health ─────────────────────────────────────────────────────────────
  ["product.viewed", "first_low_score", isLowScoreProduct],
  ["product.viewed", "low_score_10", isLowScoreProduct],
  ["product.compared", "compare_products"],
  ["product.compared", "compare_10"],
  ["filter.allergen_applied", "allergen_filter"],
  // ── Engagement ─────────────────────────────────────────────────────────
  ["list.created", "first_list"],
  ["product.added_to_list", "list_10_products"],
  ["product.submitted", "first_submission"],
  ["product.shared", "share_product"],
  ["session.weekly_visit", "weekly_streak_4"],
  // ── Mastery ────────────────────────────────────────────────────────────
  ["learn.page_viewed", "read_learn_page"],
]);

/* ── Helpers ───────────────────────────────────────────────────────────────── */

/** All achievement slugs covered by the mapping (for test assertions). */
export const MAPPED_SLUGS = [
  ...new Set(ACHIEVEMENT_MAP.map((m) => m.achievementSlug)),
];

/** All unique event types referenced in the mapping. */
export const MAPPED_EVENT_TYPES = [
  ...new Set(ACHIEVEMENT_MAP.map((m) => m.event)),
];
