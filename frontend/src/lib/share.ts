/**
 * Web Share API wrapper with clipboard fallback.
 *
 * Uses navigator.share() on supporting browsers (mobile Safari, Android Chrome),
 * falls back to navigator.clipboard.writeText() on desktop, then to a manual
 * copy fallback if clipboard API is also unavailable.
 */

import { showToast } from "@/lib/toast";

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/** Check if an error is an AbortError (user dismissed share sheet). */
function isAbortError(err: unknown): boolean {
  return (
    typeof err === "object" &&
    err !== null &&
    "name" in err &&
    (err as { name: string }).name === "AbortError"
  );
}

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export interface ShareableProduct {
  product_name: string;
  brand: string;
  unhealthiness_score: number;
  product_id: number;
}

// ---------------------------------------------------------------------------
// Share functions
// ---------------------------------------------------------------------------

/**
 * Share a single product via Web Share API or clipboard fallback.
 */
export async function shareProduct(product: ShareableProduct): Promise<void> {
  const shareData: ShareData = {
    title: `${product.product_name} — Health Score ${product.unhealthiness_score}/100`,
    text: `Check out ${product.product_name} by ${product.brand} on Poland Food DB`,
    url: `${globalThis.location.origin}/app/product/${product.product_id}`,
  };

  if (typeof navigator.share === "function") {
    try {
      if (typeof navigator.canShare === "function" && !navigator.canShare(shareData)) {
        await copyToClipboard(shareData.url!);
        return;
      }
      await navigator.share(shareData);
      return;
    } catch (err: unknown) {
      // AbortError means user dismissed the share sheet — not an error
      if (isAbortError(err)) return;
      // Fall through to clipboard
    }
  }

  await copyToClipboard(shareData.url!);
}

/**
 * Share a URL (e.g. list or comparison link) via Web Share API or clipboard.
 */
export async function shareUrl(url: string, title?: string): Promise<void> {
  const shareData: ShareData = { title, url };

  if (typeof navigator.share === "function") {
    try {
      await navigator.share(shareData);
      return;
    } catch (err: unknown) {
      if (isAbortError(err)) return;
    }
  }

  await copyToClipboard(url);
}

/**
 * Copy text to clipboard with toast feedback.
 */
async function copyToClipboard(text: string): Promise<void> {
  try {
    await navigator.clipboard.writeText(text);
    showToast({ type: "success", messageKey: "export.linkCopied" });
  } catch {
    // Final fallback: prompt user to copy manually
    showToast({ type: "info", message: text });
  }
}
