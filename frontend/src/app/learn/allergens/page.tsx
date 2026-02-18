"use client";

import Link from "next/link";
import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { LearnSidebar } from "@/components/learn/LearnSidebar";
import { Disclaimer } from "@/components/learn/Disclaimer";
import { SourceCitation } from "@/components/learn/SourceCitation";
import { useTranslation } from "@/lib/i18n";
import { AlertTriangle } from "lucide-react";

// ─── Allergens topic page ──────────────────────────────────────────────────

export default function AllergensPage() {
  const { t } = useTranslation();

  const allergenKeys = Array.from({ length: 14 }, (_, i) => `allergen${i + 1}`);

  return (
    <div className="flex min-h-screen flex-col">
      <Header />

      <div className="mx-auto flex w-full max-w-5xl flex-1 gap-8 px-4 py-8">
        <LearnSidebar className="w-56 shrink-0" />

        <main className="min-w-0 flex-1">
          <Link
            href="/learn"
            className="mb-4 inline-block text-sm text-brand-600 hover:text-brand-700 dark:text-brand-400 md:hidden"
          >
            {t("learn.backToHub")}
          </Link>

          <article className="prose max-w-none">
            <h1 className="flex items-center gap-2">
              <AlertTriangle
                size={28}
                aria-hidden="true"
                className="inline-block"
              />{" "}
              {t("learn.allergens.title")}
            </h1>

            <div className="rounded-lg bg-brand-50 p-4 not-prose dark:bg-brand-950/30">
              <p className="text-sm font-medium text-brand-800 dark:text-brand-300">
                {t("learn.tldr")}
              </p>
              <p className="mt-1 text-sm text-brand-700 dark:text-brand-400">
                {t("learn.allergens.summary")}
              </p>
            </div>

            <h2>{t("learn.allergens.eu14Title")}</h2>
            <p>{t("learn.allergens.eu14Text")}</p>

            <ol>
              {allergenKeys.map((key) => (
                <li key={key}>{t(`learn.allergens.${key}`)}</li>
              ))}
            </ol>

            <h2>{t("learn.allergens.containsVsTracesTitle")}</h2>
            <p>{t("learn.allergens.containsVsTracesText")}</p>

            <h2>{t("learn.allergens.polishLabelsTitle")}</h2>
            <p>{t("learn.allergens.polishLabelsText")}</p>

            <h2>{t("learn.allergens.inFoodDBTitle")}</h2>
            <p>{t("learn.allergens.inFoodDBText")}</p>

            <Disclaimer className="mt-8" />

            <h2>{t("learn.sourcesTitle")}</h2>
            <div className="not-prose space-y-2">
              <SourceCitation
                author="EU"
                title="Regulation (EU) No 1169/2011 on the provision of food information to consumers"
                year={2011}
                url="https://eur-lex.europa.eu/legal-content/EN/ALL/?uri=CELEX:32011R1169"
              />
            </div>
          </article>
        </main>
      </div>

      <Footer />
    </div>
  );
}
