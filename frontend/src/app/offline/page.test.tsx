import { describe, expect, it, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import OfflinePage from "./page";

vi.mock("next/image", () => ({
  default: ({ priority, ...props }: Record<string, unknown>) => (
    // eslint-disable-next-line @next/next/no-img-element, jsx-a11y/alt-text
    <img {...props} data-priority={priority ? "true" : "false"} />
  ),
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("OfflinePage", () => {
  it("renders offline title", () => {
    render(<OfflinePage />);
    expect(screen.getByText("You're Offline")).toBeInTheDocument();
  });

  it("renders offline description", () => {
    render(<OfflinePage />);
    expect(
      screen.getByText(/lost your internet connection/i),
    ).toBeInTheDocument();
  });

  it("renders error illustration", () => {
    const { container } = render(<OfflinePage />);
    const img = container.querySelector("img[data-illustration='offline']");
    expect(img).toBeTruthy();
  });

  it("renders try again button", () => {
    render(<OfflinePage />);
    expect(
      screen.getByRole("button", { name: "Try Again" }),
    ).toBeInTheDocument();
  });

  it("reloads page on try again click", () => {
    const reloadMock = vi.fn();
    Object.defineProperty(globalThis, "location", {
      value: { reload: reloadMock },
      writable: true,
    });
    render(<OfflinePage />);
    fireEvent.click(screen.getByRole("button", { name: "Try Again" }));
    expect(reloadMock).toHaveBeenCalledOnce();
  });
});
