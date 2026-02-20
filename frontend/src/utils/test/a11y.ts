// ─── Component-level a11y test helper ────────────────────────────────────────
// Wraps vitest-axe to provide a one-liner for asserting zero a11y violations
// on rendered React components in Vitest + jsdom.
//
// Issue #50 — A11y CI Gate, Phase 4

import type { RenderResult } from "@testing-library/react";
import { render } from "@testing-library/react";
import type { AxeResults, RunOptions } from "axe-core";
import type { ReactElement } from "react";
import { axe } from "vitest-axe";

/* ── Types ───────────────────────────────────────────────────────────────── */

export interface ComponentA11yOptions {
  /** axe-core run options (rules to enable/disable, tags, etc.) */
  axeOptions?: RunOptions;
}

/* ── Core helper ─────────────────────────────────────────────────────────── */

/**
 * Render a React element and run axe-core against its container.
 * Asserts zero violations via vitest-axe's `toHaveNoViolations` matcher.
 *
 * @example
 * ```tsx
 * await assertComponentA11y(<Button>Click me</Button>);
 * await assertComponentA11y(<FormField label="Name" name="name"><input /></FormField>);
 * ```
 *
 * @returns The axe results for further inspection if needed.
 */
export async function assertComponentA11y(
  ui: ReactElement,
  options: ComponentA11yOptions = {},
): Promise<AxeResults> {
  const { container } = render(ui);
  const results = await axe(container, options.axeOptions);

  expect(results).toHaveNoViolations();

  return results;
}

/**
 * Run axe-core against an already-rendered container without asserting.
 * Useful when you need to inspect specific violations or do custom assertions.
 *
 * @param container The DOM element to audit (e.g., from `render().container`).
 * @returns The full axe results.
 */
export async function auditComponentA11y(
  container: RenderResult["container"],
  options: ComponentA11yOptions = {},
): Promise<AxeResults> {
  return axe(container, options.axeOptions);
}
