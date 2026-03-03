// ─── Public home / landing page ───────────────────────────────────────────
// 6 sections: Hero · Features · How It Works · Data Stats · CTA Repeat · Footer
// Issue #573 — redesign with hero, features, and social proof

"use client";

import { Logo } from "@/components/common/Logo";
import { SkipLink } from "@/components/common/SkipLink";
import { Footer } from "@/components/layout/Footer";
import { Header } from "@/components/layout/Header";
import { useTranslation } from "@/lib/i18n";
import {
    BarChart3,
    Camera,
    ChevronRight,
    Database,
    Layers,
    Search,
    Shield,
    ShoppingBasket,
    type LucideIcon,
} from "lucide-react";
import Link from "next/link";

// ─── Section components ─────────────────────────────────────────────────────

function HeroSection() {
  const { t } = useTranslation();
  return (
    <section className="relative overflow-hidden bg-gradient-to-b from-brand/5 to-transparent pb-16 pt-20 sm:pb-24 sm:pt-28">
      <div className="mx-auto max-w-5xl px-4 text-center">
        <div className="mb-6">
          <Logo variant="icon" size={64} />
        </div>
        <h1 className="mb-4 text-4xl font-extrabold tracking-tight text-foreground sm:text-5xl lg:text-6xl">
          {t("landing.tagline")}
        </h1>
        <p className="mx-auto mb-8 max-w-2xl text-lg text-foreground-secondary sm:text-xl">
          {t("landing.description")}
        </p>
        <div className="flex flex-col items-center gap-3 sm:flex-row sm:justify-center">
          <Link
            href="/auth/signup"
            className="btn-primary px-8 py-3 text-base"
          >
            {t("landing.getStarted")}
            <ChevronRight size={18} className="ml-1 inline-block" aria-hidden="true" />
          </Link>
          <Link
            href="/auth/login"
            className="btn-secondary px-8 py-3 text-base"
          >
            {t("landing.signIn")}
          </Link>
        </div>
      </div>
    </section>
  );
}

function FeaturesSection() {
  const { t } = useTranslation();
  const features: { icon: LucideIcon; title: string; desc: string }[] = [
    { icon: Search, title: t("landing.featureSearch"), desc: t("landing.featureSearchDesc") },
    { icon: Camera, title: t("landing.featureScan"), desc: t("landing.featureScanDesc") },
    { icon: BarChart3, title: t("landing.featureCompare"), desc: t("landing.featureCompareDesc") },
  ];
  return (
    <section aria-labelledby="features-heading" className="py-16 sm:py-20">
      <div className="mx-auto max-w-5xl px-4">
        <h2 id="features-heading" className="mb-10 text-center text-2xl font-bold text-foreground sm:text-3xl">
          {t("landing.featuresHeading")}
        </h2>
        <div className="grid gap-8 sm:grid-cols-3">
          {features.map((f) => (
            <div key={f.title} className="card text-center">
              <div className="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-xl bg-brand/10">
                <f.icon size={28} aria-hidden="true" className="text-brand" />
              </div>
              <h3 className="mb-2 text-lg font-semibold text-foreground">{f.title}</h3>
              <p className="text-sm leading-relaxed text-foreground-secondary">{f.desc}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function HowItWorksSection() {
  const { t } = useTranslation();
  const steps: { num: number; icon: LucideIcon; title: string; desc: string }[] = [
    { num: 1, icon: Search, title: t("landing.step1Title"), desc: t("landing.step1Desc") },
    { num: 2, icon: Shield, title: t("landing.step2Title"), desc: t("landing.step2Desc") },
    { num: 3, icon: ShoppingBasket, title: t("landing.step3Title"), desc: t("landing.step3Desc") },
  ];
  return (
    <section aria-labelledby="how-it-works-heading" className="bg-surface-subtle py-16 sm:py-20">
      <div className="mx-auto max-w-5xl px-4">
        <h2 id="how-it-works-heading" className="mb-10 text-center text-2xl font-bold text-foreground sm:text-3xl">
          {t("landing.howItWorksHeading")}
        </h2>
        <div className="grid gap-8 sm:grid-cols-3">
          {steps.map((s) => (
            <div key={s.num} className="flex flex-col items-center text-center">
              <div className="relative mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-brand text-foreground-inverse">
                <s.icon size={28} aria-hidden="true" />
                <span className="absolute -right-1 -top-1 flex h-6 w-6 items-center justify-center rounded-full bg-foreground text-xs font-bold text-foreground-inverse">
                  {s.num}
                </span>
              </div>
              <h3 className="mb-2 text-lg font-semibold text-foreground">{s.title}</h3>
              <p className="text-sm leading-relaxed text-foreground-secondary">{s.desc}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function DataStatsSection() {
  const { t } = useTranslation();
  const stats: { icon: LucideIcon; value: string; label: string }[] = [
    { icon: ShoppingBasket, value: "1,200+", label: t("landing.statProducts") },
    { icon: Layers, value: "25", label: t("landing.statCategories") },
    { icon: Database, value: "9", label: t("landing.statFactors") },
    { icon: Shield, value: "2", label: t("landing.statCountries") },
  ];
  return (
    <section aria-labelledby="stats-heading" className="py-16 sm:py-20">
      <div className="mx-auto max-w-5xl px-4">
        <h2 id="stats-heading" className="mb-10 text-center text-2xl font-bold text-foreground sm:text-3xl">
          {t("landing.statsHeading")}
        </h2>
        <div className="grid grid-cols-2 gap-6 sm:grid-cols-4">
          {stats.map((s) => (
            <div key={s.label} className="card flex flex-col items-center py-6 text-center">
              <s.icon size={24} aria-hidden="true" className="mb-2 text-brand" />
              <span className="text-3xl font-extrabold text-foreground">{s.value}</span>
              <span className="mt-1 text-sm text-foreground-secondary">{s.label}</span>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function CtaRepeatSection() {
  const { t } = useTranslation();
  return (
    <section className="bg-brand/5 py-16 sm:py-20">
      <div className="mx-auto max-w-2xl px-4 text-center">
        <h2 className="mb-4 text-2xl font-bold text-foreground sm:text-3xl">
          {t("landing.ctaHeading")}
        </h2>
        <p className="mb-8 text-foreground-secondary">
          {t("landing.ctaDescription")}
        </p>
        <Link href="/auth/signup" className="btn-primary px-10 py-3 text-base">
          {t("landing.getStarted")}
          <ChevronRight size={18} className="ml-1 inline-block" aria-hidden="true" />
        </Link>
      </div>
    </section>
  );
}

// ─── Page ───────────────────────────────────────────────────────────────────

export default function HomePage() {
  return (
    <div className="flex min-h-screen flex-col">
      <SkipLink />
      <Header />

      <main id="main-content" className="flex-1">
        <HeroSection />
        <FeaturesSection />
        <HowItWorksSection />
        <DataStatsSection />
        <CtaRepeatSection />
      </main>

      <Footer />
    </div>
  );
}
