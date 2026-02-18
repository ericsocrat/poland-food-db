"use client";

import Link from "next/link";
import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { LearnSidebar } from "@/components/learn/LearnSidebar";
import { Disclaimer } from "@/components/learn/Disclaimer";
import { useTranslation } from "@/lib/i18n";

// ─── Data Confidence topic page ────────────────────────────────────────────

export default function ConfidencePage() {
  const { t } = useTranslation();

  const levels = [
    {
      key: "levelVerified",
      color:
        "bg-green-50 border-green-200 dark:bg-green-950/20 dark:border-green-800",
      icon: "✅",
    },
    {
      key: "levelEstimated",
      color:
        "bg-amber-50 border-amber-200 dark:bg-amber-950/20 dark:border-amber-800",
      icon: "📐",
    },
    {
      key: "levelLow",
      color: "bg-red-50 border-red-200 dark:bg-red-950/20 dark:border-red-800",
      icon: "⚠️",
    },
  ] as const;

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
            <h1>✅ {t("learn.confidence.title")}</h1>

            <div className="rounded-lg bg-brand-50 p-4 not-prose dark:bg-brand-950/30">
              <p className="text-sm font-medium text-brand-800 dark:text-brand-300">
                {t("learn.tldr")}
              </p>
              <p className="mt-1 text-sm text-brand-700 dark:text-brand-400">
                {t("learn.confidence.summary")}
              </p>
            </div>

            <h2>{t("learn.confidence.whyTitle")}</h2>
            <p>{t("learn.confidence.whyText")}</p>

            <h2>{t("learn.confidence.levelsTitle")}</h2>
            <div className="not-prose space-y-3">
              {levels.map(({ key, color, icon }) => (
                <div key={key} className={`rounded-lg border p-4 ${color}`}>
                  <p className="text-sm text-foreground">
                    <span aria-hidden="true">{icon}</span>{" "}
                    {t(`learn.confidence.${key}`)}
                  </p>
                </div>
              ))}
            </div>

            <h2>{t("learn.confidence.completenessTitle")}</h2>
            <p>{t("learn.confidence.completenessText")}</p>

            <h2>{t("learn.confidence.howWeImproveTitle")}</h2>
            <p>{t("learn.confidence.howWeImproveText")}</p>

            <h2>{t("learn.confidence.whatYouCanDoTitle")}</h2>
            <p>{t("learn.confidence.whatYouCanDoText")}</p>

            <Disclaimer className="mt-8" />
          </article>
        </main>
      </div>

      <Footer />
    </div>
  );
}
