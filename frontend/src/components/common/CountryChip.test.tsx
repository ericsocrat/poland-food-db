import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { CountryChip } from "./CountryChip";

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("CountryChip", () => {
  it("renders null when country is null", () => {
    const { container } = render(<CountryChip country={null} />);
    expect(container.innerHTML).toBe("");
  });

  it("renders flag and name for known country PL", () => {
    render(<CountryChip country="PL" />);
    expect(screen.getByText("🇵🇱")).toBeTruthy();
    expect(screen.getByText("Poland")).toBeTruthy();
  });

  it("renders flag and name for known country DE", () => {
    render(<CountryChip country="DE" />);
    expect(screen.getByText("🇩🇪")).toBeTruthy();
    expect(screen.getByText("Germany")).toBeTruthy();
  });

  it("renders fallback globe for unknown country code", () => {
    render(<CountryChip country="XX" />);
    expect(screen.getByText("🌍")).toBeTruthy();
    expect(screen.getByText("XX")).toBeTruthy();
  });

  it("applies custom className", () => {
    const { container } = render(<CountryChip country="PL" className="ml-2" />);
    const chip = container.querySelector("span");
    expect(chip?.className).toContain("ml-2");
  });
});
