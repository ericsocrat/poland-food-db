// ─── Achievement Middleware — wires event bus to achievement RPC ─────────────
// Issue #52: Telemetry Mapping for Achievements
//
// Subscribes to the event bus and calls increment_achievement_progress
// for every matching event→achievement mapping. Fully fire-and-forget:
// never blocks the user action, never throws.

import { eventBus } from "./bus";
import { ACHIEVEMENT_MAP } from "./achievement-map";
import { createClient } from "@/lib/supabase/client";
import { incrementAchievementProgress } from "@/lib/api";
import { showToast } from "@/lib/toast";
import type { AppEvent } from "./types";

/**
 * Process a single event against the achievement mapping.
 * Exported for unit testing; not meant for direct application use.
 */
export async function processEvent(event: AppEvent): Promise<void> {
  const supabase = createClient();

  // Skip if user is not authenticated (anonymous visitors don't earn achievements)
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return;

  const mappings = ACHIEVEMENT_MAP.filter((m) => m.event === event.type);
  if (mappings.length === 0) return;

  for (const mapping of mappings) {
    // Evaluate optional condition guard
    if (
      mapping.condition &&
      !mapping.condition(event.payload as Record<string, unknown>)
    ) {
      continue;
    }

    // Fire-and-forget — do not await in caller's critical path
    incrementAchievementProgress(
      supabase,
      mapping.achievementSlug,
      mapping.increment,
    )
      .then((result) => {
        if (result.ok && result.data.newly_unlocked) {
          showToast({
            type: "success",
            messageKey: "achievements.unlocked",
          });
        }
      })
      .catch((err: unknown) => {
        if (process.env.NODE_ENV === "development") {
          console.warn(
            "[achievements] Failed to increment:",
            mapping.achievementSlug,
            err,
          );
        }
      });
  }
}

/**
 * Initialize the achievement middleware by subscribing to the event bus.
 * Call once during app startup (e.g. in Providers or layout).
 * Returns an unsubscribe function for cleanup.
 */
export function initAchievementMiddleware(): () => void {
  return eventBus.subscribe((event) => {
    // processEvent is async but we don't await — fire-and-forget
    void processEvent(event);
  });
}
