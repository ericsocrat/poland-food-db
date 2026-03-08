"use client";

// ─── ShareComparison — save & share toolbar for comparison view ─────────────

import { Button } from "@/components/common/Button";
import { useSaveComparison } from "@/hooks/use-compare";
import { useTranslation } from "@/lib/i18n";
import { Check, ClipboardCopy, Link2, Save } from "lucide-react";
import { useState } from "react";

interface ShareComparisonProps {
  productIds: number[];
  /** If already saved, show the existing share URL */
  existingShareToken?: string;
}

export function ShareComparison({
  productIds,
  existingShareToken,
}: Readonly<ShareComparisonProps>) {
  const { t } = useTranslation();
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
      <Button
        variant="secondary"
        onClick={handleCopyUrl}
      >
        {copied && !shareToken ? (
          <span className="inline-flex items-center gap-1"><Check size={14} aria-hidden="true" /> Copied!</span>
        ) : (
          <span className="inline-flex items-center gap-1">
            <ClipboardCopy size={14} aria-hidden="true" />{" "}
            {t("compare.copyUrl")}
          </span>
        )}
      </Button>

      {/* Save comparison */}
      {!shareToken && (
        <Button
          onClick={handleSave}
          disabled={isPending}
        >
          {isPending ? (
            `${t("common.saving")}`
          ) : (
            <>
              <Save size={14} aria-hidden="true" className="inline" />{" "}
              {t("compare.saveComparison")}
            </>
          )}
        </Button>
      )}

      {/* Share link (after saving) */}
      {shareToken && (
        <Button
          onClick={handleCopyShareLink}
        >
          {copied ? (
            <span className="inline-flex items-center gap-1"><Check size={14} aria-hidden="true" /> Copied!</span>
          ) : (
            <>
              <Link2 size={14} aria-hidden="true" className="inline" />{" "}
              {t("compare.copyShareLink")}
            </>
          )}
        </Button>
      )}
    </div>
  );
}
