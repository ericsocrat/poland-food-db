"use client";

// ─── SkipLink — hidden skip-to-content link for keyboard users ──────────────
// Sits at the very top of the DOM, invisible until focused via Tab.
// Allows keyboard & screen-reader users to jump past navigation directly
// to the main content area.

import { useTranslation } from "@/lib/i18n";

export function SkipLink() {
  const { t } = useTranslation();

  return (
    <a
      href="#main-content"
      className="fixed left-2 top-2 z-[100] -translate-y-full rounded-lg bg-brand px-4 py-2.5 text-sm font-semibold text-foreground-inverse shadow-lg transition-transform focus:translate-y-0 focus:outline-2 focus:outline-offset-2 focus:outline-brand"
    >
      {t("a11y.skipToContent")}
    </a>
  );
}
