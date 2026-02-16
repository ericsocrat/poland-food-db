// ─── Public home page ─────────────────────────────────────────────────────

"use client";

import Link from "next/link";
import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { useTranslation } from "@/lib/i18n";

export default function HomePage() {
  const { t } = useTranslation();
  return (
    <div className="flex min-h-screen flex-col">
      <Header />

      <main className="flex flex-1 flex-col items-center justify-center px-4 py-16">
        <div className="max-w-md text-center">
          <h1 className="mb-4 text-4xl font-bold text-gray-900">
            {t("landing.tagline")}
          </h1>
          <p className="mb-8 text-lg text-gray-500">
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
            icon="🔍"
            title={t("landing.featureSearch")}
            desc={t("landing.featureSearchDesc")}
          />
          <Feature
            icon="📷"
            title={t("landing.featureScan")}
            desc={t("landing.featureScanDesc")}
          />
          <Feature
            icon="📊"
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
  icon,
  title,
  desc,
}: Readonly<{
  icon: string;
  title: string;
  desc: string;
}>) {
  return (
    <div className="text-center">
      <span className="text-3xl">{icon}</span>
      <h3 className="mt-2 font-semibold text-gray-900">{title}</h3>
      <p className="mt-1 text-sm text-gray-500">{desc}</p>
    </div>
  );
}
