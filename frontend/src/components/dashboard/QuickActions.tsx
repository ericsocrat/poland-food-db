"use client";

// ─── QuickActions — primary action buttons for dashboard ────────────────────

import { useTranslation } from "@/lib/i18n";
import type { DashboardStats } from "@/lib/types";
import { Camera, ClipboardList, Scale, Search, type LucideIcon } from "lucide-react";
import Link from "next/link";

interface ActionDef {
  key: string;
  icon: LucideIcon;
  href: string;
  iconBg: string;
  badgeKey?: keyof Pick<DashboardStats, "lists_count" | "favorites_count">;
}

const ACTIONS: readonly ActionDef[] = [
  { key: "scan", icon: Camera, href: "/app/scan", iconBg: "bg-emerald-100 text-emerald-700 dark:bg-emerald-900/40 dark:text-emerald-400" },
  { key: "search", icon: Search, href: "/app/search", iconBg: "bg-blue-100 text-blue-700 dark:bg-blue-900/40 dark:text-blue-400" },
  { key: "compare", icon: Scale, href: "/app/compare", iconBg: "bg-amber-100 text-amber-700 dark:bg-amber-900/40 dark:text-amber-400" },
  { key: "lists", icon: ClipboardList, href: "/app/lists", iconBg: "bg-purple-100 text-purple-700 dark:bg-purple-900/40 dark:text-purple-400", badgeKey: "lists_count" },
];

interface QuickActionsProps {
  stats?: DashboardStats | null;
}

export function QuickActions({ stats }: QuickActionsProps) {
  const { t } = useTranslation();

  return (
    <section aria-label={t("dashboard.quickActions")} data-testid="quick-actions">
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-4 lg:gap-4">
        {ACTIONS.map((action, index) => {
          const badge = action.badgeKey && stats?.[action.badgeKey];
          return (
            <Link
              key={action.key}
              href={action.href}
              className="card group relative flex flex-col items-center gap-2 py-4 text-center transition-transform transition-shadow duration-200 hover:scale-[1.04] hover:shadow-md lg:py-6"
              style={{
                animation: `bounceIn 400ms ease-out ${index * 100}ms both`,
              }}
            >
              <span
                className={`flex h-10 w-10 items-center justify-center rounded-xl ${action.iconBg}`}
                aria-hidden="true"
              >
                <action.icon size={22} />
              </span>
              <span className="text-xs font-medium text-foreground-secondary group-hover:text-foreground sm:text-sm lg:text-base">
                {t(`dashboard.action.${action.key}`)}
              </span>
              {typeof badge === "number" && badge > 0 && (
                <span
                  className="absolute -top-1 -right-1 flex h-5 min-w-5 items-center justify-center rounded-full bg-brand-primary px-1 text-[10px] font-bold text-white"
                  aria-label={`${badge}`}
                >
                  {badge > 99 ? "99+" : badge}
                </span>
              )}
            </Link>
          );
        })}
      </div>
    </section>
  );
}
