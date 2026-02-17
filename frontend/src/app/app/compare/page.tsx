"use client";

// ─── Compare page — side-by-side product comparison ─────────────────────────
// URL: /app/compare?ids=1,2,3,4
// Works with 2-4 product IDs from URL params.
// Authenticated users can save comparisons and see avoid badges.

import { useMemo, useEffect } from "react";
import { useSearchParams } from "next/navigation";
import Link from "next/link";
import { useCompareProducts } from "@/hooks/use-compare";
import { ComparisonGrid } from "@/components/compare/ComparisonGrid";
import { ShareComparison } from "@/components/compare/ShareComparison";
import { ExportButton } from "@/components/export/ExportButton";
import { ComparisonGridSkeleton } from "@/components/common/skeletons";
import { EmptyState } from "@/components/common/EmptyState";
import { useCompareStore } from "@/stores/compare-store";
import { useAnalytics } from "@/hooks/use-analytics";
import { useTranslation } from "@/lib/i18n";
import { ErrorBoundary } from "@/components/common/ErrorBoundary";
import type { ExportableProduct } from "@/lib/export";

export default function ComparePage() {
  const searchParams = useSearchParams();
  const idsParam = searchParams.get("ids") ?? "";
  const clear = useCompareStore((s) => s.clear);
  const { t } = useTranslation();

  const productIds = useMemo(() => {
    if (!idsParam) return [];
    return idsParam
      .split(",")
      .map(Number)
      .filter((n) => !Number.isNaN(n) && n > 0)
      .slice(0, 4);
  }, [idsParam]);

  const { data, isLoading, error } = useCompareProducts(productIds);
  const { track } = useAnalytics();

  const exportableProducts: ExportableProduct[] = useMemo(() => {
    if (!data?.products) return [];
    return data.products.map((p) => ({
      product_name: p.product_name,
      brand: p.brand,
      ean: p.ean ?? undefined,
      category: p.category,
      unhealthiness_score: p.unhealthiness_score,
      nutri_score_label: p.nutri_score ?? "–",
      nova_group: p.nova_group,
      calories_kcal: p.calories,
      total_fat_g: p.total_fat_g,
      saturated_fat_g: p.saturated_fat_g,
      sugars_g: p.sugars_g,
      salt_g: p.salt_g,
      protein_g: p.protein_g,
      fiber_g: p.fibre_g ?? undefined,
      allergen_tags: p.allergen_tags
        ? p.allergen_tags.split(",").map((s) => s.trim())
        : undefined,
      confidence_band: p.confidence,
    }));
  }, [data?.products]);

  useEffect(() => {
    if (productIds.length >= 2) {
      track("compare_opened", {
        product_ids: productIds,
        count: productIds.length,
      });
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [productIds.length]);

  // Empty state — no IDs provided
  if (productIds.length < 2) {
    return (
      <div className="space-y-4">
        <h1 className="text-xl font-bold text-foreground">
          ⚖️ {t("compare.title")}
        </h1>
        <EmptyState
          variant="no-data"
          icon={<span>⚖️</span>}
          titleKey="compare.selectPrompt"
          descriptionKey="compare.useCheckbox"
          action={{ labelKey: "compare.searchProducts", href: "/app/search" }}
          secondaryAction={{
            labelKey: "compare.savedComparisons",
            href: "/app/compare/saved",
          }}
        />
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {/* Header */}
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-bold text-foreground">
          ⚖️ {t("compare.title")}
        </h1>
        <div className="flex items-center gap-2">
          <Link
            href="/app/compare/saved"
            className="text-sm text-brand-600 hover:text-brand-700"
          >
            📂 {t("compare.savedComparisons")}
          </Link>
          <button
            type="button"
            onClick={clear}
            className="text-sm text-foreground-secondary hover:text-foreground"
          >
            {t("compare.clearSelection")}
          </button>
        </div>
      </div>

      {/* Loading */}
      {isLoading && <ComparisonGridSkeleton />}

      {/* Error */}
      {error && <EmptyState variant="error" titleKey="compare.loadFailed" />}

      {/* Comparison grid */}
      {data && data.products.length >= 2 && (
        <>
          {/* Share / Save toolbar */}
          <div className="card flex items-center justify-between">
            <p className="text-sm text-foreground-secondary">
              {t("compare.comparing", { count: data.product_count })}
            </p>
            <div className="flex items-center gap-2">
              <ExportButton
                products={exportableProducts}
                filename="comparison"
                comparison
              />
              <ShareComparison productIds={productIds} />
            </div>
          </div>

          <ErrorBoundary
            level="section"
            context={{ section: "comparison-grid" }}
          >
            <ComparisonGrid products={data.products} showAvoidBadge />
          </ErrorBoundary>
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
