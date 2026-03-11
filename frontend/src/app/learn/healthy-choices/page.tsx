"use client";

import { SkipLink } from "@/components/common/SkipLink";
import { Footer } from "@/components/layout/Footer";
import { Header } from "@/components/layout/Header";
import { Disclaimer } from "@/components/learn/Disclaimer";
import { LearnSidebar } from "@/components/learn/LearnSidebar";
import { LearnTopicNav } from "@/components/learn/LearnTopicNav";
import { SourceCitation } from "@/components/learn/SourceCitation";
import { useTranslation } from "@/lib/i18n";
import { Heart } from "lucide-react";
import Link from "next/link";

// ─── Making Healthier Choices topic page ───────────────────────────────────

export default function HealthyChoicesPage() {
  const { t } = useTranslation();

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
              <Heart
                size={28}
                aria-hidden="true"
                className="inline-block"
              />{" "}
              {t("learn.healthyChoices.title")}
            </h1>

            <div className="rounded-lg bg-brand-subtle p-4 not-prose">
              <p className="text-sm font-medium text-brand">
                {t("learn.tldr")}
              </p>
              <p className="mt-1 text-sm text-brand">
                {t("learn.healthyChoices.summary")}
              </p>
            </div>

            <h2>{t("learn.healthyChoices.startSmallTitle")}</h2>
            <p>{t("learn.healthyChoices.startSmallText")}</p>

            <h2>{t("learn.healthyChoices.compareTitle")}</h2>
            <p>{t("learn.healthyChoices.compareText")}</p>

            <h2>{t("learn.healthyChoices.readLabelsTitle")}</h2>
            <p>{t("learn.healthyChoices.readLabelsText")}</p>

            <h2>{t("learn.healthyChoices.processingTitle")}</h2>
            <p>{t("learn.healthyChoices.processingText")}</p>

            <h2>{t("learn.healthyChoices.allergenTitle")}</h2>
            <p>{t("learn.healthyChoices.allergenText")}</p>

            <h2>{t("learn.healthyChoices.habitsTitle")}</h2>
            <p>{t("learn.healthyChoices.habitsText")}</p>

            <Disclaimer className="mt-8" />

            <h2>{t("learn.sourcesTitle")}</h2>
            <div className="not-prose space-y-2">
              <SourceCitation
                author="WHO"
                title="Healthy diet fact sheet"
                year={2024}
                url="https://www.who.int/news-room/fact-sheets/detail/healthy-diet"
              />
              <SourceCitation
                author="EFSA"
                title="Dietary reference values for nutrients"
                url="https://www.efsa.europa.eu/en/topics/topic/dietary-reference-values"
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
