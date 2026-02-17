"use client";

// ─── SearchAutocomplete — debounced prefix search + recent/popular ──────────

import { useState, useEffect, useRef, useCallback, useMemo } from "react";
import { useQuery } from "@tanstack/react-query";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { searchAutocomplete } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { SCORE_BANDS, NUTRI_COLORS } from "@/lib/constants";
import {
  getRecentSearches,
  removeRecentSearch,
  clearRecentSearches,
} from "@/lib/recent-searches";
import type { AutocompleteSuggestion } from "@/lib/types";
import { useTranslation } from "@/lib/i18n";

// ─── Curated popular searches (Phase 4 of #62) ─────────────────────────────

const POPULAR_SEARCHES = [
  "mleko",
  "ser",
  "jogurt",
  "chleb",
  "masło",
  "kiełbasa",
  "szynka",
  "czekolada",
  "chipsy",
  "sok",
];

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
  const { t } = useTranslation();
  const supabase = createClient();
  const router = useRouter();
  const debouncedQuery = useDebounce(query, 200);
  const [activeIndex, setActiveIndex] = useState(-1);
  const listRef = useRef<HTMLUListElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const [recentSearches, setRecentSearches] = useState<string[]>([]);

  // Load recent searches when dropdown opens
  useEffect(() => {
    if (show) setRecentSearches(getRecentSearches());
  }, [show]);

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

  // Determine what to show: suggestions when there's a query, recent/popular otherwise
  const isQueryMode = query.trim().length >= 1;
  const showRecent = !isQueryMode && recentSearches.length > 0;
  const showPopular = !isQueryMode && recentSearches.length === 0;

  // Total navigable items count for keyboard nav
  const navigableCount = (() => {
    if (isQueryMode) return suggestions.length + 1; // +1 for "Search for…" footer
    if (showRecent) return recentSearches.length;
    if (showPopular) return POPULAR_SEARCHES.length;
    return 0;
  })();

  // Reset active index when suggestions change
  useEffect(() => {
    setActiveIndex(-1);
  }, [suggestions.length, debouncedQuery, isQueryMode]);

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
      if (!show || navigableCount === 0) return;

      switch (e.key) {
        case "ArrowDown":
          e.preventDefault();
          setActiveIndex((prev) => (prev < navigableCount - 1 ? prev + 1 : 0));
          break;
        case "ArrowUp":
          e.preventDefault();
          setActiveIndex((prev) => (prev > 0 ? prev - 1 : navigableCount - 1));
          break;
        case "Enter":
          e.preventDefault();
          if (isQueryMode) {
            if (activeIndex >= 0 && activeIndex < suggestions.length) {
              const selected = suggestions[activeIndex];
              onSelect(selected);
              router.push(`/app/product/${selected.product_id}`);
            } else if (query.trim().length >= 1) {
              onQuerySubmit(query.trim());
            }
          } else if (showRecent && activeIndex >= 0) {
            onQuerySubmit(recentSearches[activeIndex]);
          } else if (showPopular && activeIndex >= 0) {
            onQuerySubmit(POPULAR_SEARCHES[activeIndex]);
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
      navigableCount,
      isQueryMode,
      suggestions,
      activeIndex,
      query,
      recentSearches,
      showRecent,
      showPopular,
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

  // Nothing to show
  if (!show) return null;
  if (isQueryMode && suggestions.length === 0 && !isFetching) return null;
  if (!isQueryMode && !showRecent && !showPopular) return null;

  const dropdownLabelKey = showRecent
    ? "search.recentSearches"
    : "search.popularSearches";
  const dropdownLabel = isQueryMode
    ? t("search.suggestions")
    : t(dropdownLabelKey);

  return (
    <div
      ref={containerRef}
      aria-label={dropdownLabel}
      className="absolute left-0 right-0 top-full z-50 mt-1 max-h-80 overflow-y-auto rounded-xl border bg-surface shadow-lg"
    >
      {/* ── Recent searches (empty-query mode) ────────────────────── */}
      {showRecent && (
        <>
          <div className="flex items-center justify-between px-4 pb-1 pt-3">
            <span className="text-xs font-semibold uppercase tracking-wider text-foreground-muted">
              {t("search.recentSearches")}
            </span>
            <button
              type="button"
              className="text-xs text-brand-600 hover:text-brand-700"
              onClick={() => {
                clearRecentSearches();
                setRecentSearches([]);
              }}
            >
              {t("search.clearRecent")}
            </button>
          </div>
          <ul ref={listRef}>
            {recentSearches.map((q, i) => (
              <li
                key={q}
                className={`flex cursor-pointer items-center gap-3 px-4 py-2 transition-colors ${
                  i === activeIndex
                    ? "bg-brand-50 text-brand-900"
                    : "hover:bg-surface-subtle"
                }`}
              >
                <button
                  type="button"
                  className="flex min-w-0 flex-1 items-center gap-3"
                  onMouseEnter={() => setActiveIndex(i)}
                  onClick={() => {
                    onQuerySubmit(q);
                    onClose();
                  }}
                >
                  <span className="text-foreground-muted">🕐</span>
                  <span className="min-w-0 flex-1 truncate text-left text-sm text-foreground">
                    {q}
                  </span>
                </button>
                <button
                  type="button"
                  className="ml-auto flex-shrink-0 rounded p-0.5 text-foreground-muted hover:bg-surface-muted hover:text-foreground"
                  aria-label={t("search.removeRecent", { query: q })}
                  onClick={() => {
                    removeRecentSearch(q);
                    const updated = recentSearches.filter((s) => s !== q);
                    setRecentSearches(updated);
                  }}
                >
                  <svg
                    className="h-3.5 w-3.5"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth={2}
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      d="M6 18L18 6M6 6l12 12"
                    />
                  </svg>
                </button>
              </li>
            ))}
          </ul>
        </>
      )}

      {/* ── Popular searches (empty-query mode, no recents) ───────── */}
      {showPopular && (
        <>
          <div className="px-4 pb-1 pt-3">
            <span className="text-xs font-semibold uppercase tracking-wider text-foreground-muted">
              {t("search.popularSearches")}
            </span>
          </div>
          <ul ref={listRef}>
            {POPULAR_SEARCHES.map((q, i) => (
              <li
                key={q}
                className={`flex cursor-pointer items-center gap-3 px-4 py-2 transition-colors ${
                  i === activeIndex
                    ? "bg-brand-50 text-brand-900"
                    : "hover:bg-surface-subtle"
                }`}
              >
                <button
                  type="button"
                  className="flex min-w-0 flex-1 items-center gap-3"
                  onMouseEnter={() => setActiveIndex(i)}
                  onClick={() => {
                    onQuerySubmit(q);
                    onClose();
                  }}
                >
                  <span className="text-foreground-muted">🔥</span>
                  <span className="min-w-0 flex-1 truncate text-left text-sm text-foreground">
                    {q}
                  </span>
                </button>
              </li>
            ))}
          </ul>
        </>
      )}

      {/* ── Query-mode suggestions ────────────────────────────────── */}
      {isQueryMode && (
        <>
          {isFetching && suggestions.length === 0 && (
            <div className="px-4 py-3 text-center text-sm text-foreground-muted">
              {t("search.searching")}
            </div>
          )}
          <ul ref={listRef}>
            {suggestions.map((s, i) => {
              const band = SCORE_BANDS[s.score_band];
              const nutriClass = s.nutri_score
                ? NUTRI_COLORS[s.nutri_score]
                : "bg-surface-muted text-foreground-secondary";

              return (
                <li
                  key={s.product_id}
                  className={`flex cursor-pointer items-center gap-3 px-4 py-2.5 transition-colors ${
                    i === activeIndex
                      ? "bg-brand-50 text-brand-900"
                      : "hover:bg-surface-subtle"
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
                      <p className="truncate text-sm font-medium text-foreground">
                        {s.product_name_display ?? s.product_name}
                      </p>
                      <p className="truncate text-xs text-foreground-secondary">
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
          <button
            type="button"
            className={`flex w-full items-center gap-2 border-t px-4 py-2.5 text-sm transition-colors ${
              activeIndex === suggestions.length
                ? "bg-brand-50 text-brand-900"
                : "text-foreground-secondary hover:bg-surface-subtle"
            }`}
            onMouseEnter={() => setActiveIndex(suggestions.length)}
            onClick={() => {
              onQuerySubmit(query.trim());
              onClose();
            }}
          >
            <svg
              className="h-4 w-4 text-foreground-muted"
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
            {t("search.searchFor", { query: query.trim() })}
          </button>
        </>
      )}
    </div>
  );
}

export { type SearchAutocompleteProps };
