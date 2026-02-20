// ─── Achievement Map unit tests ──────────────────────────────────────────────
// Issue #52: Telemetry Mapping for Achievements

import { describe, it, expect } from "vitest";
import {
  ACHIEVEMENT_MAP,
  MAPPED_SLUGS,
  MAPPED_EVENT_TYPES,
} from "@/lib/events/achievement-map";

/** All 16 client-trackable v1 achievement slugs (excludes meta: all_exploration, all_health). */
const V1_CLIENT_SLUGS = [
  "first_scan",
  "scan_10",
  "scan_50",
  "first_search",
  "explore_5_categories",
  "first_low_score",
  "low_score_10",
  "compare_products",
  "compare_10",
  "allergen_filter",
  "first_list",
  "list_10_products",
  "first_submission",
  "share_product",
  "weekly_streak_4",
  "read_learn_page",
];

describe("ACHIEVEMENT_MAP", () => {
  it("covers all v1 client-trackable achievement slugs", () => {
    for (const slug of V1_CLIENT_SLUGS) {
      expect(MAPPED_SLUGS).toContain(slug);
    }
  });

  it("has no duplicate entries (same event + same slug)", () => {
    const keys = ACHIEVEMENT_MAP.map((m) => `${m.event}::${m.achievementSlug}`);
    const uniqueKeys = new Set(keys);
    expect(keys.length).toBe(uniqueKeys.size);
  });

  it("every mapping has a positive increment", () => {
    for (const m of ACHIEVEMENT_MAP) {
      expect(m.increment).toBeGreaterThan(0);
    }
  });

  it("every event type in the map is a valid AppEvent type", () => {
    const validTypes = [
      "product.scanned",
      "product.searched",
      "product.viewed",
      "product.compared",
      "product.added_to_list",
      "product.shared",
      "product.submitted",
      "list.created",
      "filter.allergen_applied",
      "category.viewed",
      "learn.page_viewed",
      "session.weekly_visit",
    ];
    for (const eventType of MAPPED_EVENT_TYPES) {
      expect(validTypes).toContain(eventType);
    }
  });

  it("product.viewed condition filters by low score (≤ 30)", () => {
    const lowScoreMappings = ACHIEVEMENT_MAP.filter(
      (m) => m.event === "product.viewed" && m.condition,
    );

    expect(lowScoreMappings.length).toBe(2);

    for (const m of lowScoreMappings) {
      // Score 25 → should pass
      expect(m.condition!({ score: 25 })).toBe(true);
      // Score 30 → boundary → should pass
      expect(m.condition!({ score: 30 })).toBe(true);
      // Score 31 → should fail
      expect(m.condition!({ score: 31 })).toBe(false);
      // Score 80 → should fail
      expect(m.condition!({ score: 80 })).toBe(false);
      // Missing score → should fail gracefully
      expect(m.condition!({ score: undefined })).toBe(false);
    }
  });

  it("product.scanned maps to three scan achievements", () => {
    const scanMappings = ACHIEVEMENT_MAP.filter(
      (m) => m.event === "product.scanned",
    );
    const slugs = scanMappings.map((m) => m.achievementSlug);
    expect(slugs).toEqual(
      expect.arrayContaining(["first_scan", "scan_10", "scan_50"]),
    );
    expect(slugs.length).toBe(3);
  });

  it("no mapping for meta achievements (all_exploration, all_health)", () => {
    const metaSlugs = MAPPED_SLUGS.filter(
      (s) => s === "all_exploration" || s === "all_health",
    );
    expect(metaSlugs).toHaveLength(0);
  });

  it("MAPPED_SLUGS has no duplicates", () => {
    expect(MAPPED_SLUGS.length).toBe(new Set(MAPPED_SLUGS).size);
  });
});
