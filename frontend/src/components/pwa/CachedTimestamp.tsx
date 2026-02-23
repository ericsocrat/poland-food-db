"use client";

import { Clock } from "lucide-react";
import { timeAgo } from "@/lib/cache-manager";
import { useTranslation } from "@/lib/i18n";

interface CachedTimestampProps {
  readonly cachedAt: number;
}

/**
 * Shows "Cached 2h ago" badge when viewing a product from offline cache.
 */
export function CachedTimestamp({ cachedAt }: CachedTimestampProps) {
  const { t } = useTranslation();
  return (
    <output className="inline-flex items-center gap-1 rounded-full bg-amber-100 px-2.5 py-0.5 text-xs font-medium text-amber-700">
      <Clock size={12} aria-hidden="true" />
      {t("pwa.cachedAgo", { time: timeAgo(cachedAt) })}
    </output>
  );
}
