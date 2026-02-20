"use client";

// ─── useAchievements — fetch + cache achievement gallery data ────────────────
// Issue #51: Achievements v1

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { createClient } from "@/lib/supabase/client";
import { getAchievements, incrementAchievementProgress } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { showToast } from "@/lib/toast";
import { useTranslation } from "@/lib/i18n";
import type { AchievementCategory } from "@/lib/types";

/* ── Constants ────────────────────────────────────────────────────────────── */

const CATEGORY_ORDER: readonly AchievementCategory[] = [
  "exploration",
  "health",
  "engagement",
  "mastery",
] as const;

/* ── Main hook: gallery data ──────────────────────────────────────────────── */

export function useAchievements() {
  const supabase = createClient();

  return useQuery({
    queryKey: queryKeys.achievements,
    queryFn: async () => {
      const result = await getAchievements(supabase);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.achievements,
  });
}

/* ── Mutation hook: increment progress + toast on unlock ──────────────────── */

export function useAchievementProgress() {
  const supabase = createClient();
  const queryClient = useQueryClient();
  const { t } = useTranslation();

  return useMutation({
    mutationFn: async ({
      slug,
      increment,
    }: {
      slug: string;
      increment?: number;
    }) => {
      const result = await incrementAchievementProgress(
        supabase,
        slug,
        increment,
      );
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    onSuccess: (data) => {
      // Invalidate achievements cache to reflect new progress
      void queryClient.invalidateQueries({
        queryKey: queryKeys.achievements,
      });

      // Show toast on newly unlocked achievement
      if (data.newly_unlocked) {
        showToast({
          type: "success",
          messageKey: "achievements.unlocked",
        });
      }
    },
    onError: () => {
      showToast({
        type: "error",
        message: t("achievements.progressError"),
      });
    },
  });
}

/* ── Helper: group achievements by category ───────────────────────────────── */

export { CATEGORY_ORDER };
