"use client";

// ─── Bottom navigation for the app shell ────────────────────────────────────
// Issue #67 — replaced Settings with "More" drawer to surface all nav items.

import { useState, useCallback } from "react";
import Link from "next/link";
import { useActiveRoute, type PrimaryRouteKey } from "@/hooks/use-active-route";
import { useTranslation } from "@/lib/i18n";
import { useLists } from "@/hooks/use-lists";
import { Icon } from "@/components/common/Icon";
import { MoreDrawer } from "@/components/layout/MoreDrawer";
import { Home, Search, Camera, ClipboardList, MoreHorizontal } from "lucide-react";
import type { LucideIcon } from "lucide-react";

interface NavItem {
  href: string;
  labelKey: string;
  icon: LucideIcon;
  routeKey: PrimaryRouteKey;
}

/** Routes that live in the "More" drawer rather than the bottom bar. */
const MORE_ROUTE_KEYS = new Set<PrimaryRouteKey>([
  "compare",
  "categories",
  "watchlist",
  "settings",
]);

const NAV_ITEMS: NavItem[] = [
  { href: "/app", labelKey: "nav.home", icon: Home, routeKey: "home" },
  {
    href: "/app/search",
    labelKey: "nav.search",
    icon: Search,
    routeKey: "search",
  },
  { href: "/app/scan", labelKey: "nav.scan", icon: Camera, routeKey: "scan" },
  {
    href: "/app/lists",
    labelKey: "nav.lists",
    icon: ClipboardList,
    routeKey: "lists",
  },
];

export function Navigation() {
  const activeRoute = useActiveRoute();
  const { t } = useTranslation();
  const { data: lists } = useLists();
  const [moreOpen, setMoreOpen] = useState(false);

  const openMore = useCallback(() => setMoreOpen(true), []);
  const closeMore = useCallback(() => setMoreOpen(false), []);

  // Badge counts keyed by routeKey — only show when count > 0
  const badgeCounts: Partial<Record<NonNullable<PrimaryRouteKey>, number>> = {};
  if (lists && lists.lists.length > 0) {
    badgeCounts.lists = lists.lists.length;
  }

  // Highlight "More" if active route lives in the drawer
  const isMoreActive = MORE_ROUTE_KEYS.has(activeRoute);

  return (
    <>
      <nav
        className="fixed bottom-0 left-0 right-0 z-40 border-t border-border bg-surface pb-[env(safe-area-inset-bottom)] lg:hidden"
        aria-label="Main navigation"
      >
        <div className="mx-auto flex max-w-5xl">
          {NAV_ITEMS.map((item) => {
            const isActive = activeRoute === item.routeKey;
            const label = t(item.labelKey);
            const badge = item.routeKey
              ? badgeCounts[item.routeKey]
              : undefined;
            return (
              <Link
                key={item.href}
                href={item.href}
                aria-label={label}
                aria-current={isActive ? "page" : undefined}
                className={`relative flex flex-1 flex-col items-center justify-center gap-0.5 min-h-[48px] min-w-[64px] py-2 landscape:py-1 text-xs transition-colors ${
                  isActive
                    ? "text-brand font-semibold"
                    : "text-foreground-secondary hover:text-foreground"
                }`}
              >
                {/* Active indicator pill */}
                {isActive && (
                  <span
                    className="absolute top-1 h-1 w-6 rounded-full bg-brand"
                    aria-hidden="true"
                  />
                )}
                <span className="relative">
                  <Icon icon={item.icon} size="md" />
                  {badge != null && badge > 0 && (
                    <span
                      className="absolute -right-2 -top-1.5 flex h-4 min-w-[16px] items-center justify-center rounded-full bg-brand px-1 text-[10px] font-bold leading-none text-white"
                      data-testid={`nav-badge-${item.routeKey}`}
                      aria-label={`${badge}`}
                    >
                      {badge > 99 ? "99+" : badge}
                    </span>
                  )}
                </span>
                <span>{label}</span>
              </Link>
            );
          })}

          {/* More button — opens drawer with secondary nav items */}
          <button
            type="button"
            onClick={openMore}
            aria-expanded={moreOpen}
            aria-haspopup="dialog"
            className={`relative flex flex-1 flex-col items-center justify-center gap-0.5 min-h-[48px] min-w-[64px] py-2 landscape:py-1 text-xs transition-colors ${
              isMoreActive
                ? "text-brand font-semibold"
                : "text-foreground-secondary hover:text-foreground"
            }`}
          >
            {isMoreActive && (
              <span
                className="absolute top-1 h-1 w-6 rounded-full bg-brand"
                aria-hidden="true"
              />
            )}
            <Icon icon={MoreHorizontal} size="md" />
            <span>{t("nav.more")}</span>
          </button>
        </div>
      </nav>

      {/* More drawer */}
      <MoreDrawer open={moreOpen} onClose={closeMore} />
    </>
  );
}
