// ─── Component-level a11y tests ─────────────────────────────────────────────
// Validates that core UI components produce accessible HTML via axe-core
// running in jsdom (Vitest). Complements the E2E Playwright a11y audits.
//
// Issue #50 — A11y CI Gate, Phase 4/
//
// Components tested:
//   - Button (all variants)
//   - ScoreBadge (score display with aria-label)
//   - FormField (label-input association, error/hint binding)

import { describe, it, expect } from "vitest";
import React from "react";
import { render } from "@testing-library/react";
import { assertComponentA11y } from "@/utils/test/a11y";

/* ── Button ──────────────────────────────────────────────────────────────── */

describe("Button — a11y", () => {
  // Dynamic import to avoid module-level React errors with client components
  let Button: typeof import("@/components/common/Button").Button;

  beforeAll(async () => {
    const mod = await import("@/components/common/Button");
    Button = mod.Button;
  });

  it("primary button passes axe", async () => {
    await assertComponentA11y(<Button>Save</Button>);
  });

  it("secondary button passes axe", async () => {
    await assertComponentA11y(<Button variant="secondary">Cancel</Button>);
  });

  it("ghost button passes axe", async () => {
    await assertComponentA11y(<Button variant="ghost">More</Button>);
  });

  it("danger button passes axe", async () => {
    await assertComponentA11y(<Button variant="danger">Delete</Button>);
  });

  it("disabled button passes axe", async () => {
    await assertComponentA11y(<Button disabled>Disabled</Button>);
  });

  it("loading button passes axe", async () => {
    await assertComponentA11y(<Button loading>Saving</Button>);
  });

  it("button with icon passes axe", async () => {
    await assertComponentA11y(
      <Button icon={<span aria-hidden="true">✓</span>}>Confirm</Button>,
    );
  });
});

/* ── ScoreBadge ──────────────────────────────────────────────────────────── */

describe("ScoreBadge — a11y", () => {
  let ScoreBadge: typeof import("@/components/common/ScoreBadge").ScoreBadge;

  beforeAll(async () => {
    const mod = await import("@/components/common/ScoreBadge");
    ScoreBadge = mod.ScoreBadge;
  });

  it("score badge with valid score passes axe", async () => {
    await assertComponentA11y(<ScoreBadge score={42} />);
  });

  it("score badge with null score (N/A) passes axe", async () => {
    await assertComponentA11y(<ScoreBadge score={null} />);
  });

  it("score badge with label passes axe", async () => {
    await assertComponentA11y(<ScoreBadge score={75} showLabel />);
  });

  it("score badge has aria-label", async () => {
    const { container } = render(<ScoreBadge score={42} />);
    const badge = container.querySelector("[aria-label]");
    expect(badge).toBeTruthy();
    expect(badge?.getAttribute("aria-label")).toContain("42");
  });

  it("N/A badge has aria-label", async () => {
    const { container } = render(<ScoreBadge score={null} />);
    const badge = container.querySelector("[aria-label]");
    expect(badge).toBeTruthy();
    expect(badge?.getAttribute("aria-label")).toContain("N/A");
  });

  it("all size variants pass axe", async () => {
    for (const size of ["sm", "md", "lg"] as const) {
      await assertComponentA11y(<ScoreBadge score={50} size={size} />);
    }
  });
});

/* ── FormField ───────────────────────────────────────────────────────────── */

describe("FormField — a11y", () => {
  let FormField: typeof import("@/components/common/FormField").FormField;

  beforeAll(async () => {
    const mod = await import("@/components/common/FormField");
    FormField = mod.FormField;
  });

  it("form field with text input passes axe", async () => {
    await assertComponentA11y(
      <FormField label="Email" name="email">
        <input type="email" />
      </FormField>,
    );
  });

  it("required form field passes axe", async () => {
    await assertComponentA11y(
      <FormField label="Name" name="name" required>
        <input type="text" />
      </FormField>,
    );
  });

  it("form field with error passes axe", async () => {
    await assertComponentA11y(
      <FormField label="Password" name="password" error="Too short">
        <input type="password" />
      </FormField>,
    );
  });

  it("form field with hint passes axe", async () => {
    await assertComponentA11y(
      <FormField label="Username" name="username" hint="3-20 characters">
        <input type="text" />
      </FormField>,
    );
  });

  it("label is associated with input via htmlFor/id", async () => {
    const { container } = render(
      <FormField label="Email" name="email">
        <input type="email" />
      </FormField>,
    );

    const label = container.querySelector("label");
    const input = container.querySelector("input");
    expect(label).toBeTruthy();
    expect(input).toBeTruthy();
    expect(label?.getAttribute("for")).toBe(input?.getAttribute("id"));
  });

  it("error message is linked via aria-describedby", async () => {
    const { container } = render(
      <FormField label="Name" name="name" error="Required">
        <input type="text" />
      </FormField>,
    );

    const input = container.querySelector("input");
    const errorEl = container.querySelector('[role="alert"]');
    expect(input).toBeTruthy();
    expect(errorEl).toBeTruthy();
    expect(input?.getAttribute("aria-describedby")).toBe(
      errorEl?.getAttribute("id"),
    );
  });

  it("error state sets aria-invalid", async () => {
    const { container } = render(
      <FormField label="Email" name="email" error="Invalid email">
        <input type="email" />
      </FormField>,
    );

    const input = container.querySelector("input");
    expect(input?.getAttribute("aria-invalid")).toBe("true");
  });

  it("required state sets aria-required", async () => {
    const { container } = render(
      <FormField label="Email" name="email" required>
        <input type="email" />
      </FormField>,
    );

    const input = container.querySelector("input");
    expect(input?.getAttribute("aria-required")).toBe("true");
  });
});
