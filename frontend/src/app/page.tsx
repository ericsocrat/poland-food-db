// ─── Public home page ─────────────────────────────────────────────────────

"use client";

import Link from "next/link";
import { Search, Camera, BarChart3 } from "lucide-react";
import type { LucideIcon } from "lucide-react";
import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { SkipLink } from "@/components/common/SkipLink";
import { useTranslation } from "@/lib/i18n";

export default function HomePage() {
  const { t } = useTranslation();
  return (
    <div className="flex min-h-screen flex-col">
      <SkipLink />
      <Header />

      <main id="main-content" className="flex flex-1 flex-col items-center justify-center px-4 py-16">
        <div className="max-w-md text-center">
          <h1 className="mb-4 text-4xl font-bold text-foreground">
            {t("landing.tagline")}
          </h1>
          <p className="mb-8 text-lg text-foreground-secondary">
            {t("landing.description")}
          </p>

          <div className="flex flex-col gap-3 sm:flex-row sm:justify-center">
            <Link href="/auth/signup" className="btn-primary px-8 py-3">
              {t("landing.getStarted")}
            </Link>
            <Link href="/auth/login" className="btn-secondary px-8 py-3">
              {t("landing.signIn")}
            </Link>
          </div>
        </div>

        {/* Feature highlights */}
        <div className="mt-16 grid max-w-lg gap-6 sm:grid-cols-3">
          <Feature
            icon={Search}
            title={t("landing.featureSearch")}
            desc={t("landing.featureSearchDesc")}
          />
          <Feature
            icon={Camera}
            title={t("landing.featureScan")}
            desc={t("landing.featureScanDesc")}
          />
          <Feature
            icon={BarChart3}
            title={t("landing.featureCompare")}
            desc={t("landing.featureCompareDesc")}
          />
        </div>
      </main>

      <Footer />
    </div>
  );
}

function Feature({
  icon: Icon,
  title,
  desc,
}: Readonly<{
  icon: LucideIcon;
  title: string;
  desc: string;
}>) {
  return (
    <div className="text-center">
      <Icon size={32} aria-hidden="true" className="mx-auto text-brand" />
      <h3 className="mt-2 font-semibold text-foreground">{title}</h3>
      <p className="mt-1 text-sm text-foreground-secondary">{desc}</p>
    </div>
  );
}
