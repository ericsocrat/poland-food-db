/**
 * Input — standardized text input replacing `.input-field` CSS class.
 *
 * Includes built-in label, error message (linked via `aria-describedby`),
 * hint text, and optional leading icon. All styling via design tokens.
 */

import {
  forwardRef,
  useId,
  type InputHTMLAttributes,
  type ReactNode,
} from "react";

// ─── Types ──────────────────────────────────────────────────────────────────

export type InputSize = "sm" | "md" | "lg";

export interface InputProps extends Omit<
  InputHTMLAttributes<HTMLInputElement>,
  "size"
> {
  /** Visible label text. */
  readonly label?: string;
  /** Error message — shows in red, linked via aria-describedby. */
  readonly error?: string;
  /** Hint text shown below the input (info-level). */
  readonly hint?: string;
  /** Icon rendered inside the input on the left. */
  readonly icon?: ReactNode;
  /** Size preset. @default "md" */
  readonly size?: InputSize;
}

// ─── Style maps ─────────────────────────────────────────────────────────────

const SIZE_CLASSES: Record<InputSize, string> = {
  sm: "px-2.5 py-1.5 text-xs",
  md: "px-3.5 py-2.5 text-sm",
  lg: "px-4 py-3 text-base",
};

// ─── Component ──────────────────────────────────────────────────────────────

export const Input = forwardRef<HTMLInputElement, InputProps>(function Input(
  {
    label,
    error,
    hint,
    icon,
    size = "md",
    className = "",
    id: externalId,
    ...rest
  },
  ref,
) {
  const autoId = useId();
  const inputId = externalId ?? autoId;
  const errorId = error ? `${inputId}-error` : undefined;
  const hintId = hint && !error ? `${inputId}-hint` : undefined;
  const describedBy = errorId ?? hintId;

  return (
    <div className={className}>
      {label && (
        <label
          htmlFor={inputId}
          className="mb-1.5 block text-sm font-medium text-foreground"
        >
          {label}
        </label>
      )}

      <div className="relative">
        {icon && (
          <span className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3 text-foreground-muted">
            {icon}
          </span>
        )}
        <input
          ref={ref}
          id={inputId}
          aria-invalid={error ? true : undefined}
          aria-describedby={describedBy}
          className={[
            "block w-full rounded-lg border bg-surface shadow-sm transition-colors",
            "placeholder:text-foreground-muted",
            "focus:outline-none focus:ring-1",
            error
              ? "border-error focus:border-error focus:ring-error"
              : "border-strong focus:border-brand focus:ring-brand",
            SIZE_CLASSES[size],
            icon ? "pl-10" : "",
          ]
            .filter(Boolean)
            .join(" ")}
          {...rest}
        />
      </div>

      {error && (
        <p id={errorId} className="mt-1.5 text-xs text-error" role="alert">
          {error}
        </p>
      )}
      {hint && !error && (
        <p id={hintId} className="mt-1.5 text-xs text-foreground-muted">
          {hint}
        </p>
      )}
    </div>
  );
});
