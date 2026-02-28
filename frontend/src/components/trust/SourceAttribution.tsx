// ─── SourceAttribution ──────────────────────────────────────────────────────
// Expandable panel showing per-field data source attribution with branded icons.
//
// Shows where each piece of product data came from:
//   Field name → Source icon + name → "Updated X days ago" → optional link
//
// Known source types have branded icons (OFF logo, manual entry, scan, CSV).
// Lazy-loaded: data is only fetched when the panel is expanded.
// Degrades gracefully: shows placeholder message when no source data available.
// Backend dependency: api_product_provenance() (#193) — not yet implemented.

"use client";

import { useState } from "react";
import {
  ChevronDown,
  ChevronUp,
  ExternalLink,
  Database,
  PenTool,
  ScanLine,
  FileSpreadsheet,
  HelpCircle,
} from "lucide-react";
import { useTranslation } from "@/lib/i18n";

// ─── Types ──────────────────────────────────────────────────────────────────

export interface SourceField {
  /** Field name (e.g., "Nutrition", "Allergens", "Brand"). */
  field: string;
  /** Source display name (e.g., "Open Food Facts", "Manual entry"). */
  source: string;
  /** Days since last update. */
  daysSinceUpdate: number;
  /** Optional URL to the source (e.g., OFF product page). */
  url?: string;
}

interface SourceAttributionProps {
  /** Array of source attribution data per field. Null/undefined/empty → show placeholder. */
  readonly sources: SourceField[] | null | undefined;
}

// ─── Source Icon Mapping ────────────────────────────────────────────────────
// Maps known source names to lucide icons. Unknown sources get HelpCircle.

const SOURCE_ICONS: Record<string, typeof Database> = {
  "Open Food Facts": Database,
  "Manual entry": PenTool,
  "Barcode scan": ScanLine,
  "CSV import": FileSpreadsheet,
};

function getSourceIcon(sourceName: string) {
  return SOURCE_ICONS[sourceName] ?? HelpCircle;
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
              {sources.map((sf) => {
                const SourceIcon = getSourceIcon(sf.source);
                return (
                  <li
                    key={sf.field}
                    className="flex items-center justify-between text-xs"
                  >
                    <span className="font-medium text-foreground">
                      {sf.field}
                    </span>
                    <span className="inline-flex items-center gap-1 text-foreground-secondary">
                      <SourceIcon
                        size={12}
                        aria-hidden="true"
                        data-testid={`source-icon-${sf.field}`}
                      />
                      {sf.url ? (
                        <a
                          href={sf.url}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="underline hover:text-foreground"
                          data-testid={`source-link-${sf.field}`}
                        >
                          {sf.source}
                        </a>
                      ) : (
                        <span data-testid={`source-name-${sf.field}`}>
                          {sf.source}
                        </span>
                      )}
                      <span>&middot;</span>
                      {t("trust.sourceAttribution.updatedAgo", {
                        days: sf.daysSinceUpdate,
                      })}
                    </span>
                  </li>
                );
              })}
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
