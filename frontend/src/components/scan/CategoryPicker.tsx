"use client";

// ─── CategoryPicker — mobile-friendly category selector ─────────────────────
// Replaces native <select> with a scrollable grid of tappable emoji pills.
// Falls back to the same value semantics (slug string or "").

import { FOOD_CATEGORIES } from "@/lib/constants";
import { useTranslation } from "@/lib/i18n";

interface CategoryPickerProps {
  readonly value: string;
  readonly onChange: (slug: string) => void;
}

export function CategoryPicker({ value, onChange }: CategoryPickerProps) {
  const { t } = useTranslation();

  return (
    <div className="flex flex-wrap gap-2">
      {FOOD_CATEGORIES.map((cat) => {
        const isSelected = value === cat.slug;
        return (
          <button
            key={cat.slug}
            type="button"
            onClick={() => onChange(isSelected ? "" : cat.slug)}
            className={`inline-flex items-center gap-1.5 rounded-full border px-3 py-1.5 text-sm transition-colors ${
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
    </div>
  );
}
