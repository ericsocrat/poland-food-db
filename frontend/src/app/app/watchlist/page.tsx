"use client";

/**
 * WatchlistPage — /app/watchlist
 * Lists all products the user is watching, with trend sparklines,
 * score deltas, and reformulation badges.
 */

import { useState } from "react";
import Link from "next/link";
import { useQuery } from "@tanstack/react-query";
import { Eye, ChevronLeft, ChevronRight } from "lucide-react";
import { useTranslation } from "@/lib/i18n";
import { Icon } from "@/components/common/Icon";
import { createClient } from "@/lib/supabase/client";
import { getWatchlist } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { ScoreTrendChart } from "@/components/product/ScoreTrendChart";
import { ScoreChangeIndicator } from "@/components/product/ScoreChangeIndicator";
import { ReformulationBadge } from "@/components/product/ReformulationBadge";
import type { WatchlistItem } from "@/lib/types";

const SCORE_BAND_COLORS: Record<string, string> = {
  low: "text-success",
  moderate: "text-warning",
  high: "text-orange-500",
  very_high: "text-error",
};

function WatchlistCard({ item }: Readonly<{ item: WatchlistItem }>) {
  const bandColor = SCORE_BAND_COLORS[item.score_band] ?? "text-foreground";

  return (
    <Link
      href={`/app/product/${item.product_id}`}
      className="group flex items-center gap-4 rounded-xl border border-border bg-surface p-4 transition-colors hover:border-brand/30 hover:bg-surface-muted"
      data-testid="watchlist-card"
    >
      {/* Score */}
      <div className="flex flex-col items-center gap-0.5">
        <span
          className={`text-2xl font-bold tabular-nums ${bandColor}`}
          data-testid="watchlist-score"
        >
          {item.current_score ?? "–"}
        </span>
        <ScoreChangeIndicator delta={item.last_delta} />
      </div>

      {/* Product info */}
      <div className="min-w-0 flex-1">
        <p className="truncate text-sm font-semibold text-foreground">
          {item.product_name}
        </p>
        {item.brand && (
          <p className="truncate text-xs text-foreground-secondary">
            {item.brand}
          </p>
        )}
        <div className="mt-1 flex flex-wrap items-center gap-2">
          {item.category && (
            <span className="text-xs text-foreground-secondary">
              {item.category}
            </span>
          )}
          <ReformulationBadge detected={item.reformulation_detected} />
        </div>
      </div>

      {/* Sparkline */}
      <div className="hidden sm:block">
        <ScoreTrendChart
          history={item.sparkline}
          trend={item.trend}
          width={100}
          height={32}
        />
      </div>
    </Link>
  );
}

export default function WatchlistPage() {
  const { t } = useTranslation();
  const supabase = createClient();
  const [page, setPage] = useState(1);

  const { data, isLoading, error } = useQuery({
    queryKey: queryKeys.watchlist(page),
    queryFn: async () => {
      const result = await getWatchlist(supabase, page, 20);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.watchlist,
  });

  const items = data?.items ?? [];
  const totalPages = data?.total_pages ?? 1;

  return (
    <div>
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "watchlist.title" },
        ]}
      />

      <div className="mb-6 flex items-center gap-3">
        <Icon icon={Eye} size="lg" className="text-brand" />
        <div>
          <h1 className="text-xl font-bold text-foreground">
            {t("watchlist.title")}
          </h1>
          <p className="text-sm text-foreground-secondary">
            {t("watchlist.subtitle")}
          </p>
        </div>
      </div>

      {isLoading && (
        <div className="space-y-3" data-testid="watchlist-loading">
          {[1, 2, 3].map((i) => (
            <div
              key={i}
              className="h-20 animate-pulse rounded-xl border border-border bg-surface-muted"
            />
          ))}
        </div>
      )}

      {error && (
        <div
          className="rounded-xl border border-error/30 bg-error/5 p-4 text-sm text-error"
          data-testid="watchlist-error"
        >
          {t("watchlist.loadError")}
        </div>
      )}

      {!isLoading && !error && items.length === 0 && (
        <div
          className="flex flex-col items-center gap-3 rounded-xl border border-border bg-surface p-8 text-center"
          data-testid="watchlist-empty"
        >
          <Icon icon={Eye} size="xl" className="text-foreground-muted" />
          <h2 className="text-lg font-semibold text-foreground">
            {t("watchlist.emptyTitle")}
          </h2>
          <p className="max-w-md text-sm text-foreground-secondary">
            {t("watchlist.emptyDescription")}
          </p>
          <Link href="/app/search" className="btn-primary mt-2 text-sm">
            {t("watchlist.browseProducts")}
          </Link>
        </div>
      )}

      {items.length > 0 && (
        <div className="space-y-3">
          {items.map((item) => (
            <WatchlistCard key={item.watch_id} item={item} />
          ))}
        </div>
      )}

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="mt-6 flex items-center justify-center gap-4">
          <button
            onClick={() => setPage((p) => Math.max(1, p - 1))}
            disabled={page <= 1}
            className="touch-target rounded-lg border border-border px-3 py-1.5 text-sm text-foreground-secondary transition-colors hover:bg-surface-muted disabled:opacity-50"
            aria-label={t("watchlist.prevPage")}
          >
            <Icon icon={ChevronLeft} size="sm" />
          </button>
          <span className="text-sm text-foreground-secondary">
            {t("watchlist.pageIndicator", {
              page: String(page),
              total: String(totalPages),
            })}
          </span>
          <button
            onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
            disabled={page >= totalPages}
            className="touch-target rounded-lg border border-border px-3 py-1.5 text-sm text-foreground-secondary transition-colors hover:bg-surface-muted disabled:opacity-50"
            aria-label={t("watchlist.nextPage")}
          >
            <Icon icon={ChevronRight} size="sm" />
          </button>
        </div>
      )}
    </div>
  );
}
