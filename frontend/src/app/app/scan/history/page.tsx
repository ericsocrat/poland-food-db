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
import type { ScanHistoryItem } from "@/lib/types";

const FILTERS = [
  { value: "all", label: "All" },
  { value: "found", label: "Found" },
  { value: "not_found", label: "Not Found" },
] as const;

export default function ScanHistoryPage() {
  const supabase = createClient();
  const router = useRouter();
  const queryClient = useQueryClient();
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
          <h1 className="text-lg font-semibold text-gray-900">
            📋 Scan History
          </h1>
          <p className="text-sm text-gray-500">Your barcode scan activity</p>
        </div>
        <Link
          href="/app/scan"
          className="text-sm text-brand-600 hover:text-brand-700"
        >
          ← Back to Scanner
        </Link>
      </div>

      {/* Filter toggle */}
      <div className="flex gap-1 rounded-lg bg-gray-100 p-1">
        {FILTERS.map((f) => (
          <button
            key={f.value}
            onClick={() => {
              setFilter(f.value);
              setPage(1);
            }}
            className={`flex-1 rounded-md px-3 py-1.5 text-sm font-medium transition-colors ${
              filter === f.value
                ? "bg-white text-brand-700 shadow-sm"
                : "text-gray-500 hover:text-gray-700"
            }`}
          >
            {f.label}
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
        <div className="card border-red-200 bg-red-50 text-center">
          <p className="mb-2 text-sm text-red-600">
            Failed to load scan history.
          </p>
          <button
            onClick={handleRetry}
            className="text-sm font-medium text-red-700 hover:text-red-800"
          >
            🔄 Retry
          </button>
        </div>
      )}

      {/* Empty */}
      {data?.scans.length === 0 && (
        <div className="py-12 text-center">
          <p className="mb-2 text-4xl">📷</p>
          <p className="mb-1 text-sm text-gray-500">No scans yet</p>
          <p className="mb-4 text-xs text-gray-400">
            Scan a barcode to start building your history.
          </p>
          <Link
            href="/app/scan"
            className="text-sm text-brand-600 hover:text-brand-700"
          >
            Start scanning →
          </Link>
        </div>
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
            ← Prev
          </button>
          <span className="text-sm text-gray-500">
            Page {data.page} of {data.pages}
          </span>
          <button
            onClick={() => setPage((p) => Math.min(data.pages, p + 1))}
            disabled={page >= data.pages}
            className="btn-secondary px-3 py-1.5 text-sm disabled:opacity-40"
          >
            Next →
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
          onClick={() => onNavigate(scan.product_id!)}
          className="flex w-full items-center gap-3 text-left"
        >
          {/* Nutri badge */}
          {scan.nutri_score && (
            <span
              className={`flex h-7 w-7 flex-shrink-0 items-center justify-center rounded text-xs font-bold text-white ${
                NUTRI_COLORS[scan.nutri_score] ?? "bg-gray-400"
              }`}
            >
              {scan.nutri_score}
            </span>
          )}
          <div className="min-w-0 flex-1">
            <p className="truncate font-medium text-gray-900">
              {scan.product_name}
            </p>
            <p className="text-xs text-gray-500">
              {scan.brand} · {scan.category}
            </p>
          </div>
          <div className="flex flex-shrink-0 flex-col items-end">
            <span className="text-xs text-gray-400">{timeStr}</span>
            <span className="mt-0.5 text-xs font-mono text-gray-300">
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
          <p className="font-mono text-sm text-gray-700">{scan.ean}</p>
          <p className="text-xs text-gray-500">
            Not found
            {scan.submission_status && (
              <span className="ml-1">
                · Submission: {scan.submission_status}
              </span>
            )}
          </p>
        </div>
        <div className="flex flex-shrink-0 flex-col items-end gap-1">
          <span className="text-xs text-gray-400">{timeStr}</span>
          {!scan.submission_status && (
            <Link
              href={`/app/scan/submit?ean=${scan.ean}`}
              className="text-xs text-brand-600 hover:text-brand-700"
            >
              Submit →
            </Link>
          )}
        </div>
      </div>
    </li>
  );
}
