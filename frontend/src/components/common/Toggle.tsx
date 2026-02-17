/**
 * Toggle — accessible boolean switch for settings (dark mode, notifications, etc.).
 *
 * Uses `role="switch"` with `aria-checked` for screen readers.
 * Styling via design tokens with smooth transition.
 */

import { useId, type KeyboardEvent } from "react";

// ─── Types ──────────────────────────────────────────────────────────────────

export type ToggleSize = "sm" | "md";

export interface ToggleProps {
  /** Visible label text. */
  readonly label: string;
  /** Controlled checked state. */
  readonly checked: boolean;
  /** Change handler. */
  readonly onChange: (checked: boolean) => void;
  /** Size preset. @default "md" */
  readonly size?: ToggleSize;
  /** Disable interactions. */
  readonly disabled?: boolean;
  /** Additional CSS classes on the root wrapper. */
  readonly className?: string;
}

// ─── Style maps ─────────────────────────────────────────────────────────────

const TRACK_SIZES: Record<ToggleSize, string> = {
  sm: "h-5 w-9",
  md: "h-6 w-11",
};

const THUMB_SIZES: Record<ToggleSize, { size: string; translate: string }> = {
  sm: { size: "h-3.5 w-3.5", translate: "translate-x-4" },
  md: { size: "h-4.5 w-4.5", translate: "translate-x-5" },
};

// ─── Component ──────────────────────────────────────────────────────────────

export function Toggle({
  label,
  checked,
  onChange,
  size = "md",
  disabled = false,
  className = "",
}: Readonly<ToggleProps>) {
  const labelId = useId();

  function handleKeyDown(e: KeyboardEvent) {
    if (e.key === " " || e.key === "Enter") {
      e.preventDefault();
      if (!disabled) onChange(!checked);
    }
  }

  return (
    <div className={`flex items-center gap-3 ${className}`}>
      <button
        type="button"
        role="switch"
        aria-checked={checked}
        aria-labelledby={labelId}
        disabled={disabled}
        onClick={() => onChange(!checked)}
        onKeyDown={handleKeyDown}
        className={[
          "relative inline-flex shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors",
          "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand",
          "disabled:opacity-50 disabled:cursor-not-allowed",
          TRACK_SIZES[size],
          checked ? "bg-brand" : "bg-surface-muted",
        ].join(" ")}
      >
        <span
          aria-hidden="true"
          className={[
            "pointer-events-none inline-block transform rounded-full bg-white shadow-sm ring-0 transition-transform",
            THUMB_SIZES[size].size,
            checked ? THUMB_SIZES[size].translate : "translate-x-0",
          ].join(" ")}
        />
      </button>
      <span
        id={labelId}
        className={`text-sm ${disabled ? "text-foreground-muted" : "text-foreground"}`}
      >
        {label}
      </span>
    </div>
  );
}
