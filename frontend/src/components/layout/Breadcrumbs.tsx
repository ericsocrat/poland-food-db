"use client";

// ─── Breadcrumbs — semantic breadcrumb navigation for deep pages ─────────────
// Renders an ordered list of links with proper ARIA markup.
// The last item is the current page (no link, aria-current="page").
//
// Usage:
//   <Breadcrumbs items={[
//     { labelKey: "nav.home", href: "/app" },
//     { labelKey: "nav.lists", href: "/app/lists" },
//     { label: "My Favorites" },
//   ]} />

import { useTranslation } from "@/lib/i18n";
import { ChevronLeft } from "lucide-react";
import Link from "next/link";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export interface BreadcrumbItem {
  /** i18n key for the label — used when label is a translatable string */
  labelKey?: string;
  /** Raw label — used for dynamic names (product name, list name) */
  label?: string;
  /** Link href. Omit for the current page (last item). */
  href?: string;
}

interface BreadcrumbsProps {
  items: BreadcrumbItem[];
}

// ---------------------------------------------------------------------------
// Component
// ---------------------------------------------------------------------------

export function Breadcrumbs({ items }: Readonly<BreadcrumbsProps>) {
  const { t } = useTranslation();

  if (items.length === 0) return null;

  // Parent item = second-to-last (the page one level up)
  const parentItem = items.length >= 2 ? items[items.length - 2] : null;
  const parentText = parentItem
    ? parentItem.labelKey
      ? t(parentItem.labelKey)
      : (parentItem.label ?? "")
    : "";

  return (
    <nav aria-label={t("a11y.breadcrumb")} className="mb-3">
      {/* Mobile: compact parent-only link */}
      {parentItem?.href && (
        <Link
          href={parentItem.href}
          className="flex items-center gap-1 text-sm text-foreground-secondary hover:text-foreground transition-colors min-h-[44px] md:hidden"
        >
          <ChevronLeft size={16} aria-hidden="true" />
          <span className="truncate max-w-[200px]">{parentText}</span>
        </Link>
      )}

      {/* Desktop: full breadcrumb trail */}
      <ol className="hidden md:flex flex-wrap items-center gap-1 text-sm text-foreground-secondary">
        {items.map((item, index) => {
          const isLast = index === items.length - 1;
          const text = item.labelKey ? t(item.labelKey) : (item.label ?? "");

          return (
            <li key={item.href ?? index} className="flex items-center gap-1">
              {index > 0 && (
                <span aria-hidden="true" className="text-foreground-muted">
                  /
                </span>
              )}
              {isLast || !item.href ? (
                <span
                  aria-current={isLast ? "page" : undefined}
                  className={
                    isLast
                      ? "font-medium text-foreground truncate max-w-[200px]"
                      : ""
                  }
                  title={text}
                >
                  {text}
                </span>
              ) : (
                <Link
                  href={item.href}
                  className="hover:text-foreground transition-colors truncate max-w-[200px]"
                  title={text}
                >
                  {text}
                </Link>
              )}
            </li>
          );
        })}
      </ol>
    </nav>
  );
}
