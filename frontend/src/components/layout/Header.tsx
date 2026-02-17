"use client";

import Link from "next/link";
import { useTranslation } from "@/lib/i18n";
import { useTheme } from "@/hooks/use-theme";

export function Header() {
  const { t } = useTranslation();
  const { resolved, setMode } = useTheme();

  function toggleTheme() {
    setMode(resolved === "dark" ? "light" : "dark");
  }

  return (
    <header className="border-b bg-surface">
      <div className="mx-auto flex h-14 max-w-5xl items-center justify-between px-4">
        <Link href="/" className="text-xl font-bold text-brand-700">
          {t("layout.appNameWithEmoji")}
        </Link>
        <nav className="flex items-center gap-4">
          <Link
            href="/contact"
            className="touch-target text-sm text-foreground-secondary hover:text-foreground"
          >
            {t("layout.contact")}
          </Link>
          <button
            onClick={toggleTheme}
            className="touch-target rounded-md p-2 text-foreground-secondary hover:bg-surface-muted hover:text-foreground transition-colors"
            aria-label={
              resolved === "dark" ? t("theme.light") : t("theme.dark")
            }
            title={resolved === "dark" ? t("theme.light") : t("theme.dark")}
          >
            {resolved === "dark" ? "☀️" : "🌙"}
          </button>
          <Link href="/auth/login" className="btn-primary text-sm">
            {t("auth.signIn")}
          </Link>
        </nav>
      </div>
    </header>
  );
}
