// ─── Global error boundary ────────────────────────────────────────────────
// Catches errors in the root layout itself.
// Must include its own <html> and <body> tags.
// Reports to Sentry (#183).

"use client";

import { translate } from "@/lib/i18n";
import type { SupportedLanguage } from "@/stores/language-store";
import * as Sentry from "@sentry/nextjs";
import { useEffect } from "react";

/** Detect locale from browser language (no React context available in global error boundary). */
function detectClientLocale(): SupportedLanguage {
  if (typeof navigator !== "undefined") {
    const lang = navigator.language.slice(0, 2);
    if (lang === "pl" || lang === "de") return lang;
  }
  return "en";
}

export default function GlobalError({
  error,
  reset,
}: Readonly<{
  error: Error & { digest?: string };
  reset: () => void;
}>) {
  const locale = detectClientLocale();

  useEffect(() => {
    Sentry.captureException(error, {
      tags: { boundary: "global-error" },
    });
  }, [error]);
  return (
    <html lang={locale}>
      <body>
        <div
          style={{
            display: "flex",
            minHeight: "100vh",
            flexDirection: "column",
            alignItems: "center",
            justifyContent: "center",
            padding: "1rem",
            fontFamily: "system-ui, sans-serif",
          }}
        >
          <h1
            style={{
              fontSize: "1.5rem",
              fontWeight: 700,
              marginBottom: "0.5rem",
            }}
          >
            {translate(locale, "error.somethingWrong")}
          </h1>
          <p style={{ color: "#6b7280", marginBottom: "1.5rem" }}>
            {translate(locale, "error.critical")}
          </p>
          <button
            onClick={reset}
            style={{
              padding: "0.75rem 1.5rem",
              backgroundColor: "#16a34a",
              color: "white",
              border: "none",
              borderRadius: "0.5rem",
              cursor: "pointer",
              fontSize: "1rem",
              fontWeight: 500,
            }}
          >
            {translate(locale, "common.tryAgain")}
          </button>
        </div>
      </body>
    </html>
  );
}
