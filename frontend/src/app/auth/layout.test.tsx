import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import AuthLayout from "./layout";

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("AuthLayout", () => {
  it("renders children in the form panel", () => {
    render(
      <AuthLayout>
        <div data-testid="child">Form content</div>
      </AuthLayout>,
    );
    expect(screen.getByTestId("child")).toBeInTheDocument();
    expect(screen.getByText("Form content")).toBeInTheDocument();
  });

  it("renders illustration panel with welcome image", () => {
    const { container } = render(
      <AuthLayout>
        <div>Form</div>
      </AuthLayout>,
    );
    const illustration = container.querySelector(
      '.auth-illustration img[src="/illustrations/onboarding/step-1-welcome.svg"]',
    );
    expect(illustration).toBeInTheDocument();
  });

  it("renders logo lockup in illustration panel", () => {
    render(
      <AuthLayout>
        <div>Form</div>
      </AuthLayout>,
    );
    // Logo component renders an img with alt="TryVit"
    const logos = screen.getAllByAltText("TryVit");
    expect(logos.length).toBeGreaterThanOrEqual(1);
  });

  it("renders brand description text in illustration panel", () => {
    render(
      <AuthLayout>
        <div>Form</div>
      </AuthLayout>,
    );
    expect(
      screen.getByText(/Search, scan, and compare food products/),
    ).toBeInTheDocument();
  });

  it("illustration panel has auth-illustration class for gradient", () => {
    const { container } = render(
      <AuthLayout>
        <div>Form</div>
      </AuthLayout>,
    );
    const panel = container.querySelector(".auth-illustration");
    expect(panel).toBeInTheDocument();
  });

  it("illustration panel is hidden on mobile (lg:flex)", () => {
    const { container } = render(
      <AuthLayout>
        <div>Form</div>
      </AuthLayout>,
    );
    const panel = container.querySelector(".auth-illustration");
    expect(panel).toHaveClass("hidden", "lg:flex");
  });
});
