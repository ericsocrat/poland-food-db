import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";

// ── Mocks ────────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => key,
  }),
}));

// Mock HTMLDialogElement.showModal (not available in jsdom)
beforeEach(() => {
  HTMLDialogElement.prototype.showModal =
    HTMLDialogElement.prototype.showModal || vi.fn();
  HTMLDialogElement.prototype.close =
    HTMLDialogElement.prototype.close || vi.fn();
});

import { PrivacyNotice } from "./PrivacyNotice";

// ── Tests ────────────────────────────────────────────────────────────────────

describe("PrivacyNotice", () => {
  it("renders nothing when open is false", () => {
    const { container } = render(
      <PrivacyNotice open={false} onAccept={vi.fn()} />,
    );
    expect(container.innerHTML).toBe("");
  });

  it("renders dialog with title when open", () => {
    render(<PrivacyNotice open={true} onAccept={vi.fn()} />);
    expect(
      screen.getByText("imageSearch.privacy.title"),
    ).toBeInTheDocument();
  });

  it("renders body text", () => {
    render(<PrivacyNotice open={true} onAccept={vi.fn()} />);
    expect(
      screen.getByText("imageSearch.privacy.body"),
    ).toBeInTheDocument();
  });

  it("renders all 4 privacy bullets", () => {
    render(<PrivacyNotice open={true} onAccept={vi.fn()} />);
    expect(screen.getByText("imageSearch.privacy.bullet1")).toBeInTheDocument();
    expect(screen.getByText("imageSearch.privacy.bullet2")).toBeInTheDocument();
    expect(screen.getByText("imageSearch.privacy.bullet3")).toBeInTheDocument();
    expect(screen.getByText("imageSearch.privacy.bullet4")).toBeInTheDocument();
  });

  it("renders accept button", () => {
    render(<PrivacyNotice open={true} onAccept={vi.fn()} />);
    const btn = screen.getByTestId("privacy-accept-btn");
    expect(btn).toBeInTheDocument();
    expect(btn).toHaveTextContent("imageSearch.privacy.accept");
  });

  it("calls onAccept when accept button is clicked", () => {
    const onAccept = vi.fn();
    render(<PrivacyNotice open={true} onAccept={onAccept} />);
    fireEvent.click(screen.getByTestId("privacy-accept-btn"));
    expect(onAccept).toHaveBeenCalledOnce();
  });

  it("has correct aria-labelledby on dialog", () => {
    const { container } = render(<PrivacyNotice open={true} onAccept={vi.fn()} />);
    const dialog = container.querySelector("dialog");
    expect(dialog).toHaveAttribute(
      "aria-labelledby",
      "privacy-notice-title",
    );
  });
});
