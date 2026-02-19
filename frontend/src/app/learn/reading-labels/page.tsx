"use client";

import Link from "next/link";
import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { LearnSidebar } from "@/components/learn/LearnSidebar";
import { Disclaimer } from "@/components/learn/Disclaimer";
import { SourceCitation } from "@/components/learn/SourceCitation";
import { useTranslation } from "@/lib/i18n";
import { Tag } from "lucide-react";

// ─── Reading Labels topic page ─────────────────────────────────────────────

export default function ReadingLabelsPage() {
  const { t } = useTranslation();

  const mandatoryItems = Array.from(
    { length: 9 },
    (_, i) => `mandatoryItem${i + 1}`,
  );
  const tips = Array.from({ length: 5 }, (_, i) => `tip${i + 1}`);

  return (
    <div className="flex min-h-screen flex-col">
      <Header />

      <div className="mx-auto flex w-full max-w-5xl flex-1 gap-8 px-4 py-8">
        <LearnSidebar className="w-56 shrink-0" />

        <main className="min-w-0 flex-1">
          <Link
            href="/learn"
            className="mb-4 inline-block text-sm text-brand hover:text-brand-hover md:hidden"
          >
            {t("learn.backToHub")}
          </Link>

          <article className="prose max-w-none">
            <h1 className="flex items-center gap-2">
              <Tag size={28} aria-hidden="true" className="inline-block" />{" "}
              {t("learn.readingLabels.title")}
            </h1>

            <div className="rounded-lg bg-brand-subtle p-4 not-prose">
              <p className="text-sm font-medium text-brand">
                {t("learn.tldr")}
              </p>
              <p className="mt-1 text-sm text-brand">
                {t("learn.readingLabels.summary")}
              </p>
            </div>

            <h2>{t("learn.readingLabels.nutritionTableTitle")}</h2>
            <p>{t("learn.readingLabels.nutritionTableText")}</p>

            <h2>{t("learn.readingLabels.per100gTitle")}</h2>
            <p>{t("learn.readingLabels.per100gText")}</p>

            <h2>{t("learn.readingLabels.mandatoryTitle")}</h2>
            <ol>
              {mandatoryItems.map((key) => (
                <li key={key}>{t(`learn.readingLabels.${key}`)}</li>
              ))}
            </ol>

            <h2>{t("learn.readingLabels.tipsTitle")}</h2>
            <ul>
              {tips.map((key) => (
                <li key={key}>{t(`learn.readingLabels.${key}`)}</li>
              ))}
            </ul>

            <Disclaimer className="mt-8" />

            <h2>{t("learn.sourcesTitle")}</h2>
            <div className="not-prose space-y-2">
              <SourceCitation
                author="EU"
                title="Regulation (EU) No 1169/2011 on the provision of food information to consumers"
                year={2011}
                url="https://eur-lex.europa.eu/legal-content/EN/ALL/?uri=CELEX:32011R1169"
              />
              <SourceCitation
                author="EU"
                title="Regulation (EU) No 1169/2011, Annex XIII — Reference intakes"
                year={2011}
              />
            </div>
          </article>
        </main>
      </div>

      <Footer />
    </div>
  );
}
