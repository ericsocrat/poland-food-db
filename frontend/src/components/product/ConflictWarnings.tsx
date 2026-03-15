"use client";

import { useTranslation } from "@/lib/i18n";
import type { ConflictItem, NutriGrade } from "@/lib/types";
import { AlertTriangle, Info } from "lucide-react";

// ─── Severity Config ────────────────────────────────────────────────────────

const severityConfig = {
  high: {
    icon: AlertTriangle,
    containerClass: "bg-warning/10 border-warning/30",
    iconClass: "text-warning",
    textClass: "text-warning",
  },
  medium: {
    icon: AlertTriangle,
    containerClass: "bg-amber-50 border-amber-200 dark:bg-amber-900/20 dark:border-amber-800/40",
    iconClass: "text-amber-500 dark:text-amber-400",
    textClass: "text-amber-700 dark:text-amber-300",
  },
  info: {
    icon: Info,
    containerClass: "bg-blue-50 border-blue-200 dark:bg-blue-900/20 dark:border-blue-800/40",
    iconClass: "text-blue-500 dark:text-blue-400",
    textClass: "text-blue-700 dark:text-blue-300",
  },
} as const;

// ─── Props ──────────────────────────────────────────────────────────────────

interface ConflictWarningsProps {
  readonly conflicts: ConflictItem[];
  readonly nutriScoreLabel?: NutriGrade;
}

// ─── Component ──────────────────────────────────────────────────────────────

export function ConflictWarnings({
  conflicts,
  nutriScoreLabel,
}: ConflictWarningsProps) {
  const { t } = useTranslation();

  if (conflicts.length === 0) return null;

  return (
    <div className="space-y-2" data-testid="conflict-warnings">
      <p className="text-xs font-semibold text-foreground-secondary">
        {t("conflicts.title")}
      </p>
      {conflicts.map((c) => {
        const cfg = severityConfig[c.severity] ?? severityConfig.info;
        const Icon = cfg.icon;
        const needsGrade =
          c.key === "nutri_score_poor" || c.key === "nutri_score_favorable";
        const label = needsGrade
          ? t(`conflicts.${c.key}`, { grade: nutriScoreLabel ?? "?" })
          : t(`conflicts.${c.key}`);

        return (
          <div
            key={c.rule}
            className={`flex items-start gap-2 rounded-lg border px-3 py-2 ${cfg.containerClass}`}
          >
            <Icon
              size={14}
              className={`mt-0.5 shrink-0 ${cfg.iconClass}`}
              aria-hidden="true"
            />
            <span className={`text-xs ${cfg.textClass}`}>{label}</span>
          </div>
        );
      })}
    </div>
  );
}
