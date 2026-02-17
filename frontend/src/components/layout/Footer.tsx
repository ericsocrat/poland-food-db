"use client";

import Link from "next/link";
import { useTranslation } from "@/lib/i18n";

export function Footer() {
  const { t } = useTranslation();
  return (
    <footer className="border-t bg-surface-subtle py-8">
      <div className="mx-auto max-w-5xl px-4 text-center text-sm text-foreground-secondary">
        <div className="mb-3 flex items-center justify-center gap-2">
          <Link
            href="/privacy"
            className="touch-target px-2 hover:text-foreground"
          >
            {t("layout.privacy")}
          </Link>
          <span aria-hidden="true">·</span>
          <Link
            href="/terms"
            className="touch-target px-2 hover:text-foreground"
          >
            {t("layout.terms")}
          </Link>
          <span aria-hidden="true">·</span>
          <Link
            href="/contact"
            className="touch-target px-2 hover:text-foreground"
          >
            {t("layout.contact")}
          </Link>
        </div>
        <p>{t("layout.copyright", { year: new Date().getFullYear() })}</p>
      </div>
    </footer>
  );
}
