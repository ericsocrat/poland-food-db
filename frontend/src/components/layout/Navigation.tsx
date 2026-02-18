"use client";

// ─── Bottom navigation for the app shell ────────────────────────────────────

import Link from "next/link";
import { useActiveRoute, type PrimaryRouteKey } from "@/hooks/use-active-route";
import { useTranslation } from "@/lib/i18n";
import { Icon } from "@/components/common/Icon";
import { Home, Search, Camera, ClipboardList, Settings } from "lucide-react";
import type { LucideIcon } from "lucide-react";

interface NavItem {
  href: string;
  labelKey: string;
  icon: LucideIcon;
  routeKey: PrimaryRouteKey;
}

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
  {
    href: "/app/settings",
    labelKey: "nav.settings",
    icon: Settings,
    routeKey: "settings",
  },
];

export function Navigation() {
  const activeRoute = useActiveRoute();
  const { t } = useTranslation();

  return (
    <nav
      className="sticky bottom-0 z-40 border-t border-border bg-surface pb-[env(safe-area-inset-bottom)]"
      aria-label="Main navigation"
    >
      <div className="mx-auto flex max-w-5xl">
        {NAV_ITEMS.map((item) => {
          const isActive = activeRoute === item.routeKey;
          const label = t(item.labelKey);
          return (
            <Link
              key={item.href}
              href={item.href}
              aria-label={label}
              aria-current={isActive ? "page" : undefined}
              className={`relative flex flex-1 flex-col items-center justify-center gap-0.5 min-h-[48px] min-w-[64px] py-2 landscape:py-1 text-xs transition-colors ${
                isActive
                  ? "text-brand-700 font-semibold dark:text-brand-400"
                  : "text-foreground-secondary hover:text-foreground"
              }`}
            >
              {/* Active indicator pill */}
              {isActive && (
                <span
                  className="absolute top-1 h-1 w-6 rounded-full bg-brand-600 dark:bg-brand-400"
                  aria-hidden="true"
                />
              )}
              <Icon icon={item.icon} size="md" />
              <span>{label}</span>
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
