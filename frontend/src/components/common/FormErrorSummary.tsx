/**
 * FormErrorSummary — accessible error summary shown at the top of a form
 * when submission fails validation.
 *
 * Uses `aria-live="assertive"` so screen readers announce errors immediately.
 * Each error links to its field via `#${name}` anchor.
 *
 * @see Issue #69 — Form Validation UX Standard
 */

"use client";

import { useEffect, useRef, type JSX } from "react";
import type { FieldErrors } from "react-hook-form";

// ─── Types ──────────────────────────────────────────────────────────────────

export interface FormErrorSummaryProps {
  /** React Hook Form errors object. */
  readonly errors: FieldErrors;
  /** Map of field name → human-readable label for display. */
  readonly fieldLabels: Record<string, string>;
  /** i18n-resolved heading (default: "Please fix the following errors:"). */
  readonly heading?: string;
}

// ─── Helpers ────────────────────────────────────────────────────────────────

function flattenErrors(
  errors: FieldErrors,
  fieldLabels: Record<string, string>,
): Array<{ name: string; label: string; message: string }> {
  const result: Array<{ name: string; label: string; message: string }> = [];

  for (const [name, error] of Object.entries(errors)) {
    if (!error) continue;
    const label = fieldLabels[name] ?? name;
    const message =
      typeof error.message === "string" ? error.message : "Invalid";
    result.push({ name, label, message });
  }

  return result;
}

// ─── Component ──────────────────────────────────────────────────────────────

export function FormErrorSummary({
  errors,
  fieldLabels,
  heading = "Please fix the following errors:",
}: FormErrorSummaryProps): JSX.Element | null {
  const ref = useRef<HTMLDivElement>(null);
  const entries = flattenErrors(errors, fieldLabels);

  // Focus the summary when errors first appear so screen readers announce it
  useEffect(() => {
    if (entries.length > 0 && ref.current) {
      ref.current.focus();
    }
  }, [entries.length]);

  if (entries.length === 0) return null;

  return (
    <div
      ref={ref}
      role="alert"
      aria-live="assertive"
      tabIndex={-1}
      className="mb-4 rounded-lg border border-error/30 bg-error/5 p-4 focus:outline-none focus:ring-2 focus:ring-error"
    >
      <h3 className="mb-2 text-sm font-semibold text-error">
        {heading.replace("{count}", String(entries.length))}
      </h3>
      <ul className="list-inside list-disc space-y-1">
        {entries.map(({ name, label, message }) => (
          <li key={name} className="text-sm text-error">
            <a
              href={`#${name}`}
              className="underline hover:no-underline focus:outline-none focus:ring-1 focus:ring-error"
              onClick={(e) => {
                e.preventDefault();
                // Find the input by name attribute and focus it
                const field = document.querySelector<HTMLElement>(
                  `[name="${name}"]`,
                );
                field?.focus();
              }}
            >
              {label}
            </a>
            : {message}
          </li>
        ))}
      </ul>
    </div>
  );
}
