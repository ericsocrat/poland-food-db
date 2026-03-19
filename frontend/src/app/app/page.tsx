"use client";

import { EmptyState } from "@/components/common/EmptyState";
import { ErrorBoundary } from "@/components/common/ErrorBoundary";
import { PullToRefresh } from "@/components/common/PullToRefresh";
import { DashboardSkeleton } from "@/components/common/skeletons";
import { CategoriesBrowse } from "@/components/dashboard/CategoriesBrowse";
import { DashboardGreeting } from "@/components/dashboard/DashboardGreeting";
import { HealthInsightsPanel } from "@/components/dashboard/HealthInsightsPanel";
import { HealthSummary } from "@/components/dashboard/HealthSummary";
import { NewUserWelcome } from "@/components/dashboard/NewUserWelcome";
import { NutritionTip } from "@/components/dashboard/NutritionTip";
import { QuickActions } from "@/components/dashboard/QuickActions";
import { QuickWinCard } from "@/components/dashboard/QuickWinCard";
import { RecentlyViewed } from "@/components/dashboard/RecentlyViewed";
import { useAnalytics } from "@/hooks/use-analytics";
import { getDashboardData } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { createClient } from "@/lib/supabase/client";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useCallback, useEffect, useState } from "react";

// ─── Main Page ──────────────────────────────────────────────────────────────

export default function DashboardPage() {
  const supabase = createClient();
  const queryClient = useQueryClient();
  const { track } = useAnalytics();
  const [displayName, setDisplayName] = useState<string | null>(null);

  const { data, isLoading, isError } = useQuery({
    queryKey: queryKeys.dashboard,
    queryFn: async () => {
      const result = await getDashboardData(supabase);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.dashboard,
  });

  useEffect(() => {
    track("dashboard_viewed");
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    supabase.auth.getUser().then(({ data: { user } }) => {
      const name =
        user?.user_metadata?.full_name ??
        user?.user_metadata?.name ??
        null;
      setDisplayName(typeof name === "string" ? name : null);
    });
  }, [supabase]);

  const handleRefresh = useCallback(async () => {
    await queryClient.invalidateQueries({ queryKey: queryKeys.dashboard });
  }, [queryClient]);

  if (isLoading) {
    return <DashboardSkeleton />;
  }

  if (isError || !data) {
    return (
      <EmptyState
        variant="error"
        titleKey="dashboard.errorMessage"
        action={{
          labelKey: "common.tryAgain",
          onClick: () => {
            queryClient.invalidateQueries({
              queryKey: queryKeys.dashboard,
            });
          },
        }}
      />
    );
  }

  const dashboard = data;

  const hasContent =
    dashboard.recently_viewed.length > 0 ||
    dashboard.stats.total_viewed > 0 ||
    dashboard.stats.total_scanned > 0;

  if (!hasContent) {
    return <NewUserWelcome />;
  }

  return (
    <PullToRefresh onRefresh={handleRefresh}>
    <div className="space-y-6 lg:space-y-8">
      <div className="animate-fade-in-up">
        <DashboardGreeting displayName={displayName} />
      </div>

      {/* Health summary — average score + band distribution */}
      <div className="animate-fade-in-up" style={{ animationDelay: "50ms" }}>
        <HealthSummary products={dashboard.recently_viewed} />
      </div>

      {/* Health insights — trends, NOVA, allergens, diversity, comparisons */}
      <div className="animate-fade-in-up" style={{ animationDelay: "100ms" }}>
        <ErrorBoundary level="section" context={{ section: "health-insights" }}>
          <HealthInsightsPanel />
        </ErrorBoundary>
      </div>

      {/* Quick win — swap suggestion for worst product */}
      <div className="animate-fade-in-up" style={{ animationDelay: "150ms" }}>
        <ErrorBoundary level="section" context={{ section: "quick-win" }}>
          <QuickWinCard products={dashboard.recently_viewed} />
        </ErrorBoundary>
      </div>

      {/* Nutrition tip — daily rotating health tip */}
      <div className="animate-fade-in-up" style={{ animationDelay: "200ms" }}>
        <NutritionTip />
      </div>

      {/* Recently viewed — compact card list */}
      {dashboard.recently_viewed.length > 0 && (
        <div className="animate-fade-in-up" style={{ animationDelay: "250ms" }}>
          <ErrorBoundary
            level="section"
            context={{ section: "recently-viewed" }}
          >
            <RecentlyViewed products={dashboard.recently_viewed} />
          </ErrorBoundary>
        </div>
      )}

      {/* Browse categories — horizontal scrollable chips */}
      <div className="animate-fade-in-up" style={{ animationDelay: "300ms" }}>
        <ErrorBoundary level="section" context={{ section: "categories-browse" }}>
          <CategoriesBrowse />
        </ErrorBoundary>
      </div>

      {/* Quick actions */}
      <div className="animate-fade-in-up" style={{ animationDelay: "350ms" }}>
        <QuickActions stats={dashboard.stats} />
      </div>
    </div>
    </PullToRefresh>
  );
}
