"use client";

// ─── ProductHeroImage ────────────────────────────────────────────────────────
// Primary product image displayed in the product profile header.
// Shows the product's front photo from Open Food Facts, or falls back to
// a CategoryPlaceholder icon when no image is available.
//
// When the product_images table has no entry but the product has an EAN,
// we fetch the image URL from the OFF API as a runtime fallback.

import { useState, useEffect } from "react";
import Image from "next/image";
import { ProductImages } from "@/lib/types";
import { CategoryPlaceholder } from "./CategoryPlaceholder";
import { ImageSourceBadge } from "./ImageSourceBadge";

interface ProductHeroImageProps {
  readonly images: ProductImages;
  readonly productName: string;
  readonly categoryIcon: string;
  /** EAN barcode — used to fetch a fallback image from OFF when product_images is empty. */
  readonly ean?: string | null;
}

/**
 * Fetch the front image URL for a product from Open Food Facts by EAN.
 * Returns `null` when no image is available.
 */
async function fetchOffImageUrl(ean: string): Promise<string | null> {
  try {
    const res = await fetch(
      `https://world.openfoodfacts.org/api/v2/product/${ean}.json?fields=image_front_url`,
    );
    if (!res.ok) return null;
    const data = await res.json();
    const url: string | undefined = data?.product?.image_front_url;
    return url && url.startsWith("https://") ? url : null;
  } catch {
    return null;
  }
}

export function ProductHeroImage({
  images,
  productName,
  categoryIcon,
  ean,
}: ProductHeroImageProps) {
  // ── OFF API fallback state ──────────────────────────────────────────────
  const needsFallback = !images.has_image || !images.primary;
  const [offUrl, setOffUrl] = useState<string | null>(null);
  const [offLoading, setOffLoading] = useState(false);
  const [imageLoaded, setImageLoaded] = useState(false);

  useEffect(() => {
    if (!needsFallback || !ean) return;
    let cancelled = false;
    setOffLoading(true);
    fetchOffImageUrl(ean).then((url) => {
      if (!cancelled) {
        setOffUrl(url);
        setOffLoading(false);
      }
    });
    return () => {
      cancelled = true;
    };
  }, [needsFallback, ean]);

  // ── Determine which image to show ──────────────────────────────────────
  const url = images.primary?.url ?? offUrl;
  const source = images.primary ? images.primary.source : "off_api";
  const altText = images.primary?.alt_text ?? productName;

  // Still loading OFF fallback — show blur placeholder
  if (!url) {
    if (offLoading) {
      return (
        <div className="flex h-32 w-full items-center justify-center overflow-hidden rounded-xl bg-surface-muted">
          <div
            className="absolute inset-0 animate-pulse bg-gradient-to-br from-gray-200 via-gray-100 to-gray-200"
            style={{ filter: "blur(8px)" }}
            aria-hidden="true"
          />
          <span className="relative text-sm text-foreground-muted">
            Loading image…
          </span>
        </div>
      );
    }
    return (
      <CategoryPlaceholder
        icon={categoryIcon}
        productName={productName}
        size="lg"
      />
    );
  }

  return (
    <div className="group relative">
      <div className="relative h-72 w-full overflow-hidden rounded-xl bg-surface-muted">
        {/* Blur placeholder shown until image fully loads */}
        {!imageLoaded && (
          <div
            className="absolute inset-0 animate-pulse bg-gradient-to-br from-gray-200 via-gray-100 to-gray-200"
            style={{ filter: "blur(8px)" }}
            aria-hidden="true"
            data-testid="image-blur-placeholder"
          />
        )}
        <Image
          src={url}
          alt={altText}
          fill
          className={`object-contain transition-opacity duration-300 ${imageLoaded ? "opacity-100" : "opacity-0"}`}
          sizes="(max-width: 640px) 100vw, 400px"
          priority
          onLoad={() => setImageLoaded(true)}
        />
      </div>
      <ImageSourceBadge source={source} />
    </div>
  );
}
