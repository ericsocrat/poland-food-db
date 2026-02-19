"use client";

// ─── Contact page stub ──────────────────────────────────────────────────────

import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { useTranslation } from "@/lib/i18n";

export default function ContactPage() {
  const { t } = useTranslation();
  return (
    <div className="flex min-h-screen flex-col">
      <Header />

      <main className="flex flex-1 flex-col items-center px-4 py-16">
        <div className="max-w-md">
          <h1 className="mb-4 text-2xl font-bold text-foreground">
            {t("legal.contactTitle")}
          </h1>
          <p className="mb-6 text-foreground-secondary">
            {t("legal.contactIntro")}
          </p>
          <div className="card space-y-3">
            <p className="text-sm text-foreground-secondary">
              <strong>{t("legal.emailLabel")}</strong>{" "}
              <a
                href="mailto:hello@example.com"
                className="text-brand underline"
              >
                hello@example.com
              </a>
            </p>
            <p className="text-sm text-foreground-secondary">
              {t("legal.responseTime")}
            </p>
          </div>
        </div>
      </main>

      <Footer />
    </div>
  );
}
