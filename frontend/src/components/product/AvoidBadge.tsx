"use client";

// ─── AvoidBadge ─────────────────────────────────────────────────────────────
// Compact badge shown on product rows when a product is on the user's Avoid
// list. Uses the Zustand store for O(1) lookups — no network calls.

import { Ban } from "lucide-react";
import { useAvoidStore } from "@/stores/avoid-store";
import { useTranslation } from "@/lib/i18n";

interface AvoidBadgeProps {
  readonly productId: number;
}

export function AvoidBadge({ productId }: AvoidBadgeProps) {
  const isAvoided = useAvoidStore((s) => s.isAvoided(productId));
  const { t } = useTranslation();

  if (!isAvoided) return null;

  return (
    <span
      title={t("productActions.onAvoidList")}
      className="inline-flex flex-shrink-0 items-center gap-0.5 rounded-full bg-error/15 px-2 py-0.5 text-xs font-medium text-error"
    >
      <Ban size={12} aria-hidden="true" /> {t("productActions.avoid")}
    </span>
  );
}
