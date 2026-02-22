"use client";

// ─── SearchAutocomplete — debounced prefix search + recent/popular ──────────

import { useState, useEffect, useRef, useCallback, useMemo } from "react";
import { useQuery } from "@tanstack/react-query";
import { useRouter } from "next/navigation";
import { Flame } from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import { searchAutocomplete } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { SCORE_BANDS, NUTRI_COLORS } from "@/lib/constants";
import { nutriScoreLabel } from "@/lib/nutri-label";
import {
  getRecentSearches,
  removeRecentSearch,
  clearRecentSearches,
} from "@/lib/recent-searches";
import type { AutocompleteSuggestion } from "@/lib/types";
import { useTranslation } from "@/lib/i18n";

// ─── Text highlight helper (#62) ────────────────────────────────────────────

/**
 * Highlights matching portions of `text` that match `query`.
 * Diacritic-insensitive: "zol" highlights "żół" in "Ser Żółty".
 * Returns JSX with <mark> tags around matched segments.
 */
function HighlightMatch({
  text,
  query,
}: Readonly<{ text: string; query: string }>) {
  if (!query || query.length < 1) return <>{text}</>;

  // Normalize both strings for comparison (strip diacritics, lowercase)
  const normalize = (s: string) =>
    s
      .normalize("NFD")
      .replaceAll(/[\u0300-\u036f]/g, "")
      .replaceAll("ł", "l")
      .replaceAll("Ł", "L")
      .toLowerCase();

  const normalizedText = normalize(text);
  const normalizedQuery = normalize(query);

  // Find all non-overlapping match positions
  const parts: { start: number; end: number; isMatch: boolean }[] = [];
  let searchFrom = 0;
  let lastEnd = 0;

  while (searchFrom <= normalizedText.length - normalizedQuery.length) {
    const idx = normalizedText.indexOf(normalizedQuery, searchFrom);
    if (idx === -1) break;

    if (idx > lastEnd) {
      parts.push({ start: lastEnd, end: idx, isMatch: false });
    }
    parts.push({
      start: idx,
      end: idx + normalizedQuery.length,
      isMatch: true,
    });
    lastEnd = idx + normalizedQuery.length;
    searchFrom = lastEnd;
  }

  if (lastEnd < text.length) {
    parts.push({ start: lastEnd, end: text.length, isMatch: false });
  }

  // No match found — return original text
  if (parts.length === 0 || !parts.some((p) => p.isMatch)) {
    return <>{text}</>;
  }

  return (
    <>
      {parts.map((part) =>
        part.isMatch ? (
          <mark
            key={part.start}
            className="bg-brand/20 text-foreground rounded-sm"
          >
            {text.slice(part.start, part.end)}
          </mark>
        ) : (
          <span key={part.start}>{text.slice(part.start, part.end)}</span>
        ),
      )}
    </>
  );
}

interface SearchAutocompleteProps {
  query: string;
  onSelect: (product: AutocompleteSuggestion) => void;
  onQuerySubmit: (query: string) => void;
  onQueryChange: (query: string) => void;
  show: boolean;
  onClose: () => void;
  /** Ref callback — receives the keyboard handler so the parent input can use it */
  onInputKeyDown?: (handler: (e: React.KeyboardEvent) => void) => void;
  /** Reports the active option DOM id for aria-activedescendant binding */
  onActiveIdChange?: (id: string | undefined) => void;
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
  onActiveIdChange,
}: Readonly<SearchAutocompleteProps>) {
  const { t } = useTranslation();
  const popularSearches = useMemo(() => t("search.popularTerms").split(","), [t]);
  const supabase = createClient();
  const router = useRouter();
  const debouncedQuery = useDebounce(query, 200);
  const [activeIndex, setActiveIndex] = useState(-1);
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
  const showPopular = !isQueryMode;
  const popularIndexOffset = showRecent ? recentSearches.length : 0;

  // Total navigable items count for keyboard nav
  const navigableCount = (() => {
    if (isQueryMode) return suggestions.length + 1; // +1 for "Search for…" footer
    let count = 0;
    if (showRecent) count += recentSearches.length;
    if (showPopular) count += popularSearches.length;
    return count;
  })();

  /** Stable option id for aria-activedescendant */
  const getOptionId = (index: number) =>
    index >= 0 ? `search-autocomplete-option-${index}` : undefined;

  // Reset active index when suggestions change
  useEffect(() => {
    setActiveIndex(-1);
  }, [suggestions.length, debouncedQuery, isQueryMode]);

  // Report active ID to parent for aria-activedescendant
  useEffect(() => {
    onActiveIdChange?.(getOptionId(activeIndex));
  }, [activeIndex, onActiveIdChange]);

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

  /** Handle Enter key selection — extracted to reduce cognitive complexity. */
  const handleEnterSelection = useCallback(() => {
    if (isQueryMode) {
      if (activeIndex >= 0 && activeIndex < suggestions.length) {
        const selected = suggestions[activeIndex];
        onSelect(selected);
        router.push(`/app/product/${selected.product_id}`);
      } else if (query.trim().length >= 1) {
        onQuerySubmit(query.trim());
      }
    } else if (activeIndex >= 0) {
      if (showRecent && activeIndex < recentSearches.length) {
        onQuerySubmit(recentSearches[activeIndex]);
      } else if (showPopular) {
        const popIdx = activeIndex - popularIndexOffset;
        if (popIdx >= 0 && popIdx < popularSearches.length) {
          onQuerySubmit(popularSearches[popIdx]);
        }
      }
    }
  }, [
    isQueryMode,
    activeIndex,
    suggestions,
    query,
    showRecent,
    recentSearches,
    showPopular,
    popularIndexOffset,
    popularSearches,
    onSelect,
    onQuerySubmit,
    router,
  ]);

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
          handleEnterSelection();
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
      handleEnterSelection,
      onClose,
    ],
  );

  // Expose keyboard handler to parent input
  useEffect(() => {
    onInputKeyDown?.(handleKeyDown);
  }, [handleKeyDown, onInputKeyDown]);

  // Scroll active item into view (ID-based for multi-section support)
  useEffect(() => {
    if (activeIndex >= 0 && containerRef.current) {
      const id = getOptionId(activeIndex);
      if (id) {
        const el = containerRef.current.querySelector(`#${id}`);
        if (el instanceof HTMLElement) el.scrollIntoView({ block: "nearest" });
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
      id="search-autocomplete-listbox"
      role="listbox"
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
              className="text-xs text-brand hover:text-brand-hover"
              onClick={() => {
                clearRecentSearches();
                setRecentSearches([]);
              }}
            >
              {t("search.clearRecent")}
            </button>
          </div>
          <ul>
            {recentSearches.map((q, i) => (
              <li
                key={q}
                id={getOptionId(i)}
                role="option"
                aria-selected={i === activeIndex}
                className={`flex cursor-pointer items-center gap-3 px-4 py-2 transition-colors ${
                  i === activeIndex
                    ? "bg-brand-subtle text-foreground"
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

      {/* ── Popular searches (empty-query mode) ─────────────────── */}
      {showPopular && (
        <>
          <div className={`px-4 pb-1 pt-3${showRecent ? " border-t" : ""}`}>
            <span className="text-xs font-semibold uppercase tracking-wider text-foreground-muted">
              {t("search.popularSearches")}
            </span>
          </div>
          <ul>
            {popularSearches.map((q, i) => {
              const idx = popularIndexOffset + i;
              return (
                <li
                  key={q}
                  id={getOptionId(idx)}
                  role="option"
                  aria-selected={idx === activeIndex}
                  className={`flex cursor-pointer items-center gap-3 px-4 py-2 transition-colors ${
                    idx === activeIndex
                      ? "bg-brand-subtle text-foreground"
                      : "hover:bg-surface-subtle"
                  }`}
                >
                  <button
                    type="button"
                    className="flex min-w-0 flex-1 items-center gap-3"
                    onMouseEnter={() => setActiveIndex(idx)}
                    onClick={() => {
                      onQuerySubmit(q);
                      onClose();
                    }}
                  >
                    <span className="text-foreground-muted">
                      <Flame size={14} aria-hidden="true" />
                    </span>
                    <span className="min-w-0 flex-1 truncate text-left text-sm text-foreground">
                      {q}
                    </span>
                  </button>
                </li>
              );
            })}
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
          <ul>
            {suggestions.map((s, i) => {
              const band = SCORE_BANDS[s.score_band];
              const nutriClass = s.nutri_score
                ? NUTRI_COLORS[s.nutri_score]
                : "bg-surface-muted text-foreground-secondary";

              return (
                <li
                  key={s.product_id}
                  id={getOptionId(i)}
                  role="option"
                  aria-selected={i === activeIndex}
                  className={`flex cursor-pointer items-center gap-3 px-4 py-2.5 transition-colors ${
                    i === activeIndex
                      ? "bg-brand-subtle text-foreground"
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
                        <HighlightMatch
                          text={s.product_name_display ?? s.product_name}
                          query={query}
                        />
                      </p>
                      <p className="truncate text-xs text-foreground-secondary">
                        {s.brand} · {s.category}
                      </p>
                    </div>

                    {/* Nutri badge */}
                    <span
                      className={`flex h-7 w-7 flex-shrink-0 items-center justify-center rounded-full text-xs font-bold ${nutriClass}`}
                    >
                      {nutriScoreLabel(s.nutri_score, "?")}
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
                ? "bg-brand-subtle text-foreground"
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
