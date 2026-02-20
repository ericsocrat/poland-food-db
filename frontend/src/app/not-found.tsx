// ─── Global 404 page ──────────────────────────────────────────────────────

"use client";

import Link from "next/link";
import { FileQuestion } from "lucide-react";
import { useTranslation } from "@/lib/i18n";

export default function NotFound() {
  const { t } = useTranslation();
  return (
    <div className="flex min-h-screen flex-col items-center justify-center px-4">
      <FileQuestion size={48} className="mb-4 text-foreground-muted" aria-hidden="true" />
      <h1 className="mb-2 text-6xl font-bold text-foreground">
        {t("error.notFoundCode")}
      </h1>
      <p className="mb-1 text-xl font-semibold text-foreground-secondary">
        {t("error.notFoundTitle")}
      </p>
      <p className="mb-6 text-lg text-foreground-secondary">
        {t("error.notFoundMessage")}
      </p>
      <Link href="/" className="btn-primary px-6 py-3">
        {t("error.goHome")}
      </Link>
    </div>
  );
}
