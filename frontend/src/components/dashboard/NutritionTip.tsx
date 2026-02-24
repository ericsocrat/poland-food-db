"use client";

// ─── NutritionTip — cycling daily health tip card ───────────────────────────

import Link from "next/link";
import { useTranslation } from "@/lib/i18n";
import { qaStable } from "@/lib/qa-mode";

/** Total number of tips available in i18n files (dashboard.tip.0 … tip.N-1). */
const TIP_COUNT = 14;

/**
 * Maps each tip index to a relevant Learn page for "Learn more" links.
 * All paths are relative to /learn/.
 */
const TIP_LEARN_LINKS: Record<number, string> = {
  0: "/learn/reading-labels",
  1: "/learn/reading-labels",
  2: "/learn/reading-labels",
  3: "/learn/nova-groups",
  4: "/learn/unhealthiness-score",
  5: "/learn/reading-labels",
  6: "/learn/nutri-score",
  7: "/learn/unhealthiness-score",
  8: "/learn/reading-labels",
  9: "/learn/additives",
  10: "/learn/reading-labels",
  11: "/learn/reading-labels",
  12: "/learn/reading-labels",
  13: "/learn/nutri-score",
};

/**
 * Deterministic tip index based on the current day of the year.
 * Cycles through all tips, so each day shows a different one.
 */
export function tipIndexForToday(): number {
  const now = new Date();
  const start = new Date(now.getFullYear(), 0, 0);
  const dayOfYear = Math.floor(
    (now.getTime() - start.getTime()) / (1000 * 60 * 60 * 24),
  );
  return dayOfYear % TIP_COUNT;
}

export function NutritionTip() {
  const { t } = useTranslation();
  const index = qaStable(tipIndexForToday(), 0);
  const learnHref = TIP_LEARN_LINKS[index];

  return (
    <section
      className="rounded-xl border bg-surface p-4 shadow-sm lg:p-6"
      aria-label={t("dashboard.tipTitle")}
    >
      <div className="flex items-start gap-3">
        <span className="text-2xl" aria-hidden="true">
          💡
        </span>
        <div className="min-w-0">
          <h3 className="text-sm font-semibold text-foreground lg:text-base">
            {t("dashboard.tipTitle")}
          </h3>
          <p className="mt-0.5 text-sm leading-relaxed text-foreground-secondary">
            {t(`dashboard.tip.${index}`)}
          </p>
          {learnHref && (
            <Link
              href={learnHref}
              className="mt-1.5 inline-block text-xs font-medium text-brand hover:text-brand-hover transition-colors"
            >
              {t("dashboard.tipLearnMore")} →
            </Link>
          )}
        </div>
      </div>
    </section>
  );
}
