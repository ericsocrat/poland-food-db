"use client";

// ─── ActiveFilterChips — chip bar showing active filters with × to remove ───

import { ALLERGEN_TAGS } from "@/lib/constants";
import type { SearchFilters } from "@/lib/types";

interface ActiveFilterChipsProps {
  filters: SearchFilters;
  onChange: (filters: SearchFilters) => void;
}

export function ActiveFilterChips({
  filters,
  onChange,
}: Readonly<ActiveFilterChipsProps>) {
  const chips: { key: string; label: string; onRemove: () => void }[] = [];

  // Category chips
  for (const cat of filters.category ?? []) {
    chips.push({
      key: `cat-${cat}`,
      label: cat,
      onRemove: () => {
        const next = (filters.category ?? []).filter((c) => c !== cat);
        onChange({
          ...filters,
          category: next.length > 0 ? next : undefined,
        });
      },
    });
  }

  // Nutri-Score chips
  for (const ns of filters.nutri_score ?? []) {
    chips.push({
      key: `ns-${ns}`,
      label: `Nutri ${ns}`,
      onRemove: () => {
        const next = (filters.nutri_score ?? []).filter((n) => n !== ns);
        onChange({
          ...filters,
          nutri_score: next.length > 0 ? next : undefined,
        });
      },
    });
  }

  // Allergen-free chips
  for (const tag of filters.allergen_free ?? []) {
    const info = ALLERGEN_TAGS.find((a) => a.tag === tag);
    const label = info
      ? `${info.label}-free`
      : `${tag.replace("en:", "")}-free`;
    chips.push({
      key: `al-${tag}`,
      label,
      onRemove: () => {
        const next = (filters.allergen_free ?? []).filter((a) => a !== tag);
        onChange({
          ...filters,
          allergen_free: next.length > 0 ? next : undefined,
        });
      },
    });
  }

  // Max unhealthiness
  if (filters.max_unhealthiness !== undefined) {
    chips.push({
      key: "max-score",
      label: `Score ≤ ${filters.max_unhealthiness}`,
      onRemove: () => onChange({ ...filters, max_unhealthiness: undefined }),
    });
  }

  // Sort (if non-default)
  if (filters.sort_by && filters.sort_by !== "relevance") {
    const sortLabels: Record<string, string> = {
      name: "Name",
      unhealthiness: "Health Score",
      nutri_score: "Nutri-Score",
      calories: "Calories",
    };
    chips.push({
      key: "sort",
      label: `Sort: ${sortLabels[filters.sort_by] ?? filters.sort_by} ${
        filters.sort_order === "desc" ? "↓" : "↑"
      }`,
      onRemove: () =>
        onChange({
          ...filters,
          sort_by: undefined,
          sort_order: undefined,
        }),
    });
  }

  if (chips.length === 0) return null;

  return (
    <div className="flex flex-wrap gap-1.5">
      {chips.map((chip) => (
        <span
          key={chip.key}
          className="inline-flex items-center gap-1 rounded-full bg-brand-50 px-2.5 py-1 text-xs font-medium text-brand-700"
        >
          {chip.label}
          <button
            type="button"
            onClick={chip.onRemove}
            className="ml-0.5 rounded-full p-0.5 text-brand-400 transition-colors hover:bg-brand-100 hover:text-brand-600"
            aria-label={`Remove ${chip.label} filter`}
          >
            <svg className="h-3 w-3" viewBox="0 0 20 20" fill="currentColor">
              <path
                fillRule="evenodd"
                d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"
                clipRule="evenodd"
              />
            </svg>
          </button>
        </span>
      ))}
      {chips.length > 1 && (
        <button
          type="button"
          onClick={() => onChange({})}
          className="text-xs text-gray-400 hover:text-gray-600"
        >
          Clear all
        </button>
      )}
    </div>
  );
}
