import { describe, it, expect, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { Checkbox } from "./Checkbox";

describe("Checkbox", () => {
  it("renders with label", () => {
    render(<Checkbox label="Accept terms" />);
    expect(screen.getByLabelText("Accept terms")).toBeTruthy();
  });

  it("renders as checkbox input", () => {
    render(<Checkbox label="Accept" />);
    const input = screen.getByRole("checkbox");
    expect(input).toBeTruthy();
  });

  it("reflects checked state", () => {
    const { rerender } = render(
      <Checkbox label="Test" checked={false} onChange={() => {}} />,
    );
    expect(screen.getByRole("checkbox")).not.toBeChecked();
    rerender(<Checkbox label="Test" checked={true} onChange={() => {}} />);
    expect(screen.getByRole("checkbox")).toBeChecked();
  });

  it("calls onChange when clicked", () => {
    const onChange = vi.fn();
    render(<Checkbox label="Test" onChange={onChange} />);
    fireEvent.click(screen.getByRole("checkbox"));
    expect(onChange).toHaveBeenCalled();
  });

  it("supports indeterminate state", () => {
    render(<Checkbox label="Select all" indeterminate />);
    const input = screen.getByRole("checkbox") as HTMLInputElement;
    expect(input.indeterminate).toBe(true);
  });

  it("disables when disabled", () => {
    render(<Checkbox label="Locked" disabled />);
    expect(screen.getByRole("checkbox")).toBeDisabled();
  });
});
