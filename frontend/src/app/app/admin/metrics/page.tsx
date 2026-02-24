"use client";

// ─── Admin Business Metrics Dashboard (#188) ────────────────────────────────
// Displays 10 core business metrics: DAU, searches, top queries, failed
// searches, top products, allergen distribution, feature usage, scan vs
// search, onboarding funnel, and category popularity.
// Data fetched via api_admin_get_business_metrics RPC.
// Protected by middleware (ADMIN_EMAILS allow-list).

import { useState, useCallback } from "react";
import { useQuery } from "@tanstack/react-query";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import { createClient } from "@/lib/supabase/client";
import { getBusinessMetrics } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import {
  BarChart3,
  Users,
  Search,
  ScanLine,
  AlertTriangle,
  ShoppingBag,
  Shield,
  Layers,
  GitBranch,
  FolderOpen,
  Download,
  RefreshCw,
  XCircle,
} from "lucide-react";
import type { BusinessMetricsResponse } from "@/lib/types";

// ─── Constants ──────────────────────────────────────────────────────────────

const DATE_RANGE_OPTIONS = [
  { label: "7 days", value: 7 },
  { label: "14 days", value: 14 },
  { label: "30 days", value: 30 },
  { label: "90 days", value: 90 },
] as const;

// ─── Sub-components ─────────────────────────────────────────────────────────

function MetricCard({
  icon,
  label,
  value,
  subtitle,
  testId,
}: Readonly<{
  icon: React.ReactNode;
  label: string;
  value: string | number;
  subtitle?: React.ReactNode;
  testId: string;
}>) {
  return (
    <div
      className="rounded-lg border bg-white p-4 dark:border-gray-700 dark:bg-gray-800"
      data-testid={testId}
    >
      <div className="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-400">
        {icon}
        <span>{label}</span>
      </div>
      <p className="mt-2 text-2xl font-bold">{typeof value === "number" ? value.toLocaleString() : value}</p>
      {subtitle && (
        <div className="mt-1 text-xs text-gray-500 dark:text-gray-400">
          {subtitle}
        </div>
      )}
    </div>
  );
}

function RankingTable({
  title,
  icon,
  columns,
  rows,
  testId,
}: Readonly<{
  title: string;
  icon: React.ReactNode;
  columns: string[];
  rows: (string | number)[][];
  testId: string;
}>) {
  return (
    <div
      className="rounded-lg border bg-white p-4 dark:border-gray-700 dark:bg-gray-800"
      data-testid={testId}
    >
      <h3 className="mb-3 flex items-center gap-2 font-semibold">
        {icon}
        {title}
      </h3>
      {rows.length === 0 ? (
        <p className="text-sm text-gray-500 dark:text-gray-400">No data yet</p>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b text-left text-gray-500 dark:border-gray-700 dark:text-gray-400">
                <th className="pb-2 pr-2">#</th>
                {columns.map((col) => (
                  <th key={col} className="pb-2 pr-2">
                    {col}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {rows.map((row, i) => (
                <tr
                  key={i}
                  className="border-b last:border-0 dark:border-gray-700"
                >
                  <td className="py-1.5 pr-2 text-gray-400">{i + 1}</td>
                  {row.map((cell, j) => (
                    <td
                      key={j}
                      className={`py-1.5 pr-2 ${j === 0 ? "max-w-[200px] truncate" : "font-mono"}`}
                    >
                      {typeof cell === "number" ? cell.toLocaleString() : cell}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

function BarRow({
  label,
  value,
  maxValue,
  color,
}: Readonly<{
  label: string;
  value: number;
  maxValue: number;
  color: string;
}>) {
  const pct = maxValue > 0 ? Math.round((value / maxValue) * 100) : 0;
  return (
    <div className="flex items-center gap-2 text-sm">
      <span className="w-28 truncate text-gray-600 dark:text-gray-400">
        {label}
      </span>
      <div className="relative h-5 flex-1 rounded bg-gray-100 dark:bg-gray-700">
        <div
          className={`absolute left-0 top-0 h-5 rounded ${color}`}
          style={{ width: `${pct}%` }}
        />
        <span className="absolute inset-0 flex items-center justify-center text-xs font-medium">
          {value.toLocaleString()}
        </span>
      </div>
      <span className="w-10 text-right font-mono text-xs text-gray-500">
        {pct}%
      </span>
    </div>
  );
}

function FeatureUsageChart({
  data,
}: Readonly<{ data: BusinessMetricsResponse["feature_usage"] }>) {
  if (data.length === 0) {
    return <p className="text-sm text-gray-500 dark:text-gray-400">No data yet</p>;
  }
  const maxVal = Math.max(...data.map((d) => d.usage_count));
  return (
    <div className="space-y-2">
      {data.slice(0, 12).map((item) => (
        <BarRow
          key={item.feature}
          label={item.feature.replace(/_/g, " ")}
          value={item.usage_count}
          maxValue={maxVal}
          color="bg-blue-400 dark:bg-blue-600"
        />
      ))}
    </div>
  );
}

function ScanSearchRatio({
  data,
}: Readonly<{ data: BusinessMetricsResponse["scan_vs_search"] }>) {
  if (data.length === 0) {
    return <p className="text-sm text-gray-500 dark:text-gray-400">No data yet</p>;
  }
  const total = data.reduce((s, d) => s + d.count, 0);
  return (
    <div className="flex gap-2">
      {data.map((item) => {
        const pct = total > 0 ? Math.round((item.count / total) * 100) : 0;
        const color = item.method.includes("scan")
          ? "bg-purple-500"
          : "bg-blue-500";
        return (
          <div
            key={item.method}
            className={`flex flex-col items-center rounded-lg p-3 text-white ${color}`}
            style={{ flex: pct }}
          >
            <span className="text-xs font-medium opacity-80">
              {item.method.replace(/_/g, " ")}
            </span>
            <span className="text-lg font-bold">{pct}%</span>
            <span className="text-xs opacity-80">
              ({item.count.toLocaleString()})
            </span>
          </div>
        );
      })}
    </div>
  );
}

function TrendSparkline({
  data,
  metric,
}: Readonly<{
  data: BusinessMetricsResponse["trend"];
  metric: string;
}>) {
  const points = data
    .filter((d) => d.metric === metric)
    .sort((a, b) => a.date.localeCompare(b.date));

  if (points.length < 2) return null;

  const values = points.map((p) => p.value);
  const max = Math.max(...values, 1);
  const min = Math.min(...values, 0);
  const range = max - min || 1;
  const w = 120;
  const h = 32;

  const pathD = values
    .map((v, i) => {
      const x = (i / (values.length - 1)) * w;
      const y = h - ((v - min) / range) * h;
      return `${i === 0 ? "M" : "L"}${x},${y}`;
    })
    .join(" ");

  return (
    <svg width={w} height={h} className="inline-block" aria-hidden="true">
      <path d={pathD} fill="none" stroke="currentColor" strokeWidth="1.5" className="text-blue-500" />
    </svg>
  );
}

// ─── Page Component ─────────────────────────────────────────────────────────

export default function AdminMetricsPage() {
  const supabase = createClient();
  const [days, setDays] = useState(7);

  const { data, isLoading, error, refetch, dataUpdatedAt } = useQuery({
    queryKey: queryKeys.adminMetrics(undefined, days),
    queryFn: async () => {
      const result = await getBusinessMetrics(supabase, { days });
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.adminMetrics,
    retry: 1,
  });

  const handleExport = useCallback(() => {
    if (!data) return;
    const blob = new Blob([JSON.stringify(data, null, 2)], {
      type: "application/json",
    });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `metrics_${data.date}_${days}d.json`;
    a.click();
    URL.revokeObjectURL(url);
  }, [data, days]);

  const breadcrumbs = [
    { labelKey: "nav.admin", href: "/app/admin/submissions" },
    { label: "Business Metrics" },
  ];

  return (
    <div className="mx-auto max-w-6xl px-4 py-6">
      <Breadcrumbs items={breadcrumbs} />

      {/* Header */}
      <div className="mt-4 flex flex-wrap items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <BarChart3 className="h-6 w-6 text-blue-600 dark:text-blue-400" />
          <div>
            <h1 className="text-2xl font-bold">Business Metrics</h1>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Platform usage analytics and engagement data
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          {/* Date range selector */}
          <select
            value={days}
            onChange={(e) => setDays(Number(e.target.value))}
            className="rounded-md border bg-white px-3 py-1.5 text-sm dark:border-gray-700 dark:bg-gray-800"
            data-testid="date-range-select"
          >
            {DATE_RANGE_OPTIONS.map((opt) => (
              <option key={opt.value} value={opt.value}>
                {opt.label}
              </option>
            ))}
          </select>

          {/* Refresh */}
          <button
            onClick={() => refetch()}
            className="rounded-md border p-1.5 text-gray-600 hover:bg-gray-100 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700"
            title="Refresh"
            data-testid="refresh-btn"
          >
            <RefreshCw className="h-4 w-4" />
          </button>

          {/* Export */}
          <button
            onClick={handleExport}
            disabled={!data}
            className="flex items-center gap-1.5 rounded-md border px-3 py-1.5 text-sm text-gray-600 hover:bg-gray-100 disabled:opacity-50 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700"
            data-testid="export-btn"
          >
            <Download className="h-4 w-4" />
            Export JSON
          </button>
        </div>
      </div>

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
              Failed to load metrics. Check your connection and admin access.
            </p>
          </div>
        </div>
      )}

      {/* Data display */}
      {data && (
        <div className="mt-6 space-y-6">
          {/* Row 1: Summary cards */}
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
            <MetricCard
              icon={<Users className="h-4 w-4" />}
              label="Daily Active Users"
              value={data.dau}
              subtitle={
                data.trend.length > 0 ? (
                  <span className="inline-flex items-center gap-1">
                    <TrendSparkline data={data.trend} metric="dau" />
                  </span>
                ) : undefined
              }
              testId="metric-dau"
            />
            <MetricCard
              icon={<Search className="h-4 w-4" />}
              label="Searches Today"
              value={data.searches}
              testId="metric-searches"
            />
            <MetricCard
              icon={<AlertTriangle className="h-4 w-4" />}
              label="Failed Searches"
              value={data.failed_searches.length}
              subtitle="Zero-result queries"
              testId="metric-failed"
            />
            <MetricCard
              icon={<ScanLine className="h-4 w-4" />}
              label="Scan vs Search"
              value={
                data.scan_vs_search.length > 0
                  ? data.scan_vs_search
                      .map((s) => `${s.percentage}% ${s.method.includes("scan") ? "scan" : "search"}`)
                      .join(" / ")
                  : "No data"
              }
              testId="metric-scan-ratio"
            />
          </div>

          {/* Row 2: Tables */}
          <div className="grid gap-4 lg:grid-cols-2">
            <RankingTable
              title="Top Search Queries"
              icon={<Search className="h-4 w-4" />}
              columns={["Query", "Count"]}
              rows={data.top_queries.map((q) => [q.query, q.count])}
              testId="top-queries"
            />
            <RankingTable
              title="Top Products"
              icon={<ShoppingBag className="h-4 w-4" />}
              columns={["Product", "Views"]}
              rows={data.top_products.map((p) => [
                p.product_name || p.product_id,
                p.views,
              ])}
              testId="top-products"
            />
          </div>

          {/* Row 3: Feature usage */}
          <div className="rounded-lg border bg-white p-4 dark:border-gray-700 dark:bg-gray-800" data-testid="feature-usage">
            <h3 className="mb-3 flex items-center gap-2 font-semibold">
              <Layers className="h-4 w-4" />
              Feature Usage ({days} days)
            </h3>
            <FeatureUsageChart data={data.feature_usage} />
          </div>

          {/* Row 4: Allergen distribution + Scan vs search */}
          <div className="grid gap-4 lg:grid-cols-2">
            <div
              className="rounded-lg border bg-white p-4 dark:border-gray-700 dark:bg-gray-800"
              data-testid="allergen-dist"
            >
              <h3 className="mb-3 flex items-center gap-2 font-semibold">
                <Shield className="h-4 w-4" />
                Allergen Profile Distribution
              </h3>
              {data.allergen_distribution.length === 0 ? (
                <p className="text-sm text-gray-500 dark:text-gray-400">
                  No allergen profiles configured yet
                </p>
              ) : (
                <div className="space-y-2">
                  {data.allergen_distribution.slice(0, 10).map((item) => (
                    <BarRow
                      key={item.allergen}
                      label={item.allergen.replace("en:", "")}
                      value={item.user_count}
                      maxValue={data.allergen_distribution[0].user_count}
                      color="bg-amber-400 dark:bg-amber-600"
                    />
                  ))}
                </div>
              )}
            </div>

            <div
              className="rounded-lg border bg-white p-4 dark:border-gray-700 dark:bg-gray-800"
              data-testid="scan-vs-search"
            >
              <h3 className="mb-3 flex items-center gap-2 font-semibold">
                <ScanLine className="h-4 w-4" />
                Scan vs Search
              </h3>
              <ScanSearchRatio data={data.scan_vs_search} />
            </div>
          </div>

          {/* Row 5: Onboarding funnel + Category popularity */}
          <div className="grid gap-4 lg:grid-cols-2">
            <RankingTable
              title="Onboarding Funnel"
              icon={<GitBranch className="h-4 w-4" />}
              columns={["Step", "Users", "Rate"]}
              rows={data.onboarding_funnel.map((s) => [
                s.step,
                s.user_count,
                `${s.completion_rate}%`,
              ])}
              testId="onboarding-funnel"
            />
            <RankingTable
              title="Category Popularity"
              icon={<FolderOpen className="h-4 w-4" />}
              columns={["Category", "Views", "Users"]}
              rows={data.category_popularity.map((c) => [
                c.category,
                c.views,
                c.unique_users,
              ])}
              testId="category-popularity"
            />
          </div>

          {/* Footer */}
          <div className="flex items-center justify-between text-xs text-gray-500 dark:text-gray-500">
            <span>
              <RefreshCw className="mr-1 inline-block h-3 w-3" />
              Last updated:{" "}
              {dataUpdatedAt > 0
                ? new Date(dataUpdatedAt).toLocaleTimeString()
                : "—"}
            </span>
            <span>
              Date: {data.date} · Range: {data.days} days
            </span>
          </div>
        </div>
      )}
    </div>
  );
}
