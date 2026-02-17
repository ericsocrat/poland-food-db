/**
 * Checkbox — accessible checkbox with label and optional indeterminate state.
 *
 * Uses native `<input type="checkbox">` with custom styling via design tokens.
 */

import {
  forwardRef,
  useEffect,
  useId,
  useRef,
  type InputHTMLAttributes,
} from "react";

// ─── Types ──────────────────────────────────────────────────────────────────

export interface CheckboxProps extends Omit<
  InputHTMLAttributes<HTMLInputElement>,
  "type" | "size"
> {
  /** Visible label text. */
  readonly label: string;
  /** Show indeterminate (dash) state. */
  readonly indeterminate?: boolean;
}

// ─── Component ──────────────────────────────────────────────────────────────

export const Checkbox = forwardRef<HTMLInputElement, CheckboxProps>(
  function Checkbox(
    { label, indeterminate = false, className = "", id: externalId, ...rest },
    ref,
  ) {
    const autoId = useId();
    const checkboxId = externalId ?? autoId;
    const internalRef = useRef<HTMLInputElement | null>(null);

    // Sync indeterminate prop (not a standard HTML attribute)
    useEffect(() => {
      const el = internalRef.current;
      if (el) el.indeterminate = indeterminate;
    }, [indeterminate]);

    return (
      <div className={`flex items-center gap-2.5 ${className}`}>
        <input
          ref={(node) => {
            internalRef.current = node;
            if (typeof ref === "function") ref(node);
            else if (ref) ref.current = node;
          }}
          type="checkbox"
          id={checkboxId}
          className={[
            "h-4 w-4 shrink-0 rounded border-strong bg-surface text-brand",
            "focus:ring-2 focus:ring-brand focus:ring-offset-0",
            "disabled:opacity-50 disabled:cursor-not-allowed",
            "accent-brand cursor-pointer",
          ].join(" ")}
          {...rest}
        />
        <label
          htmlFor={checkboxId}
          className="text-sm text-foreground cursor-pointer select-none"
        >
          {label}
        </label>
      </div>
    );
  },
);
