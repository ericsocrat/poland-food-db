"use client";

// ─── ShareComparison — save & share toolbar for comparison view ─────────────

import { useState } from "react";
import { useSaveComparison } from "@/hooks/use-compare";

interface ShareComparisonProps {
  productIds: number[];
  /** If already saved, show the existing share URL */
  existingShareToken?: string;
}

export function ShareComparison({
  productIds,
  existingShareToken,
}: Readonly<ShareComparisonProps>) {
  const [copied, setCopied] = useState(false);
  const [shareToken, setShareToken] = useState(existingShareToken ?? "");
  const { mutate: save, isPending } = useSaveComparison();

  const origin =
    typeof globalThis !== "undefined" && globalThis.location
      ? globalThis.location.origin
      : "";
  const shareUrl = shareToken ? `${origin}/compare/shared/${shareToken}` : "";

  function handleCopyUrl() {
    // Copy the current URL params version (no auth needed)
    const url = `${globalThis.location.origin}/app/compare?ids=${productIds.join(",")}`;
    navigator.clipboard.writeText(url).then(() => {
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    });
  }

  function handleSave() {
    save(
      { productIds },
      {
        onSuccess: (data) => {
          setShareToken(data.share_token);
        },
      },
    );
  }

  function handleCopyShareLink() {
    navigator.clipboard.writeText(shareUrl).then(() => {
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    });
  }

  return (
    <div className="flex flex-wrap items-center gap-2">
      {/* Copy URL button */}
      <button
        type="button"
        onClick={handleCopyUrl}
        className="btn-secondary text-sm"
      >
        {copied && !shareToken ? "✓ Copied!" : "📋 Copy URL"}
      </button>

      {/* Save comparison */}
      {!shareToken && (
        <button
          type="button"
          onClick={handleSave}
          disabled={isPending}
          className="btn-primary text-sm disabled:opacity-50"
        >
          {isPending ? "Saving…" : "💾 Save Comparison"}
        </button>
      )}

      {/* Share link (after saving) */}
      {shareToken && (
        <button
          type="button"
          onClick={handleCopyShareLink}
          className="btn-primary text-sm"
        >
          {copied ? "✓ Copied!" : "🔗 Copy Share Link"}
        </button>
      )}
    </div>
  );
}
