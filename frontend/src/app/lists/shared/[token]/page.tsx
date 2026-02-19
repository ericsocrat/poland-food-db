"use client";

// ─── Shared list page (public) ──────────────────────────────────────────────
// Accessible without authentication via share token URL.
// Shows read-only view of a shared list with product details.

import { useParams } from "next/navigation";
import Link from "next/link";
import { useSharedList } from "@/hooks/use-lists";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import { SCORE_BANDS, NUTRI_COLORS, scoreBandFromScore } from "@/lib/constants";
import { useTranslation } from "@/lib/i18n";

export default function SharedListPage() {
  const params = useParams();
  const token = String(params.token ?? "");

  const { data, isLoading, error } = useSharedList(token);
  const { t } = useTranslation();

  if (isLoading) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-surface-subtle">
        <LoadingSpinner />
      </div>
    );
  }

  if (error || !data) {
    return (
      <div className="flex min-h-screen flex-col items-center justify-center bg-surface-subtle px-4">
        <p className="mb-2 text-4xl">🔒</p>
        <h1 className="mb-1 text-lg font-bold text-foreground">
          {t("shared.listNotFound")}
        </h1>
        <p className="mb-6 text-sm text-foreground-secondary">
          {t("shared.listNotFoundMessage")}
        </p>
        <Link href="/" className="btn-primary">
          {t("error.goHome")}
        </Link>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-surface-subtle">
      {/* Header */}
      <header className="border-b border bg-white/80 backdrop-blur">
        <div className="mx-auto flex h-14 max-w-3xl items-center justify-between px-4">
          <span className="text-lg font-bold text-brand">🥗 FoodDB</span>
          <span className="rounded-full bg-blue-50 px-2.5 py-0.5 text-xs font-medium text-blue-600">
            {t("shared.sharedList")}
          </span>
        </div>
      </header>

      <main className="mx-auto max-w-3xl px-4 py-6">
        <div className="space-y-4">
          {/* List info */}
          <div className="card">
            <h1 className="text-lg font-bold text-foreground">
              {data.list_name}
            </h1>
            {data.description && (
              <p className="mt-1 text-sm text-foreground-secondary">
                {data.description}
              </p>
            )}
            <p className="mt-1 text-xs text-foreground-muted">
              {t("common.products", { count: data.total_count })}
            </p>
          </div>

          {/* Items */}
          {data.items.length === 0 ? (
            <div className="py-12 text-center">
              <p className="text-sm text-foreground-muted">
                {t("shared.listEmpty")}
              </p>
            </div>
          ) : (
            <ul className="space-y-2">
              {data.items.map((item) => {
                const score = item.unhealthiness_score;
                const bandKey = scoreBandFromScore(score);
                const band = SCORE_BANDS[bandKey];
                const nutriClass = item.nutri_score_label
                  ? (NUTRI_COLORS[item.nutri_score_label] ??
                    "bg-surface-muted text-foreground-secondary")
                  : "bg-surface-muted text-foreground-secondary";

                return (
                  <li
                    key={item.product_id}
                    className="card flex items-center gap-3"
                  >
                    {/* Score badge */}
                    <div
                      className={`flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-lg text-lg font-bold ${band.bg} ${band.color}`}
                    >
                      {item.unhealthiness_score}
                    </div>

                    {/* Product info */}
                    <div className="min-w-0 flex-1">
                      <p className="truncate font-medium text-foreground">
                        {item.product_name}
                      </p>
                      <p className="truncate text-sm text-foreground-secondary">
                        {item.brand}
                        {item.category && ` · ${item.category}`}
                      </p>
                    </div>

                    {/* Nutri badge */}
                    <span
                      className={`flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-full text-sm font-bold ${nutriClass}`}
                    >
                      {item.nutri_score_label ?? "?"}
                    </span>
                  </li>
                );
              })}
            </ul>
          )}
        </div>
      </main>
    </div>
  );
}
