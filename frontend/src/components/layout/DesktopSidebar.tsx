"use client";

// ─── DesktopSidebar — persistent left sidebar for xl+ viewports ──────────────
// Renders a fixed sidebar with primary and secondary nav sections.
// Hidden below xl breakpoint (1280px). CSS-only show/hide, no JS.
//
// Issue #72 — Desktop Navigation Architecture

import { Icon } from "@/components/common/Icon";
import { Logo } from "@/components/common/Logo";
import { useActiveRoute, type PrimaryRouteKey } from "@/hooks/use-active-route";
import { useTranslation } from "@/lib/i18n";
import {
    Activity,
    BookOpen,
    Camera,
    ClipboardList,
    Eye,
    FileText,
    FolderOpen,
    Gauge,
    Home,
    Scale,
    ScanText,
    Search,
    Settings,
    ShieldCheck,
    Trophy,
    UtensilsCrossed,
    type LucideIcon,
} from "lucide-react";
import Link from "next/link";
import { usePathname } from "next/navigation";

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
  {
    href: "/app/image-search",
    labelKey: "nav.imageSearch",
    icon: ScanText,
    routeKey: "image-search",
  },
] as const;

const SECONDARY_ITEMS: readonly SidebarNavItem[] = [
  {
    href: "/learn",
    labelKey: "nav.learn",
    icon: BookOpen,
    routeKey: null,
  },
  {
    href: "/app/settings",
    labelKey: "nav.settings",
    icon: Settings,
    routeKey: "settings",
  },
] as const;

/* ── Admin items (middleware-gated, shown unconditionally for discoverability) */

interface AdminNavItem {
  readonly href: string;
  readonly labelKey: string;
  readonly icon: LucideIcon;
}

const ADMIN_ITEMS: readonly AdminNavItem[] = [
  {
    href: "/app/admin/submissions",
    labelKey: "nav.adminSubmissions",
    icon: FileText,
  },
  {
    href: "/app/admin/metrics",
    labelKey: "nav.adminMetrics",
    icon: Gauge,
  },
  {
    href: "/app/admin/monitoring",
    labelKey: "nav.adminMonitoring",
    icon: Activity,
  },
] as const;

/* ── Component ────────────────────────────────────────────────────────────── */

export function DesktopSidebar() {
  const activeRoute = useActiveRoute();
  const pathname = usePathname();
  const { t } = useTranslation();

  return (
    <nav
      className="fixed inset-y-0 left-0 z-30 hidden w-56 flex-col border-r border-border bg-surface xl:flex"
      aria-label={t("a11y.sidebarNavigation")}
    >
      {/* Logo */}
      <div className="flex h-14 items-center px-5">
        <Link href="/app" aria-label="TryVit">
          <Logo variant="lockup" size={24} />
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

      {/* Divider + admin nav (access gated by middleware) */}
      <div className="border-t border-border px-3 py-2">
        <div className="mb-1 flex items-center gap-2 px-3 pt-1 pb-1.5">
          <Icon icon={ShieldCheck} size="sm" className="text-foreground-tertiary" />
          <span className="text-xs font-semibold uppercase tracking-wider text-foreground-tertiary">
            {t("nav.admin")}
          </span>
        </div>
        {ADMIN_ITEMS.map((item) => {
          const label = t(item.labelKey);
          const isActive =
            activeRoute === "admin" &&
            pathname.startsWith(item.href);
          return (
            <Link
              key={item.href}
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
        })}
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
