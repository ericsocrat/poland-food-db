import { describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { Providers } from "./Providers";

// Mock sonner Toaster — lightweight stub
vi.mock("sonner", () => ({
  Toaster: () => <div data-testid="toaster" />,
}));

describe("Providers", () => {
  it("renders children", () => {
    render(
      <Providers>
        <p>Hello</p>
      </Providers>,
    );
    expect(screen.getByText("Hello")).toBeInTheDocument();
  });

  it("renders Toaster", () => {
    render(
      <Providers>
        <span />
      </Providers>,
    );
    expect(screen.getByTestId("toaster")).toBeInTheDocument();
  });

  it("renders multiple children", () => {
    render(
      <Providers>
        <p>A</p>
        <p>B</p>
      </Providers>,
    );
    expect(screen.getByText("A")).toBeInTheDocument();
    expect(screen.getByText("B")).toBeInTheDocument();
  });
});
