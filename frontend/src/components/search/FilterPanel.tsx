"use client";

// ─── FilterPanel — sidebar (desktop) / bottom sheet (mobile) ────────────────

import { useCallback } from "react";
import { useQuery } from "@tanstack/react-query";
import { createClient } from "@/lib/supabase/client";
import { getFilterOptions } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { ALLERGEN_TAGS, NUTRI_COLORS } from "@/lib/constants";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import { useTranslation } from "@/lib/i18n";
import type { SearchFilters } from "@/lib/types";

interface FilterPanelProps {
  filters: SearchFilters;
  onChange: (filters: SearchFilters) => void;
  show: boolean;
  onClose: () => void;
}

export function FilterPanel({
  filters,
  onChange,
  show,
  onClose,
}: Readonly<FilterPanelProps>) {
  const { t } = useTranslation();
  const supabase = createClient();

  const { data, isLoading } = useQuery({
    queryKey: queryKeys.filterOptions,
    queryFn: async () => {
      const result = await getFilterOptions(supabase);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.filterOptions,
  });

  const toggleArrayFilter = useCallback(
    (key: "category" | "nutri_score" | "allergen_free", value: string) => {
      const current = filters[key] ?? [];
      const next = current.includes(value)
        ? current.filter((v) => v !== value)
        : [...current, value];
      onChange({ ...filters, [key]: next.length > 0 ? next : undefined });
    },
    [filters, onChange],
  );

  const setMaxScore = useCallback(
    (value: number | undefined) => {
      onChange({ ...filters, max_unhealthiness: value });
    },
    [filters, onChange],
  );

  const setSortBy = useCallback(
    (value: SearchFilters["sort_by"]) => {
      onChange({
        ...filters,
        sort_by: value,
        sort_order: value === "relevance" ? undefined : filters.sort_order,
      });
    },
    [filters, onChange],
  );

  const setSortOrder = useCallback(
    (value: SearchFilters["sort_order"]) => {
      onChange({ ...filters, sort_order: value });
    },
    [filters, onChange],
  );

  const clearAll = useCallback(() => {
    onChange({});
  }, [onChange]);

  const hasFilters =
    (filters.category?.length ?? 0) > 0 ||
    (filters.nutri_score?.length ?? 0) > 0 ||
    (filters.allergen_free?.length ?? 0) > 0 ||
    filters.max_unhealthiness !== undefined ||
    (filters.sort_by !== undefined && filters.sort_by !== "relevance");

  // Filter content (shared between desktop sidebar and mobile bottom sheet)
  const filterContent = (
    <div className="space-y-5">
      {isLoading ? (
        <div className="flex justify-center py-8">
          <LoadingSpinner />
        </div>
      ) : (
        <>
          {/* Sort */}
          <div>
            <h3 className="mb-2 text-xs font-semibold uppercase tracking-wider text-foreground-secondary">
              {t("filters.sortBy")}
            </h3>
            <div className="grid grid-cols-2 gap-1.5">
              {[
                { value: "relevance" as const, label: t("filters.relevance") },
                { value: "name" as const, label: t("filters.name") },
                {
                  value: "unhealthiness" as const,
                  label: t("filters.healthScore"),
                },
                {
                  value: "nutri_score" as const,
                  label: t("filters.nutriScore"),
                },
                { value: "calories" as const, label: t("filters.calories") },
              ].map((opt) => (
                <button
                  key={opt.value}
                  type="button"
                  onClick={() => setSortBy(opt.value)}
                  className={`rounded-lg px-3 py-2 text-xs font-medium transition-colors ${
                    (filters.sort_by ?? "relevance") === opt.value
                      ? "bg-brand-subtle text-brand"
                      : "bg-surface-muted text-foreground-secondary hover:bg-surface-subtle"
                  }`}
                >
                  {opt.label}
                </button>
              ))}
            </div>
            {filters.sort_by && filters.sort_by !== "relevance" && (
              <div className="mt-2 flex gap-1.5">
                <button
                  type="button"
                  onClick={() => setSortOrder("asc")}
                  className={`rounded-md px-3 py-2 text-xs ${
                    (filters.sort_order ?? "asc") === "asc"
                      ? "bg-brand-subtle text-brand"
                      : "bg-surface-muted text-foreground-muted"
                  }`}
                >
                  {t("filters.asc")}
                </button>
                <button
                  type="button"
                  onClick={() => setSortOrder("desc")}
                  className={`rounded-md px-3 py-2 text-xs ${
                    filters.sort_order === "desc"
                      ? "bg-brand-subtle text-brand"
                      : "bg-surface-muted text-foreground-muted"
                  }`}
                >
                  {t("filters.desc")}
                </button>
              </div>
            )}
          </div>

          {/* Categories */}
          {data && data.categories.length > 0 && (
            <div>
              <h3 className="mb-2 text-xs font-semibold uppercase tracking-wider text-foreground-secondary">
                {t("filters.category")}
              </h3>
              <div className="space-y-1 max-h-48 overflow-y-auto">
                {data.categories.map((cat) => {
                  const selected = (filters.category ?? []).includes(
                    cat.category,
                  );
                  return (
                    <label
                      key={cat.category}
                      className="flex cursor-pointer items-center gap-2 rounded-lg px-2 py-2.5 transition-colors hover:bg-surface-subtle"
                    >
                      <input
                        type="checkbox"
                        checked={selected}
                        onChange={() =>
                          toggleArrayFilter("category", cat.category)
                        }
                        className="h-5 w-5 rounded border-strong text-brand focus:ring-brand"
                      />
                      <span className="text-sm">
                        {cat.icon_emoji} {cat.display_name}
                      </span>
                      <span className="ml-auto text-xs text-foreground-muted">
                        {cat.count}
                      </span>
                    </label>
                  );
                })}
              </div>
            </div>
          )}

          {/* Nutri-Score */}
          {data && data.nutri_scores.length > 0 && (
            <div>
              <h3 className="mb-2 text-xs font-semibold uppercase tracking-wider text-foreground-secondary">
                {t("filters.nutriScore")}
              </h3>
              <div className="flex flex-wrap gap-2">
                {data.nutri_scores.map((ns) => {
                  const selected = (filters.nutri_score ?? []).includes(
                    ns.label,
                  );
                  const nutriClass =
                    NUTRI_COLORS[ns.label] ?? "bg-surface-muted";
                  return (
                    <button
                      key={ns.label}
                      type="button"
                      onClick={() => toggleArrayFilter("nutri_score", ns.label)}
                      className={`flex items-center gap-1.5 rounded-full px-3 py-2 text-xs font-bold transition-all ${
                        selected
                          ? `${nutriClass} ring-2 ring-offset-1 ring-brand`
                          : `${nutriClass} opacity-60 hover:opacity-100`
                      }`}
                    >
                      {ns.label}
                      <span
                        className={`text-[10px] font-normal ${
                          selected ? "opacity-80" : "opacity-60"
                        }`}
                      >
                        ({ns.count})
                      </span>
                    </button>
                  );
                })}
              </div>
            </div>
          )}

          {/* Allergen-Free */}
          {data && data.allergens.length > 0 && (
            <div>
              <h3 className="mb-2 text-xs font-semibold uppercase tracking-wider text-foreground-secondary">
                {t("filters.allergenFree")}
              </h3>
              <div className="space-y-1 max-h-40 overflow-y-auto">
                {data.allergens.map((al) => {
                  const labelInfo = ALLERGEN_TAGS.find((a) => a.tag === al.tag);
                  const label = labelInfo?.label ?? al.tag.replace("en:", "");
                  const selected = (filters.allergen_free ?? []).includes(
                    al.tag,
                  );
                  return (
                    <label
                      key={al.tag}
                      className="flex cursor-pointer items-center gap-2 rounded-lg px-2 py-2.5 transition-colors hover:bg-surface-subtle"
                    >
                      <input
                        type="checkbox"
                        checked={selected}
                        onChange={() =>
                          toggleArrayFilter("allergen_free", al.tag)
                        }
                        className="h-5 w-5 rounded border-strong text-brand focus:ring-brand"
                      />
                      <span className="text-sm">{label}-free</span>
                      <span className="ml-auto text-xs text-foreground-muted">
                        {al.count}
                      </span>
                    </label>
                  );
                })}
              </div>
            </div>
          )}

          {/* Max Unhealthiness Slider */}
          <div>
            <h3 className="mb-2 text-xs font-semibold uppercase tracking-wider text-foreground-secondary">
              {t("filters.maxHealthScore")}
            </h3>
            <div className="px-1">
              <input
                type="range"
                min={0}
                max={100}
                step={5}
                value={filters.max_unhealthiness ?? 100}
                onChange={(e) => {
                  const val = Number.parseInt(e.target.value);
                  setMaxScore(val >= 100 ? undefined : val);
                }}
                aria-label={t("filters.maxHealthScore")}
                className="w-full accent-brand"
              />
              <div className="flex justify-between text-xs text-foreground-muted">
                <span>0</span>
                <span className="font-medium text-foreground-secondary">
                  {filters.max_unhealthiness === undefined
                    ? t("filters.any")
                    : `≤ ${filters.max_unhealthiness}`}
                </span>
                <span>100</span>
              </div>
            </div>
          </div>

          {/* Clear filters */}
          {hasFilters && (
            <button
              type="button"
              onClick={clearAll}
              className="w-full rounded-lg border border py-2 text-sm text-foreground-secondary transition-colors hover:bg-surface-subtle"
            >
              {t("filters.clearAll")}
            </button>
          )}
        </>
      )}
    </div>
  );

  return (
    <>
      {/* Desktop sidebar */}
      <div className="hidden lg:block">
        <div className="sticky top-20 w-64 rounded-xl border border bg-surface p-4 xl:w-72">
          <div className="mb-3 flex items-center justify-between">
            <h2 className="text-sm font-semibold text-foreground">
              {t("search.filters")}
            </h2>
            {hasFilters && (
              <button
                type="button"
                onClick={clearAll}
                className="text-xs text-brand hover:text-brand-hover"
              >
                {t("common.clear")}
              </button>
            )}
          </div>
          {filterContent}
        </div>
      </div>

      {/* Mobile bottom sheet */}
      {show && (
        <div className="fixed inset-0 z-50 lg:hidden">
          {/* Backdrop */}
          <button
            type="button"
            className="absolute inset-0 bg-black/30"
            onClick={onClose}
            aria-label={t("filters.closeFilters")}
          />
          {/* Sheet */}
          <div className="animate-slide-up-sheet absolute bottom-0 left-0 right-0 max-h-[85vh] overflow-y-auto rounded-t-2xl bg-surface px-4 pb-8 pt-3 shadow-2xl">
            {/* Handle */}
            <div className="mx-auto mb-4 h-1 w-10 rounded-full bg-surface-muted" />
            <div className="mb-4 flex items-center justify-between">
              <h2 className="text-base font-semibold text-foreground">
                {t("search.filters")}
              </h2>
              <button
                type="button"
                onClick={onClose}
                className="touch-target rounded-full p-2 text-foreground-muted hover:bg-surface-muted hover:text-foreground-secondary"
              >
                <svg
                  className="h-5 w-5"
                  viewBox="0 0 20 20"
                  fill="currentColor"
                >
                  <path
                    fillRule="evenodd"
                    d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"
                    clipRule="evenodd"
                  />
                </svg>
              </button>
            </div>
            {filterContent}
            <div className="mt-4">
              <button
                type="button"
                onClick={onClose}
                className="btn-primary w-full py-2.5 text-sm"
              >
                {t("filters.showResults")}
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
