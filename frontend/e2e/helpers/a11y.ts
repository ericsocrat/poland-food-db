// ─── axe-core a11y audit helper ─────────────────────────────────────────────
// Shared utility for automated WCAG 2.1 AA accessibility audits.
// Critical + Serious violations → test failure (zero-tolerance).
// Moderate + Minor violations → console warnings (fix encouraged, not required).
//
// Issue #50 — A11y CI Gate

import AxeBuilder from "@axe-core/playwright";
import type { Page } from "@playwright/test";
import { expect } from "@playwright/test";
import type { Result } from "axe-core";

/* ── Types ───────────────────────────────────────────────────────────────── */

export interface A11yAuditOptions {
  /** CSS selectors to exclude from the audit (e.g., third-party widgets) */
  exclude?: string[];
  /** axe-core rule IDs to disable for this audit */
  disableRules?: string[];
  /** Additional WCAG tags to include (default: wcag2a, wcag2aa, wcag21a, wcag21aa) */
  additionalTags?: string[];
}

export interface A11yAuditResult {
  /** All violations found */
  violations: Result[];
  /** Violations that block the build (critical + serious) */
  blocking: Result[];
  /** Violations logged as warnings (moderate + minor) */
  warnings: Result[];
  /** Number of rules that passed */
  passes: number;
}

/* ── Formatting ──────────────────────────────────────────────────────────── */

function formatViolation(v: Result): string {
  const nodes = v.nodes
    .map(
      (n) =>
        `    → ${n.target.join(", ")}\n    ℹ ${n.failureSummary ?? "No fix suggestion"}`,
    )
    .join("\n");
  return `${v.id} (${v.impact}): ${v.description}\n  WCAG: ${v.tags.filter((t) => t.startsWith("wcag")).join(", ")}\n  Help: ${v.helpUrl}\n${nodes}`;
}

function logWarnings(warnings: Result[]): void {
  if (warnings.length === 0) return;

  const moderate = warnings.filter((v) => v.impact === "moderate");
  const minor = warnings.filter((v) => v.impact === "minor");

  console.warn(
    `⚠️  A11y warnings (${moderate.length} moderate, ${minor.length} minor):`,
  );
  warnings.forEach((v) => {
    console.warn(`  ${v.id} (${v.impact}): ${v.description}`);
    v.nodes.forEach((n) => console.warn(`    → ${n.target.join(", ")}`));
  });
}

/* ── Core audit function ─────────────────────────────────────────────────── */

/**
 * Run an axe-core WCAG 2.1 AA audit on the current page.
 *
 * - Critical + Serious violations → expect.soft failure (blocks test).
 * - Moderate + Minor violations → console warnings (non-blocking).
 *
 * @returns Structured audit result for further assertions if needed.
 */
export async function assertNoA11yViolations(
  page: Page,
  options: A11yAuditOptions = {},
): Promise<A11yAuditResult> {
  const tags = [
    "wcag2a",
    "wcag2aa",
    "wcag21a",
    "wcag21aa",
    ...(options.additionalTags ?? []),
  ];

  let builder = new AxeBuilder({ page }).withTags(tags);

  // Global exclusions — third-party widgets, iframes, etc.
  builder = builder.exclude(".third-party-widget");

  if (options.exclude) {
    for (const sel of options.exclude) {
      builder = builder.exclude(sel);
    }
  }

  if (options.disableRules) {
    builder = builder.disableRules(options.disableRules);
  }

  const results = await builder.analyze();

  const critical = results.violations.filter((v) => v.impact === "critical");
  const serious = results.violations.filter((v) => v.impact === "serious");
  const moderate = results.violations.filter((v) => v.impact === "moderate");
  const minor = results.violations.filter((v) => v.impact === "minor");

  const blocking = [...critical, ...serious];
  const warnings = [...moderate, ...minor];

  // Log warnings (non-blocking)
  logWarnings(warnings);

  // Fail on critical + serious
  if (blocking.length > 0) {
    const details = blocking.map(formatViolation).join("\n\n");
    expect
      .soft(
        blocking,
        `🚫 A11y violations (${critical.length} critical, ${serious.length} serious):\n\n${details}`,
      )
      .toHaveLength(0);
  }

  return {
    violations: results.violations,
    blocking,
    warnings,
    passes: results.passes.length,
  };
}

/**
 * Run an axe-core audit and return results without asserting.
 * Useful for custom violation counting or baseline management.
 */
export async function auditA11y(
  page: Page,
  options: A11yAuditOptions = {},
): Promise<A11yAuditResult> {
  const tags = ["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"];

  let builder = new AxeBuilder({ page }).withTags(tags);
  builder = builder.exclude(".third-party-widget");

  if (options.exclude) {
    for (const sel of options.exclude) {
      builder = builder.exclude(sel);
    }
  }
  if (options.disableRules) {
    builder = builder.disableRules(options.disableRules);
  }

  const results = await builder.analyze();

  const critical = results.violations.filter((v) => v.impact === "critical");
  const serious = results.violations.filter((v) => v.impact === "serious");
  const moderate = results.violations.filter((v) => v.impact === "moderate");
  const minor = results.violations.filter((v) => v.impact === "minor");

  return {
    violations: results.violations,
    blocking: [...critical, ...serious],
    warnings: [...moderate, ...minor],
    passes: results.passes.length,
  };
}
