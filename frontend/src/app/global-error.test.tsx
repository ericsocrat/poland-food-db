import { describe, expect, it, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import GlobalError from "./global-error";

describe("GlobalError", () => {
  it("renders heading", () => {
    render(<GlobalError error={new Error("test")} reset={vi.fn()} />);
    expect(screen.getByText("Something went wrong")).toBeInTheDocument();
  });

  it("renders critical error message", () => {
    render(<GlobalError error={new Error("test")} reset={vi.fn()} />);
    expect(screen.getByText(/critical error/i)).toBeInTheDocument();
  });

  it("calls reset when clicking try again", () => {
    const reset = vi.fn();
    render(<GlobalError error={new Error("test")} reset={reset} />);
    fireEvent.click(screen.getByRole("button", { name: "Try again" }));
    expect(reset).toHaveBeenCalledOnce();
  });

  it("renders with an error that has a digest property", () => {
    const error = Object.assign(new Error("crash"), { digest: "abc123" });
    render(<GlobalError error={error} reset={vi.fn()} />);
    expect(screen.getByText("Something went wrong")).toBeInTheDocument();
  });

  it("renders centered layout with flexbox", () => {
    const { container } = render(
      <GlobalError error={new Error("test")} reset={vi.fn()} />,
    );
    const div = container.querySelector("div");
    expect(div).toHaveStyle({ display: "flex" });
  });

  it("apply the green style on the button", () => {
    render(<GlobalError error={new Error("test")} reset={vi.fn()} />);
    const btn = screen.getByRole("button", { name: "Try again" });
    expect(btn).toHaveStyle({ backgroundColor: "#16a34a" });
  });
});
