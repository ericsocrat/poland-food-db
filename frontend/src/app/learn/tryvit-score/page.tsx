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
    "bg-success-bg border-success-border",
    "bg-band-good-bg border-band-good-border",
    "bg-warning-bg border-warning-border",
    "bg-band-caution-bg border-band-caution-border",
    "bg-error-bg border-error-border",
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
                      <div className="relative h-2 flex-1 rounded-full bg-[var(--color-border)]">
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
              <div className="rounded-lg border border-success-border bg-success-bg p-3">
                <div className="flex items-start gap-3">
                  <div className="min-w-0 flex-1">
                    <p className="text-sm text-foreground">
                      {t(`learn.tryvitScore.${bonusFactor.key}`)}
                    </p>
                  </div>
                  <div className="flex w-28 shrink-0 items-center gap-2">
                    <div className="relative h-2 flex-1 rounded-full bg-[var(--color-border)]">
                      <div
                        className="absolute left-0 top-0 h-full rounded-full bg-success"
                        style={{
                          width: `${(bonusFactor.weight / 17) * 100}%`,
                        }}
                      />
                    </div>
                    <span className="w-8 text-right text-xs font-medium text-success-text">
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
