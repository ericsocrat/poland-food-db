"use client";

// ─── Settings sub-page tab navigation ───────────────────────────────────────

import { useTranslation } from "@/lib/i18n";
import { Bell, KeyRound, Shield, User, Utensils } from "lucide-react";
import Link from "next/link";
import { usePathname } from "next/navigation";

const TABS = [
  { key: "profile", href: "/app/settings", icon: User, matchExact: true },
  { key: "nutrition", href: "/app/settings/nutrition", icon: Utensils },
  { key: "notifications", href: "/app/settings/notifications", icon: Bell },
  { key: "privacy", href: "/app/settings/privacy", icon: Shield },
  { key: "account", href: "/app/settings/account", icon: KeyRound },
] as const;

export function SettingsNav() {
  const pathname = usePathname();
  const { t } = useTranslation();

  function isActive(tab: (typeof TABS)[number]) {
    if ("matchExact" in tab && tab.matchExact) return pathname === tab.href;
    return pathname.startsWith(tab.href);
  }

  return (
    <nav
      className="flex gap-1 overflow-x-auto border-b border-border pb-px"
      aria-label={t("a11y.settingsSections")}
    >
      {TABS.map((tab) => {
        const active = isActive(tab);
        const Icon = tab.icon;
        return (
          <Link
            key={tab.key}
            href={tab.href}
            className={`flex items-center gap-1.5 whitespace-nowrap px-3 py-2 text-sm font-medium transition-colors ${
              active
                ? "border-b-2 border-brand text-brand"
                : "text-foreground-secondary hover:text-foreground-primary"
            }`}
            aria-current={active ? "page" : undefined}
          >
            <Icon size={16} aria-hidden="true" />
            {t(`settings.tab${tab.key.charAt(0).toUpperCase() + tab.key.slice(1)}`)}
          </Link>
        );
      })}
    </nav>
  );
}
