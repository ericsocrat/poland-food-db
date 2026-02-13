"use client";

// ─── Search page — debounced product search ─────────────────────────────────

import { useState, useEffect, useCallback } from "react";
import { useQuery } from "@tanstack/react-query";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import { searchProducts } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { SCORE_BANDS, NUTRI_COLORS } from "@/lib/constants";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import type { SearchResponse, SearchResult } from "@/lib/types";

function useDebounce(value: string, delay: number) {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const id = setTimeout(() => setDebounced(value), delay);
    return () => clearTimeout(id);
  }, [value, delay]);
  return debounced;
}

export default function SearchPage() {
  const supabase = createClient();
  const [query, setQuery] = useState("");
  const debouncedQuery = useDebounce(query, 350);

  const { data, isLoading, isFetching } = useQuery({
    queryKey: queryKeys.search(debouncedQuery),
    queryFn: async () => {
      const result = await searchProducts(supabase, {
        p_query: debouncedQuery,
        p_limit: 30,
      });
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    enabled: debouncedQuery.length >= 2,
    staleTime: staleTimes.search,
  });

  return (
    <div className="space-y-4">
      {/* Search input */}
      <div className="relative">
        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search products…"
          className="input-field pl-10"
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
      </div>

      {/* Results */}
      {debouncedQuery.length < 2 && (
        <p className="py-12 text-center text-sm text-gray-400">
          Type at least 2 characters to search
        </p>
      )}

      {isLoading && debouncedQuery.length >= 2 && (
        <div className="flex justify-center py-12">
          <LoadingSpinner />
        </div>
      )}

      {data && (
        <>
          <p className="text-sm text-gray-500">
            {data.total_count} result{data.total_count !== 1 && "s"} for &ldquo;
            {data.query}&rdquo;
          </p>

          {data.results.length === 0 ? (
            <p className="py-12 text-center text-sm text-gray-400">
              No products found. Try a different search.
            </p>
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

function ProductRow({ product }: { product: SearchResult }) {
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
