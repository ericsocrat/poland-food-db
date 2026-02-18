"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useTranslation } from "@/lib/i18n";

/** Topic definition for sidebar navigation. */
interface LearnTopic {
  readonly slug: string;
  readonly labelKey: string;
  readonly icon: string;
}

/** All learn topics in display order. */
const TOPICS: LearnTopic[] = [
  { slug: "nutri-score", labelKey: "learn.nutriScore.title", icon: "🅰️" },
  { slug: "nova-groups", labelKey: "learn.novaGroups.title", icon: "🏭" },
  {
    slug: "unhealthiness-score",
    labelKey: "learn.unhealthinessScore.title",
    icon: "📊",
  },
  { slug: "additives", labelKey: "learn.additives.title", icon: "🧪" },
  { slug: "allergens", labelKey: "learn.allergens.title", icon: "⚠️" },
  { slug: "reading-labels", labelKey: "learn.readingLabels.title", icon: "🏷️" },
  { slug: "confidence", labelKey: "learn.confidence.title", icon: "✅" },
];

interface LearnSidebarProps {
  /** Optional additional classes. */
  readonly className?: string;
}

/**
 * Sidebar navigation for /learn/* pages.
 * Highlights the current topic. Hidden on mobile (shown as back link instead).
 */
export function LearnSidebar({ className = "" }: LearnSidebarProps) {
  const { t } = useTranslation();
  const pathname = usePathname();

  return (
    <nav
      aria-label={t("learn.sidebarLabel")}
      className={`hidden md:block ${className}`}
    >
      <div className="sticky top-20 space-y-1">
        <Link
          href="/learn"
          className={`block rounded-lg px-3 py-2 text-sm font-medium transition-colors ${
            pathname === "/learn"
              ? "bg-brand-50 text-brand-700 dark:bg-brand-950 dark:text-brand-400"
              : "text-foreground-secondary hover:bg-surface-subtle hover:text-foreground"
          }`}
        >
          📚 {t("learn.hubTitle")}
        </Link>

        <div className="my-2 border-t" />

        {TOPICS.map(({ slug, labelKey, icon }) => {
          const href = `/learn/${slug}`;
          const isActive = pathname === href;
          return (
            <Link
              key={slug}
              href={href}
              className={`block rounded-lg px-3 py-2 text-sm transition-colors ${
                isActive
                  ? "bg-brand-50 font-medium text-brand-700 dark:bg-brand-950 dark:text-brand-400"
                  : "text-foreground-secondary hover:bg-surface-subtle hover:text-foreground"
              }`}
              aria-current={isActive ? "page" : undefined}
            >
              <span aria-hidden="true">{icon}</span> {t(labelKey)}
            </Link>
          );
        })}
      </div>
    </nav>
  );
}

/** Re-export TOPICS for use in the hub page. */
export { TOPICS };
