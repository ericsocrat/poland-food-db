"use client";

// ─── Compare page — side-by-side product comparison ─────────────────────────
// URL: /app/compare?ids=1,2,3,4
// Works with 2-4 product IDs from URL params.
// Authenticated users can save comparisons and see avoid badges.

import { EmptyState } from "@/components/common/EmptyState";
import { EmptyStateIllustration } from "@/components/common/EmptyStateIllustration";
import { ErrorBoundary } from "@/components/common/ErrorBoundary";
import { PrintButton } from "@/components/common/PrintButton";
import { ComparisonGridSkeleton } from "@/components/common/skeletons";
import { ComparisonGrid } from "@/components/compare/ComparisonGrid";
import { ShareComparison } from "@/components/compare/ShareComparison";
import { ExportButton } from "@/components/export/ExportButton";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { useAnalytics } from "@/hooks/use-analytics";
import { useCompareProducts } from "@/hooks/use-compare";
import { eventBus } from "@/lib/events";
import type { ExportableProduct } from "@/lib/export";
import { useTranslation } from "@/lib/i18n";
import { useCompareStore } from "@/stores/compare-store";
import { AlertTriangle, FolderOpen, Scale } from "lucide-react";
import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { useEffect, useMemo } from "react";

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
      nova_group: p.nova_group ?? "–",
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
      void eventBus.emit({
        type: "product.compared",
        payload: { productIds },
      });
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [productIds.length]);

  // Empty state — no IDs provided
  if (productIds.length < 2) {
    return (
      <div className="space-y-6">
        <h1 className="flex items-center gap-2 text-xl font-bold text-foreground lg:text-2xl">
          <Scale size={22} aria-hidden="true" /> {t("compare.title")}
        </h1>
        <EmptyStateIllustration
          type="no-comparisons"
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
    <div className="compare-print-container space-y-6">
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "nav.compare" },
        ]}
      />
      {/* Header */}
      <div className="flex items-center justify-between">
        <h1 className="flex items-center gap-2 text-xl font-bold text-foreground lg:text-2xl">
          <Scale size={22} aria-hidden="true" /> {t("compare.title")}
        </h1>
        <div className="no-print flex items-center gap-2">
          <Link
            href="/app/compare/saved"
            className="text-sm text-brand hover:text-brand-hover"
          >
            <FolderOpen size={16} className="inline-block" aria-hidden="true" />{" "}
            {t("compare.savedComparisons")}
          </Link>
          <button
            type="button"
            onClick={clear}
            className="text-sm text-foreground-secondary hover:text-foreground"
          >
            {t("compare.clearSelection")}
          </button>
          <PrintButton />
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
          <div className="card no-print flex items-center justify-between">
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
        <div className="card border-warning-border bg-warning-bg">
          <p className="flex items-center gap-1 text-sm text-warning-text">
            <AlertTriangle size={16} aria-hidden="true" />{" "}
            {t("compare.productsNotFound", {
              count: productIds.length - data.products.length,
            })}{" "}
            {t("compare.onlyShowingAvailable")}
          </p>
        </div>
      )}
    </div>
  );
}
