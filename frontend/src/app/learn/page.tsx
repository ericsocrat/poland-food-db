"use client";

import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { LearnCard } from "@/components/learn/LearnCard";
import { Disclaimer } from "@/components/learn/Disclaimer";
import { useTranslation } from "@/lib/i18n";
import {
  Award,
  Factory,
  BarChart3,
  FlaskConical,
  AlertTriangle,
  Tag,
  BadgeCheck,
  BookOpen,
} from "lucide-react";
import type { LucideIcon } from "lucide-react";

/** Topics for the hub index page. */
const TOPICS: readonly {
  slug: string;
  icon: LucideIcon;
  titleKey: string;
  descKey: string;
}[] = [
  {
    slug: "nutri-score",
    icon: Award,
    titleKey: "learn.nutriScore.title",
    descKey: "learn.nutriScore.description",
  },
  {
    slug: "nova-groups",
    icon: Factory,
    titleKey: "learn.novaGroups.title",
    descKey: "learn.novaGroups.description",
  },
  {
    slug: "unhealthiness-score",
    icon: BarChart3,
    titleKey: "learn.unhealthinessScore.title",
    descKey: "learn.unhealthinessScore.description",
  },
  {
    slug: "additives",
    icon: FlaskConical,
    titleKey: "learn.additives.title",
    descKey: "learn.additives.description",
  },
  {
    slug: "allergens",
    icon: AlertTriangle,
    titleKey: "learn.allergens.title",
    descKey: "learn.allergens.description",
  },
  {
    slug: "reading-labels",
    icon: Tag,
    titleKey: "learn.readingLabels.title",
    descKey: "learn.readingLabels.description",
  },
  {
    slug: "confidence",
    icon: BadgeCheck,
    titleKey: "learn.confidence.title",
    descKey: "learn.confidence.description",
  },
];

export default function LearnHubPage() {
  const { t } = useTranslation();

  return (
    <div className="flex min-h-screen flex-col">
      <Header />

      <main className="flex-1 px-4 py-12">
        <div className="mx-auto max-w-5xl">
          {/* Hero */}
          <div className="mb-10 text-center">
            <h1 className="mb-3 flex items-center justify-center gap-3 text-3xl font-bold text-foreground md:text-4xl">
              <BookOpen size={32} aria-hidden="true" /> {t("learn.hubTitle")}
            </h1>
            <p className="mx-auto max-w-2xl text-lg text-foreground-secondary">
              {t("learn.hubSubtitle")}
            </p>
          </div>

          {/* Disclaimer */}
          <Disclaimer className="mb-10" />

          {/* Topic grid */}
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {TOPICS.map(({ slug, icon, titleKey, descKey }) => (
              <LearnCard
                key={slug}
                icon={icon}
                title={t(titleKey)}
                description={t(descKey)}
                href={`/learn/${slug}`}
              />
            ))}
          </div>
        </div>
      </main>

      <Footer />
    </div>
  );
}
