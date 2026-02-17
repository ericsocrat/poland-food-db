// ─── App-level error boundary ─────────────────────────────────────────────
// Catches errors within /app/* route segments. More specific than root error.tsx.
// Renders within the app layout (navigation stays intact).

"use client";

import { useEffect } from "react";
import { useTranslation } from "@/lib/i18n";
import { useRouter } from "next/navigation";

export default function AppError({
  error,
  reset,
}: Readonly<{
  error: Error & { digest?: string };
  reset: () => void;
}>) {
  const { t } = useTranslation();
  const router = useRouter();

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
      <p className="mb-3 text-4xl" aria-hidden="true">
        ⚠️
      </p>
      <h2
        className="mb-2 text-xl font-bold"
        style={{ color: "var(--color-text-primary)" }}
      >
        {t("errorBoundary.pageTitle")}
      </h2>
      <p
        className="mb-6 max-w-md text-sm"
        style={{ color: "var(--color-text-secondary)" }}
      >
        {t("errorBoundary.pageDescription")}
      </p>
      {error.digest && (
        <p
          className="mb-4 font-mono text-xs"
          style={{ color: "var(--color-text-muted)" }}
        >
          {t("errorBoundary.errorId")}: {error.digest}
        </p>
      )}
      <div className="flex gap-3">
        <button
          onClick={reset}
          className="rounded-lg px-5 py-2.5 text-sm font-medium text-white"
          style={{ backgroundColor: "var(--color-brand)" }}
        >
          {t("common.tryAgain")}
        </button>
        <button
          onClick={() => router.push("/app")}
          className="rounded-lg border px-5 py-2.5 text-sm font-medium"
          style={{
            borderColor: "var(--color-border)",
            color: "var(--color-text-primary)",
          }}
        >
          {t("errorBoundary.goHome")}
        </button>
      </div>
    </div>
  );
}
