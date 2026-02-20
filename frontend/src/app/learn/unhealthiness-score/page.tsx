"use client";

import Link from "next/link";
import { Header } from "@/components/layout/Header";
import { SkipLink } from "@/components/common/SkipLink";
import { Footer } from "@/components/layout/Footer";
import { LearnSidebar } from "@/components/learn/LearnSidebar";
import { Disclaimer } from "@/components/learn/Disclaimer";
import { SourceCitation } from "@/components/learn/SourceCitation";
import { useTranslation } from "@/lib/i18n";
import { BarChart3 } from "lucide-react";

// ─── Unhealthiness Score topic page ─────────────────────────────────────────

export default function UnhealthinessScorePage() {
  const { t } = useTranslation();

  const factors = [
    "factorSatFat",
    "factorSugars",
    "factorSalt",
    "factorCalories",
    "factorTransFat",
    "factorAdditives",
    "factorPrepMethod",
    "factorControversies",
    "factorConcern",
  ] as const;

  const bands = ["band1", "band2", "band3", "band4", "band5"] as const;
  const bandColors = [
    "bg-green-50 border-green-200 dark:bg-green-950/20 dark:border-green-800",
    "bg-lime-50 border-lime-200 dark:bg-lime-950/20 dark:border-lime-800",
    "bg-amber-50 border-amber-200 dark:bg-amber-950/20 dark:border-amber-800",
    "bg-orange-50 border-orange-200 dark:bg-orange-950/20 dark:border-orange-800",
    "bg-red-50 border-red-200 dark:bg-red-950/20 dark:border-red-800",
  ];

  return (
    <div className="flex min-h-screen flex-col">
      <SkipLink />
      <Header />

      <div className="mx-auto flex w-full max-w-5xl flex-1 gap-8 px-4 py-8">
        <LearnSidebar className="w-56 shrink-0" />

        <main id="main-content" className="min-w-0 flex-1">
          <Link
            href="/learn"
            className="mb-4 inline-block text-sm text-brand hover:text-brand-hover md:hidden"
          >
            {t("learn.backToHub")}
          </Link>

          <article className="prose max-w-none">
            <h1 className="flex items-center gap-2">
              <BarChart3
                size={28}
                aria-hidden="true"
                className="inline-block"
              />{" "}
              {t("learn.unhealthinessScore.title")}
            </h1>

            <div className="rounded-lg bg-brand-subtle p-4 not-prose">
              <p className="text-sm font-medium text-brand">
                {t("learn.tldr")}
              </p>
              <p className="mt-1 text-sm text-brand">
                {t("learn.unhealthinessScore.summary")}
              </p>
            </div>

            <h2>{t("learn.unhealthinessScore.whatIsTitle")}</h2>
            <p>{t("learn.unhealthinessScore.whatIsText")}</p>

            <h2>{t("learn.unhealthinessScore.factorsTitle")}</h2>
            <div className="not-prose space-y-2">
              {factors.map((key) => (
                <div
                  key={key}
                  className="rounded-lg border bg-surface-subtle p-3"
                >
                  <p className="text-sm text-foreground">
                    {t(`learn.unhealthinessScore.${key}`)}
                  </p>
                </div>
              ))}
            </div>

            <h2>{t("learn.unhealthinessScore.bandsTitle")}</h2>
            <div className="not-prose space-y-2">
              {bands.map((key, i) => (
                <div
                  key={key}
                  className={`rounded-lg border p-3 ${bandColors[i]}`}
                >
                  <p className="text-sm font-medium text-foreground">
                    {t(`learn.unhealthinessScore.${key}`)}
                  </p>
                </div>
              ))}
            </div>

            <h2>{t("learn.unhealthinessScore.formulaTitle")}</h2>
            <p>{t("learn.unhealthinessScore.formulaText")}</p>

            <h2>{t("learn.unhealthinessScore.whyDifferentTitle")}</h2>
            <p>{t("learn.unhealthinessScore.whyDifferentText")}</p>

            <Disclaimer className="mt-8" />

            <h2>{t("learn.sourcesTitle")}</h2>
            <div className="not-prose space-y-2">
              <SourceCitation
                author="WHO"
                title="Guideline: Sugars intake for adults and children"
                year={2015}
                url="https://www.who.int/publications/i/item/9789241549028"
              />
              <SourceCitation
                author="WHO"
                title="Guideline: Sodium intake for adults and children"
                year={2023}
                url="https://www.who.int/publications/i/item/9789240073784"
              />
              <SourceCitation
                author="EFSA"
                title="Scientific opinion on dietary reference values for fats"
                year={2010}
              />
              <SourceCitation
                author="EU"
                title="Regulation 2019/649 on trans fatty acids"
                year={2019}
              />
            </div>
          </article>
        </main>
      </div>

      <Footer />
    </div>
  );
}
