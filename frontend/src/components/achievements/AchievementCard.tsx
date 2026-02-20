"use client";

// ─── AchievementCard — displays a single achievement (locked or unlocked) ────
// Issue #51: Achievements v1
//
// Unlocked: full-color emoji, title, description, unlock date
// Locked: grayscale, progress bar showing current/threshold

import { useTranslation } from "@/lib/i18n";
import { Card } from "@/components/common/Card";
import { ProgressBar } from "@/components/common/ProgressBar";
import { Badge } from "@/components/common/Badge";
import type { AchievementDef } from "@/lib/types";

/* ── Props ────────────────────────────────────────────────────────────────── */

interface AchievementCardProps {
  readonly achievement: AchievementDef;
}

/* ── Component ────────────────────────────────────────────────────────────── */

export function AchievementCard({ achievement }: AchievementCardProps) {
  const { t } = useTranslation();
  const isUnlocked = achievement.unlocked_at !== null;
  const progressPct = Math.min(
    Math.round((achievement.progress / achievement.threshold) * 100),
    100,
  );

  return (
    <Card
      variant="outlined"
      padding="md"
      className={`flex flex-col items-center gap-2 text-center transition-all ${
        isUnlocked
          ? "border-brand/30 bg-brand/5"
          : "border-border bg-surface opacity-70 grayscale"
      }`}
      data-testid={`achievement-card-${achievement.slug}`}
    >
      {/* Icon */}
      <span
        className="text-3xl"
        role="img"
        aria-label={t(achievement.title_key)}
      >
        {achievement.icon}
      </span>

      {/* Title */}
      <h3 className="text-sm font-semibold leading-tight text-foreground">
        {t(achievement.title_key)}
      </h3>

      {/* Description */}
      <p className="text-xs leading-snug text-muted">
        {t(achievement.desc_key)}
      </p>

      {/* Status: unlocked date or progress bar */}
      {isUnlocked ? (
        <Badge variant="success" size="sm">
          {t("achievements.earned")}
        </Badge>
      ) : (
        <div className="mt-auto w-full space-y-1">
          <ProgressBar
            value={progressPct}
            size="sm"
            variant="brand"
            ariaLabel={`${achievement.progress} / ${achievement.threshold}`}
          />
          <p className="text-xs text-muted" data-testid="achievement-progress">
            {achievement.progress} / {achievement.threshold}
          </p>
        </div>
      )}
    </Card>
  );
}
