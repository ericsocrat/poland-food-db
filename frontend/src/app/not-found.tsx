// ─── Global 404 page ──────────────────────────────────────────────────────

"use client";

import { ButtonLink } from "@/components/common/Button";
import { ErrorIllustration } from "@/components/common/ErrorIllustration";
import { useTranslation } from "@/lib/i18n";

export default function NotFound() {
  const { t } = useTranslation();
  return (
    <div className="flex min-h-screen flex-col items-center justify-center px-4">
      <ErrorIllustration type="not-found" priority className="mb-6" />
      <h1 className="mb-2 text-6xl font-bold text-foreground">
        {t("error.notFoundCode")}
      </h1>
      <p className="mb-1 text-xl font-semibold text-foreground-secondary">
        {t("error.notFoundTitle")}
      </p>
      <p className="mb-6 text-lg text-foreground-secondary">
        {t("error.notFoundMessage")}
      </p>
      <ButtonLink href="/" size="lg">
        {t("error.goHome")}
      </ButtonLink>
    </div>
  );
}
