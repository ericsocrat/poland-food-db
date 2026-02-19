"use client";

// ─── Shared Comparison Page — public, no auth required ──────────────────────
// URL: /compare/shared/[token]
// Displays a shared comparison with the ComparisonGrid component.
// No avoid badges or save features — read-only public view.

import { useParams } from "next/navigation";
import Link from "next/link";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { useSharedComparison } from "@/hooks/use-compare";
import { ComparisonGrid } from "@/components/compare/ComparisonGrid";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import { useTranslation } from "@/lib/i18n";
import { Link2, Scale } from "lucide-react";

const queryClient = new QueryClient();

function SharedComparisonContent() {
  const params = useParams();
  const token = String(params.token ?? "");
  const { data, isLoading, error } = useSharedComparison(token);
  const { t } = useTranslation();

  return (
    <div className="min-h-screen bg-surface-subtle">
      {/* Header */}
      <header className="border-b border bg-surface">
        <div className="mx-auto flex h-14 max-w-5xl items-center justify-between px-4">
          <Link
            href="/"
            className="text-lg font-bold text-brand-700 dark:text-brand-400"
          >
            🥗 FoodDB
          </Link>
          <span className="rounded-full bg-blue-100 px-3 py-1 text-xs font-medium text-blue-700">
            {t("shared.sharedComparison")}
          </span>
        </div>
      </header>

      <main className="mx-auto max-w-5xl px-4 py-6 space-y-4">
        {/* Loading */}
        {isLoading && (
          <div className="flex justify-center py-12">
            <LoadingSpinner />
          </div>
        )}

        {/* Error / not found */}
        {error && (
          <div className="card border-red-200 bg-red-50 py-8 text-center">
            <Link2
              size={40}
              aria-hidden="true"
              className="mx-auto mb-2 text-foreground-muted"
            />
            <p className="mb-1 text-sm text-red-600">
              {t("shared.comparisonInvalid")}
            </p>
            <Link href="/" className="mt-3 btn-primary inline-block text-sm">
              {t("shared.goToFoodDB")}
            </Link>
          </div>
        )}

        {/* Comparison data */}
        {data && data.products.length >= 2 && (
          <>
            <div className="flex items-center justify-between">
              <div>
                <h1 className="text-xl font-bold text-foreground flex items-center gap-1.5">
                  <Scale size={20} aria-hidden="true" />{" "}
                  {data.title ?? t("shared.productComparison")}
                </h1>
                <p className="text-sm text-foreground-secondary">
                  {data.product_count} {t("shared.productsCompared")} ·{" "}
                  {new Date(data.created_at).toLocaleDateString()}
                </p>
              </div>
            </div>

            <ComparisonGrid products={data.products} showAvoidBadge={false} />
          </>
        )}

        {/* CTA */}
        <div className="card bg-brand-50 text-center">
          <p className="mb-2 text-sm text-foreground-secondary">
            {t("shared.wantToCompare")}
          </p>
          <Link href="/auth/login" className="btn-primary inline-block text-sm">
            {t("shared.signUpFree")}
          </Link>
        </div>
      </main>
    </div>
  );
}

export default function SharedComparisonPage() {
  return (
    <QueryClientProvider client={queryClient}>
      <SharedComparisonContent />
    </QueryClientProvider>
  );
}
