"use client";

/**
 * ReformulationBadge — shows "Reformulated" when a product's score
 * changed by ≥10 points in a single snapshot.
 */

import { RefreshCw } from "lucide-react";
import { useTranslation } from "@/lib/i18n";
import { Icon } from "@/components/common/Icon";

interface ReformulationBadgeProps {
  detected: boolean;
  className?: string;
}

export function ReformulationBadge({
  detected,
  className,
}: Readonly<ReformulationBadgeProps>) {
  const { t } = useTranslation();

  if (!detected) return null;

  return (
    <span
      className={`inline-flex items-center gap-1 rounded-full bg-warning/10 px-2 py-0.5 text-xs font-medium text-warning ${className ?? ""}`}
      data-testid="reformulation-badge"
    >
      <Icon icon={RefreshCw} size="sm" />
      {t("watchlist.reformulated")}
    </span>
  );
}
