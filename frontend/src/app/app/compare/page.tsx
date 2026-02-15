"use client";

// ─── Compare page — side-by-side product comparison ─────────────────────────
// URL: /app/compare?ids=1,2,3,4
// Works with 2-4 product IDs from URL params.
// Authenticated users can save comparisons and see avoid badges.

import { useMemo } from "react";
import { useSearchParams } from "next/navigation";
import Link from "next/link";
import { useCompareProducts } from "@/hooks/use-compare";
import { ComparisonGrid } from "@/components/compare/ComparisonGrid";
import { ShareComparison } from "@/components/compare/ShareComparison";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import { useCompareStore } from "@/stores/compare-store";

export default function ComparePage() {
  const searchParams = useSearchParams();
  const idsParam = searchParams.get("ids") ?? "";
  const clear = useCompareStore((s) => s.clear);

  const productIds = useMemo(() => {
    if (!idsParam) return [];
    return idsParam
      .split(",")
      .map(Number)
      .filter((n) => !Number.isNaN(n) && n > 0)
      .slice(0, 4);
  }, [idsParam]);

  const { data, isLoading, error } = useCompareProducts(productIds);

  // Empty state — no IDs provided
  if (productIds.length < 2) {
    return (
      <div className="space-y-4">
        <h1 className="text-xl font-bold text-gray-900">⚖️ Compare Products</h1>
        <div className="card py-12 text-center">
          <p className="mb-2 text-4xl">⚖️</p>
          <p className="mb-1 text-sm text-gray-500">
            Select 2–4 products to compare
          </p>
          <p className="mb-4 text-xs text-gray-400">
            Use the ⚖️ checkbox on product cards in search or categories.
          </p>
          <div className="flex justify-center gap-3">
            <Link href="/app/search" className="btn-primary text-sm">
              🔍 Search Products
            </Link>
            <Link href="/app/compare/saved" className="btn-secondary text-sm">
              📂 Saved Comparisons
            </Link>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {/* Header */}
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-bold text-gray-900">⚖️ Compare Products</h1>
        <div className="flex items-center gap-2">
          <Link href="/app/compare/saved" className="text-sm text-brand-600 hover:text-brand-700">
            📂 Saved
          </Link>
          <button
            type="button"
            onClick={clear}
            className="text-sm text-gray-500 hover:text-gray-700"
          >
            Clear selection
          </button>
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
          <p className="mb-2 text-sm text-red-600">
            Failed to load comparison data.
          </p>
          <p className="text-xs text-gray-500">{error.message}</p>
        </div>
      )}

      {/* Comparison grid */}
      {data && data.products.length >= 2 && (
        <>
          {/* Share / Save toolbar */}
          <div className="card flex items-center justify-between">
            <p className="text-sm text-gray-500">
              Comparing {data.product_count} products
            </p>
            <ShareComparison productIds={productIds} />
          </div>

          <ComparisonGrid products={data.products} showAvoidBadge />
        </>
      )}

      {/* Partial results — some products not found */}
      {data && data.products.length < productIds.length && (
        <div className="card border-amber-200 bg-amber-50">
          <p className="text-sm text-amber-700">
            ⚠️ {productIds.length - data.products.length} product(s) not found.
            Only showing available products.
          </p>
        </div>
      )}
    </div>
  );
}
