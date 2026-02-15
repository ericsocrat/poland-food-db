"use client";

// ─── Saved Comparisons — list of user's saved comparisons ───────────────────
// URL: /app/compare/saved

import Link from "next/link";
import { useSavedComparisons, useDeleteComparison } from "@/hooks/use-compare";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import type { SavedComparison } from "@/lib/types";

export default function SavedComparisonsPage() {
  const { data, isLoading, error } = useSavedComparisons();
  const { mutate: remove } = useDeleteComparison();

  return (
    <div className="space-y-4">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <Link
            href="/app/compare"
            className="inline-flex items-center gap-1 text-sm text-gray-500 hover:text-gray-700"
          >
            <svg className="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
              <path
                fillRule="evenodd"
                d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z"
                clipRule="evenodd"
              />
            </svg>
            Compare
          </Link>
          <h1 className="mt-1 text-xl font-bold text-gray-900">
            📂 Saved Comparisons
          </h1>
        </div>
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
          <p className="text-sm text-red-600">Failed to load comparisons.</p>
        </div>
      )}

      {/* Empty state */}
      {data && data.comparisons.length === 0 && (
        <div className="card py-12 text-center">
          <p className="mb-2 text-4xl">📂</p>
          <p className="mb-1 text-sm text-gray-500">No saved comparisons yet</p>
          <p className="mb-4 text-xs text-gray-400">
            Compare products and save them for later reference.
          </p>
          <Link href="/app/search" className="btn-primary text-sm">
            🔍 Find Products
          </Link>
        </div>
      )}

      {/* Comparisons list */}
      {data && data.comparisons.length > 0 && (
        <ul className="space-y-2">
          {data.comparisons.map((comp) => (
            <ComparisonCard
              key={comp.comparison_id}
              comparison={comp}
              onDelete={() => remove(comp.comparison_id)}
            />
          ))}
        </ul>
      )}
    </div>
  );
}

function ComparisonCard({
  comparison,
  onDelete,
}: Readonly<{
  comparison: SavedComparison;
  onDelete: () => void;
}>) {
  const ids = comparison.product_ids.join(",");
  const date = new Date(comparison.created_at).toLocaleDateString();

  return (
    <li className="card">
      <div className="flex items-start justify-between">
        <Link
          href={`/app/compare?ids=${ids}`}
          className="min-w-0 flex-1 hover:text-brand-600"
        >
          <p className="font-medium text-gray-900">
            {comparison.title ??
              `Compare ${comparison.product_ids.length} products`}
          </p>
          <div className="mt-1 flex flex-wrap gap-1">
            {comparison.product_names.map((name, i) => (
              <span
                key={i}
                className="rounded-full bg-gray-100 px-2 py-0.5 text-xs text-gray-600"
              >
                {name}
              </span>
            ))}
          </div>
          <p className="mt-1 text-xs text-gray-400">{date}</p>
        </Link>

        <div className="ml-3 flex items-center gap-2">
          {/* Share link */}
          {comparison.share_token && (
            <button
              type="button"
              onClick={(e) => {
                e.preventDefault();
                const url = `${window.location.origin}/compare/shared/${comparison.share_token}`;
                navigator.clipboard.writeText(url);
              }}
              className="text-sm text-gray-400 hover:text-brand-600"
              title="Copy share link"
            >
              🔗
            </button>
          )}

          {/* Delete */}
          <button
            type="button"
            onClick={(e) => {
              e.preventDefault();
              onDelete();
            }}
            className="text-sm text-gray-400 hover:text-red-500"
            title="Delete comparison"
          >
            🗑️
          </button>
        </div>
      </div>
    </li>
  );
}
