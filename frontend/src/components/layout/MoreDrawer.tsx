"use client";

// ─── MoreDrawer — slide-up sheet for secondary mobile nav items ──────────────
// Opened from the "More" button in the mobile bottom Navigation bar.
// Shows Compare, Categories, Watchlist, Settings, and Admin (role-gated).
//
// Issue #67 — Navigation & IA Polish

import { useCallback, useEffect, useRef, useState } from "react";
import Link from "next/link";
import { useActiveRoute, type PrimaryRouteKey } from "@/hooks/use-active-route";
import { useTranslation } from "@/lib/i18n";
import { Icon } from "@/components/common/Icon";
import {
  Scale,
  FolderOpen,
  Eye,
  Settings,
  ShieldCheck,
  Trophy,
  X,
} from "lucide-react";
import type { LucideIcon } from "lucide-react";

/* ── Types ────────────────────────────────────────────────────────────────── */

interface DrawerNavItem {
  readonly href: string;
  readonly labelKey: string;
  readonly icon: LucideIcon;
  readonly routeKey: PrimaryRouteKey;
}

/* ── Route definitions ────────────────────────────────────────────────────── */

const DRAWER_ITEMS: readonly DrawerNavItem[] = [
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
    href: "/app/watchlist",
    labelKey: "nav.watchlist",
    icon: Eye,
    routeKey: "watchlist",
  },
  {
    href: "/app/settings",
    labelKey: "nav.settings",
    icon: Settings,
    routeKey: "settings",
  },
  {
    href: "/app/achievements",
    labelKey: "nav.achievements",
    icon: Trophy,
    routeKey: "achievements",
  },
  {
    href: "/app/admin/submissions",
    labelKey: "nav.admin",
    icon: ShieldCheck,
    routeKey: null,
  },
] as const;

/* ── Props ────────────────────────────────────────────────────────────────── */

interface MoreDrawerProps {
  open: boolean;
  onClose: () => void;
}

/* ── Component ────────────────────────────────────────────────────────────── */

export function MoreDrawer({ open, onClose }: Readonly<MoreDrawerProps>) {
  const activeRoute = useActiveRoute();
  const { t } = useTranslation();
  const drawerRef = useRef<HTMLDialogElement>(null);
  const [animating, setAnimating] = useState(false);

  // Track mount animation
  useEffect(() => {
    if (open) {
      // Force reflow then animate in
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

  const handleBackdropClick = useCallback(
    (e: React.MouseEvent | React.KeyboardEvent) => {
      if ("key" in e && e.key !== "Enter" && e.key !== " ") return;
      if ("target" in e && "currentTarget" in e && e.target === e.currentTarget) onClose();
    },
    [onClose],
  );

  if (!open) return null;

  return (
    /* Backdrop */
    <div
      className={`fixed inset-0 z-50 transition-colors duration-200 ${
        animating ? "bg-black/40" : "bg-transparent"
      }`}
      role="presentation"
      onClick={handleBackdropClick}
      onKeyDown={handleBackdropClick}
    >
      {/* Drawer panel — uses native <dialog> for built-in accessibility */}
      <dialog
        ref={drawerRef}
        open
        aria-label={t("a11y.moreNavigation")}
        className={`fixed bottom-0 left-0 right-0 z-50 m-0 w-full max-w-full transform rounded-t-2xl border-t border-border bg-surface p-0 pb-[env(safe-area-inset-bottom)] transition-transform duration-200 ease-out ${
          animating ? "translate-y-0" : "translate-y-full"
        }`}
      >
        {/* Drag handle + close */}
        <div className="flex items-center justify-between px-4 py-3">
          <span className="text-sm font-semibold text-foreground">
            {t("nav.more")}
          </span>
          <button
            type="button"
            onClick={onClose}
            className="rounded-full p-1.5 text-foreground-secondary hover:bg-surface-muted hover:text-foreground transition-colors"
            aria-label={t("common.close")}
          >
            <Icon icon={X} size="md" />
          </button>
        </div>

        {/* Nav items */}
        <nav aria-label={t("a11y.moreNavigation")}>
          <ul className="px-2 pb-4">
            {DRAWER_ITEMS.map((item) => {
              const isActive = activeRoute === item.routeKey;
              const label = t(item.labelKey);
              return (
                <li key={item.href}>
                  <Link
                    href={item.href}
                    onClick={onClose}
                    aria-current={isActive ? "page" : undefined}
                    className={`flex items-center gap-3 rounded-xl px-3 py-3 text-sm font-medium transition-colors ${
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
        </nav>
      </dialog>
    </div>
  );
}
