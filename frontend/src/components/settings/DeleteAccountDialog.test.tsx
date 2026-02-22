import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { DeleteAccountDialog } from "./DeleteAccountDialog";

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

describe("DeleteAccountDialog", () => {
  const defaultProps = {
    open: true,
    loading: false,
    onConfirm: vi.fn(),
    onCancel: vi.fn(),
  };

  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("renders nothing when closed", () => {
    const { container } = render(
      <DeleteAccountDialog {...defaultProps} open={false} />,
    );
    expect(container.innerHTML).toBe("");
  });

  it("renders dialog when open", () => {
    render(<DeleteAccountDialog {...defaultProps} />);
    expect(screen.getByTestId("delete-account-dialog")).toBeInTheDocument();
  });

  it("shows warning text", () => {
    render(<DeleteAccountDialog {...defaultProps} />);
    expect(
      screen.getByText(/permanently delete all your data/i),
    ).toBeInTheDocument();
  });

  it("shows export-first suggestion", () => {
    render(<DeleteAccountDialog {...defaultProps} />);
    expect(
      screen.getByText(/recommend exporting your data first/i),
    ).toBeInTheDocument();
  });

  it("has confirmation text input", () => {
    render(<DeleteAccountDialog {...defaultProps} />);
    expect(screen.getByTestId("delete-confirm-input")).toBeInTheDocument();
  });

  it("confirm button is disabled by default", () => {
    render(<DeleteAccountDialog {...defaultProps} />);
    expect(
      screen.getByTestId("delete-account-confirm-button"),
    ).toBeDisabled();
  });

  it("confirm button enables when DELETE is typed", async () => {
    render(<DeleteAccountDialog {...defaultProps} />);
    const user = userEvent.setup();
    const input = screen.getByTestId("delete-confirm-input");

    await user.type(input, "DELETE");

    expect(
      screen.getByTestId("delete-account-confirm-button"),
    ).toBeEnabled();
  });

  it("confirm button stays disabled with wrong text", async () => {
    render(<DeleteAccountDialog {...defaultProps} />);
    const user = userEvent.setup();
    const input = screen.getByTestId("delete-confirm-input");

    await user.type(input, "delete"); // lowercase — case sensitive

    expect(
      screen.getByTestId("delete-account-confirm-button"),
    ).toBeDisabled();
  });

  it("calls onConfirm when DELETE is typed and button clicked", async () => {
    render(<DeleteAccountDialog {...defaultProps} />);
    const user = userEvent.setup();

    await user.type(screen.getByTestId("delete-confirm-input"), "DELETE");
    await user.click(screen.getByTestId("delete-account-confirm-button"));

    expect(defaultProps.onConfirm).toHaveBeenCalledTimes(1);
  });

  it("calls onCancel when cancel button clicked", async () => {
    render(<DeleteAccountDialog {...defaultProps} />);
    const user = userEvent.setup();

    const dialog = screen.getByTestId("delete-account-dialog");
    const cancelBtn = within(dialog).getByRole("button", {
      name: /cancel/i,
    });
    await user.click(cancelBtn);

    expect(defaultProps.onCancel).toHaveBeenCalledTimes(1);
  });

  it("shows processing text when loading", () => {
    render(<DeleteAccountDialog {...defaultProps} loading={true} />);
    expect(screen.getByText(/Deleting account/i)).toBeInTheDocument();
  });

  it("disables input and buttons when loading", () => {
    render(<DeleteAccountDialog {...defaultProps} loading={true} />);
    expect(screen.getByTestId("delete-confirm-input")).toBeDisabled();
    expect(
      screen.getByTestId("delete-account-confirm-button"),
    ).toBeDisabled();
  });

  it("does not call onCancel when loading", async () => {
    render(<DeleteAccountDialog {...defaultProps} loading={true} />);
    const user = userEvent.setup();

    const dialog = screen.getByTestId("delete-account-dialog");
    const cancelBtn = within(dialog).getByRole("button", {
      name: /cancel/i,
    });
    // Cancel button is disabled during loading
    expect(cancelBtn).toBeDisabled();
    await user.click(cancelBtn);

    expect(defaultProps.onCancel).not.toHaveBeenCalled();
  });

  it("fires onCancel on native dialog cancel event when not loading", () => {
    render(<DeleteAccountDialog {...defaultProps} />);
    const dialog = screen.getByTestId("delete-account-dialog");
    dialog.dispatchEvent(new Event("cancel"));
    expect(defaultProps.onCancel).toHaveBeenCalledTimes(1);
  });

  it("ignores native dialog cancel event when loading", () => {
    render(<DeleteAccountDialog {...defaultProps} loading={true} />);
    const dialog = screen.getByTestId("delete-account-dialog");
    dialog.dispatchEvent(new Event("cancel"));
    expect(defaultProps.onCancel).not.toHaveBeenCalled();
  });
});
