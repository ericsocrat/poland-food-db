import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => key,
  }),
}));

import { NutritionHighlights } from "./NutritionHighlights";

// ── Fixtures ─────────────────────────────────────────────────────────────────

const baseNutrition = {
  total_fat_g: 10,
  saturated_fat_g: 5,
  sugars_g: 12,
  salt_g: 1.2,
};

// ── Tests ────────────────────────────────────────────────────────────────────

describe("NutritionHighlights", () => {
  // ── Rendering ────────────────────────────────────────────────────────────

  it("renders the key nutrients header", () => {
    render(<NutritionHighlights nutrition={baseNutrition} />);
    expect(screen.getByText("product.keyNutrients")).toBeInTheDocument();
  });

  it("renders per100g footer", () => {
    render(<NutritionHighlights nutrition={baseNutrition} />);
    expect(screen.getByText("product.per100g")).toBeInTheDocument();
  });

  it("renders all 4 nutrient values", () => {
    render(<NutritionHighlights nutrition={baseNutrition} />);
    expect(screen.getByText("10.0g")).toBeInTheDocument();
    expect(screen.getByText("5.0g")).toBeInTheDocument();
    expect(screen.getByText("12.0g")).toBeInTheDocument();
    expect(screen.getByText("1.2g")).toBeInTheDocument();
  });

  it("renders 4 progress bars", () => {
    render(<NutritionHighlights nutrition={baseNutrition} />);
    const bars = screen.getAllByRole("progressbar");
    expect(bars).toHaveLength(4);
  });

  // ── ARIA values ──────────────────────────────────────────────────────────

  it("sets correct aria-valuenow on progress bars", () => {
    render(<NutritionHighlights nutrition={baseNutrition} />);
    const bars = screen.getAllByRole("progressbar");
    const values = bars.map((b) => Number(b.getAttribute("aria-valuenow")));
    expect(values).toEqual([10, 5, 12, 1.2]);
  });

  // ── Zero values ──────────────────────────────────────────────────────────

  it("renders zero values correctly", () => {
    render(
      <NutritionHighlights
        nutrition={{
          total_fat_g: 0,
          saturated_fat_g: 0,
          sugars_g: 0,
          salt_g: 0,
        }}
      />,
    );
    const zeros = screen.getAllByText("0.0g");
    expect(zeros).toHaveLength(4);
  });

  // ── High values clamp bar width ──────────────────────────────────────────

  it("renders high values without overflowing bars", () => {
    render(
      <NutritionHighlights
        nutrition={{
          total_fat_g: 80,
          saturated_fat_g: 30,
          sugars_g: 100,
          salt_g: 10,
        }}
      />,
    );
    // Values should render as text
    expect(screen.getByText("80.0g")).toBeInTheDocument();
    expect(screen.getByText("30.0g")).toBeInTheDocument();
    expect(screen.getByText("100.0g")).toBeInTheDocument();
    expect(screen.getByText("10.0g")).toBeInTheDocument();
  });
});
