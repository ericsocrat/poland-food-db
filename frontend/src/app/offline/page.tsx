"use client";

import { useTranslation } from "@/lib/i18n";

export default function OfflinePage() {
  const { t } = useTranslation();
  return (
    <div className="flex min-h-[60vh] flex-col items-center justify-center px-4 text-center">
      <p className="text-5xl">📡</p>
      <h1 className="mt-4 text-xl font-bold text-foreground">
        {t("offline.title")}
      </h1>
      <p className="mt-2 max-w-sm text-sm text-foreground-secondary">
        {t("offline.offlinePage")}
      </p>
      <button
        className="btn-primary mt-6"
        onClick={() => window.location.reload()}
      >
        {t("offline.tryAgain")}
      </button>
    </div>
  );
}
