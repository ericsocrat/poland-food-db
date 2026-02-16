"use client";

// ─── Health Warnings Card ───────────────────────────────────────────────────
// Displays personalized health warnings for a product based on the user's
// active health profile. Only renders when the user has an active profile.

import { useQuery } from "@tanstack/react-query";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import { getProductHealthWarnings, getActiveHealthProfile } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { WARNING_SEVERITY, HEALTH_CONDITIONS } from "@/lib/constants";
import { useTranslation } from "@/lib/i18n";
import type { HealthWarning, WarningSeverity } from "@/lib/types";

// ─── Severity icon mapping ─────────────────────────────────────────────────

const SEVERITY_ICON: Record<WarningSeverity, string> = {
  critical: "🚫",
  high: "⚠️",
  moderate: "ℹ️",
};

/** Sort order for warning severities (lower = more severe). */
const SEVERITY_ORDER: Record<WarningSeverity, number> = {
  critical: 0,
  high: 1,
  moderate: 2,
};

// ─── Condition icon lookup ──────────────────────────────────────────────────

function getConditionIcon(condition: string): string {
  const found = HEALTH_CONDITIONS.find((c) => c.value === condition);
  return found?.icon ?? "⚕️";
}

// ─── Component ──────────────────────────────────────────────────────────────

export function HealthWarningsCard({
  productId,
}: Readonly<{ productId: number }>) {
  const supabase = createClient();
  const { t } = useTranslation();

  // Check if user has an active health profile
  const { data: profileData, isLoading: profileLoading } = useQuery({
    queryKey: queryKeys.activeHealthProfile,
    queryFn: async () => {
      const result = await getActiveHealthProfile(supabase);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.healthProfiles,
  });

  // Fetch warnings only when user has an active profile
  const hasProfile =
    profileData?.profile !== null && profileData?.profile !== undefined;

  const { data: warningsData, isLoading: warningsLoading } = useQuery({
    queryKey: queryKeys.healthWarnings(productId),
    queryFn: async () => {
      const result = await getProductHealthWarnings(supabase, productId);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.healthWarnings,
    enabled: hasProfile,
  });

  // Loading profile — show skeleton to avoid layout jump
  if (profileLoading) {
    return (
      <div className="card animate-pulse">
        <div className="flex items-center gap-2">
          <div className="h-5 w-5 rounded-full bg-gray-200" />
          <div className="h-4 w-48 rounded bg-gray-200" />
        </div>
      </div>
    );
  }

  // No active profile — show a subtle prompt
  if (!hasProfile) {
    return (
      <div className="card border-gray-200 bg-gray-50">
        <div className="flex items-center gap-2">
          <span className="text-lg">🛡️</span>
          <div className="flex-1">
            <p className="text-sm font-medium text-gray-700">
              {t("healthWarnings.title")}
            </p>
            <p className="text-xs text-gray-500">
              {
                t("healthWarnings.setupPrompt").split(
                  t("healthWarnings.healthProfile"),
                )[0]
              }
              <Link
                href="/app/settings"
                className="text-brand-600 underline hover:text-brand-700"
              >
                {t("healthWarnings.healthProfile")}
              </Link>
              {
                t("healthWarnings.setupPrompt").split(
                  t("healthWarnings.healthProfile"),
                )[1]
              }
            </p>
          </div>
        </div>
      </div>
    );
  }

  // Loading warnings
  if (warningsLoading) {
    return (
      <div className="card animate-pulse">
        <div className="h-4 w-40 rounded bg-gray-200" />
        <div className="mt-2 h-3 w-64 rounded bg-gray-100" />
      </div>
    );
  }

  // No warnings — product is safe for this profile
  if (!warningsData || warningsData.warning_count === 0) {
    return (
      <div className="card border-green-200 bg-green-50">
        <div className="flex items-center gap-2">
          <span className="text-lg">✅</span>
          <div>
            <p className="text-sm font-medium text-green-800">
              {t("healthWarnings.withinLimits")}
            </p>
            <p className="text-xs text-green-600">
              {t("healthWarnings.noWarningsFor", {
                name: profileData.profile?.profile_name ?? "",
              })}
            </p>
          </div>
        </div>
      </div>
    );
  }

  // Sort: critical first, then high, then moderate
  const sorted = [...warningsData.warnings].sort(
    (a, b) =>
      (SEVERITY_ORDER[a.severity] ?? 3) - (SEVERITY_ORDER[b.severity] ?? 3),
  );

  // Determine overall card severity (use the highest)
  const topSeverity = sorted[0].severity;
  const cardStyle = WARNING_SEVERITY[topSeverity];

  return (
    <div className={`card border ${cardStyle.border} ${cardStyle.bg}`}>
      {/* Header */}
      <div className="mb-2 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <span className="text-lg">🛡️</span>
          <p className={`text-sm font-semibold ${cardStyle.color}`}>
            {t("healthWarnings.warningCount", {
              count: warningsData.warning_count,
            })}
          </p>
        </div>
        <span className="text-xs text-gray-400">
          {t("healthWarnings.profile", {
            name: profileData.profile?.profile_name ?? "",
          })}
        </span>
      </div>

      {/* Warning list */}
      <ul className="space-y-1.5">
        {sorted.map((warning) => (
          <WarningRow
            key={`${warning.condition}-${warning.severity}`}
            warning={warning}
          />
        ))}
      </ul>
    </div>
  );
}

// ─── Warning Row ────────────────────────────────────────────────────────────

function WarningRow({ warning }: Readonly<{ warning: HealthWarning }>) {
  const style = WARNING_SEVERITY[warning.severity];
  const icon = SEVERITY_ICON[warning.severity];
  const conditionIcon = getConditionIcon(warning.condition);

  return (
    <li className="flex items-start gap-2">
      <span className="mt-0.5 flex-shrink-0 text-sm" title={style.label}>
        {icon}
      </span>
      <div className="min-w-0 flex-1">
        <div className="flex items-center gap-1.5">
          <span className="text-xs">{conditionIcon}</span>
          <span className={`text-xs font-medium ${style.color}`}>
            {warning.message}
          </span>
        </div>
      </div>
    </li>
  );
}

// ─── Compact badge for search/category results ─────────────────────────────

export function HealthWarningBadge({
  productId,
}: Readonly<{ productId: number }>) {
  const supabase = createClient();
  const { t } = useTranslation();

  // Only fetch if user has an active profile
  const { data: profileData } = useQuery({
    queryKey: queryKeys.activeHealthProfile,
    queryFn: async () => {
      const result = await getActiveHealthProfile(supabase);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.healthProfiles,
  });

  const hasProfile =
    profileData?.profile !== null && profileData?.profile !== undefined;

  const { data: warningsData } = useQuery({
    queryKey: queryKeys.healthWarnings(productId),
    queryFn: async () => {
      const result = await getProductHealthWarnings(supabase, productId);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.healthWarnings,
    enabled: hasProfile,
  });

  // Don't show anything if no profile or no warnings
  if (!hasProfile || !warningsData || warningsData.warning_count === 0) {
    // Show a green check if profile exists but no warnings
    if (hasProfile && warningsData?.warning_count === 0) {
      return (
        <span
          className="flex h-5 w-5 flex-shrink-0 items-center justify-center rounded-full bg-green-100 text-xs"
          title={t("healthWarnings.noWarnings")}
        >
          ✓
        </span>
      );
    }
    return null;
  }

  // Show warning count badge with severity coloring
  const topSeverity = warningsData.warnings.reduce<WarningSeverity>(
    (worst, w) => {
      return SEVERITY_ORDER[w.severity] < SEVERITY_ORDER[worst]
        ? w.severity
        : worst;
    },
    "moderate",
  );

  const style = WARNING_SEVERITY[topSeverity];

  return (
    <span
      className={`flex h-5 min-w-5 flex-shrink-0 items-center justify-center rounded-full px-1 text-xs font-bold ${style.bg} ${style.color}`}
      title={t("healthWarnings.warningCount", {
        count: warningsData.warning_count,
      })}
    >
      {warningsData.warning_count}
    </span>
  );
}
