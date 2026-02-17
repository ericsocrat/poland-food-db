import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { SubmitButton } from "./SubmitButton";

describe("SubmitButton", () => {
  it("renders label when idle and valid", () => {
    render(<SubmitButton isSubmitting={false} isValid={true} label="Save" />);
    const button = screen.getByRole("button");
    expect(button.textContent).toBe("Save");
    expect(button).not.toBeDisabled();
  });

  it("is disabled when invalid", () => {
    render(<SubmitButton isSubmitting={false} isValid={false} label="Save" />);
    const button = screen.getByRole("button");
    expect(button).toBeDisabled();
    expect(button.getAttribute("title")).toBe("Please fix form errors");
  });

  it("is disabled and shows loading label when submitting", () => {
    render(
      <SubmitButton
        isSubmitting={true}
        isValid={true}
        label="Save"
        loadingLabel="Saving…"
      />,
    );
    const button = screen.getByRole("button");
    expect(button).toBeDisabled();
    expect(button.textContent).toContain("Saving…");
    expect(button.getAttribute("aria-busy")).toBe("true");
  });

  it("shows spinner SVG when submitting", () => {
    render(<SubmitButton isSubmitting={true} isValid={true} label="Save" />);
    const svg = document.querySelector("svg.animate-spin");
    expect(svg).not.toBeNull();
  });

  it("does NOT show spinner when idle", () => {
    render(<SubmitButton isSubmitting={false} isValid={true} label="Save" />);
    const svg = document.querySelector("svg.animate-spin");
    expect(svg).toBeNull();
  });

  it("has type=submit", () => {
    render(<SubmitButton isSubmitting={false} isValid={true} label="Save" />);
    const button = screen.getByRole("button");
    expect(button.getAttribute("type")).toBe("submit");
  });

  it("uses default loading label when not provided", () => {
    render(<SubmitButton isSubmitting={true} isValid={true} label="Save" />);
    const button = screen.getByRole("button");
    expect(button.textContent).toContain("Saving…");
  });

  it("respects additional disabled prop", () => {
    render(
      <SubmitButton
        isSubmitting={false}
        isValid={true}
        label="Save"
        disabled={true}
      />,
    );
    expect(screen.getByRole("button")).toBeDisabled();
  });
});
