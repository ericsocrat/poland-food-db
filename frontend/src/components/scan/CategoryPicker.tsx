"use client";

// ─── CategoryPicker — mobile-friendly category selector ─────────────────────
// Replaces native <select> with a scrollable grid of tappable emoji pills.
// Falls back to the same value semantics (slug string or "").

import { FOOD_CATEGORIES } from "@/lib/constants";
import { useTranslation } from "@/lib/i18n";
import { ChevronDown, ChevronUp } from "lucide-react";
import { useState } from "react";

const COLLAPSED_COUNT = 8;

interface CategoryPickerProps {
  readonly value: string;
  readonly onChange: (slug: string) => void;
}

export function CategoryPicker({ value, onChange }: CategoryPickerProps) {
  const { t } = useTranslation();
  const [expanded, setExpanded] = useState(false);
  const canCollapse = FOOD_CATEGORIES.length > COLLAPSED_COUNT;
  const visible = canCollapse && !expanded
    ? FOOD_CATEGORIES.slice(0, COLLAPSED_COUNT)
    : FOOD_CATEGORIES;

  return (
    <div className="flex flex-wrap gap-2">
      {visible.map((cat) => {
        const isSelected = value === cat.slug;
        return (
          <button
            key={cat.slug}
            type="button"
            onClick={() => onChange(isSelected ? "" : cat.slug)}
            className={`inline-flex items-center gap-1.5 rounded-full border px-3 py-1.5 text-sm transition-all duration-150 active:scale-95 ${
              isSelected
                ? "border-brand bg-brand/10 font-medium text-brand"
                : "border-border bg-surface text-foreground-secondary hover:border-brand/40"
            }`}
            aria-pressed={isSelected}
          >
            <span aria-hidden="true">{cat.emoji}</span>
            {t(cat.labelKey)}
          </button>
        );
      })}
      {canCollapse && (
        <button
          type="button"
          onClick={() => setExpanded((v) => !v)}
          className="inline-flex items-center gap-1 rounded-full border border-dashed border-border px-3 py-1.5 text-sm text-foreground-muted transition-all duration-150 hover:border-brand/40 hover:text-foreground-secondary active:scale-95"
        >
          {expanded ? (
            <>
              {t("categoryPicker.showLess")}
              <ChevronUp size={14} aria-hidden="true" />
            </>
          ) : (
            <>
              {t("categoryPicker.showAll")}
              <ChevronDown size={14} aria-hidden="true" />
            </>
          )}
        </button>
      )}
    </div>
  );
}
