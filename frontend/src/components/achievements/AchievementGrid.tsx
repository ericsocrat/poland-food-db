"use client";

// ─── AchievementGrid — groups achievements by category ───────────────────────
// Issue #51: Achievements v1
//
// Renders a responsive grid of AchievementCards, grouped by category.
// 4 columns on desktop, 2 on mobile.

import { useMemo } from "react";
import { useTranslation } from "@/lib/i18n";
import { AchievementCard } from "./AchievementCard";
import { CATEGORY_ORDER } from "@/hooks/use-achievements";
import type { AchievementDef, AchievementCategory } from "@/lib/types";

/* ── Props ────────────────────────────────────────────────────────────────── */

interface AchievementGridProps {
  readonly achievements: AchievementDef[];
}

/* ── Category label map ───────────────────────────────────────────────────── */

const CATEGORY_ICON: Record<AchievementCategory, string> = {
  exploration: "🧭",
  health: "💚",
  engagement: "🤝",
  mastery: "⭐",
};

/* ── Component ────────────────────────────────────────────────────────────── */

export function AchievementGrid({ achievements }: AchievementGridProps) {
  const { t } = useTranslation();

  // Group achievements by category
  const grouped = useMemo(() => {
    const map = new Map<AchievementCategory, AchievementDef[]>();
    for (const a of achievements) {
      const list = map.get(a.category) ?? [];
      list.push(a);
      map.set(a.category, list);
    }
    return map;
  }, [achievements]);

  return (
    <div className="space-y-8" data-testid="achievement-grid">
      {CATEGORY_ORDER.map((category) => {
        const items = grouped.get(category);
        if (!items?.length) return null;

        return (
          <section key={category} aria-labelledby={`cat-${category}`}>
            <h2
              id={`cat-${category}`}
              className="mb-4 flex items-center gap-2 text-lg font-bold text-foreground"
            >
              <span aria-hidden="true">{CATEGORY_ICON[category]}</span>
              {t(`achievements.category.${category}`)}
            </h2>

            <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4">
              {items.map((a) => (
                <AchievementCard key={a.id} achievement={a} />
              ))}
            </div>
          </section>
        );
      })}
    </div>
  );
}
