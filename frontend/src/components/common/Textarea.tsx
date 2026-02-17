/**
 * Textarea — multi-line text input with label, error, hint, and character count.
 *
 * Styling via design tokens, consistent with Input component.
 */

import { forwardRef, useId, type TextareaHTMLAttributes } from "react";

// ─── Types ──────────────────────────────────────────────────────────────────

export interface TextareaProps extends Omit<
  TextareaHTMLAttributes<HTMLTextAreaElement>,
  "children"
> {
  /** Visible label text. */
  readonly label?: string;
  /** Error message — shows in red, linked via aria-describedby. */
  readonly error?: string;
  /** Hint text shown below the textarea. */
  readonly hint?: string;
  /** Show a character counter when maxLength is set. */
  readonly showCount?: boolean;
  /** Current value length (needed for controlled char count). Falls back to 0. */
  readonly currentLength?: number;
}

// ─── Component ──────────────────────────────────────────────────────────────

export const Textarea = forwardRef<HTMLTextAreaElement, TextareaProps>(
  function Textarea(
    {
      label,
      error,
      hint,
      showCount = false,
      currentLength = 0,
      maxLength,
      rows = 3,
      className = "",
      id: externalId,
      ...rest
    },
    ref,
  ) {
    const autoId = useId();
    const textareaId = externalId ?? autoId;
    const errorId = error ? `${textareaId}-error` : undefined;
    const hintId = hint && !error ? `${textareaId}-hint` : undefined;
    const describedBy = errorId ?? hintId;

    return (
      <div className={className}>
        {label && (
          <label
            htmlFor={textareaId}
            className="mb-1.5 block text-sm font-medium text-foreground"
          >
            {label}
          </label>
        )}

        <textarea
          ref={ref}
          id={textareaId}
          rows={rows}
          maxLength={maxLength}
          aria-invalid={error ? true : undefined}
          aria-describedby={describedBy}
          className={[
            "block w-full rounded-lg border bg-surface px-3.5 py-2.5 text-sm shadow-sm transition-colors",
            "placeholder:text-foreground-muted resize-y",
            "focus:outline-none focus:ring-1",
            error
              ? "border-error focus:border-error focus:ring-error"
              : "border-strong focus:border-brand focus:ring-brand",
          ].join(" ")}
          {...rest}
        />

        <div className="mt-1.5 flex justify-between">
          <div>
            {error && (
              <p id={errorId} className="text-xs text-error" role="alert">
                {error}
              </p>
            )}
            {hint && !error && (
              <p id={hintId} className="text-xs text-foreground-muted">
                {hint}
              </p>
            )}
          </div>
          {showCount && maxLength != null && (
            <span
              className={`text-xs ${
                currentLength > maxLength
                  ? "text-error"
                  : "text-foreground-muted"
              }`}
              aria-live="polite"
            >
              {currentLength}/{maxLength}
            </span>
          )}
        </div>
      </div>
    );
  },
);
