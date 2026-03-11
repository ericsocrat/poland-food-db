"use client";

import { SkipLink } from "@/components/common/SkipLink";
import { Footer } from "@/components/layout/Footer";
import { Header } from "@/components/layout/Header";
import { Disclaimer } from "@/components/learn/Disclaimer";
import { LearnSidebar } from "@/components/learn/LearnSidebar";
import { LearnTopicNav } from "@/components/learn/LearnTopicNav";
import { SourceCitation } from "@/components/learn/SourceCitation";
import { useTranslation } from "@/lib/i18n";
import { AlertTriangle, BadgeCheck, Ruler, type LucideIcon } from "lucide-react";
import Link from "next/link";

// ─── Data Confidence topic page ────────────────────────────────────────────

export default function ConfidencePage() {
  const { t } = useTranslation();

  const levels: { key: string; color: string; icon: LucideIcon }[] = [
    {
      key: "levelVerified",
      color:
        "bg-success-bg border-success-border",
      icon: BadgeCheck,
    },
    {
      key: "levelEstimated",
      color:
        "bg-warning-bg border-warning-border",
      icon: Ruler,
    },
    {
      key: "levelLow",
      color: "bg-error-bg border-error-border",
      icon: AlertTriangle,
    },
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
              <BadgeCheck
                size={28}
                aria-hidden="true"
                className="inline-block"
              />{" "}
              {t("learn.confidence.title")}
            </h1>

            <div className="rounded-lg bg-brand-subtle p-4 not-prose">
              <p className="text-sm font-medium text-brand">
                {t("learn.tldr")}
              </p>
              <p className="mt-1 text-sm text-brand">
                {t("learn.confidence.summary")}
              </p>
            </div>

            <h2>{t("learn.confidence.whyTitle")}</h2>
            <p>{t("learn.confidence.whyText")}</p>

            <h2>{t("learn.confidence.levelsTitle")}</h2>
            <div className="not-prose space-y-3">
              {levels.map(({ key, color, icon: LevelIcon }) => (
                <div key={key} className={`rounded-lg border p-4 ${color}`}>
                  <p className="flex items-center gap-2 text-sm text-foreground">
                    <LevelIcon size={16} aria-hidden="true" />{" "}
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

            <h2>{t("learn.sourcesTitle")}</h2>
            <div className="not-prose space-y-2">
              <SourceCitation
                author="EFSA"
                title="Guidance on the assessment of the safety of feed additives"
                year={2017}
              />
              <SourceCitation
                author="Open Food Facts"
                title="Data quality framework and completeness metrics"
                url="https://wiki.openfoodfacts.org/Data_quality"
              />
            </div>

            <LearnTopicNav />
          </article>
        </main>
      </div>

      <Footer />
    </div>
  );
}
