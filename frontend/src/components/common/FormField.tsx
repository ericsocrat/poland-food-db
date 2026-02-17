/**
 * FormField — wrapper that connects a form input to label, error, hint,
 * and required indicator with proper ARIA attributes.
 *
 * Works with any child element (plain `<input>`, `<Input>`, `<Select>`, etc.)
 * by cloning the child and injecting a11y props.
 *
 * @see Issue #69 — Form Validation UX Standard
 */

"use client";

import React, { useId, type ReactElement } from "react";

// ─── Types ──────────────────────────────────────────────────────────────────

export interface FormFieldProps {
  /** Visible label text (already i18n-resolved). */
  readonly label: string;
  /** Field name — matches the Zod schema key and is used for id/error linking. */
  readonly name: string;
  /** Error message to display below the field. */
  readonly error?: string;
  /** Whether the field is required (shows * indicator). */
  readonly required?: boolean;
  /** Helper text shown below the field when there is no error. */
  readonly hint?: string;
  /** The input element to render. */
  readonly children: ReactElement;
  /** Additional className for the outer wrapper. */
  readonly className?: string;
}

// ─── Component ──────────────────────────────────────────────────────────────

export function FormField({
  label,
  name,
  error,
  required,
  hint,
  children,
  className = "",
}: FormFieldProps) {
  const autoId = useId();
  const inputId = `${name}-${autoId}`;
  const errorId = `${name}-error`;
  const hintId = `${name}-hint`;
  const describedBy = error ? errorId : hint ? hintId : undefined;

  return (
    <div className={className}>
      <label
        htmlFor={inputId}
        className="mb-1.5 block text-sm font-medium text-foreground"
      >
        {label}
        {required && (
          <span className="ml-1 text-error" aria-hidden="true">
            *
          </span>
        )}
      </label>

      {React.cloneElement(
        children as ReactElement<Record<string, unknown>>,
        {
          id: inputId,
          name,
          "aria-invalid": error ? true : undefined,
          "aria-describedby": describedBy,
          "aria-required": required || undefined,
        },
      )}

      {/* Reserve min-height to prevent layout shift when error appears */}
      <div className="min-h-[1.25rem]">
        {error && (
          <p id={errorId} className="mt-1 text-xs text-error" role="alert">
            {error}
          </p>
        )}
        {hint && !error && (
          <p id={hintId} className="mt-1 text-xs text-foreground-muted">
            {hint}
          </p>
        )}
      </div>
    </div>
  );
}
