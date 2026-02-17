"use client";

// ─── Terms of service stub ───────────────────────────────────────────────────

import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { useTranslation } from "@/lib/i18n";

export default function TermsPage() {
  const { t } = useTranslation();
  return (
    <div className="flex min-h-screen flex-col">
      <Header />

      <main className="flex flex-1 flex-col items-center px-4 py-16">
        <div className="prose max-w-lg">
          <h1>{t("legal.termsTitle")}</h1>
          <p className="text-sm text-foreground-secondary">{t("legal.lastUpdated")}</p>

          <h2>{t("legal.acceptance")}</h2>
          <p>{t("legal.acceptanceText")}</p>

          <h2>{t("legal.serviceDescription")}</h2>
          <p>{t("legal.serviceDescText")}</p>

          <h2>{t("legal.dataAccuracy")}</h2>
          <p>{t("legal.dataAccuracyText")}</p>

          <h2>{t("legal.userAccounts")}</h2>
          <p>{t("legal.userAccountsText")}</p>

          <h2>{t("legal.liability")}</h2>
          <p>{t("legal.liabilityText")}</p>

          <h2>{t("legal.contactSection")}</h2>
          <p>{t("legal.contactText")}</p>
        </div>
      </main>

      <Footer />
    </div>
  );
}
