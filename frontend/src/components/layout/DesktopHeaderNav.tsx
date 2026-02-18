"use client";

// ─── DesktopHeaderNav — horizontal nav links for lg–xl viewports ─────────────
// Renders inline nav links inside the app header at lg breakpoint.
// Hidden below lg (1024px) and at xl+ (1280px) where sidebar takes over.
// CSS-only show/hide, no JS.
//
// Issue #72 — Desktop Navigation Architecture

import Link from "next/link";
import { useActiveRoute, type PrimaryRouteKey } from "@/hooks/use-active-route";
import { useTranslation } from "@/lib/i18n";

/* ── Route definitions ────────────────────────────────────────────────────── */

interface HeaderNavItem {
  readonly href: string;
  readonly labelKey: string;
  readonly routeKey: PrimaryRouteKey;
}

const NAV_ITEMS: readonly HeaderNavItem[] = [
  { href: "/app", labelKey: "nav.home", routeKey: "home" },
  { href: "/app/search", labelKey: "nav.search", routeKey: "search" },
  { href: "/app/scan", labelKey: "nav.scan", routeKey: "scan" },
  { href: "/app/lists", labelKey: "nav.lists", routeKey: "lists" },
  { href: "/app/compare", labelKey: "nav.compare", routeKey: "compare" },
  {
    href: "/app/categories",
    labelKey: "nav.categories",
    routeKey: "categories",
  },
  { href: "/app/settings", labelKey: "nav.settings", routeKey: "settings" },
] as const;

/* ── Component ────────────────────────────────────────────────────────────── */

export function DesktopHeaderNav() {
  const activeRoute = useActiveRoute();
  const { t } = useTranslation();

  return (
    <nav
      className="hidden items-center gap-1 lg:flex xl:hidden"
      aria-label={t("a11y.headerNavigation")}
    >
      {NAV_ITEMS.map((item) => {
        const isActive = activeRoute === item.routeKey;
        const label = t(item.labelKey);
        return (
          <Link
            key={item.href}
            href={item.href}
            aria-current={isActive ? "page" : undefined}
            className={`rounded-md px-2.5 py-1.5 text-sm font-medium transition-colors ${
              isActive
                ? "text-brand-700 dark:text-brand-400"
                : "text-foreground-secondary hover:bg-surface-muted hover:text-foreground"
            }`}
          >
            {label}
            {isActive && (
              <span className="absolute bottom-0 left-1/2 h-0.5 w-4 -translate-x-1/2 rounded-full bg-brand-600 dark:bg-brand-400" />
            )}
          </Link>
        );
      })}
    </nav>
  );
}
