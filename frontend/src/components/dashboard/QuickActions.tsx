"use client";

// ─── QuickActions — primary action buttons for dashboard ────────────────────

import { useTranslation } from "@/lib/i18n";
import { Camera, ClipboardList, Scale, Search, type LucideIcon } from "lucide-react";
import Link from "next/link";

const ACTIONS: readonly { key: string; icon: LucideIcon; href: string }[] = [
  { key: "scan", icon: Camera, href: "/app/scan" },
  { key: "search", icon: Search, href: "/app/search" },
  { key: "compare", icon: Scale, href: "/app/compare" },
  { key: "lists", icon: ClipboardList, href: "/app/lists" },
];

export function QuickActions() {
  const { t } = useTranslation();

  return (
    <section aria-label={t("dashboard.quickActions")} data-testid="quick-actions">
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-4 lg:gap-4">
        {ACTIONS.map((action) => (
          <Link
            key={action.key}
            href={action.href}
            className="card hover-lift-press group flex flex-col items-center gap-2 py-4 text-center transition-shadow hover:shadow-md lg:py-6"
          >
            <span
              className="flex items-center justify-center"
              aria-hidden="true"
            >
              <action.icon size={28} />
            </span>
            <span className="text-xs font-medium text-foreground-secondary group-hover:text-foreground sm:text-sm lg:text-base">
              {t(`dashboard.action.${action.key}`)}
            </span>
          </Link>
        ))}
      </div>
    </section>
  );
}
