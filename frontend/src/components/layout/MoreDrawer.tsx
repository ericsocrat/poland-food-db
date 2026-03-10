"use client";

// ─── MoreDrawer — slide-up sheet for secondary mobile nav items ──────────────
// Opened from the "More" button in the mobile bottom Navigation bar.
// Groups items into semantic sections with visual dividers.
//
// Issue #67 — Navigation & IA Polish
// Issue #692 — Group items, drag handle, swipe-to-dismiss

import { Icon } from "@/components/common/Icon";
import { useActiveRoute, type PrimaryRouteKey } from "@/hooks/use-active-route";
import { useTranslation } from "@/lib/i18n";
import { useAdminStore } from "@/stores/admin-store";
import {
    BookOpen,
    Eye,
    FolderOpen,
    Scale,
    ScanText,
    Settings,
    ShieldCheck,
    Trophy,
    UtensilsCrossed,
    X,
    type LucideIcon,
} from "lucide-react";
import Link from "next/link";
import { useCallback, useEffect, useRef, useState } from "react";

/* ── Types ────────────────────────────────────────────────────────────────── */

interface DrawerNavItem {
  readonly href: string;
  readonly labelKey: string;
  readonly icon: LucideIcon;
  readonly routeKey: PrimaryRouteKey;
}

interface DrawerSection {
  readonly labelKey: string;
  readonly items: readonly DrawerNavItem[];
}

/* ── Section definitions ──────────────────────────────────────────────────── */

const DRAWER_SECTIONS: readonly DrawerSection[] = [
  {
    labelKey: "nav.sectionBrowse",
    items: [
      { href: "/app/categories", labelKey: "nav.categories", icon: FolderOpen, routeKey: "categories" },
      { href: "/app/recipes", labelKey: "nav.recipes", icon: UtensilsCrossed, routeKey: "recipes" },
      { href: "/app/image-search", labelKey: "nav.imageSearch", icon: ScanText, routeKey: "image-search" },
    ],
  },
  {
    labelKey: "nav.sectionYourStuff",
    items: [
      { href: "/app/compare", labelKey: "nav.compare", icon: Scale, routeKey: "compare" },
      { href: "/app/watchlist", labelKey: "nav.watchlist", icon: Eye, routeKey: "watchlist" },
      { href: "/app/achievements", labelKey: "nav.achievements", icon: Trophy, routeKey: "achievements" },
    ],
  },
  {
    labelKey: "nav.sectionApp",
    items: [
      { href: "/learn", labelKey: "nav.learn", icon: BookOpen, routeKey: null },
      { href: "/app/settings", labelKey: "nav.settings", icon: Settings, routeKey: "settings" },
    ],
  },
  {
    labelKey: "nav.admin",
    items: [
      { href: "/app/admin/submissions", labelKey: "nav.admin", icon: ShieldCheck, routeKey: null },
    ],
  },
];

const SWIPE_DISMISS_THRESHOLD = 80;

/* ── Props ────────────────────────────────────────────────────────────────── */

interface MoreDrawerProps {
  open: boolean;
  onClose: () => void;
}

/* ── Component ────────────────────────────────────────────────────────────── */

export function MoreDrawer({ open, onClose }: Readonly<MoreDrawerProps>) {
  const activeRoute = useActiveRoute();
  const { t } = useTranslation();
  const isAdmin = useAdminStore((s) => s.isAdmin);
  const drawerRef = useRef<HTMLDialogElement>(null);
  const [animating, setAnimating] = useState(false);
  const touchStartY = useRef(0);
  const touchDeltaY = useRef(0);

  // Track mount animation
  useEffect(() => {
    if (open) {
      requestAnimationFrame(() => setAnimating(true));
    } else {
      setAnimating(false);
    }
  }, [open]);

  // Close on Escape
  useEffect(() => {
    if (!open) return;
    function handleKeyDown(e: KeyboardEvent) {
      if (e.key === "Escape") onClose();
    }
    document.addEventListener("keydown", handleKeyDown);
    return () => document.removeEventListener("keydown", handleKeyDown);
  }, [open, onClose]);

  // Trap focus inside drawer when open
  useEffect(() => {
    if (!open || !drawerRef.current) return;
    const firstFocusable = drawerRef.current.querySelector<HTMLElement>(
      'a, button, [tabindex]:not([tabindex="-1"])',
    );
    firstFocusable?.focus();
  }, [open]);

  // Swipe-to-dismiss handlers
  const handleTouchStart = useCallback((e: React.TouchEvent) => {
    touchStartY.current = e.touches[0].clientY;
    touchDeltaY.current = 0;
  }, []);

  const handleTouchMove = useCallback((e: React.TouchEvent) => {
    const delta = e.touches[0].clientY - touchStartY.current;
    touchDeltaY.current = delta;
    if (delta > 0 && drawerRef.current) {
      drawerRef.current.style.transform = `translateY(${delta}px)`;
    }
  }, []);

  const handleTouchEnd = useCallback(() => {
    if (touchDeltaY.current > SWIPE_DISMISS_THRESHOLD) {
      onClose();
    }
    if (drawerRef.current) {
      drawerRef.current.style.transform = "";
    }
  }, [onClose]);

  if (!open) return null;

  return (
    /* Backdrop */
    <div
      className={`fixed inset-0 z-50 transition-colors duration-200 ${
        animating ? "bg-black/40" : "bg-transparent"
      }`}
    >
      <button
        type="button"
        className="absolute inset-0 h-full w-full"
        onClick={onClose}
        aria-label={t("shortcuts.closeOverlay")}
      />

      {/* Drawer panel */}
      <dialog
        ref={drawerRef}
        open
        aria-label={t("a11y.moreNavigation")}
        className={`fixed bottom-0 left-0 right-0 z-50 m-0 w-full max-w-full transform rounded-t-2xl border-t border-border bg-surface p-0 pb-[env(safe-area-inset-bottom)] transition-transform duration-200 ease-out ${
          animating ? "translate-y-0" : "translate-y-full"
        }`}
        onTouchStart={handleTouchStart}
        onTouchMove={handleTouchMove}
        onTouchEnd={handleTouchEnd}
      >
        {/* Drag handle */}
        <div className="flex justify-center pt-2 pb-1">
          <div className="h-1 w-8 rounded-full bg-border" />
        </div>

        {/* Header + close */}
        <div className="flex items-center justify-between px-4 py-2">
          <span className="text-sm font-semibold text-foreground">
            {t("nav.more")}
          </span>
          <button
            type="button"
            onClick={onClose}
            className="touch-target rounded-full p-1.5 text-foreground-secondary hover:bg-surface-muted hover:text-foreground transition-colors"
            aria-label={t("common.close")}
          >
            <Icon icon={X} size="md" />
          </button>
        </div>

        {/* Grouped nav items */}
        <nav aria-label={t("a11y.moreNavigation")}>
          <div className="px-2 pb-4">
            {DRAWER_SECTIONS.filter(
              (s) => s.labelKey !== "nav.admin" || isAdmin,
            ).map((section, sectionIdx) => (
              <div key={section.labelKey}>
                {/* Section divider (not before first section) */}
                {sectionIdx > 0 && (
                  <div className="mx-3 my-1.5 border-t border-border" />
                )}
                {/* Section label */}
                <p className="px-3 pt-2 pb-1 text-xs font-semibold uppercase tracking-wider text-foreground-muted">
                  {t(section.labelKey)}
                </p>
                <ul>
                  {section.items.map((item) => {
                    const isActive = activeRoute === item.routeKey;
                    const label = t(item.labelKey);
                    return (
                      <li key={item.href}>
                        <Link
                          href={item.href}
                          onClick={onClose}
                          aria-current={isActive ? "page" : undefined}
                          className={`flex min-h-[48px] items-center gap-3 rounded-xl px-3 py-3 text-sm font-medium transition-colors ${
                            isActive
                              ? "border-l-3 border-brand bg-brand-subtle text-brand font-semibold"
                              : "text-foreground-secondary hover:bg-surface-muted hover:text-foreground"
                          }`}
                        >
                          <Icon icon={item.icon} size="md" />
                          <span>{label}</span>
                        </Link>
                      </li>
                    );
                  })}
                </ul>
              </div>
            ))}
          </div>
        </nav>
      </dialog>
    </div>
  );
}
