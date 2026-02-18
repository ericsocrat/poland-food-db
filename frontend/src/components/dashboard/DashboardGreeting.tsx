"use client";

// ─── DashboardGreeting — time-aware personalized greeting ───────────────────

import { useTranslation } from "@/lib/i18n";

function getTimeOfDay(): "morning" | "afternoon" | "evening" | "night" {
  const hour = new Date().getHours();
  if (hour >= 5 && hour < 12) return "morning";
  if (hour >= 12 && hour < 17) return "afternoon";
  if (hour >= 17 && hour < 22) return "evening";
  return "night";
}

interface DashboardGreetingProps {
  displayName?: string | null;
}

export function DashboardGreeting({
  displayName,
}: Readonly<DashboardGreetingProps>) {
  const { t } = useTranslation();
  const timeOfDay = getTimeOfDay();

  const greeting = displayName
    ? t(`dashboard.greeting.${timeOfDay}Named`, { name: displayName })
    : t(`dashboard.greeting.${timeOfDay}`);

  return (
    <div className="space-y-1">
      <h1 className="text-xl font-bold text-foreground sm:text-2xl lg:text-3xl">
        {greeting}
      </h1>
      <p className="text-sm text-foreground-secondary lg:text-base">
        {t("dashboard.subtitle")}
      </p>
    </div>
  );
}

/** Export for testing */
export { getTimeOfDay };
