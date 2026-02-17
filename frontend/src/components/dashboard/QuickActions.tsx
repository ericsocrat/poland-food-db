"use client";

// ─── QuickActions — primary action buttons for dashboard ────────────────────

import Link from "next/link";
import { useTranslation } from "@/lib/i18n";

const ACTIONS = [
  { key: "scan", icon: "📷", href: "/app/scan" },
  { key: "search", icon: "🔍", href: "/app/search" },
  { key: "compare", icon: "⚖️", href: "/app/compare" },
  { key: "lists", icon: "📋", href: "/app/lists" },
] as const;

export function QuickActions() {
  const { t } = useTranslation();

  return (
    <section aria-label={t("dashboard.quickActions")}>
      <div className="grid grid-cols-4 gap-3">
        {ACTIONS.map((action) => (
          <Link
            key={action.key}
            href={action.href}
            className="card group flex flex-col items-center gap-2 py-4 text-center transition-all hover:shadow-md hover:scale-[1.02] active:scale-[0.98]"
          >
            <span className="text-2xl sm:text-3xl" aria-hidden="true">
              {action.icon}
            </span>
            <span className="text-xs font-medium text-foreground-secondary group-hover:text-foreground sm:text-sm">
              {t(`dashboard.action.${action.key}`)}
            </span>
          </Link>
        ))}
      </div>
    </section>
  );
}
