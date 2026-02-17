"use client";

import { useTranslation } from "@/lib/i18n";

const SIZES = {
  sm: "h-4 w-4 border-2",
  md: "h-8 w-8 border-4",
  lg: "h-12 w-12 border-4",
} as const;

export function LoadingSpinner({
  className = "",
  size = "md",
}: Readonly<{
  className?: string;
  size?: keyof typeof SIZES;
}>) {
  const { t } = useTranslation();
  return (
    <output
      className={`flex items-center justify-center ${className}`}
      aria-label={t("common.loading")}
    >
      <div
        className={`animate-spin rounded-full border-surface-muted border-t-brand ${SIZES[size]}`}
      />
      <span className="sr-only">{t("common.loading")}</span>
    </output>
  );
}
