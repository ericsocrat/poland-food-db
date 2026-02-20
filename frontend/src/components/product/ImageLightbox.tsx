"use client";

// ─── ImageLightbox ──────────────────────────────────────────────────────────
// Fullscreen modal image viewer with zoom, swipe navigation, and keyboard support.
// No external dependencies — pure React + CSS transforms.

import { useState, useEffect, useCallback, useRef } from "react";
import Image from "next/image";
import { X, ZoomIn, ZoomOut, ChevronLeft, ChevronRight } from "lucide-react";
import type { ProductImage } from "@/lib/types";
import { useTranslation } from "@/lib/i18n";

interface ImageLightboxProps {
  readonly images: ProductImage[];
  readonly initialIndex: number;
  readonly productName: string;
  readonly onClose: () => void;
}

const ZOOM_LEVELS = [1, 1.5, 2, 3] as const;

export function ImageLightbox({
  images,
  initialIndex,
  productName,
  onClose,
}: ImageLightboxProps) {
  const { t } = useTranslation();
  const [currentIndex, setCurrentIndex] = useState(initialIndex);
  const [zoomLevel, setZoomLevel] = useState(0); // index into ZOOM_LEVELS
  const [panOffset, setPanOffset] = useState({ x: 0, y: 0 });
  const containerRef = useRef<HTMLDivElement>(null);
  const touchStartRef = useRef<{ x: number; y: number } | null>(null);

  const zoom = ZOOM_LEVELS[zoomLevel];
  const image = images[currentIndex];
  const canZoomIn = zoomLevel < ZOOM_LEVELS.length - 1;
  const canZoomOut = zoomLevel > 0;

  const resetZoom = useCallback(() => {
    setZoomLevel(0);
    setPanOffset({ x: 0, y: 0 });
  }, []);

  const goTo = useCallback(
    (idx: number) => {
      setCurrentIndex(idx);
      resetZoom();
    },
    [resetZoom],
  );

  const prev = useCallback(
    () => goTo((currentIndex - 1 + images.length) % images.length),
    [currentIndex, images.length, goTo],
  );

  const next = useCallback(
    () => goTo((currentIndex + 1) % images.length),
    [currentIndex, images.length, goTo],
  );

  // Keyboard navigation
  useEffect(() => {
    function handleKey(e: KeyboardEvent) {
      switch (e.key) {
        case "Escape":
          onClose();
          break;
        case "ArrowLeft":
          prev();
          break;
        case "ArrowRight":
          next();
          break;
        case "+":
        case "=":
          if (canZoomIn) setZoomLevel((z) => z + 1);
          break;
        case "-":
          if (canZoomOut) {
            setZoomLevel((z) => z - 1);
            setPanOffset({ x: 0, y: 0 });
          }
          break;
      }
    }
    document.addEventListener("keydown", handleKey);
    return () => document.removeEventListener("keydown", handleKey);
  }, [onClose, prev, next, canZoomIn, canZoomOut]);

  // Prevent body scroll while lightbox is open
  useEffect(() => {
    const original = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = original;
    };
  }, []);

  // Touch swipe handling
  const handleTouchStart = useCallback(
    (e: React.TouchEvent) => {
      if (zoom > 1) return; // don't swipe while zoomed
      const touch = e.touches[0];
      touchStartRef.current = { x: touch.clientX, y: touch.clientY };
    },
    [zoom],
  );

  const handleTouchEnd = useCallback(
    (e: React.TouchEvent) => {
      if (!touchStartRef.current || zoom > 1) return;
      const touch = e.changedTouches[0];
      const dx = touch.clientX - touchStartRef.current.x;
      const threshold = 50;
      if (Math.abs(dx) > threshold) {
        if (dx > 0) prev();
        else next();
      }
      touchStartRef.current = null;
    },
    [zoom, prev, next],
  );

  // Pan while zoomed (mouse drag)
  const handleMouseDown = useCallback(
    (e: React.MouseEvent) => {
      if (zoom <= 1) return;
      e.preventDefault();
      const startX = e.clientX - panOffset.x;
      const startY = e.clientY - panOffset.y;

      function handleMove(ev: MouseEvent) {
        setPanOffset({ x: ev.clientX - startX, y: ev.clientY - startY });
      }
      function handleUp() {
        document.removeEventListener("mousemove", handleMove);
        document.removeEventListener("mouseup", handleUp);
      }
      document.addEventListener("mousemove", handleMove);
      document.addEventListener("mouseup", handleUp);
    },
    [zoom, panOffset],
  );

  if (!image) return null;

  return (
    <div
      ref={containerRef}
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/90"
      role="dialog"
      aria-modal="true"
      aria-label={t("imageLightbox.title")}
      onClick={(e) => {
        if (e.target === containerRef.current) onClose();
      }}
    >
      {/* Top toolbar */}
      <div className="absolute top-0 left-0 right-0 z-10 flex items-center justify-between px-4 py-3">
        <span className="text-sm font-medium text-white/80">
          {currentIndex + 1} / {images.length}
        </span>
        <div className="flex items-center gap-2">
          <button
            type="button"
            onClick={() => {
              if (canZoomIn) {
                setZoomLevel((z) => z + 1);
              }
            }}
            disabled={!canZoomIn}
            className="rounded-full bg-white/10 p-2 text-white transition-colors hover:bg-white/20 disabled:opacity-30"
            aria-label={t("imageLightbox.zoomIn")}
          >
            <ZoomIn size={18} />
          </button>
          <button
            type="button"
            onClick={() => {
              if (canZoomOut) {
                setZoomLevel((z) => z - 1);
                setPanOffset({ x: 0, y: 0 });
              }
            }}
            disabled={!canZoomOut}
            className="rounded-full bg-white/10 p-2 text-white transition-colors hover:bg-white/20 disabled:opacity-30"
            aria-label={t("imageLightbox.zoomOut")}
          >
            <ZoomOut size={18} />
          </button>
          <button
            type="button"
            onClick={onClose}
            className="rounded-full bg-white/10 p-2 text-white transition-colors hover:bg-white/20"
            aria-label={t("common.close")}
          >
            <X size={18} />
          </button>
        </div>
      </div>

      {/* Navigation arrows */}
      {images.length > 1 && (
        <>
          <button
            type="button"
            onClick={prev}
            className="absolute left-2 top-1/2 z-10 -translate-y-1/2 rounded-full bg-white/10 p-2 text-white transition-colors hover:bg-white/20"
            aria-label={t("imageLightbox.previous")}
          >
            <ChevronLeft size={24} />
          </button>
          <button
            type="button"
            onClick={next}
            className="absolute right-2 top-1/2 z-10 -translate-y-1/2 rounded-full bg-white/10 p-2 text-white transition-colors hover:bg-white/20"
            aria-label={t("imageLightbox.next")}
          >
            <ChevronRight size={24} />
          </button>
        </>
      )}

      {/* Image area */}
      <div
        className="flex h-full w-full items-center justify-center overflow-hidden"
        onTouchStart={handleTouchStart}
        onTouchEnd={handleTouchEnd}
        onMouseDown={handleMouseDown}
        style={{ cursor: zoom > 1 ? "grab" : "default" }}
      >
        <div
          className="transition-transform duration-200"
          style={{
            transform: `scale(${zoom}) translate(${panOffset.x / zoom}px, ${panOffset.y / zoom}px)`,
          }}
        >
          <Image
            src={image.url}
            alt={image.alt_text ?? `${productName} — ${image.image_type}`}
            width={image.width ?? 800}
            height={image.height ?? 800}
            className="max-h-[85vh] max-w-[90vw] object-contain"
            sizes="90vw"
            priority
          />
        </div>
      </div>

      {/* Thumbnail strip */}
      {images.length > 1 && (
        <div className="absolute bottom-4 left-1/2 z-10 flex -translate-x-1/2 gap-2">
          {images.map((img, idx) => (
            <button
              key={img.image_id}
              type="button"
              onClick={() => goTo(idx)}
              className={`h-12 w-12 overflow-hidden rounded-md border-2 transition-all ${
                idx === currentIndex
                  ? "border-white opacity-100"
                  : "border-transparent opacity-50 hover:opacity-75"
              }`}
              aria-label={`${img.image_type} (${idx + 1})`}
            >
              <Image
                src={img.url}
                alt=""
                width={48}
                height={48}
                className="h-full w-full object-cover"
                sizes="48px"
              />
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
