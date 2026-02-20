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

  return (
    <div className="space-y-1">
      <h1 className="text-xl font-bold text-foreground sm:text-2xl md:text-3xl lg:text-4xl">
        {greeting}
      </h1>
      <p className="text-sm text-foreground-secondary lg:text-base">
        {t("dashboard.subtitle")}
      </p>
      <p
        className="text-xs text-foreground-muted lg:text-sm"
        data-testid="seasonal-nudge"
      >
        {t(`dashboard.season.${season}`)}
      </p>
    </div>
  );
}

/** Export for testing */
export { getTimeOfDay, getSeasonKey };
