"use client";

import Link from "next/link";
import { useTranslation } from "@/lib/i18n";

export function Header() {
  const { t } = useTranslation();
  return (
    <header className="border-b bg-surface">
      <div className="mx-auto flex h-14 max-w-5xl items-center justify-between px-4">
        <Link href="/" className="text-xl font-bold text-brand-700">
          {t("layout.appNameWithEmoji")}
        </Link>
        <nav className="flex items-center gap-4">
          <Link
            href="/contact"
            className="text-sm text-foreground-secondary hover:text-foreground"
          >
            {t("layout.contact")}
          </Link>
          <Link href="/auth/login" className="btn-primary text-sm">
            {t("auth.signIn")}
          </Link>
        </nav>
      </div>
    </header>
  );
}
