"use client";

// ─── CompareCheckbox — selection toggle for product comparison ──────────────
// Renders a checkbox on product cards (search results, category listing, lists).
// Max 4 selected — disables further selection with tooltip.

import { useCompareStore } from "@/stores/compare-store";

interface CompareCheckboxProps {
  productId: number;
}

export function CompareCheckbox({ productId }: Readonly<CompareCheckboxProps>) {
  const isSelected = useCompareStore((s) => s.isSelected(productId));
  const isFull = useCompareStore((s) => s.isFull());
  const toggle = useCompareStore((s) => s.toggle);

  const disabled = !isSelected && isFull;

  function getTitle(): string {
    if (disabled) return "Max 4 products — deselect one first";
    if (isSelected) return "Remove from comparison";
    return "Add to comparison";
  }

  function getVariantClass(): string {
    if (isSelected) return "border-brand-600 bg-brand-600 text-white";
    if (disabled)
      return "border-gray-200 bg-gray-50 text-gray-300 cursor-not-allowed";
    return "border-gray-300 bg-white text-gray-400 hover:border-brand-400 hover:text-brand-500";
  }

  return (
    <button
      type="button"
      onClick={(e) => {
        e.preventDefault();
        e.stopPropagation();
        if (!disabled) toggle(productId);
      }}
      disabled={disabled}
      title={getTitle()}
      className={`flex h-7 w-7 flex-shrink-0 items-center justify-center rounded border transition-colors ${getVariantClass()}`}
      aria-label={isSelected ? "Remove from comparison" : "Add to comparison"}
    >
      {isSelected ? (
        <svg className="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
          <path
            fillRule="evenodd"
            d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
            clipRule="evenodd"
          />
        </svg>
      ) : (
        <span className="text-xs">⚖️</span>
      )}
    </button>
  );
}
