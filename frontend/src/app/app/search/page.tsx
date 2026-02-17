"use client";

// ─── Enhanced Search page — autocomplete, multi-faceted filters, pagination ─

import { useState, useEffect, useCallback, useRef } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import { searchProducts } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { SCORE_BANDS, NUTRI_COLORS } from "@/lib/constants";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import { HealthWarningBadge } from "@/components/product/HealthWarningsCard";
import { AvoidBadge } from "@/components/product/AvoidBadge";
import { AddToListMenu } from "@/components/product/AddToListMenu";
import { CompareCheckbox } from "@/components/compare/CompareCheckbox";
import { SearchAutocomplete } from "@/components/search/SearchAutocomplete";
import { FilterPanel } from "@/components/search/FilterPanel";
import { ActiveFilterChips } from "@/components/search/ActiveFilterChips";
import { SaveSearchDialog } from "@/components/search/SaveSearchDialog";
import { EmptyState } from "@/components/common/EmptyState";
import { SearchResultsSkeleton } from "@/components/common/skeletons";
import { useAnalytics } from "@/hooks/use-analytics";
import { useTranslation } from "@/lib/i18n";
import type { SearchResult, SearchFilters, FormSubmitEvent } from "@/lib/types";

const RECENT_KEY = "fooddb:recent-searches";
const MAX_RECENT = 10;
const AVOID_TOGGLE_KEY = "fooddb:show-avoided";
const PAGE_SIZE = 20;

/* ── localStorage helpers ─────────────────────────────────────────────────── */

function getRecentSearches(): string[] {
  if (globalThis.localStorage === undefined) return [];
  try {
    return JSON.parse(globalThis.localStorage.getItem(RECENT_KEY) ?? "[]");
  } catch {
    return [];
  }
}

function saveRecentSearch(q: string) {
  if (globalThis.localStorage === undefined) return;
  const prev = getRecentSearches().filter((s) => s !== q);
  const next = [q, ...prev].slice(0, MAX_RECENT);
  globalThis.localStorage.setItem(RECENT_KEY, JSON.stringify(next));
}

function getShowAvoided(): boolean {
  if (globalThis.localStorage === undefined) return false;
  return globalThis.localStorage.getItem(AVOID_TOGGLE_KEY) === "true";
}

function setShowAvoidedStorage(val: boolean) {
  if (globalThis.localStorage === undefined) return;
  globalThis.localStorage.setItem(AVOID_TOGGLE_KEY, String(val));
}

/* ── Page component ───────────────────────────────────────────────────────── */

export default function SearchPage() {
  const supabase = createClient();
  const queryClient = useQueryClient();
  const { t } = useTranslation();
  const inputRef = useRef<HTMLInputElement>(null);
  const autocompleteKeyDownRef = useRef<
    ((e: React.KeyboardEvent) => void) | null
  >(null);

  const [query, setQuery] = useState("");
  const [submittedQuery, setSubmittedQuery] = useState("");
  const [filters, setFilters] = useState<SearchFilters>({});
  const [page, setPage] = useState(1);
  const [showAvoided, setShowAvoided] = useState(false);
  const [showAutocomplete, setShowAutocomplete] = useState(false);
  const [showFilters, setShowFilters] = useState(false);
  const [showSaveDialog, setShowSaveDialog] = useState(false);
  const [recentSearches, setRecentSearches] = useState<string[]>([]);

  // The active search query (submitted)
  const activeQuery = submittedQuery || undefined;

  // Load localStorage prefs on mount
  useEffect(() => {
    setRecentSearches(getRecentSearches());
    setShowAvoided(getShowAvoided());
  }, []);

  // Reset page when filters or query change
  useEffect(() => {
    setPage(1);
  }, [submittedQuery, filters]);

  // Search query
  const { data, isLoading, isFetching, error } = useQuery({
    queryKey: queryKeys.search(submittedQuery, filters, page),
    queryFn: async () => {
      const result = await searchProducts(supabase, {
        p_query: activeQuery,
        p_filters: filters,
        p_page: page,
        p_page_size: PAGE_SIZE,
        p_show_avoided: showAvoided,
      });
      if (!result.ok) throw new Error(result.error.message);
      // Save successful text search
      if (activeQuery && activeQuery.length >= 2) {
        saveRecentSearch(activeQuery);
        setRecentSearches(getRecentSearches());
      }
      return result.data;
    },
    enabled:
      (activeQuery !== undefined && activeQuery.length >= 1) ||
      hasActiveFilters(filters),
    staleTime: staleTimes.search,
  });

  const { track } = useAnalytics();

  function handleSubmit(e: FormSubmitEvent) {
    e.preventDefault();
    const q = query.trim();
    if (q.length >= 1) {
      setSubmittedQuery(q);
      setShowAutocomplete(false);
      track("search_performed", {
        query: q,
        has_filters: hasActiveFilters(filters),
      });
    } else if (hasActiveFilters(filters)) {
      // Allow empty query with filters (browse mode)
      setSubmittedQuery("");
      setShowAutocomplete(false);
      track("search_performed", { query: "", has_filters: true });
    }
  }

  function handleAvoidToggle() {
    const next = !showAvoided;
    setShowAvoided(next);
    setShowAvoidedStorage(next);
    // Invalidate current search to re-fetch with new avoid setting
    queryClient.invalidateQueries({ queryKey: ["search"] });
  }

  const handleRetry = useCallback(() => {
    queryClient.invalidateQueries({
      queryKey: queryKeys.search(submittedQuery, filters, page),
    });
  }, [queryClient, submittedQuery, filters, page]);

  function selectRecent(q: string) {
    setQuery(q);
    setSubmittedQuery(q);
  }

  function handleFiltersChange(newFilters: SearchFilters) {
    setFilters(newFilters);
    track("filter_applied", { filters: newFilters });
    // If browse mode with filters, trigger search
    if (!submittedQuery && hasActiveFilters(newFilters)) {
      setSubmittedQuery("");
    }
  }

  const isSearchActive =
    (activeQuery !== undefined && activeQuery.length >= 1) ||
    hasActiveFilters(filters);

  return (
    <div className="flex gap-6">
      {/* Filter sidebar (desktop) */}
      <FilterPanel
        filters={filters}
        onChange={handleFiltersChange}
        show={showFilters}
        onClose={() => setShowFilters(false)}
      />

      {/* Main content */}
      <div className="min-w-0 flex-1 space-y-4">
        {/* Search input */}
        <form onSubmit={handleSubmit} className="space-y-2">
          <div className="relative">
            <input
              ref={inputRef}
              type="text"
              value={query}
              onChange={(e) => {
                setQuery(e.target.value);
                if (e.target.value.length >= 1) {
                  setShowAutocomplete(true);
                } else {
                  setShowAutocomplete(false);
                }
              }}
              onFocus={() => {
                if (query.length >= 1) setShowAutocomplete(true);
              }}
              onKeyDown={(e) => autocompleteKeyDownRef.current?.(e)}
              placeholder={t("search.placeholder")}
              className="input-field pl-10 pr-10"
              autoFocus
            />
            <svg
              className="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-foreground-muted"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
              />
            </svg>
            {isFetching && (
              <div className="absolute right-3 top-1/2 -translate-y-1/2">
                <LoadingSpinner size="sm" />
              </div>
            )}
            {!isFetching && query.length > 0 && (
              <button
                type="button"
                onClick={() => {
                  setQuery("");
                  setSubmittedQuery("");
                  setShowAutocomplete(false);
                }}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-foreground-muted hover:text-foreground-secondary"
                aria-label={t("search.clearSearch")}
              >
                <svg
                  className="h-5 w-5"
                  viewBox="0 0 20 20"
                  fill="currentColor"
                >
                  <path
                    fillRule="evenodd"
                    d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"
                    clipRule="evenodd"
                  />
                </svg>
              </button>
            )}

            {/* Autocomplete dropdown */}
            <SearchAutocomplete
              query={query}
              onSelect={() => setShowAutocomplete(false)}
              onQuerySubmit={(q) => {
                setSubmittedQuery(q);
                setShowAutocomplete(false);
              }}
              onQueryChange={setQuery}
              show={showAutocomplete}
              onClose={() => setShowAutocomplete(false)}
              onInputKeyDown={(handler) => {
                autocompleteKeyDownRef.current = handler;
              }}
            />
          </div>

          {/* Action row: search button, filter toggle, avoid toggle, save */}
          <div className="flex flex-wrap items-center gap-2">
            <button
              type="submit"
              disabled={query.trim().length < 1 && !hasActiveFilters(filters)}
              className="btn-primary px-4 py-2 text-sm disabled:cursor-not-allowed disabled:opacity-50"
            >
              {t("search.searchButton")}
            </button>

            {/* Mobile filter toggle */}
            <button
              type="button"
              onClick={() => setShowFilters(true)}
              className="touch-target flex items-center gap-1.5 rounded-lg border border-border px-3 py-2 text-sm text-foreground-secondary transition-colors hover:bg-surface-muted lg:hidden"
            >
              🎛️ {t("search.filters")}
              {hasActiveFilters(filters) && (
                <span className="flex h-4 w-4 items-center justify-center rounded-full bg-brand-600 text-[10px] font-bold text-white">
                  {countActiveFilters(filters)}
                </span>
              )}
            </button>

            {/* Avoid toggle */}
            <button
              type="button"
              onClick={handleAvoidToggle}
              className="touch-target flex items-center gap-1.5 text-xs text-foreground-secondary hover:text-foreground"
              title={
                showAvoided
                  ? t("search.avoidedShown")
                  : t("search.avoidedDemoted")
              }
            >
              <span
                className={`relative inline-flex h-4 w-7 flex-shrink-0 items-center rounded-full transition-colors ${
                  showAvoided ? "bg-brand-600" : "bg-surface-muted"
                }`}
              >
                <span
                  className={`inline-block h-3 w-3 transform rounded-full bg-surface transition-transform ${
                    showAvoided ? "translate-x-3.5" : "translate-x-0.5"
                  }`}
                />
              </span>{" "}
              {t("search.showAvoided")}
            </button>

            {/* Save search */}
            {isSearchActive && (
              <button
                type="button"
                onClick={() => setShowSaveDialog(true)}
                className="touch-target ml-auto text-xs text-foreground-muted hover:text-brand-600"
              >
                💾 {t("search.saveSearch")}
              </button>
            )}

            {/* Saved searches link */}
            <Link
              href="/app/search/saved"
              className="touch-target text-xs text-foreground-muted hover:text-brand-600"
            >
              📋 {t("search.saved")}
            </Link>
          </div>
        </form>

        {/* Active filter chips */}
        <ActiveFilterChips filters={filters} onChange={handleFiltersChange} />

        {/* Recent searches — shown when no active search */}
        {!isSearchActive && recentSearches.length > 0 && (
          <div>
            <p className="mb-2 text-xs font-medium uppercase tracking-wider text-foreground-muted">
              {t("search.recentSearches")}
            </p>
            <div className="flex flex-wrap gap-2">
              {recentSearches.map((q) => (
                <button
                  key={q}
                  onClick={() => selectRecent(q)}
                  className="touch-target rounded-full border border-border px-3 py-1.5 text-sm text-foreground-secondary transition-colors hover:border-foreground-muted hover:text-foreground"
                >
                  {q}
                </button>
              ))}
            </div>
          </div>
        )}

        {/* Empty state — no search or filters active */}
        {!isSearchActive && recentSearches.length === 0 && (
          <EmptyState
            variant="no-data"
            icon={<span>🔍</span>}
            titleKey="search.emptyState"
          />
        )}

        {/* Loading */}
        {isLoading && isSearchActive && <SearchResultsSkeleton />}

        {/* Error state */}
        {error && (
          <EmptyState
            variant="error"
            titleKey="search.searchFailed"
            action={{ labelKey: "common.retry", onClick: handleRetry }}
          />
        )}

        {/* Results */}
        {data && (
          <>
            <div className="flex items-center justify-between">
              <p className="text-sm text-foreground-secondary">
                {t("search.result", { count: data.total })}
                {data.query && (
                  <> {t("search.resultsFor", { query: data.query })}</>
                )}
              </p>
              {data.pages > 1 && (
                <p className="text-xs text-foreground-muted">
                  {t("common.pageOf", { page: data.page, pages: data.pages })}
                </p>
              )}
            </div>

            {data.results.length === 0 ? (
              <EmptyState
                variant="no-results"
                titleKey={
                  data.query ? "search.noMatchSearch" : "search.noMatchFilters"
                }
                descriptionKey="search.adjustFilters"
                action={
                  hasActiveFilters(filters)
                    ? {
                        labelKey: "search.clearAllFilters",
                        onClick: () => setFilters({}),
                      }
                    : undefined
                }
              />
            ) : (
              <>
                <ul className="space-y-2">
                  {data.results.map((product) => (
                    <ProductRow key={product.product_id} product={product} />
                  ))}
                </ul>

                {/* Pagination */}
                {data.pages > 1 && (
                  <div className="flex items-center justify-center gap-2 pt-4">
                    <button
                      type="button"
                      onClick={() => setPage((p) => Math.max(1, p - 1))}
                      disabled={page <= 1}
                      className="touch-target rounded-lg border border-border px-3 py-2 text-sm text-foreground-secondary transition-colors hover:bg-surface-muted disabled:cursor-not-allowed disabled:opacity-40"
                    >
                      {t("common.prev")}
                    </button>
                    {generatePageNumbers(data.page, data.pages).map((p, i) =>
                      p === null ? (
                        <span
                          key={`ellipsis-${i > 0 ? "end" : "start"}`}
                          className="px-1 text-foreground-muted"
                        >
                          …
                        </span>
                      ) : (
                        <button
                          key={p}
                          type="button"
                          onClick={() => setPage(p)}
                          className={`h-10 w-10 rounded-lg text-sm font-medium transition-colors ${
                            p === page
                              ? "bg-brand-600 text-white"
                              : "text-foreground-secondary hover:bg-surface-muted"
                          }`}
                        >
                          {p}
                        </button>
                      ),
                    )}
                    <button
                      type="button"
                      onClick={() =>
                        setPage((p) => Math.min(data.pages, p + 1))
                      }
                      disabled={page >= data.pages}
                      className="touch-target rounded-lg border border-border px-3 py-2 text-sm text-foreground-secondary transition-colors hover:bg-surface-muted disabled:cursor-not-allowed disabled:opacity-40"
                    >
                      {t("common.next")}
                    </button>
                  </div>
                )}
              </>
            )}
          </>
        )}

        {/* Save search dialog */}
        <SaveSearchDialog
          query={submittedQuery || null}
          filters={filters}
          show={showSaveDialog}
          onClose={() => setShowSaveDialog(false)}
        />
      </div>
    </div>
  );
}

/* ── ProductRow ────────────────────────────────────────────────────────────── */

function ProductRow({ product }: Readonly<{ product: SearchResult }>) {
  const band = SCORE_BANDS[product.score_band];
  const nutriClass = product.nutri_score
    ? NUTRI_COLORS[product.nutri_score]
    : "bg-surface-muted text-foreground-secondary";

  return (
    <Link href={`/app/product/${product.product_id}`}>
      <li
        className={`card flex items-center gap-3 transition-shadow hover:shadow-md ${
          product.is_avoided ? "opacity-50" : ""
        }`}
      >
        {/* Score badge */}
        <div
          className={`flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-lg text-lg font-bold ${band.bg} ${band.color}`}
        >
          {product.unhealthiness_score}
        </div>

        {/* Product info */}
        <div className="min-w-0 flex-1">
          <p className="truncate font-medium text-foreground">
            {product.product_name_display ?? product.product_name}
          </p>
          <p className="truncate text-sm text-foreground-secondary">
            {product.brand} · {product.category_icon}{" "}
            {product.category_display ?? product.category}
            {product.calories !== null && (
              <span className="ml-1 text-xs text-foreground-muted">
                · {Math.round(product.calories)} kcal
              </span>
            )}
          </p>
        </div>

        {/* Health warning badge */}
        <HealthWarningBadge productId={product.product_id} />

        {/* Avoid badge */}
        <AvoidBadge productId={product.product_id} />

        {/* Favorites heart */}
        <AddToListMenu productId={product.product_id} compact />

        {/* Compare checkbox */}
        <CompareCheckbox productId={product.product_id} />

        {/* Nutri badge */}
        <span
          className={`flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-full text-sm font-bold ${nutriClass}`}
        >
          {product.nutri_score ?? "?"}
        </span>
      </li>
    </Link>
  );
}

/* ── Helpers ──────────────────────────────────────────────────────────────── */

function hasActiveFilters(f: SearchFilters): boolean {
  return (
    (f.category?.length ?? 0) > 0 ||
    (f.nutri_score?.length ?? 0) > 0 ||
    (f.allergen_free?.length ?? 0) > 0 ||
    f.max_unhealthiness !== undefined
  );
}

function countActiveFilters(f: SearchFilters): number {
  let count = 0;
  count += f.category?.length ?? 0;
  count += f.nutri_score?.length ?? 0;
  count += f.allergen_free?.length ?? 0;
  if (f.max_unhealthiness !== undefined) count++;
  return count;
}

function generatePageNumbers(
  current: number,
  total: number,
): (number | null)[] {
  if (total <= 7) {
    return Array.from({ length: total }, (_, i) => i + 1);
  }
  const pages: (number | null)[] = [1];
  if (current > 3) pages.push(null);
  for (
    let i = Math.max(2, current - 1);
    i <= Math.min(total - 1, current + 1);
    i++
  ) {
    pages.push(i);
  }
  if (current < total - 2) pages.push(null);
  pages.push(total);
  return pages;
}
