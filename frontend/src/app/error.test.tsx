import { describe, expect, it, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import ErrorPage from "./error";

describe("ErrorPage", () => {
  it("renders heading", () => {
    render(<ErrorPage error={new Error("test")} reset={vi.fn()} />);
    expect(screen.getByText("Something went wrong")).toBeInTheDocument();
  });

  it("renders try again button", () => {
    render(<ErrorPage error={new Error("test")} reset={vi.fn()} />);
    expect(
      screen.getByRole("button", { name: "Try again" }),
    ).toBeInTheDocument();
  });

  it("calls reset when clicking try again", () => {
    const reset = vi.fn();
    render(<ErrorPage error={new Error("test")} reset={reset} />);
    fireEvent.click(screen.getByRole("button", { name: "Try again" }));
    expect(reset).toHaveBeenCalledOnce();
  });

  it("does not log error outside development", () => {
    const spy = vi.spyOn(console, "error").mockImplementation(() => {});
    render(<ErrorPage error={new Error("boom")} reset={vi.fn()} />);
    // In test env NODE_ENV is "test", not "development", so no logging
    expect(spy).not.toHaveBeenCalled();
    spy.mockRestore();
  });

  it("renders AlertTriangle icon", () => {
    const { container } = render(
      <ErrorPage error={new Error("test")} reset={vi.fn()} />,
    );
    const svg = container.querySelector("svg");
    expect(svg).toBeTruthy();
    expect(svg?.getAttribute("aria-hidden")).toBe("true");
  });
});
