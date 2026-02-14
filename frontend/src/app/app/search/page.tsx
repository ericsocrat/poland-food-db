"use client";

// ─── Search page — debounced product search with recent searches ────────────

import { useState, useEffect, useCallback } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import { searchProducts } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { SCORE_BANDS, NUTRI_COLORS } from "@/lib/constants";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import type { SearchResult } from "@/lib/types";

const RECENT_KEY = "fooddb:recent-searches";
const MAX_RECENT = 5;

function useDebounce(value: string, delay: number) {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const id = setTimeout(() => setDebounced(value), delay);
    return () => clearTimeout(id);
  }, [value, delay]);
  return debounced;
}

function getRecentSearches(): string[] {
  if (typeof globalThis.localStorage === "undefined") return [];
  try {
    return JSON.parse(globalThis.localStorage.getItem(RECENT_KEY) ?? "[]");
  } catch {
    return [];
  }
}

function saveRecentSearch(q: string) {
  if (typeof globalThis.localStorage === "undefined") return;
  const prev = getRecentSearches().filter((s) => s !== q);
  const next = [q, ...prev].slice(0, MAX_RECENT);
  globalThis.localStorage.setItem(RECENT_KEY, JSON.stringify(next));
}

export default function SearchPage() {
  const supabase = createClient();
  const queryClient = useQueryClient();
  const [query, setQuery] = useState("");
  const [recentSearches, setRecentSearches] = useState<string[]>([]);
  const debouncedQuery = useDebounce(query, 350);

  // Load recent searches on mount
  useEffect(() => {
    setRecentSearches(getRecentSearches());
  }, []);

  const { data, isLoading, isFetching, error } = useQuery({
    queryKey: queryKeys.search(debouncedQuery),
    queryFn: async () => {
      const result = await searchProducts(supabase, {
        p_query: debouncedQuery,
        p_limit: 30,
      });
      if (!result.ok) throw new Error(result.error.message);
      // Save successful search
      saveRecentSearch(debouncedQuery);
      setRecentSearches(getRecentSearches());
      return result.data;
    },
    enabled: debouncedQuery.length >= 2,
    staleTime: staleTimes.search,
  });

  const handleRetry = useCallback(() => {
    queryClient.invalidateQueries({
      queryKey: queryKeys.search(debouncedQuery),
    });
  }, [queryClient, debouncedQuery]);

  function selectRecent(q: string) {
    setQuery(q);
  }

  return (
    <div className="space-y-4">
      {/* Search input */}
      <div className="relative">
        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search products…"
          className="input-field pl-10 pr-10"
          autoFocus
        />
        <svg
          className="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-gray-400"
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
            onClick={() => setQuery("")}
            className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
            aria-label="Clear search"
          >
            <svg className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
              <path
                fillRule="evenodd"
                d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"
                clipRule="evenodd"
              />
            </svg>
          </button>
        )}
      </div>

      {/* Recent searches — shown when input is empty */}
      {debouncedQuery.length < 2 && recentSearches.length > 0 && (
        <div>
          <p className="mb-2 text-xs font-medium uppercase tracking-wider text-gray-400">
            Recent searches
          </p>
          <div className="flex flex-wrap gap-2">
            {recentSearches.map((q) => (
              <button
                key={q}
                onClick={() => selectRecent(q)}
                className="rounded-full border border-gray-200 px-3 py-1 text-sm text-gray-600 transition-colors hover:border-gray-400 hover:text-gray-900"
              >
                {q}
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Empty state — no query yet */}
      {debouncedQuery.length < 2 && recentSearches.length === 0 && (
        <p className="py-12 text-center text-sm text-gray-400">
          Type at least 2 characters to search
        </p>
      )}

      {/* Loading */}
      {isLoading && debouncedQuery.length >= 2 && (
        <div className="flex justify-center py-12">
          <LoadingSpinner />
        </div>
      )}

      {/* Error state with retry */}
      {error && (
        <div className="card border-red-200 bg-red-50 text-center">
          <p className="mb-2 text-sm text-red-600">
            Search failed. Please try again.
          </p>
          <button
            onClick={handleRetry}
            className="inline-flex items-center gap-1 text-sm font-medium text-red-700 hover:text-red-800"
          >
            🔄 Retry
          </button>
        </div>
      )}

      {/* Results */}
      {data && (
        <>
          <p className="text-sm text-gray-500">
            {data.total_count} result{data.total_count !== 1 && "s"} for &ldquo;
            {data.query}&rdquo;
          </p>

          {data.results.length === 0 ? (
            <div className="py-12 text-center">
              <p className="mb-2 text-4xl">🔍</p>
              <p className="mb-1 text-sm text-gray-500">
                No products found for &ldquo;{data.query}&rdquo;
              </p>
              <p className="text-xs text-gray-400">
                Try a different spelling, brand name, or broader term.
              </p>
            </div>
          ) : (
            <ul className="space-y-2">
              {data.results.map((product) => (
                <ProductRow key={product.product_id} product={product} />
              ))}
            </ul>
          )}
        </>
      )}
    </div>
  );
}

function ProductRow({ product }: Readonly<{ product: SearchResult }>) {
  const band = SCORE_BANDS[product.score_band];
  const nutriClass = product.nutri_score
    ? NUTRI_COLORS[product.nutri_score]
    : "bg-gray-200 text-gray-500";

  return (
    <Link href={`/app/product/${product.product_id}`}>
      <li className="card flex items-center gap-3 transition-shadow hover:shadow-md">
        {/* Score badge */}
        <div
          className={`flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-lg text-lg font-bold ${band.bg} ${band.color}`}
        >
          {product.unhealthiness_score}
        </div>

        {/* Product info */}
        <div className="min-w-0 flex-1">
          <p className="truncate font-medium text-gray-900">
            {product.product_name}
          </p>
          <p className="truncate text-sm text-gray-500">
            {product.brand} &middot; {product.category}
          </p>
        </div>

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
