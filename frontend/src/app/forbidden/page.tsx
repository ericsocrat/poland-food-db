// ─── 403 Forbidden page ───────────────────────────────────────────────────
// Shown when a non-admin user tries to access /app/admin/* routes.
// Middleware redirects here instead of returning raw JSON.
//
// Issue #579 — Friendly 403 page for non-admin users

"use client";

import Link from "next/link";
import { ShieldOff } from "lucide-react";
import { useTranslation } from "@/lib/i18n";

export default function ForbiddenPage() {
  const { t } = useTranslation();
  return (
    <div className="flex min-h-screen flex-col items-center justify-center px-4">
      <ShieldOff
        size={48}
        className="mb-4 text-foreground-muted"
        aria-hidden="true"
      />
      <h1 className="mb-2 text-6xl font-bold text-foreground">
        {t("error.forbiddenCode")}
      </h1>
      <p className="mb-1 text-xl font-semibold text-foreground-secondary">
        {t("error.forbiddenTitle")}
      </p>
      <p className="mb-6 text-lg text-foreground-secondary">
        {t("error.forbiddenMessage")}
      </p>
      <Link href="/app" className="btn-primary px-6 py-3">
        {t("error.goToDashboard")}
      </Link>
    </div>
  );
}
