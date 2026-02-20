// ─── Tests for assertComponentA11y helper ───────────────────────────────────
// Validates that the vitest-axe wrapper works correctly.
//
// Issue #50 — A11y CI Gate, Phase 4

import { describe, it, expect } from "vitest";
import React from "react";
import { render } from "@testing-library/react";
import { axe } from "vitest-axe";
import { assertComponentA11y, auditComponentA11y } from "./a11y";

describe("assertComponentA11y", () => {
  it("passes for an accessible button", async () => {
    const results = await assertComponentA11y(
      <button type="button">Click me</button>,
    );
    expect(results.violations).toHaveLength(0);
  });

  it("fails for an image without alt text", async () => {
    // eslint-disable-next-line @next/next/no-img-element, jsx-a11y/alt-text
    const { container } = render(<img src="/test.png" />);
    const results = await axe(container);

    // There should be at least one violation (missing alt)
    expect(results.violations.length).toBeGreaterThan(0);
    expect(results.violations.some((v) => v.id === "image-alt")).toBe(true);
  });

  it("returns AxeResults with passes array", async () => {
    const results = await assertComponentA11y(
      <button type="button">OK</button>,
    );
    expect(results.passes).toBeDefined();
    expect(results.passes.length).toBeGreaterThan(0);
  });
});

describe("auditComponentA11y", () => {
  it("returns results without asserting", async () => {
    // eslint-disable-next-line @next/next/no-img-element, jsx-a11y/alt-text
    const { container } = render(<img src="/test.png" />);
    const results = await auditComponentA11y(container);

    // Should return violations but not throw
    expect(results.violations.length).toBeGreaterThan(0);
  });

  it("accepts custom axe options", async () => {
    const { container } = render(<button type="button">OK</button>);
    const results = await auditComponentA11y(container, {
      axeOptions: { rules: { "color-contrast": { enabled: false } } },
    });
    expect(results).toBeDefined();
    expect(results.violations).toBeDefined();
  });
});
