"use client";

import { useContributorStats, type ContributorTier } from "@/hooks/use-submissions";
import { useTranslation } from "@/lib/i18n";
import { Award } from "lucide-react";

const TIER_STYLES: Record<
  Exclude<ContributorTier, "none">,
  { bg: string; text: string; labelKey: string }
> = {
  bronze: {
    bg: "bg-amber-100 dark:bg-amber-900/30",
    text: "text-amber-700 dark:text-amber-400",
    labelKey: "contributor.bronze",
  },
  silver: {
    bg: "bg-slate-100 dark:bg-slate-700/40",
    text: "text-slate-600 dark:text-slate-300",
    labelKey: "contributor.silver",
  },
  gold: {
    bg: "bg-yellow-100 dark:bg-yellow-900/30",
    text: "text-yellow-700 dark:text-yellow-400",
    labelKey: "contributor.gold",
  },
};

/** Inline badge showing the user's contributor tier based on approved submissions. */
export function ContributorBadge() {
  const { data: stats, isLoading } = useContributorStats();
  const { t } = useTranslation();

  if (isLoading || !stats || stats.tier === "none") return null;

  const style = TIER_STYLES[stats.tier];

  return (
    <span
      className={`inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 text-xs font-medium ${style.bg} ${style.text}`}
    >
      <Award size={12} aria-hidden="true" />
      {t(style.labelKey)} · {stats.approved}
    </span>
  );
}
