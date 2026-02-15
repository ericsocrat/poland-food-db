"use client";

// ─── Saved Searches page — CRUD for authenticated users ─────────────────────

import { useCallback } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { getSavedSearches, deleteSavedSearch } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { ALLERGEN_TAGS } from "@/lib/constants";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import type { SavedSearch, SearchFilters } from "@/lib/types";

export default function SavedSearchesPage() {
  const supabase = createClient();
  const queryClient = useQueryClient();
  const router = useRouter();

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
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-lg font-semibold text-gray-900">
            📋 Saved Searches
          </h1>
          <p className="text-sm text-gray-500">
            Your saved search configurations
          </p>
        </div>
        <Link
          href="/app/search"
          className="text-sm text-brand-600 hover:text-brand-700"
        >
          ← Back to Search
        </Link>
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
            Failed to load saved searches.
          </p>
          <button
            onClick={handleRetry}
            className="text-sm font-medium text-red-700 hover:text-red-800"
          >
            🔄 Retry
          </button>
        </div>
      )}

      {/* Empty state */}
      {data && data.searches.length === 0 && (
        <div className="py-12 text-center">
          <p className="mb-2 text-4xl">💾</p>
          <p className="mb-1 text-sm text-gray-500">No saved searches yet</p>
          <p className="mb-4 text-xs text-gray-400">
            Save a search from the search page to quickly re-apply it later.
          </p>
          <Link
            href="/app/search"
            className="text-sm text-brand-600 hover:text-brand-700"
          >
            Go to Search →
          </Link>
        </div>
      )}

      {/* List */}
      {data && data.searches.length > 0 && (
        <ul className="space-y-2">
          {data.searches.map((search) => (
            <li key={search.id} className="card">
              <div className="flex items-start gap-3">
                {/* Info */}
                <div
                  className="min-w-0 flex-1 cursor-pointer"
                  onClick={() => applySearch(search)}
                >
                  <p className="font-medium text-gray-900">{search.name}</p>
                  <p className="mt-0.5 text-sm text-gray-500">
                    {search.query ? (
                      <>Query: &ldquo;{search.query}&rdquo;</>
                    ) : (
                      "Browse mode"
                    )}
                  </p>
                  {/* Filter summary */}
                  {search.filters && Object.keys(search.filters).length > 0 && (
                    <div className="mt-1.5 flex flex-wrap gap-1">
                      <FilterSummaryChips filters={search.filters} />
                    </div>
                  )}
                  <p className="mt-1 text-xs text-gray-400">
                    {new Date(search.created_at).toLocaleDateString()}
                  </p>
                </div>

                {/* Actions */}
                <div className="flex flex-shrink-0 gap-1">
                  <button
                    type="button"
                    onClick={() => applySearch(search)}
                    className="rounded-lg px-3 py-1.5 text-xs font-medium text-brand-600 transition-colors hover:bg-brand-50"
                  >
                    Apply
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      if (confirm("Delete this saved search?")) {
                        deleteMutation.mutate(search.id);
                      }
                    }}
                    disabled={deleteMutation.isPending}
                    className="rounded-lg px-2 py-1.5 text-xs text-gray-400 transition-colors hover:bg-red-50 hover:text-red-500"
                  >
                    🗑️
                  </button>
                </div>
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

function FilterSummaryChips({ filters }: Readonly<{ filters: SearchFilters }>) {
  const chips: string[] = [];

  if (filters.category?.length) {
    chips.push(`${filters.category.length} categories`);
  }
  if (filters.nutri_score?.length) {
    chips.push(`Nutri: ${filters.nutri_score.join(", ")}`);
  }
  if (filters.allergen_free?.length) {
    const labels = filters.allergen_free.map((tag) => {
      const info = ALLERGEN_TAGS.find((a) => a.tag === tag);
      return info?.label ?? tag.replace("en:", "");
    });
    chips.push(`Free: ${labels.join(", ")}`);
  }
  if (filters.max_unhealthiness !== undefined) {
    chips.push(`Score ≤ ${filters.max_unhealthiness}`);
  }
  if (filters.sort_by && filters.sort_by !== "relevance") {
    chips.push(`Sort: ${filters.sort_by}`);
  }

  return (
    <>
      {chips.map((chip) => (
        <span
          key={chip}
          className="rounded-full bg-gray-100 px-2 py-0.5 text-xs text-gray-500"
        >
          {chip}
        </span>
      ))}
    </>
  );
}
