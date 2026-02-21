"use client";

// ─── Achievements Gallery Page ───────────────────────────────────────────────
// Issue #51: Achievements v1
// Route: /app/achievements
//
// Shows all achievement definitions grouped by category.
// Unlocked achievements are full-color; locked show progress bars.
// Overall progress bar at top.

import { useTranslation } from "@/lib/i18n";
import { useAchievements } from "@/hooks/use-achievements";
import { AchievementGrid } from "@/components/achievements/AchievementGrid";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { ProgressBar } from "@/components/common/ProgressBar";
import { EmptyState } from "@/components/common/EmptyState";
import { Icon } from "@/components/common/Icon";
import { Skeleton } from "@/components/common/Skeleton";
import { Trophy } from "lucide-react";

const LOADING_SKELETON_KEYS = [
  "skel-1",
  "skel-2",
  "skel-3",
  "skel-4",
  "skel-5",
  "skel-6",
  "skel-7",
  "skel-8",
] as const;

export default function AchievementsPage() {
  const { t } = useTranslation();
  const { data, isLoading, error } = useAchievements();

  const totalCount = data?.total ?? 0;
  const unlockedCount = data?.unlocked ?? 0;
  const overallPct =
    totalCount > 0 ? Math.round((unlockedCount / totalCount) * 100) : 0;

  return (
    <div>
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "achievements.title" },
        ]}
      />

      {/* Header */}
      <div className="mb-6 flex items-center gap-3">
        <Icon icon={Trophy} size="lg" className="text-brand" />
        <div>
          <h1 className="text-xl font-bold text-foreground">
            {t("achievements.title")}
          </h1>
          <p className="text-sm text-foreground-secondary">
            {t("achievements.subtitle")}
          </p>
        </div>
      </div>

      {/* Loading state */}
      {isLoading && (
        <div className="space-y-4" data-testid="achievements-loading">
          <Skeleton className="h-6 w-48" />
          <Skeleton className="h-4 w-full" />
          <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4">
            {LOADING_SKELETON_KEYS.map((key) => (
              <Skeleton key={key} className="h-36 rounded-xl" />
            ))}
          </div>
        </div>
      )}

      {/* Error state */}
      {error && (
        <EmptyState
          variant="error"
          titleKey="achievements.errorTitle"
          descriptionKey="achievements.errorDescription"
        />
      )}

      {/* Empty state */}
      {!isLoading && !error && totalCount === 0 && (
        <EmptyState
          variant="no-data"
          titleKey="achievements.emptyTitle"
          descriptionKey="achievements.emptyDescription"
        />
      )}

      {/* Achievement data */}
      {!isLoading && !error && data && totalCount > 0 && (
        <>
          {/* Overall progress */}
          <div className="mb-8 rounded-xl border border-border bg-surface p-4">
            <div className="mb-2 flex items-center justify-between text-sm">
              <span className="font-medium text-foreground">
                {t("achievements.overallProgress")}
              </span>
              <span className="text-muted" data-testid="achievements-summary">
                {unlockedCount} / {totalCount} ({overallPct}%)
              </span>
            </div>
            <ProgressBar
              value={overallPct}
              size="md"
              variant="brand"
              ariaLabel={`${unlockedCount} of ${totalCount} achievements unlocked`}
            />
          </div>

          {/* Grid */}
          <AchievementGrid achievements={data.achievements} />
        </>
      )}
    </div>
  );
}
