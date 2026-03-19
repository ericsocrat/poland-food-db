"use client";

// ─── DashboardGreeting — time-aware personalized greeting + seasonal nudge ──

import { useTranslation } from "@/lib/i18n";

function getTimeOfDay(): "morning" | "afternoon" | "evening" | "night" {
  const hour = new Date().getHours();
  if (hour >= 5 && hour < 12) return "morning";
  if (hour >= 12 && hour < 17) return "afternoon";
  if (hour >= 17 && hour < 22) return "evening";
  return "night";
}

/**
 * Map month (0-11) to a Polish seasonal nudge key.
 * Spring: Mar–May, Summer: Jun–Aug, Autumn: Sep–Nov, Winter: Dec–Feb.
 */
function getSeasonKey(): "spring" | "summer" | "autumn" | "winter" {
  const month = new Date().getMonth(); // 0-indexed
  if (month >= 2 && month <= 4) return "spring";
  if (month >= 5 && month <= 7) return "summer";
  if (month >= 8 && month <= 10) return "autumn";
  return "winter";
}

const SEASON_STYLE: Record<
  ReturnType<typeof getSeasonKey>,
  { emoji: string; className: string }
> = {
  spring: { emoji: "🌱", className: "bg-emerald-100 text-emerald-800 dark:bg-emerald-900/40 dark:text-emerald-300" },
  summer: { emoji: "☀️", className: "bg-amber-100 text-amber-800 dark:bg-amber-900/40 dark:text-amber-300" },
  autumn: { emoji: "🍂", className: "bg-orange-100 text-orange-800 dark:bg-orange-900/40 dark:text-orange-300" },
  winter: { emoji: "❄️", className: "bg-sky-100 text-sky-800 dark:bg-sky-900/40 dark:text-sky-300" },
};

interface DashboardGreetingProps {
  displayName?: string | null;
}

export function DashboardGreeting({
  displayName,
}: Readonly<DashboardGreetingProps>) {
  const { t } = useTranslation();
  const timeOfDay = getTimeOfDay();
  const season = getSeasonKey();

  const greeting = displayName
    ? t(`dashboard.greeting.${timeOfDay}Named`, { name: displayName })
    : t(`dashboard.greeting.${timeOfDay}`);

  const { emoji, className: seasonClass } = SEASON_STYLE[season];

  return (
    <div className="space-y-2">
      <h1 className="text-xl font-bold text-foreground sm:text-2xl md:text-3xl lg:text-4xl">
        {greeting}
      </h1>
      <p className="text-sm text-foreground-secondary lg:text-base">
        {t("dashboard.subtitle")}
      </p>
      <span
        className={`inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 text-xs font-medium ${seasonClass}`}
        data-testid="seasonal-nudge"
      >
        {emoji} {t(`dashboard.season.${season}`)}
      </span>
    </div>
  );
}

/** Export for testing */
export { getTimeOfDay, getSeasonKey, SEASON_STYLE };
