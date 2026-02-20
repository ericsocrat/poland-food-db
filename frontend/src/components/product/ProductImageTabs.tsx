"use client";

// ─── ProductImageTabs ────────────────────────────────────────────────────────
// Tabbed gallery showing additional product images (ingredients list,
// nutrition label, packaging) in the product profile overview tab.
// Click any image to open a fullscreen lightbox with zoom + swipe navigation.

import { useState } from "react";
import Image from "next/image";
import { Maximize2 } from "lucide-react";
import { ProductImage, ProductImages } from "@/lib/types";
import { ImageSourceBadge } from "./ImageSourceBadge";
import { ImageLightbox } from "./ImageLightbox";
import { useTranslation } from "@/lib/i18n";

interface ProductImageTabsProps {
  readonly images: ProductImages;
  readonly productName: string;
}

const typeLabels: Record<string, string> = {
  front: "Front",
  ingredients: "Ingredients",
  nutrition_label: "Nutrition",
  packaging: "Packaging",
};

export function ProductImageTabs({
  images,
  productName,
}: ProductImageTabsProps) {
  const allImages: ProductImage[] = [];
  if (images.primary) allImages.push(images.primary);
  allImages.push(...images.additional);

  const { t } = useTranslation();
  const [activeIdx, setActiveIdx] = useState(0);
  const [lightboxOpen, setLightboxOpen] = useState(false);

  // Don't render if fewer than 2 images (primary is already shown in hero)
  if (allImages.length < 2) return null;

  const activeImage = allImages[activeIdx];
  if (!activeImage) return null;

  return (
    <>
      <div className="rounded-xl border border bg-surface p-4">
        <h3 className="mb-3 text-sm font-semibold text-foreground-secondary">
          {t("product.productPhotos")}
        </h3>

        {/* Image tabs */}
        <div className="mb-3 flex gap-1">
          {allImages.map((img, idx) => (
            <button
              key={img.image_id}
              onClick={() => setActiveIdx(idx)}
              className={`cursor-pointer rounded-md px-3 py-1.5 text-xs font-medium transition-colors ${
                idx === activeIdx
                  ? "bg-brand-subtle text-brand"
                  : "bg-surface-subtle text-foreground-secondary hover:bg-surface-muted"
              }`}
            >
              {typeLabels[img.image_type] ?? img.image_type}
            </button>
          ))}
        </div>

        {/* Active image — click to open lightbox */}
        <button
          type="button"
          onClick={() => setLightboxOpen(true)}
          className="group relative w-full overflow-hidden rounded-lg bg-surface-subtle"
          aria-label={t("imageLightbox.openFullscreen")}
        >
          <Image
            src={activeImage.url}
            alt={
              activeImage.alt_text ??
              `${productName} — ${activeImage.image_type}`
            }
            width={activeImage.width ?? 400}
            height={activeImage.height ?? 400}
            className="mx-auto max-h-80 w-auto object-contain"
            sizes="(max-width: 640px) 100vw, 400px"
          />
          <ImageSourceBadge source={activeImage.source} />

          {/* Zoom hint overlay */}
          <div className="absolute inset-0 flex items-center justify-center bg-black/0 transition-colors group-hover:bg-black/10">
            <div className="rounded-full bg-black/50 p-2 opacity-0 transition-opacity group-hover:opacity-100">
              <Maximize2 size={20} className="text-white" />
            </div>
          </div>
        </button>
      </div>

      {/* Lightbox modal */}
      {lightboxOpen && (
        <ImageLightbox
          images={allImages}
          initialIndex={activeIdx}
          productName={productName}
          onClose={() => setLightboxOpen(false)}
        />
      )}
    </>
  );
}
