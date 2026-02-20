"use client";

// ─── DesktopSidebar — persistent left sidebar for xl+ viewports ──────────────
// Renders a fixed sidebar with primary and secondary nav sections.
// Hidden below xl breakpoint (1280px). CSS-only show/hide, no JS.
//
// Issue #72 — Desktop Navigation Architecture

import Link from "next/link";
import { useActiveRoute, type PrimaryRouteKey } from "@/hooks/use-active-route";
import { useTranslation } from "@/lib/i18n";
import { Icon } from "@/components/common/Icon";
import {
  Home,
  Search,
  Camera,
  ClipboardList,
  Eye,
  Scale,
  FolderOpen,
  Trophy,
  UtensilsCrossed,
  Settings,
} from "lucide-react";
import type { LucideIcon } from "lucide-react";

/* ── Nav item type ────────────────────────────────────────────────────────── */

interface SidebarNavItem {
  readonly href: string;
  readonly labelKey: string;
  readonly icon: LucideIcon;
  readonly routeKey: PrimaryRouteKey;
}

/* ── Route definitions ────────────────────────────────────────────────────── */

const PRIMARY_ITEMS: readonly SidebarNavItem[] = [
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
    href: "/app/watchlist",
    labelKey: "nav.watchlist",
    icon: Eye,
    routeKey: "watchlist",
  },
  {
    href: "/app/compare",
    labelKey: "nav.compare",
    icon: Scale,
    routeKey: "compare",
  },
  {
    href: "/app/categories",
    labelKey: "nav.categories",
    icon: FolderOpen,
    routeKey: "categories",
  },
  {
    href: "/app/achievements",
    labelKey: "nav.achievements",
    icon: Trophy,
    routeKey: "achievements",
  },
  {
    href: "/app/recipes",
    labelKey: "nav.recipes",
    icon: UtensilsCrossed,
    routeKey: "recipes",
  },
] as const;

const SECONDARY_ITEMS: readonly SidebarNavItem[] = [
  {
    href: "/app/settings",
    labelKey: "nav.settings",
    icon: Settings,
    routeKey: "settings",
  },
] as const;

/* ── Component ────────────────────────────────────────────────────────────── */

export function DesktopSidebar() {
  const activeRoute = useActiveRoute();
  const { t } = useTranslation();

  return (
    <nav
      className="fixed inset-y-0 left-0 z-30 hidden w-56 flex-col border-r border-border bg-surface xl:flex"
      aria-label={t("a11y.sidebarNavigation")}
    >
      {/* Logo */}
      <div className="flex h-14 items-center px-5">
        <Link href="/app" className="text-lg font-bold text-brand">
          {t("layout.appNameWithEmoji")}
        </Link>
      </div>

      {/* Primary nav */}
      <div className="flex-1 space-y-0.5 px-3 py-2">
        {PRIMARY_ITEMS.map((item) => (
          <SidebarLink
            key={item.href}
            item={item}
            isActive={activeRoute === item.routeKey}
          />
        ))}
      </div>

      {/* Divider + secondary nav */}
      <div className="border-t border-border px-3 py-2">
        {SECONDARY_ITEMS.map((item) => (
          <SidebarLink
            key={item.href}
            item={item}
            isActive={activeRoute === item.routeKey}
          />
        ))}
      </div>
    </nav>
  );
}

/* ── Sidebar link ─────────────────────────────────────────────────────────── */

function SidebarLink({
  item,
  isActive,
}: Readonly<{
  item: SidebarNavItem;
  isActive: boolean;
}>) {
  const { t } = useTranslation();
  const label = t(item.labelKey);

  return (
    <Link
      href={item.href}
      aria-current={isActive ? "page" : undefined}
      className={`flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors ${
        isActive
          ? "border-l-3 border-brand bg-brand-subtle font-semibold text-brand"
          : "text-foreground-secondary hover:bg-surface-muted hover:text-foreground"
      }`}
    >
      <Icon icon={item.icon} size="md" />
      <span>{label}</span>
    </Link>
  );
}
