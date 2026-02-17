"use client";

// ─── Saved Searches page — CRUD for authenticated users ─────────────────────

import { useState, useCallback } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { getSavedSearches, deleteSavedSearch } from "@/lib/api";
import { EmptyState } from "@/components/common/EmptyState";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { ALLERGEN_TAGS } from "@/lib/constants";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import { ConfirmDialog } from "@/components/common/ConfirmDialog";
import { useTranslation } from "@/lib/i18n";
import type { SavedSearch, SearchFilters } from "@/lib/types";

export default function SavedSearchesPage() {
  const supabase = createClient();
  const queryClient = useQueryClient();
  const router = useRouter();
  const { t } = useTranslation();

  const [confirmDeleteId, setConfirmDeleteId] = useState<string | null>(null);

  const { data, isLoading, error } = useQuery({
    queryKey: queryKeys.savedSearches,
    queryFn: async () => {
      const result = await getSavedSearches(supabase);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.savedSearches,
  });

  const deleteMutation = useMutation({
    mutationFn: async (searchId: string) => {
      const result = await deleteSavedSearch(supabase, searchId);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.savedSearches });
    },
  });

  const handleRetry = useCallback(() => {
    queryClient.invalidateQueries({ queryKey: queryKeys.savedSearches });
  }, [queryClient]);

  function applySearch(search: SavedSearch) {
    // Build URL params from the saved search
    const params = new URLSearchParams();
    if (search.query) params.set("q", search.query);
    if (search.filters && Object.keys(search.filters).length > 0) {
      params.set("filters", JSON.stringify(search.filters));
    }
    router.push(`/app/search?${params.toString()}`);
  }

  return (
    <div className="space-y-4">
      {/* Breadcrumbs */}
      <Breadcrumbs items={[
        { labelKey: "nav.home", href: "/app" },
        { labelKey: "nav.search", href: "/app/search" },
        { labelKey: "savedSearches.title" },
      ]} />

      {/* Header */}
      <div>
        <h1 className="text-lg font-semibold text-foreground">
          {"📋 "}
          {t("savedSearches.title")}
        </h1>
        <p className="text-sm text-foreground-secondary">{t("savedSearches.subtitle")}</p>
      </div>

      {/* Loading */}
      {isLoading && (
        <div className="flex justify-center py-12">
          <LoadingSpinner />
        </div>
      )}

      {/* Error */}
      {error && (
        <EmptyState
          variant="error"
          titleKey="savedSearches.loadFailed"
          action={{ labelKey: "common.retry", onClick: handleRetry }}
        />
      )}

      {/* Empty state */}
      {data?.searches.length === 0 && (
        <EmptyState
          variant="no-data"
          icon={<span>💾</span>}
          titleKey="savedSearches.emptyTitle"
          descriptionKey="savedSearches.emptyMessage"
          action={{ labelKey: "savedSearches.goToSearch", href: "/app/search" }}
        />
      )}

      {/* List */}
      {data && data.searches.length > 0 && (
        <ul className="space-y-2">
          {data.searches.map((search) => (
            <li key={search.id} className="card">
              <div className="flex items-start gap-3">
                {/* Info */}
                <button
                  type="button"
                  className="min-w-0 flex-1 cursor-pointer text-left"
                  onClick={() => applySearch(search)}
                >
                  <p className="font-medium text-foreground">{search.name}</p>
                  <p className="mt-0.5 text-sm text-foreground-secondary">
                    {search.query
                      ? t("savedSearches.query", { query: search.query })
                      : t("savedSearches.browseMode")}
                  </p>
                  {/* Filter summary */}
                  {search.filters && Object.keys(search.filters).length > 0 && (
                    <div className="mt-1.5 flex flex-wrap gap-1">
                      <FilterSummaryChips filters={search.filters} />
                    </div>
                  )}
                  <p className="mt-1 text-xs text-foreground-muted">
                    {new Date(search.created_at).toLocaleDateString()}
                  </p>
                </button>

                {/* Actions */}
                <div className="flex flex-shrink-0 gap-1">
                  <button
                    type="button"
                    onClick={() => applySearch(search)}
                    className="rounded-lg px-3 py-1.5 text-xs font-medium text-brand-600 transition-colors hover:bg-brand-50"
                  >
                    {t("savedSearches.apply")}
                  </button>
                  <button
                    type="button"
                    onClick={() => setConfirmDeleteId(search.id)}
                    disabled={deleteMutation.isPending}
                    className="rounded-lg px-2 py-1.5 text-xs text-foreground-muted transition-colors hover:bg-red-50 hover:text-red-500"
                  >
                    🗑️
                  </button>
                </div>
              </div>
            </li>
          ))}
        </ul>
      )}

      <ConfirmDialog
        open={confirmDeleteId !== null}
        title={t("savedSearches.deleteConfirm")}
        description={t("savedSearches.cannotUndo")}
        confirmLabel={t("common.delete")}
        variant="danger"
        onConfirm={() => {
          if (confirmDeleteId) deleteMutation.mutate(confirmDeleteId);
          setConfirmDeleteId(null);
        }}
        onCancel={() => setConfirmDeleteId(null)}
      />
    </div>
  );
}

function FilterSummaryChips({ filters }: Readonly<{ filters: SearchFilters }>) {
  const { t } = useTranslation();
  const chips: string[] = [];

  if (filters.category?.length) {
    chips.push(
      t("savedSearches.categories", { count: filters.category.length }),
    );
  }
  if (filters.nutri_score?.length) {
    chips.push(
      t("savedSearches.nutriFilter", {
        values: filters.nutri_score.join(", "),
      }),
    );
  }
  if (filters.allergen_free?.length) {
    const labels = filters.allergen_free.map((tag) => {
      const info = ALLERGEN_TAGS.find((a) => a.tag === tag);
      return info?.label ?? tag.replace("en:", "");
    });
    chips.push(
      t("savedSearches.allergenFreeFilter", { values: labels.join(", ") }),
    );
  }
  if (filters.max_unhealthiness !== undefined) {
    chips.push(
      t("savedSearches.maxScoreFilter", { score: filters.max_unhealthiness }),
    );
  }
  if (filters.sort_by && filters.sort_by !== "relevance") {
    chips.push(t("savedSearches.sortFilter", { sortBy: filters.sort_by }));
  }

  return (
    <>
      {chips.map((chip) => (
        <span
          key={chip}
          className="rounded-full bg-surface-muted px-2 py-0.5 text-xs text-foreground-secondary"
        >
          {chip}
        </span>
      ))}
    </>
  );
}
