"use client";

// ─── Scan History page — paginated list of past scans ───────────────────────

import { useState, useCallback } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { getScanHistory } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { NUTRI_COLORS } from "@/lib/constants";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import { EmptyState } from "@/components/common/EmptyState";
import { useTranslation } from "@/lib/i18n";
import type { ScanHistoryItem } from "@/lib/types";

const FILTERS = [
  { value: "all", labelKey: "scanHistory.all" },
  { value: "found", labelKey: "scanHistory.found" },
  { value: "not_found", labelKey: "scanHistory.notFound" },
] as const;

export default function ScanHistoryPage() {
  const supabase = createClient();
  const router = useRouter();
  const queryClient = useQueryClient();
  const { t } = useTranslation();
  const [page, setPage] = useState(1);
  const [filter, setFilter] = useState<string>("all");

  const { data, isLoading, error } = useQuery({
    queryKey: queryKeys.scanHistory(page, filter),
    queryFn: async () => {
      const result = await getScanHistory(supabase, page, 20, filter);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.scanHistory,
  });

  const handleRetry = useCallback(() => {
    queryClient.invalidateQueries({
      queryKey: queryKeys.scanHistory(page, filter),
    });
  }, [queryClient, page, filter]);

  return (
    <div className="space-y-4">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-lg font-semibold text-foreground">
            📋 {t("scanHistory.title")}
          </h1>
          <p className="text-sm text-foreground-secondary">
            {t("scanHistory.subtitle")}
          </p>
        </div>
        <Link
          href="/app/scan"
          className="text-sm text-brand-600 hover:text-brand-700"
        >
          {t("scanHistory.backToScanner")}
        </Link>
      </div>

      {/* Filter toggle */}
      <div className="flex gap-1 rounded-lg bg-surface-muted p-1">
        {FILTERS.map((f) => (
          <button
            key={f.value}
            onClick={() => {
              setFilter(f.value);
              setPage(1);
            }}
            className={`flex-1 rounded-md px-3 py-1.5 text-sm font-medium transition-colors ${
              filter === f.value
                ? "bg-surface text-brand-700 shadow-sm"
                : "text-foreground-secondary hover:text-foreground"
            }`}
          >
            {t(f.labelKey)}
          </button>
        ))}
      </div>

      {/* Loading */}
      {isLoading && (
        <div className="flex justify-center py-12">
          <LoadingSpinner />
        </div>
      )}

      {/* Error */}
      {error && (
        <EmptyState
          variant="error"
          titleKey="scanHistory.loadFailed"
          action={{ labelKey: "common.retry", onClick: handleRetry }}
        />
      )}

      {/* Empty */}
      {data?.scans.length === 0 && (
        <EmptyState
          variant="no-data"
          icon={<span>📷</span>}
          titleKey="scanHistory.emptyTitle"
          descriptionKey="scanHistory.emptyMessage"
          action={{ labelKey: "scanHistory.startScanning", href: "/app/scan" }}
        />
      )}

      {/* Scan list */}
      {data && data.scans.length > 0 && (
        <ul className="space-y-2">
          {data.scans.map((scan) => (
            <ScanRow
              key={scan.scan_id}
              scan={scan}
              onNavigate={(id) => router.push(`/app/product/${id}`)}
            />
          ))}
        </ul>
      )}

      {/* Pagination */}
      {data && data.pages > 1 && (
        <div className="flex items-center justify-center gap-2 pt-2">
          <button
            onClick={() => setPage((p) => Math.max(1, p - 1))}
            disabled={page <= 1}
            className="btn-secondary px-3 py-1.5 text-sm disabled:opacity-40"
          >
            {t("common.prev")}
          </button>
          <span className="text-sm text-foreground-secondary">
            {t("common.pageOf", { page: data.page, pages: data.pages })}
          </span>
          <button
            onClick={() => setPage((p) => Math.min(data.pages, p + 1))}
            disabled={page >= data.pages}
            className="btn-secondary px-3 py-1.5 text-sm disabled:opacity-40"
          >
            {t("common.next")}
          </button>
        </div>
      )}
    </div>
  );
}

function ScanRow({
  scan,
  onNavigate,
}: Readonly<{
  scan: ScanHistoryItem;
  onNavigate: (productId: number) => void;
}>) {
  const { t } = useTranslation();
  const date = new Date(scan.scanned_at);
  const timeStr = date.toLocaleString(undefined, {
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });

  if (scan.found && scan.product_id) {
    return (
      <li className="card">
        <button
          onClick={() => onNavigate(scan.product_id ?? 0)}
          className="flex w-full items-center gap-3 text-left"
        >
          {/* Nutri badge */}
          {scan.nutri_score && (
            <span
              className={`flex h-7 w-7 flex-shrink-0 items-center justify-center rounded text-xs font-bold text-white ${
                NUTRI_COLORS[scan.nutri_score] ?? "bg-foreground-muted"
              }`}
            >
              {scan.nutri_score}
            </span>
          )}
          <div className="min-w-0 flex-1">
            <p className="truncate font-medium text-foreground">
              {scan.product_name}
            </p>
            <p className="text-xs text-foreground-secondary">
              {scan.brand} · {scan.category}
            </p>
          </div>
          <div className="flex flex-shrink-0 flex-col items-end">
            <span className="text-xs text-foreground-muted">{timeStr}</span>
            <span className="mt-0.5 text-xs font-mono text-foreground-muted">
              {scan.ean}
            </span>
          </div>
        </button>
      </li>
    );
  }

  // Not found scan
  return (
    <li className="card border-amber-100 bg-amber-50/50">
      <div className="flex items-center gap-3">
        <span className="flex h-7 w-7 flex-shrink-0 items-center justify-center rounded bg-amber-200 text-sm">
          ❓
        </span>
        <div className="min-w-0 flex-1">
          <p className="font-mono text-sm text-foreground-secondary">
            {scan.ean}
          </p>
          <p className="text-xs text-foreground-secondary">
            {t("scanHistory.notFound")}
            {scan.submission_status && (
              <span className="ml-1">
                ·{" "}
                {t("scanHistory.submissionStatus", {
                  status: scan.submission_status,
                })}
              </span>
            )}
          </p>
        </div>
        <div className="flex flex-shrink-0 flex-col items-end gap-1">
          <span className="text-xs text-foreground-muted">{timeStr}</span>
          {!scan.submission_status && (
            <Link
              href={`/app/scan/submit?ean=${scan.ean}`}
              className="text-xs text-brand-600 hover:text-brand-700"
            >
              {t("scanHistory.submit")}
            </Link>
          )}
        </div>
      </div>
    </li>
  );
}
