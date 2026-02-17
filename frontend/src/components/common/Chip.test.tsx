import { describe, it, expect, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { Chip } from "./Chip";

describe("Chip", () => {
  it("renders children", () => {
    render(<Chip>Gluten Free</Chip>);
    expect(screen.getByText("Gluten Free")).toBeTruthy();
  });

  it("renders as span by default (non-interactive)", () => {
    render(<Chip>Tag</Chip>);
    const el = screen.getByText("Tag").closest("span");
    expect(el).toBeTruthy();
  });

  it("renders as button when interactive", () => {
    render(
      <Chip interactive onClick={() => {}}>
        Click
      </Chip>,
    );
    expect(screen.getByRole("button")).toBeTruthy();
  });

  it("calls onClick when interactive", () => {
    const handler = vi.fn();
    render(
      <Chip interactive onClick={handler}>
        Click
      </Chip>,
    );
    fireEvent.click(screen.getByRole("button"));
    expect(handler).toHaveBeenCalledOnce();
  });

  it("shows remove button when onRemove is provided", () => {
    const onRemove = vi.fn();
    render(<Chip onRemove={onRemove}>Filter</Chip>);
    const removeBtn = screen.getByLabelText("Remove");
    expect(removeBtn).toBeTruthy();
    fireEvent.click(removeBtn);
    expect(onRemove).toHaveBeenCalledOnce();
  });

  it("uses custom removeLabel", () => {
    render(
      <Chip onRemove={() => {}} removeLabel="Delete filter">
        Tag
      </Chip>,
    );
    expect(screen.getByLabelText("Delete filter")).toBeTruthy();
  });

  it("applies variant classes", () => {
    render(<Chip variant="primary">Primary</Chip>);
    const el = screen.getByText("Primary").closest("span")!;
    expect(el.className).toContain("bg-brand/10");
    expect(el.className).toContain("text-brand");
  });

  it("applies default variant", () => {
    render(<Chip>Default</Chip>);
    const el = screen.getByText("Default").closest("span")!;
    expect(el.className).toContain("bg-surface-muted");
  });
});
