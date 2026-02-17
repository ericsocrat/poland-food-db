import { describe, it, expect, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { Toggle } from "./Toggle";

describe("Toggle", () => {
  const defaultProps = {
    label: "Dark mode",
    checked: false,
    onChange: vi.fn(),
  };

  it("renders with label and switch role", () => {
    render(<Toggle {...defaultProps} />);
    expect(screen.getByRole("switch")).toBeTruthy();
    expect(screen.getByText("Dark mode")).toBeTruthy();
  });

  it("reflects checked state via aria-checked", () => {
    const { rerender } = render(<Toggle {...defaultProps} checked={false} />);
    expect(screen.getByRole("switch").getAttribute("aria-checked")).toBe(
      "false",
    );
    rerender(<Toggle {...defaultProps} checked={true} />);
    expect(screen.getByRole("switch").getAttribute("aria-checked")).toBe(
      "true",
    );
  });

  it("calls onChange with toggled value on click", () => {
    const onChange = vi.fn();
    render(<Toggle {...defaultProps} checked={false} onChange={onChange} />);
    fireEvent.click(screen.getByRole("switch"));
    expect(onChange).toHaveBeenCalledWith(true);
  });

  it("calls onChange on Space key", () => {
    const onChange = vi.fn();
    render(<Toggle {...defaultProps} onChange={onChange} />);
    fireEvent.keyDown(screen.getByRole("switch"), { key: " " });
    expect(onChange).toHaveBeenCalledWith(true);
  });

  it("calls onChange on Enter key", () => {
    const onChange = vi.fn();
    render(<Toggle {...defaultProps} onChange={onChange} />);
    fireEvent.keyDown(screen.getByRole("switch"), { key: "Enter" });
    expect(onChange).toHaveBeenCalledWith(true);
  });

  it("disables when disabled prop is set", () => {
    const onChange = vi.fn();
    render(<Toggle {...defaultProps} disabled onChange={onChange} />);
    const sw = screen.getByRole("switch");
    expect(sw).toBeDisabled();
    fireEvent.click(sw);
    expect(onChange).not.toHaveBeenCalled();
  });

  it("applies size classes", () => {
    render(<Toggle {...defaultProps} size="sm" />);
    expect(screen.getByRole("switch").className).toContain("h-5");
  });
});
