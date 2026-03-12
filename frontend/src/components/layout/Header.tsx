"use client";

import { ButtonLink } from "@/components/common/Button";
import { Logo } from "@/components/common/Logo";
import { useTheme } from "@/hooks/use-theme";
import { useTranslation } from "@/lib/i18n";
import { createClient } from "@/lib/supabase/client";
import { Moon, Sun } from "lucide-react";
import Link from "next/link";
import { useEffect, useState } from "react";

export function Header() {
  const { t } = useTranslation();
  const { resolved, setMode } = useTheme();
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  useEffect(() => {
    try {
      const supabase = createClient();
      supabase.auth.getUser().then(({ data }) => {
        setIsAuthenticated(!!data.user);
      });
    } catch {
      // Supabase client unavailable (SSR / test env) — stay unauthenticated
    }
  }, []);

  function toggleTheme() {
    setMode(resolved === "dark" ? "light" : "dark");
  }

  return (
    <header className="border-b bg-surface">
      <div className="mx-auto flex h-14 max-w-5xl items-center justify-between px-4">
        <Link href="/" aria-label="TryVit">
          <Logo variant="lockup" size={28} />
        </Link>
        <nav className="flex items-center gap-4">
          <Link
            href="/contact"
            className="touch-target text-sm text-foreground-secondary hover:text-foreground lg:text-base"
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
            {resolved === "dark" ? (
              <Sun size={20} aria-hidden="true" />
            ) : (
              <Moon size={20} aria-hidden="true" />
            )}
          </button>
          <ButtonLink href={isAuthenticated ? "/app" : "/auth/login"}>
            {isAuthenticated ? t("auth.dashboard") : t("auth.signIn")}
          </ButtonLink>
        </nav>
      </div>
    </header>
  );
}
