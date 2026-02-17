// ─── ShareButton — native share / clipboard fallback ──────────────────────
"use client";

import { useState, useCallback } from "react";
import { useTranslation } from "@/lib/i18n";

interface ShareButtonProps {
  readonly productName: string;
  readonly score: number;
  readonly productId: number;
}

export function ShareButton({
  productName,
  score,
  productId,
}: ShareButtonProps) {
  const { t } = useTranslation();
  const [copied, setCopied] = useState(false);

  const handleShare = useCallback(async () => {
    const shareUrl = `${globalThis.location.origin}/app/product/${productId}`;
    const shareTitle = `${productName} — Health Score: ${score}/100`;
    const shareText = `Check out ${productName} on FoodDB — Health Score: ${score}/100`;

    if (typeof navigator.share === "function") {
      try {
        await navigator.share({
          title: shareTitle,
          text: shareText,
          url: shareUrl,
        });
        return; // success — native dialog handled it
      } catch (err) {
        // User cancelled — still fall through to clipboard
        if ((err as Error).name === "AbortError") return;
      }
    }

    // Fallback: copy link to clipboard
    try {
      await navigator.clipboard.writeText(shareUrl);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch {
      // Clipboard API unavailable (e.g. insecure context)
    }
  }, [productName, score, productId]);

  return (
    <button
      type="button"
      onClick={handleShare}
      className="touch-target flex items-center gap-1.5 rounded-lg border px-3 py-2 text-sm text-foreground-secondary transition hover:bg-surface-subtle"
      aria-label={t("product.shareProduct")}
    >
      <svg
        className="h-4 w-4"
        fill="none"
        viewBox="0 0 24 24"
        strokeWidth={1.5}
        stroke="currentColor"
        aria-hidden="true"
      >
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          d="M7.217 10.907a2.25 2.25 0 1 0 0 2.186m0-2.186c.18.324.283.696.283 1.093s-.103.77-.283 1.093m0-2.186 9.566-5.314m-9.566 7.5 9.566 5.314m0 0a2.25 2.25 0 1 0 3.935 2.186 2.25 2.25 0 0 0-3.935-2.186Zm0-12.814a2.25 2.25 0 1 0 3.933-2.185 2.25 2.25 0 0 0-3.933 2.185Z"
        />
      </svg>
      {copied ? t("product.shareCopied") : t("product.share")}
    </button>
  );
}
