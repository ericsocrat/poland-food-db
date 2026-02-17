import { describe, it, expect, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { IconButton } from "./IconButton";

describe("IconButton", () => {
  it("renders with aria-label", () => {
    render(<IconButton icon={<span>✕</span>} label="Close" />);
    expect(screen.getByRole("button", { name: "Close" })).toBeTruthy();
  });

  it("applies ghost variant by default", () => {
    render(<IconButton icon={<span>✕</span>} label="Close" />);
    const btn = screen.getByRole("button");
    expect(btn.className).toContain("hover:bg-surface-subtle");
  });

  it("applies primary variant", () => {
    render(<IconButton icon={<span>+</span>} label="Add" variant="primary" />);
    expect(screen.getByRole("button").className).toContain("bg-brand");
  });

  it("applies size classes", () => {
    render(<IconButton icon={<span>✕</span>} label="Close" size="sm" />);
    expect(screen.getByRole("button").className).toContain("h-7");
  });

  it("disables when disabled", () => {
    render(<IconButton icon={<span>✕</span>} label="Close" disabled />);
    expect(screen.getByRole("button")).toBeDisabled();
  });

  it("calls onClick handler", () => {
    const handler = vi.fn();
    render(
      <IconButton icon={<span>✕</span>} label="Close" onClick={handler} />,
    );
    fireEvent.click(screen.getByRole("button"));
    expect(handler).toHaveBeenCalledOnce();
  });
});
