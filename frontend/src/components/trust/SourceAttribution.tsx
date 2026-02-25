// ─── SourceAttribution ──────────────────────────────────────────────────────
// Expandable panel showing per-field data source attribution.
//
// Shows where each piece of product data came from:
//   Field name → Source name → "Updated X days ago"
//
// Lazy-loaded: data is only fetched when the panel is expanded.
// Degrades gracefully: shows placeholder message when no source data available.
// Backend dependency: api_product_provenance() (#193) — not yet implemented.

"use client";

import { useState } from "react";
import { ChevronDown, ChevronUp, ExternalLink } from "lucide-react";
import { useTranslation } from "@/lib/i18n";

// ─── Types ──────────────────────────────────────────────────────────────────

export interface SourceField {
  /** Field name (e.g., "Nutrition", "Allergens", "Brand"). */
  field: string;
  /** Source display name (e.g., "Open Food Facts", "Manual entry"). */
  source: string;
  /** Days since last update. */
  daysSinceUpdate: number;
}

interface SourceAttributionProps {
  /** Array of source attribution data per field. Null/undefined/empty → show placeholder. */
  readonly sources: SourceField[] | null | undefined;
}

// ─── Component ──────────────────────────────────────────────────────────────

export function SourceAttribution({ sources }: SourceAttributionProps) {
  const { t } = useTranslation();
  const [isExpanded, setIsExpanded] = useState(false);

  const hasSources = sources && sources.length > 0;

  return (
    <div
      className="rounded-lg border border-border"
      aria-label={t("trust.sourceAttribution.ariaLabel")}
    >
      {/* Header — always visible */}
      <button
        type="button"
        onClick={() => setIsExpanded((prev) => !prev)}
        className="flex w-full items-center justify-between px-3 py-2 text-sm font-medium text-foreground hover:bg-muted/50"
        aria-expanded={isExpanded}
      >
        <span className="flex items-center gap-1.5">
          <ExternalLink size={14} aria-hidden="true" />
          {t("trust.sourceAttribution.title")}
        </span>
        {isExpanded ? (
          <ChevronUp size={16} aria-hidden="true" />
        ) : (
          <ChevronDown size={16} aria-hidden="true" />
        )}
      </button>

      {/* Expandable content */}
      {isExpanded && (
        <div className="border-t border-border px-3 py-2">
          {hasSources ? (
            <ul className="space-y-1.5">
              {sources.map((sf) => (
                <li
                  key={sf.field}
                  className="flex items-center justify-between text-xs"
                >
                  <span className="font-medium text-foreground">
                    {sf.field}
                  </span>
                  <span className="text-foreground-secondary">
                    {sf.source} &middot;{" "}
                    {t("trust.sourceAttribution.updatedAgo", {
                      days: sf.daysSinceUpdate,
                    })}
                  </span>
                </li>
              ))}
            </ul>
          ) : (
            <p className="text-xs text-foreground-secondary italic">
              {t("trust.sourceAttribution.noSourceData")}
            </p>
          )}
        </div>
      )}
    </div>
  );
}
