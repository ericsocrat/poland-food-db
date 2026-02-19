"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useTranslation } from "@/lib/i18n";
import {
  Award,
  Factory,
  BarChart3,
  FlaskConical,
  AlertTriangle,
  Tag,
  BadgeCheck,
  BookOpen,
} from "lucide-react";
import type { LucideIcon } from "lucide-react";

/** Topic definition for sidebar navigation. */
interface LearnTopic {
  readonly slug: string;
  readonly labelKey: string;
  readonly icon: LucideIcon;
}

/** All learn topics in display order. */
const TOPICS: LearnTopic[] = [
  { slug: "nutri-score", labelKey: "learn.nutriScore.title", icon: Award },
  { slug: "nova-groups", labelKey: "learn.novaGroups.title", icon: Factory },
  {
    slug: "unhealthiness-score",
    labelKey: "learn.unhealthinessScore.title",
    icon: BarChart3,
  },
  { slug: "additives", labelKey: "learn.additives.title", icon: FlaskConical },
  { slug: "allergens", labelKey: "learn.allergens.title", icon: AlertTriangle },
  { slug: "reading-labels", labelKey: "learn.readingLabels.title", icon: Tag },
  { slug: "confidence", labelKey: "learn.confidence.title", icon: BadgeCheck },
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
              ? "bg-brand-subtle text-brand"
              : "text-foreground-secondary hover:bg-surface-subtle hover:text-foreground"
          }`}
        >
          <BookOpen size={16} className="inline-block" aria-hidden="true" />{" "}
          {t("learn.hubTitle")}
        </Link>

        <div className="my-2 border-t" />

        {TOPICS.map(({ slug, labelKey, icon: TopicIcon }) => {
          const href = `/learn/${slug}`;
          const isActive = pathname === href;
          return (
            <Link
              key={slug}
              href={href}
              className={`block rounded-lg px-3 py-2 text-sm transition-colors ${
                isActive
                  ? "bg-brand-subtle font-medium text-brand"
                  : "text-foreground-secondary hover:bg-surface-subtle hover:text-foreground"
              }`}
              aria-current={isActive ? "page" : undefined}
            >
              <TopicIcon
                size={16}
                className="inline-block"
                aria-hidden="true"
              />{" "}
              {t(labelKey)}
            </Link>
          );
        })}
      </div>
    </nav>
  );
}

/** Re-export TOPICS for use in the hub page. */
export { TOPICS };
