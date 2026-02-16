"use client";

// ─── Privacy policy stub ─────────────────────────────────────────────────────

import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { useTranslation } from "@/lib/i18n";

export default function PrivacyPage() {
  const { t } = useTranslation();
  return (
    <div className="flex min-h-screen flex-col">
      <Header />

      <main className="flex flex-1 flex-col items-center px-4 py-16">
        <div className="prose max-w-lg">
          <h1>{t("legal.privacyTitle")}</h1>
          <p className="text-sm text-gray-500">{t("legal.lastUpdated")}</p>

          <h2>{t("legal.dataWeCollect")}</h2>
          <p>{t("legal.dataWeCollectText")}</p>

          <h2>{t("legal.howWeUse")}</h2>
          <p>{t("legal.howWeUseText")}</p>

          <h2>{t("legal.dataStorage")}</h2>
          <p>{t("legal.dataStorageText")}</p>

          <h2>{t("legal.yourRights")}</h2>
          <p>{t("legal.yourRightsText")}</p>

          <h2>{t("legal.contactSection")}</h2>
          <p>{t("legal.contactText")}</p>
        </div>
      </main>

      <Footer />
    </div>
  );
}
