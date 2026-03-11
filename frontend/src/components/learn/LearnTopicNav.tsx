"use client";

import { useTranslation } from "@/lib/i18n";
import { ChevronLeft, ChevronRight } from "lucide-react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { TOPICS } from "./LearnSidebar";

// ─── Previous / Next topic navigation ──────────────────────────────

/**
 * Bottom navigation for /learn/* topic pages.
 * Shows prev/next topic links for easy sequential browsing (especially on mobile
 * where the sidebar is hidden).
 */
export function LearnTopicNav() {
  const { t } = useTranslation();
  const pathname = usePathname();

  const currentIndex = TOPICS.findIndex((tp) => `/learn/${tp.slug}` === pathname);
  if (currentIndex === -1) return null;

  const prev = currentIndex > 0 ? TOPICS[currentIndex - 1] : null;
  const next = currentIndex < TOPICS.length - 1 ? TOPICS[currentIndex + 1] : null;

  return (
    <nav
      aria-label={t("learn.topicNavLabel")}
      className="mt-10 flex items-stretch gap-3 border-t pt-6"
    >
      {prev ? (
        <Link
          href={`/learn/${prev.slug}`}
          className="flex min-w-0 flex-1 items-center gap-2 rounded-lg border bg-surface-subtle px-4 py-3 text-sm text-foreground-secondary transition-colors hover:bg-surface-subtle/80 hover:text-foreground"
        >
          <ChevronLeft size={16} className="shrink-0" aria-hidden="true" />
          <span className="truncate">{t(prev.labelKey)}</span>
        </Link>
      ) : (
        <div className="flex-1" />
      )}

      {next ? (
        <Link
          href={`/learn/${next.slug}`}
          className="flex min-w-0 flex-1 items-center justify-end gap-2 rounded-lg border bg-surface-subtle px-4 py-3 text-sm text-foreground-secondary transition-colors hover:bg-surface-subtle/80 hover:text-foreground"
        >
          <span className="truncate">{t(next.labelKey)}</span>
          <ChevronRight size={16} className="shrink-0" aria-hidden="true" />
        </Link>
      ) : (
        <div className="flex-1" />
      )}
    </nav>
  );
}
