"use client";

// ─── Admin Monitoring Dashboard ─────────────────────────────────────────────
// Displays database health metrics: MV staleness, row count ceilings,
// connectivity status. Auto-refreshes every 60 seconds.
// Protected by existing middleware (auth required).

import { useQuery } from "@tanstack/react-query";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import { useTranslation } from "@/lib/i18n";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import {
  Activity,
  Database,
  RefreshCw,
  CheckCircle,
  AlertTriangle,
  XCircle,
  Clock,
} from "lucide-react";
import type { HealthCheckResponse } from "@/app/api/health/route";

// ─── Constants ──────────────────────────────────────────────────────────────

const REFETCH_INTERVAL_MS = 60_000;

// ─── Status helpers ─────────────────────────────────────────────────────────

function statusColor(status: string): string {
  switch (status) {
    case "healthy":
      return "text-green-600 dark:text-green-400";
    case "degraded":
      return "text-yellow-600 dark:text-yellow-400";
    case "unhealthy":
      return "text-red-600 dark:text-red-400";
    default:
      return "text-gray-600 dark:text-gray-400";
  }
}

function statusBg(status: string): string {
  switch (status) {
    case "healthy":
      return "bg-green-100 dark:bg-green-900/30";
    case "degraded":
      return "bg-yellow-100 dark:bg-yellow-900/30";
    case "unhealthy":
      return "bg-red-100 dark:bg-red-900/30";
    default:
      return "bg-gray-100 dark:bg-gray-900/30";
  }
}

function StatusIcon({ status }: Readonly<{ status: string }>) {
  switch (status) {
    case "healthy":
      return <CheckCircle className="h-5 w-5 text-green-600 dark:text-green-400" />;
    case "degraded":
      return <AlertTriangle className="h-5 w-5 text-yellow-600 dark:text-yellow-400" />;
    case "unhealthy":
      return <XCircle className="h-5 w-5 text-red-600 dark:text-red-400" />;
    default:
      return <Clock className="h-5 w-5 text-gray-600 dark:text-gray-400" />;
  }
}

// ─── Fetch helper ───────────────────────────────────────────────────────────

async function fetchHealth(): Promise<HealthCheckResponse> {
  const res = await fetch("/api/health", { cache: "no-store" });
  if (!res.ok && res.status !== 503) {
    throw new Error(`Health check failed: ${res.status}`);
  }
  return res.json();
}

// ─── Sub-components ─────────────────────────────────────────────────────────

function OverallStatus({ data }: Readonly<{ data: HealthCheckResponse }>) {
  const { t } = useTranslation();
  return (
    <div
      className={`rounded-lg border p-6 ${statusBg(data.status)}`}
      data-testid="overall-status"
    >
      <div className="flex items-center gap-3">
        <StatusIcon status={data.status} />
        <div>
          <h2 className="text-lg font-semibold">
            {t("monitoring.overallStatus")}
          </h2>
          <p className={`text-2xl font-bold uppercase ${statusColor(data.status)}`}>
            {data.status}
          </p>
        </div>
      </div>
      <p className="mt-2 text-sm text-gray-600 dark:text-gray-400">
        {t("monitoring.lastChecked")}: {data.timestamp}
      </p>
    </div>
  );
}

function MvStalenessCard({
  name,
  mvRows,
  sourceRows,
  stale,
}: Readonly<{
  name: string;
  mvRows: number;
  sourceRows: number;
  stale: boolean;
}>) {
  const status = stale ? "degraded" : "healthy";
  return (
    <div
      className={`rounded-lg border p-4 ${statusBg(status)}`}
      data-testid={`mv-${name}`}
    >
      <div className="flex items-center gap-2">
        <StatusIcon status={status} />
        <h3 className="font-medium">{name}</h3>
      </div>
      <div className="mt-3 space-y-1 text-sm">
        <div className="flex justify-between">
          <span className="text-gray-600 dark:text-gray-400">MV rows</span>
          <span className="font-mono">{mvRows.toLocaleString()}</span>
        </div>
        <div className="flex justify-between">
          <span className="text-gray-600 dark:text-gray-400">Source rows</span>
          <span className="font-mono">{sourceRows.toLocaleString()}</span>
        </div>
        <div className="flex justify-between">
          <span className="text-gray-600 dark:text-gray-400">Stale</span>
          <span className={stale ? "text-yellow-600 font-bold" : "text-green-600"}>
            {stale ? "Yes" : "No"}
          </span>
        </div>
      </div>
    </div>
  );
}

function RowCountCard({
  products,
  ceiling,
  utilizationPct,
}: Readonly<{
  products: number;
  ceiling: number;
  utilizationPct: number;
}>) {
  const status =
    utilizationPct > 95
      ? "unhealthy"
      : utilizationPct > 80
        ? "degraded"
        : "healthy";
  const barWidth = Math.min(utilizationPct, 100);

  return (
    <div
      className={`rounded-lg border p-4 ${statusBg(status)}`}
      data-testid="row-counts"
    >
      <div className="flex items-center gap-2">
        <Database className="h-5 w-5 text-blue-600 dark:text-blue-400" />
        <h3 className="font-medium">Product Row Count</h3>
      </div>
      <div className="mt-3 space-y-2">
        <div className="flex justify-between text-sm">
          <span className="text-gray-600 dark:text-gray-400">Active products</span>
          <span className="font-mono">{products.toLocaleString()}</span>
        </div>
        <div className="flex justify-between text-sm">
          <span className="text-gray-600 dark:text-gray-400">Ceiling</span>
          <span className="font-mono">{ceiling.toLocaleString()}</span>
        </div>
        <div className="relative h-3 w-full rounded-full bg-gray-200 dark:bg-gray-700">
          <div
            className={`absolute left-0 top-0 h-3 rounded-full ${
              status === "unhealthy"
                ? "bg-red-500"
                : status === "degraded"
                  ? "bg-yellow-500"
                  : "bg-green-500"
            }`}
            style={{ width: `${barWidth}%` }}
          />
        </div>
        <div className="text-right text-sm font-bold">
          <span className={statusColor(status)}>
            {utilizationPct}%
          </span>
        </div>
      </div>
    </div>
  );
}

// ─── Page Component ─────────────────────────────────────────────────────────

export default function AdminMonitoringPage() {
  const { t } = useTranslation();

  const { data, isLoading, error, dataUpdatedAt } = useQuery({
    queryKey: queryKeys.adminHealth,
    queryFn: fetchHealth,
    staleTime: staleTimes.adminHealth,
    refetchInterval: REFETCH_INTERVAL_MS,
    retry: 1,
  });

  const breadcrumbs = [
    { labelKey: "nav.admin", href: "/app/admin/submissions" },
    { labelKey: "monitoring.title" },
  ];

  return (
    <div className="mx-auto max-w-4xl px-4 py-6">
      <Breadcrumbs items={breadcrumbs} />

      <div className="mt-4 flex items-center gap-3">
        <Activity className="h-6 w-6 text-blue-600 dark:text-blue-400" />
        <h1 className="text-2xl font-bold">{t("monitoring.title")}</h1>
      </div>
      <p className="mt-1 text-sm text-gray-600 dark:text-gray-400">
        {t("monitoring.subtitle")}
      </p>

      {/* Loading state */}
      {isLoading && (
        <div className="mt-8 flex justify-center" data-testid="loading">
          <LoadingSpinner />
        </div>
      )}

      {/* Error state */}
      {error && !data && (
        <div
          className="mt-8 rounded-lg border border-red-200 bg-red-50 p-4 dark:border-red-800 dark:bg-red-900/20"
          data-testid="error-state"
        >
          <div className="flex items-center gap-2">
            <XCircle className="h-5 w-5 text-red-600" />
            <p className="font-medium text-red-800 dark:text-red-200">
              {t("monitoring.loadFailed")}
            </p>
          </div>
        </div>
      )}

      {/* Data display */}
      {data && (
        <div className="mt-6 space-y-6">
          {/* Overall Status */}
          <OverallStatus data={data} />

          {/* MV Staleness */}
          <div>
            <h2 className="mb-3 flex items-center gap-2 text-lg font-semibold">
              <RefreshCw className="h-5 w-5" />
              {t("monitoring.mvStaleness")}
            </h2>
            <div className="grid gap-4 sm:grid-cols-2">
              <MvStalenessCard
                name="mv_ingredient_frequency"
                mvRows={data.checks.mv_staleness.mv_ingredient_frequency.mv_rows}
                sourceRows={data.checks.mv_staleness.mv_ingredient_frequency.source_rows}
                stale={data.checks.mv_staleness.mv_ingredient_frequency.stale}
              />
              <MvStalenessCard
                name="v_product_confidence"
                mvRows={data.checks.mv_staleness.v_product_confidence.mv_rows}
                sourceRows={data.checks.mv_staleness.v_product_confidence.source_rows}
                stale={data.checks.mv_staleness.v_product_confidence.stale}
              />
            </div>
          </div>

          {/* Row Counts */}
          <div>
            <h2 className="mb-3 flex items-center gap-2 text-lg font-semibold">
              <Database className="h-5 w-5" />
              {t("monitoring.rowCounts")}
            </h2>
            <RowCountCard
              products={data.checks.row_counts.products}
              ceiling={data.checks.row_counts.ceiling}
              utilizationPct={data.checks.row_counts.utilization_pct}
            />
          </div>

          {/* Auto-refresh indicator */}
          <div className="text-center text-xs text-gray-500 dark:text-gray-500">
            <RefreshCw className="mr-1 inline-block h-3 w-3" />
            {t("monitoring.autoRefresh")}
            {dataUpdatedAt > 0 && (
              <span className="ml-2">
                · {t("monitoring.lastUpdated")}{" "}
                {new Date(dataUpdatedAt).toLocaleTimeString()}
              </span>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
