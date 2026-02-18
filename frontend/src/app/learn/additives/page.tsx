"use client";

import Link from "next/link";
import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { LearnSidebar } from "@/components/learn/LearnSidebar";
import { Disclaimer } from "@/components/learn/Disclaimer";
import { SourceCitation } from "@/components/learn/SourceCitation";
import { useTranslation } from "@/lib/i18n";

// ─── Additives topic page ──────────────────────────────────────────────────

export default function AdditivesPage() {
  const { t } = useTranslation();

  const tiers = ["concernTier0", "concernTier1", "concernTier2", "concernTier3"] as const;
  const tierColors = [
    "bg-green-50 border-green-200 dark:bg-green-950/20 dark:border-green-800",
    "bg-blue-50 border-blue-200 dark:bg-blue-950/20 dark:border-blue-800",
    "bg-amber-50 border-amber-200 dark:bg-amber-950/20 dark:border-amber-800",
    "bg-red-50 border-red-200 dark:bg-red-950/20 dark:border-red-800",
  ];

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
            <h1>🧪 {t("learn.additives.title")}</h1>

            <div className="rounded-lg bg-brand-50 p-4 not-prose dark:bg-brand-950/30">
              <p className="text-sm font-medium text-brand-800 dark:text-brand-300">
                {t("learn.tldr")}
              </p>
              <p className="mt-1 text-sm text-brand-700 dark:text-brand-400">
                {t("learn.additives.summary")}
              </p>
            </div>

            <h2>{t("learn.additives.whatAreTitle")}</h2>
            <p>{t("learn.additives.whatAreText")}</p>

            <h2>{t("learn.additives.notDangerousTitle")}</h2>
            <p>{t("learn.additives.notDangerousText")}</p>

            <h2>{t("learn.additives.concernTiersTitle")}</h2>
            <div className="not-prose space-y-2">
              {tiers.map((key, i) => (
                <div
                  key={key}
                  className={`rounded-lg border p-3 ${tierColors[i]}`}
                >
                  <p className="text-sm text-foreground">
                    {t(`learn.additives.${key}`)}
                  </p>
                </div>
              ))}
            </div>

            <h2>{t("learn.additives.howWeUseTitle")}</h2>
            <p>{t("learn.additives.howWeUseText")}</p>

            <h2>{t("learn.additives.polishContextTitle")}</h2>
            <p>{t("learn.additives.polishContextText")}</p>

            <Disclaimer className="mt-8" />

            <h2>{t("learn.sourcesTitle")}</h2>
            <div className="not-prose space-y-2">
              <SourceCitation
                author="EFSA"
                title="Re-evaluation of food additives programme"
                url="https://www.efsa.europa.eu/en/topics/topic/food-additive-re-evaluations"
              />
              <SourceCitation
                author="EU"
                title="Regulation (EC) No 1333/2008 on food additives"
                year={2008}
              />
            </div>
          </article>
        </main>
      </div>

      <Footer />
    </div>
  );
}
