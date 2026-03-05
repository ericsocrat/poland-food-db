"use client";

import { SkipLink } from "@/components/common/SkipLink";
import { Footer } from "@/components/layout/Footer";
import { Header } from "@/components/layout/Header";
import { Disclaimer } from "@/components/learn/Disclaimer";
import { LearnSidebar } from "@/components/learn/LearnSidebar";
import { SourceCitation } from "@/components/learn/SourceCitation";
import { useTranslation } from "@/lib/i18n";
import { BarChart3 } from "lucide-react";
import Link from "next/link";

// ─── TryVit Score topic page ─────────────────────────────────────────

const penaltyFactors = [
  { key: "factorSatFat", weight: 17 },
  { key: "factorSugars", weight: 17 },
  { key: "factorSalt", weight: 17 },
  { key: "factorCalories", weight: 10 },
  { key: "factorTransFat", weight: 11 },
  { key: "factorAdditives", weight: 7 },
  { key: "factorPrepMethod", weight: 8 },
  { key: "factorControversies", weight: 8 },
  { key: "factorConcern", weight: 5 },
] as const;

const bonusFactor = { key: "factorNutrientDensity", weight: 8 } as const;

export default function TryVitScorePage() {
  const { t } = useTranslation();

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
              {t("learn.tryvitScore.title")}
            </h1>

            <div className="rounded-lg bg-brand-subtle p-4 not-prose">
              <p className="text-sm font-medium text-brand">
                {t("learn.tldr")}
              </p>
              <p className="mt-1 text-sm text-brand">
                {t("learn.tryvitScore.summary")}
              </p>
            </div>

            <h2>{t("learn.tryvitScore.whatIsTitle")}</h2>
            <p>{t("learn.tryvitScore.whatIsText")}</p>

            <h2>{t("learn.tryvitScore.factorsTitle")}</h2>
            <div className="not-prose space-y-2">
              {penaltyFactors.map(({ key, weight }) => (
                <div
                  key={key}
                  className="rounded-lg border bg-surface-subtle p-3"
                >
                  <div className="flex items-start gap-3">
                    <div className="min-w-0 flex-1">
                      <p className="text-sm text-foreground">
                        {t(`learn.tryvitScore.${key}`)}
                      </p>
                    </div>
                    <div className="flex w-28 shrink-0 items-center gap-2">
                      <div className="relative h-2 flex-1 rounded-full bg-gray-200 dark:bg-gray-700">
                        <div
                          className="absolute left-0 top-0 h-full rounded-full bg-brand"
                          style={{ width: `${(weight / 17) * 100}%` }}
                        />
                      </div>
                      <span className="w-8 text-right text-xs font-medium text-muted">
                        {weight}%
                      </span>
                    </div>
                  </div>
                </div>
              ))}
            </div>

            <h3>{t("learn.tryvitScore.bonusTitle")}</h3>
            <div className="not-prose">
              <div className="rounded-lg border border-green-200 bg-green-50 p-3 dark:border-green-800 dark:bg-green-950/20">
                <div className="flex items-start gap-3">
                  <div className="min-w-0 flex-1">
                    <p className="text-sm text-foreground">
                      {t(`learn.tryvitScore.${bonusFactor.key}`)}
                    </p>
                  </div>
                  <div className="flex w-28 shrink-0 items-center gap-2">
                    <div className="relative h-2 flex-1 rounded-full bg-gray-200 dark:bg-gray-700">
                      <div
                        className="absolute left-0 top-0 h-full rounded-full bg-green-500"
                        style={{
                          width: `${(bonusFactor.weight / 17) * 100}%`,
                        }}
                      />
                    </div>
                    <span className="w-8 text-right text-xs font-medium text-green-700 dark:text-green-400">
                      −{bonusFactor.weight}%
                    </span>
                  </div>
                </div>
              </div>
            </div>

            <h2>{t("learn.tryvitScore.bandsTitle")}</h2>
            <div className="not-prose space-y-2">
              {bands.map((key, i) => (
                <div
                  key={key}
                  className={`rounded-lg border p-3 ${bandColors[i]}`}
                >
                  <p className="text-sm font-medium text-foreground">
                    {t(`learn.tryvitScore.${key}`)}
                  </p>
                </div>
              ))}
            </div>

            <h2>{t("learn.tryvitScore.formulaTitle")}</h2>
            <p>{t("learn.tryvitScore.formulaText")}</p>

            <h2>{t("learn.tryvitScore.whyDifferentTitle")}</h2>
            <p>{t("learn.tryvitScore.whyDifferentText")}</p>

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
