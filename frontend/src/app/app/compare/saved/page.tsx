"use client";

// ─── Saved Comparisons — list of user's saved comparisons ───────────────────
// URL: /app/compare/saved

import Link from "next/link";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { useSavedComparisons, useDeleteComparison } from "@/hooks/use-compare";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import { EmptyState } from "@/components/common/EmptyState";
import { useTranslation } from "@/lib/i18n";
import type { SavedComparison } from "@/lib/types";

export default function SavedComparisonsPage() {
  const { data, isLoading, error } = useSavedComparisons();
  const { mutate: remove } = useDeleteComparison();
  const { t } = useTranslation();

  return (
    <div className="space-y-4">
      {/* Breadcrumbs */}
      <Breadcrumbs items={[
        { labelKey: "nav.home", href: "/app" },
        { labelKey: "compare.title", href: "/app/compare" },
        { labelKey: "compare.savedComparisons" },
      ]} />

      {/* Header */}
      <h1 className="text-xl font-bold text-foreground">
        {"📂 "}
        {t("compare.savedComparisons")}
      </h1>

      {/* Loading */}
      {isLoading && (
        <div className="flex justify-center py-12">
          <LoadingSpinner />
        </div>
      )}

      {/* Error */}
      {error && <EmptyState variant="error" titleKey="compare.loadFailed" />}

      {/* Empty state */}
      {data?.comparisons.length === 0 && (
        <EmptyState
          variant="no-data"
          icon={<span>📂</span>}
          titleKey="compare.noSaved"
          descriptionKey="compare.noSavedDescription"
          action={{ labelKey: "compare.findProducts", href: "/app/search" }}
        />
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
  const { t } = useTranslation();
  const ids = comparison.product_ids.join(",");
  const date = new Date(comparison.created_at).toLocaleDateString();

  return (
    <li className="card">
      <div className="flex items-start justify-between">
        <Link
          href={`/app/compare?ids=${ids}`}
          className="min-w-0 flex-1 hover:text-brand-600"
        >
          <p className="font-medium text-foreground">
            {comparison.title ??
              t("compare.compareProducts", {
                count: comparison.product_ids.length,
              })}
          </p>
          <div className="mt-1 flex flex-wrap gap-1">
            {comparison.product_names.map((name) => (
              <span
                key={name}
                className="rounded-full bg-surface-muted px-2 py-0.5 text-xs text-foreground-secondary"
              >
                {name}
              </span>
            ))}
          </div>
          <p className="mt-1 text-xs text-foreground-muted">{date}</p>
        </Link>

        <div className="ml-3 flex items-center gap-2">
          {/* Share link */}
          {comparison.share_token && (
            <button
              type="button"
              onClick={(e) => {
                e.preventDefault();
                const url = `${globalThis.location.origin}/compare/shared/${comparison.share_token}`;
                navigator.clipboard.writeText(url);
              }}
              className="text-sm text-foreground-muted hover:text-brand-600"
              title={t("compare.copyShareLink")}
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
            className="text-sm text-foreground-muted hover:text-red-500"
            title={t("compare.deleteComparison")}
          >
            🗑️
          </button>
        </div>
      </div>
    </li>
  );
}
