// ─── App-level error boundary ─────────────────────────────────────────────
// Catches errors within /app/* route segments. More specific than root error.tsx.
// Renders within the app layout (navigation stays intact).

"use client";

import { useEffect } from "react";
import { useTranslation } from "@/lib/i18n";
import { Button, ButtonLink } from "@/components/common/Button";
import { ErrorIllustration } from "@/components/common/ErrorIllustration";

export default function AppError({
  error,
  reset,
}: Readonly<{
  error: Error & { digest?: string };
  reset: () => void;
}>) {
  const { t } = useTranslation();

  useEffect(() => {
    if (process.env.NODE_ENV === "development") {
      console.error("[AppErrorBoundary]", error);
    }
  }, [error]);

  return (
    <div
      className="flex min-h-[60vh] flex-col items-center justify-center px-4 text-center"
      role="alert"
      data-testid="error-boundary-page"
    >
      <ErrorIllustration type="server-error" className="mb-4" />
      <h2 className="mb-2 text-xl font-bold text-foreground">
        {t("errorBoundary.pageTitle")}
      </h2>
      <p className="mb-6 max-w-md text-sm text-foreground-secondary">
        {t("errorBoundary.pageDescription")}
      </p>
      {error.digest && (
        <p className="mb-4 font-mono text-xs text-foreground-muted">
          {t("errorBoundary.errorId")}: {error.digest}
        </p>
      )}
      <div className="flex gap-3">
        <Button onClick={reset}>
          {t("common.tryAgain")}
        </Button>
        <ButtonLink href="/app" variant="secondary">
          {t("errorBoundary.goHome")}
        </ButtonLink>
      </div>
    </div>
  );
}
