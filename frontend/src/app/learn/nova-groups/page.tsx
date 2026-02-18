"use client";

import Link from "next/link";
import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { LearnSidebar } from "@/components/learn/LearnSidebar";
import { Disclaimer } from "@/components/learn/Disclaimer";
import { SourceCitation } from "@/components/learn/SourceCitation";
import { useTranslation } from "@/lib/i18n";
import { Factory } from "lucide-react";

// ─── NOVA Groups topic page ────────────────────────────────────────────────

export default function NovaGroupsPage() {
  const { t } = useTranslation();

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
              <Factory size={28} aria-hidden="true" className="inline-block" />{" "}
              {t("learn.novaGroups.title")}
            </h1>

            <div className="rounded-lg bg-brand-50 p-4 not-prose dark:bg-brand-950/30">
              <p className="text-sm font-medium text-brand-800 dark:text-brand-300">
                {t("learn.tldr")}
              </p>
              <p className="mt-1 text-sm text-brand-700 dark:text-brand-400">
                {t("learn.novaGroups.summary")}
              </p>
            </div>

            <h2>{t("learn.novaGroups.whatIsTitle")}</h2>
            <p>{t("learn.novaGroups.whatIsText")}</p>

            <h2>{t("learn.novaGroups.groupsTitle")}</h2>

            <div className="not-prose space-y-3">
              {(["1", "2", "3", "4"] as const).map((n) => {
                const colorMap: Record<string, string> = {
                  "1": "border-green-200 bg-green-50 dark:border-green-800 dark:bg-green-950/20",
                  "2": "border-blue-200 bg-blue-50 dark:border-blue-800 dark:bg-blue-950/20",
                  "3": "border-amber-200 bg-amber-50 dark:border-amber-800 dark:bg-amber-950/20",
                  "4": "border-red-200 bg-red-50 dark:border-red-800 dark:bg-red-950/20",
                };
                return (
                  <div
                    key={n}
                    className={`rounded-lg border p-4 ${colorMap[n]}`}
                  >
                    <p className="text-sm font-semibold text-foreground">
                      {t(`learn.novaGroups.group${n}Title`)}
                    </p>
                    <p className="mt-1 text-sm text-foreground-secondary">
                      {t(`learn.novaGroups.group${n}Text`)}
                    </p>
                  </div>
                );
              })}
            </div>

            <h2>{t("learn.novaGroups.whyItMattersTitle")}</h2>
            <p>{t("learn.novaGroups.whyItMattersText")}</p>

            <h2>{t("learn.novaGroups.polishContextTitle")}</h2>
            <p>{t("learn.novaGroups.polishContextText")}</p>

            <h2>{t("learn.novaGroups.processingRiskTitle")}</h2>
            <p>{t("learn.novaGroups.processingRiskText")}</p>

            <Disclaimer className="mt-8" />

            <h2>{t("learn.sourcesTitle")}</h2>
            <div className="not-prose space-y-2">
              <SourceCitation
                author="Monteiro et al."
                title="Ultra-processed foods: what they are and how to identify them"
                year={2019}
                url="https://doi.org/10.1017/S1368980018003762"
              />
              <SourceCitation
                author="Schnabel et al."
                title="Association between ultra-processed food consumption and risk of mortality"
                year={2019}
                url="https://doi.org/10.1001/jamainternmed.2018.7289"
              />
              <SourceCitation
                author="Fiolet et al."
                title="Consumption of ultra-processed foods and cancer risk"
                year={2018}
                url="https://doi.org/10.1136/bmj.k322"
              />
            </div>
          </article>
        </main>
      </div>

      <Footer />
    </div>
  );
}
