import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { AllergenBadge } from "./AllergenBadge";

describe("AllergenBadge", () => {
  it("renders allergen name", () => {
    render(<AllergenBadge status="present" allergenName="Gluten" />);
    expect(screen.getByText("Gluten")).toBeTruthy();
  });

  it("applies present status styling", () => {
    render(<AllergenBadge status="present" allergenName="Milk" />);
    const badge = screen.getByLabelText("Contains Milk");
    expect(badge.className).toContain("text-allergen-present");
    expect(badge.className).toContain("bg-allergen-present/10");
  });

  it("applies traces status styling", () => {
    render(<AllergenBadge status="traces" allergenName="Nuts" />);
    const badge = screen.getByLabelText("May contain traces of Nuts");
    expect(badge.className).toContain("text-allergen-traces");
  });

  it("applies free status styling", () => {
    render(<AllergenBadge status="free" allergenName="Soy" />);
    const badge = screen.getByLabelText("Free from Soy");
    expect(badge.className).toContain("text-allergen-free");
  });

  it("shows correct icon for present", () => {
    render(<AllergenBadge status="present" allergenName="Eggs" />);
    expect(screen.getByText("⚠️")).toBeTruthy();
  });

  it("shows correct icon for traces", () => {
    render(<AllergenBadge status="traces" allergenName="Fish" />);
    expect(screen.getByText("⚡")).toBeTruthy();
  });

  it("shows correct icon for free", () => {
    render(<AllergenBadge status="free" allergenName="Sesame" />);
    expect(screen.getByText("✓")).toBeTruthy();
  });

  it("applies size classes", () => {
    render(<AllergenBadge status="present" allergenName="Gluten" size="md" />);
    const badge = screen.getByLabelText("Contains Gluten");
    expect(badge.className).toContain("text-sm");
  });
});
