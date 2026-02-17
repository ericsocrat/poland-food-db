"use client";

// ─── Bottom navigation for the app shell ────────────────────────────────────

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useTranslation } from "@/lib/i18n";

const NAV_ITEMS = [
  { href: "/app", labelKey: "nav.home", icon: "🏠", exact: true },
  { href: "/app/search", labelKey: "nav.search", icon: "🔍", exact: false },
  { href: "/app/scan", labelKey: "nav.scan", icon: "📷", exact: false },
  { href: "/app/lists", labelKey: "nav.lists", icon: "📋", exact: false },
  { href: "/app/settings", labelKey: "nav.settings", icon: "⚙️", exact: false },
];

export function Navigation() {
  const pathname = usePathname();
  const { t } = useTranslation();

  return (
    <nav
      className="sticky bottom-0 z-40 border-t border-border bg-surface pb-[env(safe-area-inset-bottom)]"
      aria-label="Main navigation"
    >
      <div className="mx-auto flex max-w-5xl">
        {NAV_ITEMS.map((item) => {
          const isActive = item.exact
            ? pathname === item.href
            : pathname.startsWith(item.href);
          const label = t(item.labelKey);
          return (
            <Link
              key={item.href}
              href={item.href}
              aria-label={label}
              aria-current={isActive ? "page" : undefined}
              className={`flex flex-1 flex-col items-center justify-center gap-0.5 min-h-[48px] min-w-[64px] py-2 landscape:py-1 text-xs transition-colors ${
                isActive
                  ? "text-brand-700 font-semibold"
                  : "text-foreground-secondary hover:text-foreground"
              }`}
            >
              <span className="text-xl">{item.icon}</span>
              <span>{label}</span>
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
