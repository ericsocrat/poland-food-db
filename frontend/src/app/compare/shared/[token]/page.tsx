"use client";

// ─── Shared Comparison Page — public, no auth required ──────────────────────
// URL: /compare/shared/[token]
// Displays a shared comparison with the ComparisonGrid component.
// No avoid badges or save features — read-only public view.

import { ButtonLink } from "@/components/common/Button";
import { ComparisonGridSkeleton } from "@/components/common/skeletons";
import { Logo } from "@/components/common/Logo";
import { ComparisonGrid } from "@/components/compare/ComparisonGrid";
import { useSharedComparison } from "@/hooks/use-compare";
import { useTranslation } from "@/lib/i18n";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Link2, Scale } from "lucide-react";
import Link from "next/link";
import { useParams } from "next/navigation";

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
            aria-label="TryVit"
          >
            <Logo variant="lockup" size={28} />
          </Link>
          <span className="rounded-full bg-info-bg px-3 py-1 text-xs font-medium text-info-text">
            {t("shared.sharedComparison")}
          </span>
        </div>
      </header>

      <main className="mx-auto max-w-5xl px-4 py-6 space-y-4">
        {/* Loading */}
        {isLoading && <ComparisonGridSkeleton />}

        {/* Error / not found */}
        {error && (
          <div className="card border-error-border bg-error-bg py-8 text-center">
            <Link2
              size={40}
              aria-hidden="true"
              className="mx-auto mb-2 text-foreground-muted"
            />
            <p className="mb-1 text-sm text-error-text">
              {t("shared.comparisonInvalid")}
            </p>
            <ButtonLink href="/" className="mt-3" size="sm">
              {t("shared.goToTryVit")}
            </ButtonLink>
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
                  {t("shared.productsCompared", { count: data.product_count })} ·{" "}
                  {new Date(data.created_at).toLocaleDateString()}
                </p>
              </div>
            </div>

            <ComparisonGrid products={data.products} showAvoidBadge={false} />
          </>
        )}

        {/* CTA */}
        <div className="card bg-brand-subtle text-center">
          <p className="mb-2 text-sm text-foreground-secondary">
            {t("shared.wantToCompare")}
          </p>
          <ButtonLink href="/auth/login" size="sm">
            {t("shared.signUpFree")}
          </ButtonLink>
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
