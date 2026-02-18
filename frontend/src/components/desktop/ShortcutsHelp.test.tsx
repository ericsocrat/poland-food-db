import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { ShortcutsHelp } from "./ShortcutsHelp";

// ─── Stub native dialog methods (jsdom doesn't support them) ────────────────

beforeEach(() => {
  HTMLDialogElement.prototype.showModal = vi.fn();
  HTMLDialogElement.prototype.close = vi.fn();
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ShortcutsHelp", () => {
  const onClose = vi.fn();

  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("calls showModal when open is true", () => {
    render(<ShortcutsHelp open={true} onClose={onClose} />);
    expect(HTMLDialogElement.prototype.showModal).toHaveBeenCalled();
  });

  it("does not call showModal when open is false", () => {
    render(<ShortcutsHelp open={false} onClose={onClose} />);
    expect(HTMLDialogElement.prototype.showModal).not.toHaveBeenCalled();
  });

  it("renders the title", () => {
    render(<ShortcutsHelp open={true} onClose={onClose} />);
    expect(screen.getByText("Keyboard Shortcuts")).toBeTruthy();
  });

  it("renders navigation shortcut keys", () => {
    render(<ShortcutsHelp open={true} onClose={onClose} />);
    expect(screen.getByText("Command Palette")).toBeTruthy();
    expect(screen.getByText("Focus Search")).toBeTruthy();
    expect(screen.getByText("Go to Dashboard")).toBeTruthy();
    expect(screen.getByText("Go to Lists")).toBeTruthy();
    expect(screen.getByText("Open Scanner")).toBeTruthy();
  });

  it("renders general shortcut labels", () => {
    render(<ShortcutsHelp open={true} onClose={onClose} />);
    expect(screen.getByText("Show this help")).toBeTruthy();
    expect(screen.getByText("Close modal / overlay")).toBeTruthy();
  });

  it("renders kbd elements for shortcut keys", () => {
    render(<ShortcutsHelp open={true} onClose={onClose} />);
    // Ctrl+K for command palette
    expect(screen.getByText("Ctrl")).toBeTruthy();
    expect(screen.getByText("K")).toBeTruthy();
    // Single key shortcuts
    expect(screen.getByText("/")).toBeTruthy();
    expect(screen.getByText("H")).toBeTruthy();
    expect(screen.getByText("L")).toBeTruthy();
    expect(screen.getByText("S")).toBeTruthy();
    expect(screen.getByText("?")).toBeTruthy();
    expect(screen.getByText("Esc")).toBeTruthy();
  });

  it("renders section headings", () => {
    render(<ShortcutsHelp open={true} onClose={onClose} />);
    expect(screen.getByText("Navigation")).toBeTruthy();
    expect(screen.getByText("General")).toBeTruthy();
  });

  it("calls onClose when close button is clicked", () => {
    render(<ShortcutsHelp open={true} onClose={onClose} />);
    const closeBtn = screen.getByLabelText("Close");
    fireEvent.click(closeBtn);
    expect(onClose).toHaveBeenCalledTimes(1);
  });

  it("calls onClose on backdrop click", () => {
    render(<ShortcutsHelp open={true} onClose={onClose} />);
    const dialog = document.querySelector("dialog");
    // Simulate clicking the dialog element itself (backdrop)
    fireEvent.click(dialog!);
    expect(onClose).toHaveBeenCalledTimes(1);
  });

  it("does not call onClose when clicking inside the dialog content", () => {
    render(<ShortcutsHelp open={true} onClose={onClose} />);
    fireEvent.click(screen.getByText("Keyboard Shortcuts"));
    expect(onClose).not.toHaveBeenCalled();
  });
});
