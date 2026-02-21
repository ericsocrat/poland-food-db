"use client";

import { useQuery } from "@tanstack/react-query";
import { createClient } from "@/lib/supabase/client";
import { getDashboardInsights } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { useTranslation } from "@/lib/i18n";
import { Skeleton } from "@/components/common/Skeleton";
import { HealthInsightsSummary } from "./HealthInsightsSummary";
import { NovaDistributionChart } from "./NovaDistribution";
import { AllergenAlert } from "./AllergenAlert";
import { CategoryDiversity } from "./CategoryDiversity";
import { RecentComparisons } from "./RecentComparisons";

function InsightsSkeleton() {
  return (
    <div className="space-y-4" data-testid="insights-skeleton">
      <Skeleton className="h-20 w-full rounded-xl" />
      <Skeleton className="h-28 w-full rounded-xl" />
      <Skeleton className="h-10 w-full rounded-xl" />
    </div>
  );
}

/**
 * Fetches and renders the full health-insights panel:
 * - Average score + trend
 * - NOVA distribution chart
 * - Allergen alerts
 * - Category diversity
 * - Recent comparisons
 *
 * Gracefully hidden if the user has no data or is not authenticated.
 */
export function HealthInsightsPanel() {
  const supabase = createClient();
  const { t } = useTranslation();

  const { data, isLoading, isError } = useQuery({
    queryKey: queryKeys.dashboardInsights,
    queryFn: async () => {
      const result = await getDashboardInsights(supabase);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.dashboardInsights,
  });

  if (isLoading) return <InsightsSkeleton />;
  if (isError || !data) return null;

  const insights = data;

  // If everything is zeroed out, skip rendering
  const hasData =
    insights.avg_score > 0 ||
    insights.allergen_alerts.count > 0 ||
    insights.recent_comparisons.length > 0 ||
    insights.category_diversity.explored > 0;

  if (!hasData) return null;

  return (
    <section
      className="space-y-4"
      aria-label={t("dashboard.healthInsightsSection")}
      data-testid="health-insights-panel"
    >
      {/* Average score + trend */}
      {insights.avg_score > 0 && (
        <div className="card">
          <HealthInsightsSummary
            avgScore={insights.avg_score}
            scoreTrend={insights.score_trend}
          />
        </div>
      )}

      {/* NOVA distribution */}
      <div className="card">
        <NovaDistributionChart distribution={insights.nova_distribution} />
      </div>

      {/* Allergen alert */}
      <AllergenAlert alerts={insights.allergen_alerts} />

      {/* Category diversity */}
      <div className="card">
        <CategoryDiversity diversity={insights.category_diversity} />
      </div>

      {/* Recent comparisons */}
      <RecentComparisons comparisons={insights.recent_comparisons} />
    </section>
  );
}
