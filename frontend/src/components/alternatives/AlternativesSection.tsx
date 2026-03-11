// ─── AlternativesSection — progressive-disclosure alternatives list ─────────
// Shows top 3 alternatives by default with "Show more" for the rest.
// Used both in the quick summary preview and the full alternatives tab.

"use client";

import { AlternativeProductCard } from "@/components/alternatives/AlternativeProductCard";
import { useTranslation } from "@/lib/i18n";
import type { ProfileAlternative } from "@/lib/types";
import { ChevronDown, ChevronUp } from "lucide-react";
import { useState } from "react";

interface AlternativesSectionProps {
  alternatives: ProfileAlternative[];
  /** Current product's unhealthiness score for comparison bars */
  currentScore: number;
  /** How many to show before "Show more" (default: 3) */
  initialCount?: number;
}

export function AlternativesSection({
  alternatives,
  currentScore,
  initialCount = 3,
}: Readonly<AlternativesSectionProps>) {
  const { t } = useTranslation();
  const [expanded, setExpanded] = useState(false);

  if (alternatives.length === 0) {
    return (
      <p className="py-8 text-center text-sm text-foreground-muted">
        {t("product.noAlternatives")}
      </p>
    );
  }

  const visible = expanded
    ? alternatives
    : alternatives.slice(0, initialCount);
  const hiddenCount = alternatives.length - initialCount;

  return (
    <div className="space-y-3">
      <p className="text-sm text-foreground-secondary">
        {t("product.healthierOptions", { count: alternatives.length })}
      </p>
      {visible.map((alt) => (
        <AlternativeProductCard
          key={alt.product_id}
          alt={alt}
          currentScore={currentScore}
        />
      ))}
      {hiddenCount > 0 && (
        <button
          type="button"
          onClick={() => setExpanded((prev) => !prev)}
          className="flex w-full items-center justify-center gap-1 rounded-lg py-2 text-sm font-medium text-brand hover:bg-surface-subtle"
          data-testid="show-more-alternatives"
        >
          {expanded ? (
            <>
              <ChevronUp className="h-4 w-4" />
              {t("product.showLessAlternatives")}
            </>
          ) : (
            <>
              <ChevronDown className="h-4 w-4" />
              {t("product.showMoreAlternatives", { count: hiddenCount })}
            </>
          )}
        </button>
      )}
    </div>
  );
}
