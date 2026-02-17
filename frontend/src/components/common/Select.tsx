/**
 * Select — native-backed select input with custom styling.
 *
 * Keyboard accessible, includes label, error state with aria-describedby,
 * and consistent styling via design tokens.
 */

import { forwardRef, useId, type SelectHTMLAttributes } from "react";

// ─── Types ──────────────────────────────────────────────────────────────────

export interface SelectOption {
  readonly value: string;
  readonly label: string;
  readonly disabled?: boolean;
}

export interface SelectProps extends Omit<
  SelectHTMLAttributes<HTMLSelectElement>,
  "size"
> {
  /** Visible label text. */
  readonly label?: string;
  /** Options to render. */
  readonly options: readonly SelectOption[];
  /** Error message — shows in red, linked via aria-describedby. */
  readonly error?: string;
  /** Placeholder text (rendered as disabled first option). */
  readonly placeholder?: string;
  /** Size preset. @default "md" */
  readonly size?: "sm" | "md" | "lg";
}

// ─── Style maps ─────────────────────────────────────────────────────────────

const SIZE_CLASSES: Record<string, string> = {
  sm: "px-2.5 py-1.5 text-xs",
  md: "px-3.5 py-2.5 text-sm",
  lg: "px-4 py-3 text-base",
};

// ─── Component ──────────────────────────────────────────────────────────────

export const Select = forwardRef<HTMLSelectElement, SelectProps>(
  function Select(
    {
      label,
      options,
      error,
      placeholder,
      size = "md",
      className = "",
      id: externalId,
      ...rest
    },
    ref,
  ) {
    const autoId = useId();
    const selectId = externalId ?? autoId;
    const errorId = error ? `${selectId}-error` : undefined;

    return (
      <div className={className}>
        {label && (
          <label
            htmlFor={selectId}
            className="mb-1.5 block text-sm font-medium text-foreground"
          >
            {label}
          </label>
        )}

        <select
          ref={ref}
          id={selectId}
          aria-invalid={error ? true : undefined}
          aria-describedby={errorId}
          className={[
            "block w-full appearance-none rounded-lg border bg-surface shadow-sm transition-colors",
            "focus:outline-none focus:ring-1",
            error
              ? "border-error focus:border-error focus:ring-error"
              : "border-strong focus:border-brand focus:ring-brand",
            SIZE_CLASSES[size],
            // Space for chevron
            "pr-10",
            // Custom chevron via background SVG
            "bg-no-repeat bg-[length:1.25rem_1.25rem]",
            "bg-[position:right_0.5rem_center]",
            "bg-[url(\"data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 20 20' fill='%236b7280'%3E%3Cpath fill-rule='evenodd' d='M5.23 7.21a.75.75 0 011.06.02L10 11.168l3.71-3.938a.75.75 0 111.08 1.04l-4.25 4.5a.75.75 0 01-1.08 0l-4.25-4.5a.75.75 0 01.02-1.06z' clip-rule='evenodd'/%3E%3C/svg%3E\")]",
          ]
            .filter(Boolean)
            .join(" ")}
          {...rest}
        >
          {placeholder && (
            <option value="" disabled>
              {placeholder}
            </option>
          )}
          {options.map((opt) => (
            <option key={opt.value} value={opt.value} disabled={opt.disabled}>
              {opt.label}
            </option>
          ))}
        </select>

        {error && (
          <p id={errorId} className="mt-1.5 text-xs text-error" role="alert">
            {error}
          </p>
        )}
      </div>
    );
  },
);
