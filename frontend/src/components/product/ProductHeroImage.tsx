"use client";

// ─── ProductHeroImage ────────────────────────────────────────────────────────
// Primary product image displayed in the product profile header.
// Shows the product's front photo from Open Food Facts, or falls back to
// a CategoryPlaceholder icon when no image is available.

import Image from "next/image";
import { ProductImages } from "@/lib/types";
import { CategoryPlaceholder } from "./CategoryPlaceholder";
import { ImageSourceBadge } from "./ImageSourceBadge";

interface ProductHeroImageProps {
  readonly images: ProductImages;
  readonly productName: string;
  readonly categoryIcon: string;
}

export function ProductHeroImage({
  images,
  productName,
  categoryIcon,
}: ProductHeroImageProps) {
  if (!images.has_image || !images.primary) {
    return (
      <CategoryPlaceholder
        icon={categoryIcon}
        productName={productName}
        size="lg"
      />
    );
  }

  const { url, alt_text, source, width, height } = images.primary;

  return (
    <div className="group relative">
      <div className="relative aspect-square w-full overflow-hidden rounded-xl bg-surface-muted">
        <Image
          src={url}
          alt={alt_text ?? productName}
          width={width ?? 400}
          height={height ?? 400}
          className="h-full w-full object-contain"
          sizes="(max-width: 640px) 100vw, 400px"
          priority
        />
      </div>
      <ImageSourceBadge source={source} />
    </div>
  );
}
