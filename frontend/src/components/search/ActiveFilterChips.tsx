"use client";

// ─── ActiveFilterChips — chip bar showing active filters with × to remove ───

import { ALLERGEN_TAGS } from "@/lib/constants";
import { useTranslation } from "@/lib/i18n";
import { nutriScoreLabel } from "@/lib/nutri-label";
import type { SearchFilters } from "@/lib/types";

interface ActiveFilterChipsProps {
  filters: SearchFilters;
  onChange: (filters: SearchFilters) => void;
}

export function ActiveFilterChips({
  filters,
  onChange,
}: Readonly<ActiveFilterChipsProps>) {
  const { t } = useTranslation();
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
      label: t("chips.nutri", {
        value: nutriScoreLabel(ns, t("filters.notRated")),
      }),
      onRemove: () => {
        const next = (filters.nutri_score ?? []).filter((n) => n !== ns);
        onChange({
          ...filters,
          nutri_score: next.length > 0 ? next : undefined,
        });
      },
    });
  }

  // NOVA group chips
  for (const group of filters.nova_group ?? []) {
    chips.push({
      key: `nova-${group}`,
      label: t("chips.nova_group", { value: group }),
      onRemove: () => {
        const next = (filters.nova_group ?? []).filter((g) => g !== group);
        onChange({
          ...filters,
          nova_group: next.length > 0 ? next : undefined,
        });
      },
    });
  }

  // Allergen-free chips
  for (const tag of filters.allergen_free ?? []) {
    const info = ALLERGEN_TAGS.find((a) => a.tag === tag);
    // Tags are bare canonical IDs; strip legacy en: prefix as fallback
    const label = info
      ? t("chips.allergenFree", { label: info.label })
      : t("chips.allergenFree", { label: tag.replace("en:", "") });
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
      label: t("chips.scoreMax", { value: filters.max_unhealthiness }),
      onRemove: () => onChange({ ...filters, max_unhealthiness: undefined }),
    });
  }

  // Sort (if non-default)
  if (filters.sort_by && filters.sort_by !== "relevance") {
    const sortLabels: Record<string, string> = {
      name: t("filters.name"),
      unhealthiness: t("filters.healthScore"),
      nutri_score: t("filters.nutriScore"),
      calories: t("filters.calories"),
    };
    chips.push({
      key: "sort",
      label: t("chips.sortLabel", {
        label: `${sortLabels[filters.sort_by] ?? filters.sort_by} ${
          filters.sort_order === "desc" ? "↓" : "↑"
        }`,
      }),
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
    <div className="flex flex-wrap gap-2">
      {chips.map((chip) => (
        <span
          key={chip.key}
          className="inline-flex items-center gap-1 rounded-full bg-brand-subtle px-3 py-1.5 text-xs font-medium text-brand"
        >
          {chip.label}
          <button
            type="button"
            onClick={chip.onRemove}
            className="touch-target-expanded ml-0.5 rounded-full p-1 text-brand transition-colors hover:bg-brand-subtle hover:text-brand"
            aria-label={t("chips.removeFilter", { label: chip.label })}
          >
            <svg
              className="h-3.5 w-3.5"
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
        </span>
      ))}
      {chips.length > 1 && (
        <button
          type="button"
          onClick={() => onChange({})}
          className="touch-target px-2 text-xs text-foreground-muted hover:text-foreground-secondary"
        >
          {t("filters.clearAll")}
        </button>
      )}
    </div>
  );
}
