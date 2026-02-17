"use client";

// ─── ThemeToggle — 3-way theme selector (Light / Dark / System) ─────────────
// Renders a segmented control for choosing the theme preference.
// Used in the Settings page and optionally in the header.

import { useTheme, type ThemeMode } from "@/hooks/use-theme";
import { useTranslation } from "@/lib/i18n";

const THEME_OPTIONS: { value: ThemeMode; icon: string; labelKey: string }[] = [
  { value: "light", icon: "☀️", labelKey: "theme.light" },
  { value: "dark", icon: "🌙", labelKey: "theme.dark" },
  { value: "system", icon: "💻", labelKey: "theme.system" },
];

export function ThemeToggle() {
  const { mode, setMode } = useTheme();
  const { t } = useTranslation();

  return (
    <div
      className="inline-flex rounded-lg border bg-surface-muted p-1"
      role="radiogroup"
      aria-label={t("theme.label")}
    >
      {THEME_OPTIONS.map((option) => (
        <button
          key={option.value}
          role="radio"
          aria-checked={mode === option.value}
          onClick={() => setMode(option.value)}
          className={`flex items-center gap-1.5 rounded-md px-3 py-1.5 text-sm font-medium transition-colors ${
            mode === option.value
              ? "bg-surface text-foreground shadow-sm"
              : "text-foreground-secondary hover:text-foreground"
          }`}
        >
          <span aria-hidden="true">{option.icon}</span>
          {t(option.labelKey)}
        </button>
      ))}
    </div>
  );
}
