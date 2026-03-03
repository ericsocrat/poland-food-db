"use client";

// ─── DesktopHeaderNav — horizontal nav links for lg–xl viewports ─────────────
// Renders inline primary nav links + a "More" dropdown for secondary items.
// Hidden below lg (1024px) and at xl+ (1280px) where sidebar takes over.
//
// Issue #72  — Desktop Navigation Architecture
// Issue #575 — Align navigation items across desktop breakpoints

import { Icon } from "@/components/common/Icon";
import { useActiveRoute, type PrimaryRouteKey } from "@/hooks/use-active-route";
import { useTranslation } from "@/lib/i18n";
import {
  BookOpen,
  ChevronDown,
  ScanText,
  Settings,
  ShieldCheck,
  Trophy,
  UtensilsCrossed,
  type LucideIcon,
} from "lucide-react";
import Link from "next/link";
import { useCallback, useEffect, useRef, useState } from "react";

/* ── Types ────────────────────────────────────────────────────────────────── */

interface HeaderNavItem {
  readonly href: string;
  readonly labelKey: string;
  readonly routeKey: PrimaryRouteKey;
}

interface DropdownNavItem {
  readonly href: string;
  readonly labelKey: string;
  readonly icon: LucideIcon;
  readonly routeKey: PrimaryRouteKey;
}

/* ── Route definitions ────────────────────────────────────────────────────── */

/** Primary items — always visible as inline text links. */
const PRIMARY_ITEMS: readonly HeaderNavItem[] = [
  { href: "/app", labelKey: "nav.home", routeKey: "home" },
  { href: "/app/search", labelKey: "nav.search", routeKey: "search" },
  { href: "/app/scan", labelKey: "nav.scan", routeKey: "scan" },
  { href: "/app/lists", labelKey: "nav.lists", routeKey: "lists" },
  { href: "/app/watchlist", labelKey: "nav.watchlist", routeKey: "watchlist" },
  { href: "/app/compare", labelKey: "nav.compare", routeKey: "compare" },
  {
    href: "/app/categories",
    labelKey: "nav.categories",
    routeKey: "categories",
  },
] as const;

/** Secondary items — grouped under the "More" dropdown. */
const DROPDOWN_ITEMS: readonly DropdownNavItem[] = [
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
  {
    href: "/app/admin/submissions",
    labelKey: "nav.admin",
    icon: ShieldCheck,
    routeKey: "admin",
  },
] as const;

/* ── Component ────────────────────────────────────────────────────────────── */

export function DesktopHeaderNav() {
  const activeRoute = useActiveRoute();
  const { t } = useTranslation();
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  const closeDropdown = useCallback(() => setDropdownOpen(false), []);

  // Close on outside click
  useEffect(() => {
    if (!dropdownOpen) return;
    function handleClick(e: MouseEvent) {
      if (
        dropdownRef.current &&
        !dropdownRef.current.contains(e.target as Node)
      ) {
        closeDropdown();
      }
    }
    document.addEventListener("mousedown", handleClick);
    return () => document.removeEventListener("mousedown", handleClick);
  }, [dropdownOpen, closeDropdown]);

  // Close on Escape
  useEffect(() => {
    if (!dropdownOpen) return;
    function handleKeyDown(e: KeyboardEvent) {
      if (e.key === "Escape") closeDropdown();
    }
    document.addEventListener("keydown", handleKeyDown);
    return () => document.removeEventListener("keydown", handleKeyDown);
  }, [dropdownOpen, closeDropdown]);

  const isDropdownItemActive = DROPDOWN_ITEMS.some(
    (item) => item.routeKey && activeRoute === item.routeKey,
  );

  return (
    <nav
      className="hidden items-center gap-1 lg:flex xl:hidden"
      aria-label={t("a11y.headerNavigation")}
    >
      {/* Primary inline links */}
      {PRIMARY_ITEMS.map((item) => {
        const isActive = activeRoute === item.routeKey;
        const label = t(item.labelKey);
        return (
          <Link
            key={item.href}
            href={item.href}
            aria-current={isActive ? "page" : undefined}
            className={`relative rounded-md px-2.5 py-1.5 text-sm font-medium transition-colors ${
              isActive
                ? "text-brand"
                : "text-foreground-secondary hover:bg-surface-muted hover:text-foreground"
            }`}
          >
            {label}
            {isActive && (
              <span className="absolute bottom-0 left-1/2 h-0.5 w-4 -translate-x-1/2 rounded-full bg-brand" />
            )}
          </Link>
        );
      })}

      {/* "More" dropdown for secondary items */}
      <div ref={dropdownRef} className="relative">
        <button
          type="button"
          onClick={() => setDropdownOpen((prev) => !prev)}
          aria-expanded={dropdownOpen}
          aria-haspopup="true"
          className={`flex items-center gap-1 rounded-md px-2.5 py-1.5 text-sm font-medium transition-colors ${
            isDropdownItemActive
              ? "text-brand"
              : "text-foreground-secondary hover:bg-surface-muted hover:text-foreground"
          }`}
        >
          {t("nav.more")}
          <Icon
            icon={ChevronDown}
            size="sm"
            className={`transition-transform ${dropdownOpen ? "rotate-180" : ""}`}
          />
        </button>

        {dropdownOpen && (
          <div
            className="absolute right-0 top-full z-50 mt-1 w-52 rounded-lg border border-border bg-surface py-1 shadow-lg"
            role="menu"
          >
            {DROPDOWN_ITEMS.map((item) => {
              const isActive = item.routeKey
                ? activeRoute === item.routeKey
                : false;
              const label = t(item.labelKey);
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  role="menuitem"
                  aria-current={isActive ? "page" : undefined}
                  onClick={closeDropdown}
                  className={`flex items-center gap-3 px-4 py-2.5 text-sm font-medium transition-colors ${
                    isActive
                      ? "bg-brand-subtle text-brand"
                      : "text-foreground-secondary hover:bg-surface-muted hover:text-foreground"
                  }`}
                >
                  <Icon icon={item.icon} size="md" />
                  <span>{label}</span>
                </Link>
              );
            })}
          </div>
        )}
      </div>
    </nav>
  );
}
