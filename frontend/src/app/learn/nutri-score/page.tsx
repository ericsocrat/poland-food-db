"use client";

import Link from "next/link";
import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { LearnSidebar } from "@/components/learn/LearnSidebar";
import { Disclaimer } from "@/components/learn/Disclaimer";
import { SourceCitation } from "@/components/learn/SourceCitation";
import { useTranslation } from "@/lib/i18n";

// ─── Nutri-Score topic page ─────────────────────────────────────────────────

export default function NutriScorePage() {
  const { t } = useTranslation();

  return (
    <div className="flex min-h-screen flex-col">
      <Header />

      <div className="mx-auto flex w-full max-w-5xl flex-1 gap-8 px-4 py-8">
        <LearnSidebar className="w-56 shrink-0" />

        <main className="min-w-0 flex-1">
          {/* Mobile back link */}
          <Link
            href="/learn"
            className="mb-4 inline-block text-sm text-brand-600 hover:text-brand-700 dark:text-brand-400 md:hidden"
          >
            {t("learn.backToHub")}
          </Link>

          <article className="prose max-w-none">
            <h1>🅰️ {t("learn.nutriScore.title")}</h1>

            {/* TL;DR */}
            <div className="rounded-lg bg-brand-50 p-4 not-prose dark:bg-brand-950/30">
              <p className="text-sm font-medium text-brand-800 dark:text-brand-300">
                {t("learn.tldr")}
              </p>
              <p className="mt-1 text-sm text-brand-700 dark:text-brand-400">
                {t("learn.nutriScore.summary")}
              </p>
            </div>

            <h2>{t("learn.nutriScore.whatIsTitle")}</h2>
            <p>{t("learn.nutriScore.whatIsText")}</p>

            <h2>{t("learn.nutriScore.howItWorksTitle")}</h2>
            <p>{t("learn.nutriScore.howItWorksText")}</p>

            <div className="not-prose grid gap-3 sm:grid-cols-2">
              <div className="rounded-lg border bg-red-50 p-4 dark:bg-red-950/20">
                <p className="text-sm font-medium text-red-800 dark:text-red-300">
                  {t("learn.nutriScore.negativeLabel")}
                </p>
                <p className="mt-1 text-sm text-red-700 dark:text-red-400">
                  {t("learn.nutriScore.negativeItems")}
                </p>
              </div>
              <div className="rounded-lg border bg-green-50 p-4 dark:bg-green-950/20">
                <p className="text-sm font-medium text-green-800 dark:text-green-300">
                  {t("learn.nutriScore.positiveLabel")}
                </p>
                <p className="mt-1 text-sm text-green-700 dark:text-green-400">
                  {t("learn.nutriScore.positiveItems")}
                </p>
              </div>
            </div>

            <h2>{t("learn.nutriScore.gradesTitle")}</h2>
            <ul>
              <li><strong>{t("learn.nutriScore.gradeA")}</strong></li>
              <li><strong>{t("learn.nutriScore.gradeB")}</strong></li>
              <li><strong>{t("learn.nutriScore.gradeC")}</strong></li>
              <li><strong>{t("learn.nutriScore.gradeD")}</strong></li>
              <li><strong>{t("learn.nutriScore.gradeE")}</strong></li>
            </ul>

            <h2>{t("learn.nutriScore.limitationsTitle")}</h2>
            <p>{t("learn.nutriScore.limitationsText")}</p>

            <h2>{t("learn.nutriScore.unknownTitle")}</h2>
            <p>{t("learn.nutriScore.unknownText")}</p>

            <h2>{t("learn.nutriScore.ourApproachTitle")}</h2>
            <p>{t("learn.nutriScore.ourApproachText")}</p>

            <Disclaimer className="mt-8" />

            {/* Sources */}
            <h2>{t("learn.sourcesTitle")}</h2>
            <div className="not-prose space-y-2">
              <SourceCitation
                author="Santé Publique France"
                title="Nutri-Score algorithm update 2024"
                year={2024}
                url="https://www.santepubliquefrance.fr/en/nutri-score"
              />
              <SourceCitation
                author="EFSA"
                title="Scientific opinion on dietary reference values for fats"
                year={2010}
                url="https://www.efsa.europa.eu/en/efsajournal/pub/1461"
              />
            </div>
          </article>
        </main>
      </div>

      <Footer />
    </div>
  );
}
