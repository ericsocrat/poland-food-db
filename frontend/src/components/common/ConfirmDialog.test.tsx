import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { ConfirmDialog } from "./ConfirmDialog";

// ─── Mock HTMLDialogElement methods (jsdom doesn't implement them) ───────────

beforeEach(() => {
  HTMLDialogElement.prototype.showModal =
    HTMLDialogElement.prototype.showModal ||
    vi.fn(function (this: HTMLDialogElement) {
      this.open = true;
    });
  HTMLDialogElement.prototype.close =
    HTMLDialogElement.prototype.close ||
    vi.fn(function (this: HTMLDialogElement) {
      this.open = false;
    });
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ConfirmDialog", () => {
  const defaultProps = {
    open: true,
    title: "Delete item?",
    description: "This action cannot be undone.",
    onConfirm: vi.fn(),
    onCancel: vi.fn(),
  };

  beforeEach(() => vi.clearAllMocks());

  it("renders title and description when open", () => {
    render(<ConfirmDialog {...defaultProps} />);
    expect(screen.getByText("Delete item?")).toBeTruthy();
    expect(screen.getByText("This action cannot be undone.")).toBeTruthy();
  });

  it("renders default confirm label", () => {
    render(<ConfirmDialog {...defaultProps} />);
    expect(screen.getByText("Confirm")).toBeTruthy();
  });

  it("renders custom confirm label", () => {
    render(<ConfirmDialog {...defaultProps} confirmLabel="Delete" />);
    expect(screen.getByText("Delete")).toBeTruthy();
  });

  it("calls onConfirm when confirm button clicked", () => {
    render(<ConfirmDialog {...defaultProps} />);
    fireEvent.click(screen.getByText("Confirm"));
    expect(defaultProps.onConfirm).toHaveBeenCalledTimes(1);
  });

  it("calls onCancel when cancel button clicked", () => {
    render(<ConfirmDialog {...defaultProps} />);
    fireEvent.click(screen.getByText("Cancel"));
    expect(defaultProps.onCancel).toHaveBeenCalledTimes(1);
  });

  it("does not render description when omitted", () => {
    const { description: _, ...propsWithoutDesc } = defaultProps;
    render(<ConfirmDialog {...propsWithoutDesc} />);
    expect(screen.queryByText("This action cannot be undone.")).toBeNull();
  });

  it("applies danger variant styling to confirm button", () => {
    render(<ConfirmDialog {...defaultProps} variant="danger" confirmLabel="Delete" />);
    const btn = screen.getByText("Delete");
    expect(btn.className).toContain("bg-red-600");
  });

  it("applies default variant styling to confirm button", () => {
    render(<ConfirmDialog {...defaultProps} variant="default" />);
    const btn = screen.getByText("Confirm");
    expect(btn.className).toContain("btn-primary");
  });
});
