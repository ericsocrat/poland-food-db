"use client";

// ─── SearchAutocomplete — debounced prefix search with keyboard nav ─────────

import { useState, useEffect, useRef, useCallback, useMemo } from "react";
import { useQuery } from "@tanstack/react-query";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { searchAutocomplete } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { SCORE_BANDS, NUTRI_COLORS } from "@/lib/constants";
import type { AutocompleteSuggestion } from "@/lib/types";

interface SearchAutocompleteProps {
  query: string;
  onSelect: (product: AutocompleteSuggestion) => void;
  onQuerySubmit: (query: string) => void;
  onQueryChange: (query: string) => void;
  show: boolean;
  onClose: () => void;
  /** Ref callback — receives the keyboard handler so the parent input can use it */
  onInputKeyDown?: (handler: (e: React.KeyboardEvent) => void) => void;
}

function useDebounce(value: string, delay: number) {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const id = setTimeout(() => setDebounced(value), delay);
    return () => clearTimeout(id);
  }, [value, delay]);
  return debounced;
}

export function SearchAutocomplete({
  query,
  onSelect,
  onQuerySubmit,
  onQueryChange: _onQueryChange,
  show,
  onClose,
  onInputKeyDown,
}: Readonly<SearchAutocompleteProps>) {
  const supabase = createClient();
  const router = useRouter();
  const debouncedQuery = useDebounce(query, 200);
  const [activeIndex, setActiveIndex] = useState(-1);
  const listRef = useRef<HTMLUListElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);

  const { data, isFetching } = useQuery({
    queryKey: queryKeys.autocomplete(debouncedQuery),
    queryFn: async () => {
      const result = await searchAutocomplete(supabase, debouncedQuery, 8);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    enabled: show && debouncedQuery.length >= 1,
    staleTime: staleTimes.autocomplete,
  });

  const suggestions = useMemo(() => data?.suggestions ?? [], [data]);

  // Reset active index when suggestions change
  useEffect(() => {
    setActiveIndex(-1);
  }, [suggestions.length, debouncedQuery]);

  // Close on click outside
  useEffect(() => {
    function handleClick(e: MouseEvent) {
      if (
        containerRef.current &&
        e.target instanceof Node &&
        !containerRef.current.contains(e.target)
      ) {
        onClose();
      }
    }
    if (show) {
      document.addEventListener("mousedown", handleClick);
      return () => document.removeEventListener("mousedown", handleClick);
    }
  }, [show, onClose]);

  const handleKeyDown = useCallback(
    (e: React.KeyboardEvent) => {
      if (!show || suggestions.length === 0) return;

      switch (e.key) {
        case "ArrowDown":
          e.preventDefault();
          setActiveIndex((prev) =>
            prev < suggestions.length - 1 ? prev + 1 : 0,
          );
          break;
        case "ArrowUp":
          e.preventDefault();
          setActiveIndex((prev) =>
            prev > 0 ? prev - 1 : suggestions.length - 1,
          );
          break;
        case "Enter":
          e.preventDefault();
          if (activeIndex >= 0 && activeIndex < suggestions.length) {
            const selected = suggestions[activeIndex];
            onSelect(selected);
            router.push(`/app/product/${selected.product_id}`);
          } else if (query.trim().length >= 1) {
            onQuerySubmit(query.trim());
          }
          onClose();
          break;
        case "Escape":
          e.preventDefault();
          onClose();
          break;
      }
    },
    [
      show,
      suggestions,
      activeIndex,
      query,
      onSelect,
      onQuerySubmit,
      onClose,
      router,
    ],
  );

  // Expose keyboard handler to parent input
  useEffect(() => {
    onInputKeyDown?.(handleKeyDown);
  }, [handleKeyDown, onInputKeyDown]);

  // Scroll active item into view
  useEffect(() => {
    if (activeIndex >= 0 && listRef.current) {
      const item = listRef.current.children[activeIndex];
      if (item instanceof HTMLElement) {
        item.scrollIntoView({ block: "nearest" });
      }
    }
  }, [activeIndex]);

  if (!show || (suggestions.length === 0 && !isFetching) || query.length < 1) {
    return null;
  }

  return (
    <div
      ref={containerRef}
      className="absolute left-0 right-0 top-full z-50 mt-1 max-h-80 overflow-y-auto rounded-xl border border-gray-200 bg-white shadow-lg"
    >
      {isFetching && suggestions.length === 0 && (
        <div className="px-4 py-3 text-center text-sm text-gray-400">
          Searching…
        </div>
      )}
      <ul ref={listRef}>
        {suggestions.map((s, i) => {
          const band = SCORE_BANDS[s.score_band];
          const nutriClass = s.nutri_score
            ? NUTRI_COLORS[s.nutri_score]
            : "bg-gray-200 text-gray-500";

          return (
            <li
              key={s.product_id}
              className={`flex cursor-pointer items-center gap-3 px-4 py-2.5 transition-colors ${
                i === activeIndex
                  ? "bg-brand-50 text-brand-900"
                  : "hover:bg-gray-50"
              }`}
            >
              <button
                type="button"
                className="flex w-full items-center gap-3"
                onMouseEnter={() => setActiveIndex(i)}
                onClick={() => {
                  onSelect(s);
                  router.push(`/app/product/${s.product_id}`);
                  onClose();
                }}
              >
                {/* Score badge */}
                <div
                  className={`flex h-9 w-9 flex-shrink-0 items-center justify-center rounded-lg text-sm font-bold ${band.bg} ${band.color}`}
                >
                  {s.unhealthiness_score}
                </div>

                {/* Product info */}
                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm font-medium text-gray-900">
                    {s.product_name}
                  </p>
                  <p className="truncate text-xs text-gray-500">
                    {s.brand} · {s.category}
                  </p>
                </div>

                {/* Nutri badge */}
                <span
                  className={`flex h-7 w-7 flex-shrink-0 items-center justify-center rounded-full text-xs font-bold ${nutriClass}`}
                >
                  {s.nutri_score ?? "?"}
                </span>
              </button>
            </li>
          );
        })}
      </ul>

      {/* "Search for…" footer */}
      {query.trim().length >= 1 && (
        <button
          type="button"
          className={`flex w-full items-center gap-2 border-t border-gray-100 px-4 py-2.5 text-sm text-gray-600 transition-colors hover:bg-gray-50`}
          onClick={() => {
            onQuerySubmit(query.trim());
            onClose();
          }}
        >
          <svg
            className="h-4 w-4 text-gray-400"
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
          Search for &ldquo;{query.trim()}&rdquo;
        </button>
      )}
    </div>
  );
}

export { type SearchAutocompleteProps };
