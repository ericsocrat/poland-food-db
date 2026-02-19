import { describe, it, expect, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import AppError from "./error";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockPush = vi.fn();

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: mockPush }),
}));

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => {
      const msgs: Record<string, string> = {
        "errorBoundary.pageTitle": "Something went wrong",
        "errorBoundary.pageDescription":
          "An unexpected error occurred. Please try again.",
        "errorBoundary.errorId": "Error ID",
        "errorBoundary.goHome": "Go Home",
        "common.tryAgain": "Try Again",
      };
      return msgs[key] ?? key;
    },
  }),
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("AppError (app-level error boundary)", () => {
  const baseError = new Error("test error");

  it("renders error alert", () => {
    render(<AppError error={baseError} reset={vi.fn()} />);
    expect(screen.getByRole("alert")).toBeInTheDocument();
    expect(screen.getByTestId("error-boundary-page")).toBeInTheDocument();
  });

  it("renders heading and description", () => {
    render(<AppError error={baseError} reset={vi.fn()} />);
    expect(screen.getByText("Something went wrong")).toBeInTheDocument();
    expect(
      screen.getByText("An unexpected error occurred. Please try again."),
    ).toBeInTheDocument();
  });

  it("renders Try Again button that calls reset", () => {
    const reset = vi.fn();
    render(<AppError error={baseError} reset={reset} />);
    const btn = screen.getByRole("button", { name: "Try Again" });
    fireEvent.click(btn);
    expect(reset).toHaveBeenCalledOnce();
  });

  it("renders Go Home button that navigates to /app", () => {
    render(<AppError error={baseError} reset={vi.fn()} />);
    const btn = screen.getByRole("button", { name: "Go Home" });
    fireEvent.click(btn);
    expect(mockPush).toHaveBeenCalledWith("/app");
  });

  it("shows error digest when present", () => {
    const errorWithDigest = Object.assign(new Error("bad"), {
      digest: "abc123",
    });
    render(<AppError error={errorWithDigest} reset={vi.fn()} />);
    expect(screen.getByText(/abc123/)).toBeInTheDocument();
    expect(screen.getByText(/Error ID/)).toBeInTheDocument();
  });

  it("does not show digest section when digest is absent", () => {
    render(<AppError error={baseError} reset={vi.fn()} />);
    expect(screen.queryByText(/Error ID/)).not.toBeInTheDocument();
  });

  it("does not log error outside development", () => {
    const spy = vi.spyOn(console, "error").mockImplementation(() => {});
    render(<AppError error={baseError} reset={vi.fn()} />);
    // NODE_ENV is "test", not "development"
    expect(spy).not.toHaveBeenCalled();
    spy.mockRestore();
  });

  it("renders warning icon as decorative", () => {
    render(<AppError error={baseError} reset={vi.fn()} />);
    const alert = screen.getByRole("alert");
    const svg = alert.querySelector("svg");
    expect(svg).toHaveAttribute("aria-hidden", "true");
  });
});
