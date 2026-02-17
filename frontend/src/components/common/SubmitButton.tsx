/**
 * SubmitButton — form submit button with idle, submitting, and invalid states.
 *
 * - idle + valid → enabled primary button
 * - idle + invalid → disabled with tooltip
 * - submitting → disabled with spinner + loading text
 *
 * @see Issue #69 — Form Validation UX Standard
 */

"use client";

import { type ButtonHTMLAttributes } from "react";

// ─── Types ──────────────────────────────────────────────────────────────────

export interface SubmitButtonProps extends Omit<
  ButtonHTMLAttributes<HTMLButtonElement>,
  "type" | "children"
> {
  /** Whether the form is currently submitting. */
  readonly isSubmitting: boolean;
  /** Whether the form is currently valid. */
  readonly isValid: boolean;
  /** Button label text (already i18n-resolved). */
  readonly label: string;
  /** Loading state label (e.g. "Saving…"). */
  readonly loadingLabel?: string;
  /** Additional className. */
  readonly className?: string;
}

// ─── Component ──────────────────────────────────────────────────────────────

export function SubmitButton({
  isSubmitting,
  isValid,
  label,
  loadingLabel = "Saving…",
  className = "",
  disabled,
  ...rest
}: SubmitButtonProps) {
  const isDisabled = disabled || isSubmitting || !isValid;

  return (
    <button
      type="submit"
      disabled={isDisabled}
      aria-busy={isSubmitting || undefined}
      className={[
        "inline-flex items-center justify-center gap-2 rounded-lg px-5 py-2.5 text-sm font-semibold transition-colors",
        "focus:outline-none focus:ring-2 focus:ring-brand focus:ring-offset-2",
        isDisabled
          ? "cursor-not-allowed bg-brand/50 text-white/70"
          : "bg-brand text-white hover:bg-brand-hover active:bg-brand-active",
        className,
      ]
        .filter(Boolean)
        .join(" ")}
      title={!isValid && !isSubmitting ? "Please fix form errors" : undefined}
      {...rest}
    >
      {isSubmitting && (
        <svg
          className="h-4 w-4 animate-spin"
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          aria-hidden="true"
        >
          <circle
            className="opacity-25"
            cx="12"
            cy="12"
            r="10"
            stroke="currentColor"
            strokeWidth="4"
          />
          <path
            className="opacity-75"
            fill="currentColor"
            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
          />
        </svg>
      )}
      {isSubmitting ? loadingLabel : label}
    </button>
  );
}
