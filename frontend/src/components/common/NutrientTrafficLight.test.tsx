import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import {
  NutrientTrafficLight,
  classifyLevel,
  THRESHOLDS,
} from "./NutrientTrafficLight";

describe("NutrientTrafficLight", () => {
  describe("classifyLevel thresholds", () => {
    // Fat: ≤3g green, 3.1–17.5g amber, >17.5g red
    it("classifies fat correctly", () => {
      expect(classifyLevel("fat", 2)).toBe("low");
      expect(classifyLevel("fat", 3)).toBe("low");
      expect(classifyLevel("fat", 3.1)).toBe("medium");
      expect(classifyLevel("fat", 17.5)).toBe("medium");
      expect(classifyLevel("fat", 17.6)).toBe("high");
    });

    // Saturates: ≤1.5g green, 1.6–5g amber, >5g red
    it("classifies saturates correctly", () => {
      expect(classifyLevel("saturates", 1)).toBe("low");
      expect(classifyLevel("saturates", 1.5)).toBe("low");
      expect(classifyLevel("saturates", 1.6)).toBe("medium");
      expect(classifyLevel("saturates", 5)).toBe("medium");
      expect(classifyLevel("saturates", 5.1)).toBe("high");
    });

    // Sugars: ≤5g green, 5.1–22.5g amber, >22.5g red
    it("classifies sugars correctly", () => {
      expect(classifyLevel("sugars", 4)).toBe("low");
      expect(classifyLevel("sugars", 5)).toBe("low");
      expect(classifyLevel("sugars", 5.1)).toBe("medium");
      expect(classifyLevel("sugars", 22.5)).toBe("medium");
      expect(classifyLevel("sugars", 22.6)).toBe("high");
    });

    // Salt: ≤0.3g green, 0.31–1.5g amber, >1.5g red
    it("classifies salt correctly", () => {
      expect(classifyLevel("salt", 0.2)).toBe("low");
      expect(classifyLevel("salt", 0.3)).toBe("low");
      expect(classifyLevel("salt", 0.31)).toBe("medium");
      expect(classifyLevel("salt", 1.5)).toBe("medium");
      expect(classifyLevel("salt", 1.6)).toBe("high");
    });
  });

  describe("rendering", () => {
    it("renders nutrient name and value", () => {
      render(<NutrientTrafficLight nutrient="sugars" value={12} />);
      expect(screen.getByText("Sugars")).toBeTruthy();
      expect(screen.getByText("12g")).toBeTruthy();
    });

    it("renders custom unit", () => {
      render(<NutrientTrafficLight nutrient="salt" value={0.8} unit="mg" />);
      expect(screen.getByText("0.8mg")).toBeTruthy();
    });

    it("applies low/green styling for low values", () => {
      render(<NutrientTrafficLight nutrient="fat" value={2} />);
      const badge = screen.getByLabelText("Fat: 2g (Low)");
      expect(badge.className).toContain("text-nutrient-low");
    });

    it("applies medium/amber styling for medium values", () => {
      render(<NutrientTrafficLight nutrient="sugars" value={15} />);
      const badge = screen.getByLabelText("Sugars: 15g (Medium)");
      expect(badge.className).toContain("text-nutrient-medium");
    });

    it("applies high/red styling for high values", () => {
      render(<NutrientTrafficLight nutrient="salt" value={2} />);
      const badge = screen.getByLabelText("Salt: 2g (High)");
      expect(badge.className).toContain("text-nutrient-high");
    });

    it("has colored dot indicator", () => {
      const { container } = render(
        <NutrientTrafficLight nutrient="fat" value={1} />,
      );
      const dot = container.querySelector('[aria-hidden="true"]');
      expect(dot).toBeTruthy();
      expect(dot!.className).toContain("rounded-full");
    });

    it("has accessible aria-label", () => {
      render(<NutrientTrafficLight nutrient="saturates" value={3} />);
      expect(screen.getByLabelText("Saturates: 3g (Medium)")).toBeTruthy();
    });
  });

  describe("thresholds are regulatory constants", () => {
    it("uses correct FSA fat thresholds", () => {
      expect(THRESHOLDS.fat).toEqual({ green: 3, amber: 17.5 });
    });
    it("uses correct FSA saturates thresholds", () => {
      expect(THRESHOLDS.saturates).toEqual({ green: 1.5, amber: 5 });
    });
    it("uses correct FSA sugars thresholds", () => {
      expect(THRESHOLDS.sugars).toEqual({ green: 5, amber: 22.5 });
    });
    it("uses correct FSA salt thresholds", () => {
      expect(THRESHOLDS.salt).toEqual({ green: 0.3, amber: 1.5 });
    });
  });
});
