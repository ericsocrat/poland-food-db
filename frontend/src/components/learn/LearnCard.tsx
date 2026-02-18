import Link from "next/link";
import type { LucideIcon } from "lucide-react";
import React from "react";
import type { ReactNode } from "react";

interface LearnCardProps {
  /** Lucide icon component or ReactNode for the topic. */
  readonly icon: LucideIcon | ReactNode;
  /** Translated title. */
  readonly title: string;
  /** Translated short description. */
  readonly description: string;
  /** Link to the topic page, e.g. "/learn/nutri-score". */
  readonly href: string;
  /** Optional additional classes. */
  readonly className?: string;
}

/**
 * Card component for the /learn hub index page.
 * Shows an icon, title, and short description for each topic.
 */
export function LearnCard({
  icon,
  title,
  description,
  href,
  className = "",
}: LearnCardProps) {
  return (
    <Link
      href={href}
      className={`group block rounded-xl border bg-surface p-5 shadow-sm transition-interactive hover-lift ${className}`}
    >
      <div className="mb-3 flex items-center" aria-hidden="true">
        {typeof icon === "function" ||
        (typeof icon === "object" &&
          icon !== null &&
          "render" in (icon as unknown as Record<string, unknown>))
          ? React.createElement(icon as LucideIcon, { size: 32 })
          : icon}
      </div>
      <h2 className="mb-1.5 text-lg font-semibold text-foreground group-hover:text-brand-700 dark:group-hover:text-brand-400 transition-colors">
        {title}
      </h2>
      <p className="text-sm leading-relaxed text-foreground-secondary">
        {description}
      </p>
    </Link>
  );
}
