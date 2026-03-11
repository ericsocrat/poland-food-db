"use client";

// ─── CrossCountryLinks — Show linked products in other countries ────────────
// Issue #605: Cross-country product linking via EAN matching for PL↔DE

import { CountryChip } from "@/components/common/CountryChip";
import { useCrossCountryLinks } from "@/hooks/use-cross-country-links";
import { SCORE_5BAND_DISPLAY, scoreColorFromScore } from "@/lib/constants";
import { useTranslation } from "@/lib/i18n";
import type { CrossCountryLink } from "@/lib/types";
import { ArrowRight, Globe } from "lucide-react";
import Link from "next/link";

// ─── Link type label mapping ────────────────────────────────────────────────

const LINK_TYPE_LABELS: Record<CrossCountryLink["link_type"], string> = {
  identical: "crossCountryLinks.typeIdentical",
  equivalent: "crossCountryLinks.typeEquivalent",
  variant: "crossCountryLinks.typeVariant",
  related: "crossCountryLinks.typeRelated",
};

// ─── Confidence badge config ────────────────────────────────────────────────

const CONFIDENCE_STYLES: Record<CrossCountryLink["confidence"], string> = {
  verified: "bg-score-green/10 text-score-green-text",
  ean_match: "bg-score-green/10 text-score-green-text",
  manual: "bg-score-yellow/10 text-score-yellow-text",
  brand_match: "bg-score-yellow/10 text-score-yellow-text",
};

// ─── Single Link Card ───────────────────────────────────────────────────────

function LinkCard({ link }: Readonly<{ link: CrossCountryLink }>) {
  const { t } = useTranslation();
  const band = scoreColorFromScore(link.product.unhealthiness_score);
  const display = SCORE_5BAND_DISPLAY[band];

  return (
    <Link
      href={`/app/product/${link.product.product_id}`}
      className="group flex items-center gap-3 rounded-lg border border-border bg-surface-subtle p-3 transition-colors hover:bg-surface-muted"
      data-testid="cross-country-link-card"
    >
      {/* Country flag */}
      <CountryChip country={link.product.country} size="sm" />

      {/* Product info */}
      <div className="min-w-0 flex-1">
        <p className="truncate text-sm font-medium text-foreground">
          {link.product.product_name}
        </p>
        <p className="truncate text-xs text-foreground-secondary">
          {link.product.brand} · {link.product.category}
        </p>
      </div>

      {/* Score badge */}
      <span
        className={`inline-flex min-w-8 items-center justify-center rounded-full px-2 py-0.5 text-xs font-semibold ${display.bg} ${display.color}`}
      >
        {link.product.unhealthiness_score}
      </span>

      {/* Link type badge */}
      <span
        className={`rounded-full px-2 py-0.5 text-xs font-medium ${CONFIDENCE_STYLES[link.confidence]}`}
      >
        {t(LINK_TYPE_LABELS[link.link_type])}
      </span>

      <ArrowRight
        size={14}
        className="shrink-0 text-foreground-secondary transition-transform group-hover:translate-x-0.5"
        aria-hidden="true"
      />
    </Link>
  );
}

// ─── Main Component ─────────────────────────────────────────────────────────

export function CrossCountryLinks({
  productId,
}: Readonly<{ productId: number }>) {
  const { t } = useTranslation();
  const { data: links, isLoading } = useCrossCountryLinks(productId);

  // Don't render skeleton — section is hidden when empty
  if (isLoading) return null;

  // No links — don't render the section at all
  if (!links || links.length === 0) return null;

  return (
    <section
      className="card"
      data-testid="cross-country-links-section"
      aria-labelledby="cross-country-links-heading"
    >
      <div className="flex items-center gap-2">
        <Globe size={20} aria-hidden="true" />
        <h2
          id="cross-country-links-heading"
          className="text-sm font-semibold text-foreground"
        >
          {t("crossCountryLinks.title")}
        </h2>
        <span className="rounded-full bg-surface-muted px-1.5 py-0.5 text-xs font-medium text-foreground-secondary">
          {links.length}
        </span>
      </div>

      <div className="mt-3 flex flex-col gap-2">
        {links.map((link) => (
          <LinkCard key={link.link_id} link={link} />
        ))}
      </div>
    </section>
  );
}
