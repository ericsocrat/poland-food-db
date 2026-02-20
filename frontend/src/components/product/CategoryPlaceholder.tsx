// ─── CategoryPlaceholder ─────────────────────────────────────────────────────
// Placeholder shown when a product has no image. Prefers the CategoryIcon
// (Lucide-based SVG) for the product's category slug, with the legacy emoji
// as a fallback. Issue #65: Iconography & Illustration System.

import {
  CategoryIcon,
  hasCategoryIcon,
  type CategoryIconSize,
} from "@/components/common/CategoryIcon";

interface CategoryPlaceholderProps {
  /** Legacy category emoji (e.g. "🧀") — used as fallback. */
  readonly icon: string;
  /** Product name for accessible label. */
  readonly productName: string;
  /** Display size preset. @default "md" */
  readonly size?: "sm" | "md" | "lg";
  /** Category slug for Lucide icon lookup (e.g. "dairy"). */
  readonly categorySlug?: string;
}

const sizeClasses = {
  sm: "h-10 w-10",
  md: "h-16 w-16",
  lg: "h-32 w-full max-w-xs",
} as const;

const ICON_SIZE_MAP: Record<string, CategoryIconSize> = {
  sm: "md",
  md: "xl",
  lg: "xl",
};

export function CategoryPlaceholder({
  icon,
  productName,
  size = "md",
  categorySlug,
}: CategoryPlaceholderProps) {
  const useLucide = categorySlug && hasCategoryIcon(categorySlug);

  return (
    <div
      aria-label={`${productName} — no image available`}
      className={`flex items-center justify-center rounded-xl bg-surface-muted text-foreground-muted ${sizeClasses[size]}`}
    >
      {useLucide ? (
        <CategoryIcon slug={categorySlug} size={ICON_SIZE_MAP[size]} />
      ) : (
        <span className="select-none text-2xl" aria-hidden="true">
          {icon}
        </span>
      )}
    </div>
  );
}
