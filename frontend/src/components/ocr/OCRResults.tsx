/**
 * OCRResults — Display extracted text with confidence indicator and actions.
 * Issue #55 — Image Search v0
 *
 * Shows:
 * - Extracted text in an editable textarea
 * - Confidence badge (green/yellow/red)
 * - Search, Edit, Retry actions
 * - Privacy confirmation ("Image deleted from memory")
 */

"use client";

import { useState } from "react";
import { Search, RefreshCw, Lock } from "lucide-react";
import { useTranslation } from "@/lib/i18n";
import { Icon } from "@/components/common/Icon";
import { CONFIDENCE } from "@/lib/ocr";
import type { OCRResult } from "@/lib/ocr";

interface OCRResultsProps {
  /** The OCR extraction result. */
  readonly result: OCRResult;
  /** Called when user wants to search with (possibly edited) text. */
  readonly onSearch: (text: string) => void;
  /** Called when user wants to retry capture. */
  readonly onRetry: () => void;
}

function confidenceBand(score: number): {
  label: string;
  className: string;
} {
  if (score >= CONFIDENCE.HIGH)
    return { label: "high", className: "bg-success/10 text-success" };
  if (score >= CONFIDENCE.LOW)
    return { label: "medium", className: "bg-warning/10 text-warning" };
  return { label: "low", className: "bg-error/10 text-error" };
}

export function OCRResults({ result, onSearch, onRetry }: OCRResultsProps) {
  const { t } = useTranslation();
  const [editedText, setEditedText] = useState(result.text);
  const band = confidenceBand(result.confidence);

  const isEmpty = result.text.trim().length === 0;

  return (
    <div className="space-y-4">
      {/* Header with confidence */}
      <div className="flex items-center justify-between">
        <h3 className="text-sm font-semibold text-foreground">
          {t("imageSearch.results.title")}
        </h3>
        <span
          className={`rounded-full px-2.5 py-0.5 text-xs font-medium ${band.className}`}
          data-testid="confidence-badge"
        >
          {t("imageSearch.results.confidence", {
            score: Math.round(result.confidence),
          })}
        </span>
      </div>

      {/* Low confidence warning */}
      {result.confidence < CONFIDENCE.LOW && (
        <p className="text-xs text-warning" role="alert" data-testid="low-confidence-warning">
          {t("imageSearch.results.lowConfidence")}
        </p>
      )}

      {/* Empty text warning */}
      {isEmpty && (
        <p className="text-xs text-error" role="alert" data-testid="empty-text-warning">
          {t("imageSearch.results.noText")}
        </p>
      )}

      {/* Editable extracted text */}
      <textarea
        value={editedText}
        onChange={(e) => setEditedText(e.target.value)}
        rows={5}
        className="w-full rounded-lg border border-border bg-surface-muted p-3 text-sm text-foreground focus:border-brand focus:outline-none focus:ring-1 focus:ring-brand"
        placeholder={t("imageSearch.results.placeholder")}
        data-testid="ocr-text"
      />

      {/* Actions */}
      <div className="flex flex-wrap gap-2">
        <button
          type="button"
          onClick={() => onSearch(editedText)}
          disabled={editedText.trim().length === 0}
          className="btn-primary flex items-center gap-2 px-4 py-2 text-sm"
          data-testid="search-btn"
        >
          <Icon icon={Search} size="sm" />
          {t("imageSearch.results.search")}
        </button>
        <button
          type="button"
          onClick={onRetry}
          className="btn-secondary flex items-center gap-2 px-4 py-2 text-sm"
          data-testid="retry-btn"
        >
          <Icon icon={RefreshCw} size="sm" />
          {t("imageSearch.results.retry")}
        </button>
      </div>

      {/* Privacy confirmation */}
      <p className="flex items-center gap-1.5 text-xs text-foreground-secondary">
        <Icon icon={Lock} size="sm" className="text-brand" />
        {t("imageSearch.results.imageDeleted")}
      </p>
    </div>
  );
}
