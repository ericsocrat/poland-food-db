import { describe, expect, it } from "vitest";
import { render, screen } from "@testing-library/react";
import OnboardingLayout from "./layout";

describe("OnboardingLayout", () => {
  it("renders FoodDB brand text in header", () => {
    render(
      <OnboardingLayout>
        <p>child</p>
      </OnboardingLayout>,
    );
    expect(screen.getByText("🥗 FoodDB")).toBeInTheDocument();
  });

  it("renders children in main area", () => {
    render(
      <OnboardingLayout>
        <p>Step 1 content</p>
      </OnboardingLayout>,
    );
    expect(screen.getByText("Step 1 content")).toBeInTheDocument();
  });

  it("renders header with border styling", () => {
    render(
      <OnboardingLayout>
        <span />
      </OnboardingLayout>,
    );
    const header = screen.getByText("🥗 FoodDB").closest("header");
    expect(header?.className).toContain("border-b");
  });
});
