"use client";

import { useState } from "react";
import Image from "next/image";
import {
  CategoryIcon,
  hasCategoryIcon,
} from "@/components/common/CategoryIcon";

// ─── Size presets for different contexts ────────────────────────────────────

const SIZE_PRESETS = {
  /** Search result list row (48 × 48) */
  sm: { container: "h-12 w-12", px: 48 },
  /** Grid card (64 × 64) */
  md: { container: "h-16 w-16", px: 64 },
  /** Large card (80 × 80) */
  lg: { container: "h-20 w-20", px: 80 },
} as const;

type ThumbnailSize = keyof typeof SIZE_PRESETS;

interface ProductThumbnailProps {
  /** Primary product image URL (nullable — falls back to category icon) */
  readonly imageUrl: string | null | undefined;
  /** Product name (used for alt text) */
  readonly productName: string;
  /** Category slug for fallback icon (e.g. "dairy", "chips-pl") */
  readonly categorySlug?: string;
  /** Emoji fallback when no Lucide category icon exists */
  readonly categoryIcon?: string;
  /** Thumbnail size preset */
  readonly size?: ThumbnailSize;
}

/**
 * Compact product image thumbnail for cards and list rows.
 *
 * Fallback chain: image → category Lucide icon → category emoji → generic icon.
 * Uses Next.js Image for optimization (lazy loading, WebP, srcset).
 */
export function ProductThumbnail({
  imageUrl,
  productName,
  categorySlug,
  categoryIcon,
  size = "sm",
}: ProductThumbnailProps) {
  const [error, setError] = useState(false);
  const preset = SIZE_PRESETS[size];

  const showImage = imageUrl && !error;

  return (
    <div
      className={`relative flex-shrink-0 overflow-hidden rounded-lg bg-surface-muted ${preset.container}`}
      data-testid="product-thumbnail"
    >
      {showImage ? (
        <Image
          src={imageUrl}
          alt={productName}
          width={preset.px}
          height={preset.px}
          className="h-full w-full object-cover"
          sizes={`${preset.px}px`}
          onError={() => setError(true)}
        />
      ) : (
        <span
          className="flex h-full w-full items-center justify-center text-foreground-muted"
          aria-label={`${productName} — no image available`}
        >
          {categorySlug && hasCategoryIcon(categorySlug) ? (
            <CategoryIcon slug={categorySlug} size={size === "sm" ? "md" : "lg"} />
          ) : (
            <span className="select-none text-lg" aria-hidden="true">
              {categoryIcon ?? "📦"}
            </span>
          )}
        </span>
      )}
    </div>
  );
}
