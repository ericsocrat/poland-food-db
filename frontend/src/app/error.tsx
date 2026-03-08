// ─── Root error boundary ──────────────────────────────────────────────────
// Catches errors in route segments. Renders in-place without losing the layout.
// Reports to Sentry (#183).

"use client";

import { Button } from "@/components/common/Button";
import { ErrorIllustration } from "@/components/common/ErrorIllustration";
import { useTranslation } from "@/lib/i18n";
import * as Sentry from "@sentry/nextjs";
import { useEffect } from "react";

export default function ErrorPage({
  error,
  reset,
}: Readonly<{
  error: Error & { digest?: string };
  reset: () => void;
}>) {
  const { t } = useTranslation();

  useEffect(() => {
    Sentry.captureException(error, {
      tags: { boundary: "route-error" },
    });

    if (process.env.NODE_ENV === "development") {
      console.error("[ErrorBoundary]", error);
    }
  }, [error]);

  return (
    <div className="flex min-h-screen flex-col items-center justify-center px-4">
      <ErrorIllustration type="server-error" className="mb-6" />
      <h1 className="mb-2 text-2xl font-bold text-foreground">
        {t("error.somethingWrong")}
      </h1>
      <p className="mb-6 text-foreground-secondary">{t("error.unexpected")}</p>
      <Button onClick={reset} size="lg">
        {t("common.tryAgain")}
      </Button>
    </div>
  );
}
