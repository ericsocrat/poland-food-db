"use client";

import { EmptyState } from "@/components/common/EmptyState";
import { ErrorBoundary } from "@/components/common/ErrorBoundary";
import { PullToRefresh } from "@/components/common/PullToRefresh";
import { DashboardSkeleton } from "@/components/common/skeletons";
import { DashboardGreeting } from "@/components/dashboard/DashboardGreeting";
import { HealthSummary } from "@/components/dashboard/HealthSummary";
import { NewUserWelcome } from "@/components/dashboard/NewUserWelcome";
import { QuickActions } from "@/components/dashboard/QuickActions";
import { QuickWinCard } from "@/components/dashboard/QuickWinCard";
import { RecentlyViewed } from "@/components/dashboard/RecentlyViewed";
import { useAnalytics } from "@/hooks/use-analytics";
import { getDashboardData } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { createClient } from "@/lib/supabase/client";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useCallback, useEffect } from "react";

// ─── Main Page ──────────────────────────────────────────────────────────────

export default function DashboardPage() {
  const supabase = createClient();
  const queryClient = useQueryClient();
  const { track } = useAnalytics();

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
      <DashboardGreeting />

      {/* Health summary — average score + band distribution */}
      <HealthSummary products={dashboard.recently_viewed} />

      {/* Quick win — swap suggestion for worst product */}
      <ErrorBoundary level="section" context={{ section: "quick-win" }}>
        <QuickWinCard products={dashboard.recently_viewed} />
      </ErrorBoundary>

      {/* Recently viewed — compact card list */}
      {dashboard.recently_viewed.length > 0 && (
        <ErrorBoundary
          level="section"
          context={{ section: "recently-viewed" }}
        >
          <RecentlyViewed products={dashboard.recently_viewed} />
        </ErrorBoundary>
      )}

      {/* Quick actions */}
      <QuickActions />
    </div>
    </PullToRefresh>
  );
}
