import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { PrintButton } from "./PrintButton";

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("PrintButton", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("renders a button with accessible label", () => {
    render(<PrintButton />);
    const btn = screen.getByRole("button");
    expect(btn).toBeInTheDocument();
    expect(btn).toHaveAttribute("aria-label");
  });

  it("calls window.print on click", async () => {
    const user = userEvent.setup();
    const printSpy = vi.fn();
    globalThis.print = printSpy;
    render(<PrintButton />);
    await user.click(screen.getByRole("button"));
    expect(printSpy).toHaveBeenCalledTimes(1);
  });

  it("applies custom className", () => {
    render(<PrintButton className="my-custom-class" />);
    expect(screen.getByRole("button")).toHaveClass("my-custom-class");
  });

  it("has the no-print class to hide in print mode", () => {
    render(<PrintButton />);
    expect(screen.getByRole("button")).toHaveClass("no-print");
  });

  it("renders the printer icon as decorative", () => {
    const { container } = render(<PrintButton />);
    const svg = container.querySelector("svg");
    expect(svg).toBeInTheDocument();
  });
});
