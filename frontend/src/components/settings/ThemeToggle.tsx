"use client";

// ─── ThemeToggle — 3-way theme selector (Light / Dark / System) ─────────────
// Renders a segmented control for choosing the theme preference.
// Used in the Settings page and optionally in the header.

import { useTheme, type ThemeMode } from "@/hooks/use-theme";
import { useTranslation } from "@/lib/i18n";
import { Sun, Moon, Monitor } from "lucide-react";
import type { LucideIcon } from "lucide-react";

const THEME_OPTIONS: {
  value: ThemeMode;
  icon: LucideIcon;
  labelKey: string;
}[] = [
  { value: "light", icon: Sun, labelKey: "theme.light" },
  { value: "dark", icon: Moon, labelKey: "theme.dark" },
  { value: "system", icon: Monitor, labelKey: "theme.system" },
];

export function ThemeToggle() {
  const { mode, setMode } = useTheme();
  const { t } = useTranslation();

  return (
    <fieldset
      className="inline-flex rounded-lg border border-border bg-surface-muted p-1 m-0"
      role="radiogroup"
      aria-label={t("theme.label")}
    >
      {THEME_OPTIONS.map((option) => (
        <label
          key={option.value}
          className={`flex cursor-pointer items-center gap-1.5 rounded-md px-3 py-1.5 text-sm font-medium transition-colors ${
            mode === option.value
              ? "bg-surface text-foreground shadow-sm"
              : "text-foreground-secondary hover:text-foreground"
          }`}
        >
          <input
            type="radio"
            name="theme"
            className="sr-only"
            value={option.value}
            checked={mode === option.value}
            onChange={() => setMode(option.value)}
          />
          <option.icon size={16} aria-hidden="true" />
          {t(option.labelKey)}
        </label>
      ))}
    </fieldset>
  );
}
