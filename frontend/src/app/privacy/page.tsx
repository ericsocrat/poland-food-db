"use client";

// ─── Privacy policy ──────────────────────────────────────────────────────────

import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { SkipLink } from "@/components/common/SkipLink";
import { useTranslation } from "@/lib/i18n";
import { Camera, ShieldCheck, Smartphone, Trash2, Eye } from "lucide-react";

export default function PrivacyPage() {
  const { t } = useTranslation();
  return (
    <div className="flex min-h-screen flex-col">
      <SkipLink />
      <Header />

      <main id="main-content" className="flex flex-1 flex-col items-center px-4 py-16">
        <div className="prose max-w-lg">
          <h1>{t("legal.privacyTitle")}</h1>
          <p className="text-sm text-foreground-secondary">{t("legal.lastUpdated")}</p>

          <h2>{t("legal.dataWeCollect")}</h2>
          <p>{t("legal.dataWeCollectText")}</p>

          <h2>{t("legal.howWeUse")}</h2>
          <p>{t("legal.howWeUseText")}</p>

          <h2>{t("legal.dataStorage")}</h2>
          <p>{t("legal.dataStorageText")}</p>

          {/* ── Image Processing Policy (#56) ─────────────────────────── */}
          <h2>{t("legal.imageProcessing")}</h2>

          <h3>{t("legal.imageWhatWeProcess")}</h3>
          <p>{t("legal.imageWhatWeProcessText")}</p>

          <h3>{t("legal.imageHowWeProcess")}</h3>
          <ul className="space-y-2" role="list">
            {(
              [
                { icon: Smartphone, key: "legal.imageOnDevice" },
                { icon: ShieldCheck, key: "legal.imageNeverUploaded" },
                { icon: Trash2, key: "legal.imageNotStored" },
                { icon: Eye, key: "legal.imageOnlyText" },
              ] as const
            ).map(({ icon: Icon, key }) => (
              <li key={key} className="flex items-start gap-2">
                <Icon
                  size={16}
                  className="mt-0.5 shrink-0 text-brand"
                  aria-hidden="true"
                />
                <span>{t(key)}</span>
              </li>
            ))}
          </ul>

          <h3>{t("legal.imageCamera")}</h3>
          <ul className="space-y-1" role="list">
            <li className="flex items-start gap-2">
              <Camera
                size={16}
                className="mt-0.5 shrink-0 text-brand"
                aria-hidden="true"
              />
              <span>{t("legal.imageCameraText")}</span>
            </li>
          </ul>

          <h3>{t("legal.imageDataCollected")}</h3>
          <p>{t("legal.imageDataCollectedText")}</p>

          <h3>{t("legal.imageLegalBasis")}</h3>
          <p>{t("legal.imageLegalBasisText")}</p>
          {/* ── End Image Processing Policy ───────────────────────────── */}

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
