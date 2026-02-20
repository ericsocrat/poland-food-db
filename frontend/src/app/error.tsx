// ─── Root error boundary ──────────────────────────────────────────────────
// Catches errors in route segments. Renders in-place without losing the layout.

"use client";

import { useEffect } from "react";
import { AlertTriangle } from "lucide-react";
import { useTranslation } from "@/lib/i18n";

export default function ErrorPage({
  error,
  reset,
}: Readonly<{
  error: Error & { digest?: string };
  reset: () => void;
}>) {
  const { t } = useTranslation();

  useEffect(() => {
    // Log error only in development; in production use an error-reporting service
    if (process.env.NODE_ENV === "development") {
      console.error("[ErrorBoundary]", error);
    }
  }, [error]);

  return (
    <div className="flex min-h-screen flex-col items-center justify-center px-4">
      <AlertTriangle size={48} className="mb-4 text-error" aria-hidden="true" />
      <h1 className="mb-2 text-2xl font-bold text-foreground">
        {t("error.somethingWrong")}
      </h1>
      <p className="mb-6 text-foreground-secondary">{t("error.unexpected")}</p>
      <button onClick={reset} className="btn-primary px-6 py-3">
        {t("common.tryAgain")}
      </button>
    </div>
  );
}
