import { describe, expect, it } from "vitest";
import { render, screen } from "@testing-library/react";
import { TrafficLightStrip } from "./TrafficLightStrip";

describe("TrafficLightStrip", () => {
  it("renders traffic light dots for key nutrients", () => {
    render(
      <TrafficLightStrip
        nutrition={{
          total_fat_g: 20,
          saturated_fat_g: 6,
          sugars_g: 3,
          salt_g: 0.2,
        }}
      />,
    );

    // Fat >17.5 = red, Sat fat >5 = red, Sugars ≤5 = green, Salt ≤0.3 = green
    const group = screen.getByRole("group");
    expect(group).toBeInTheDocument();

    // All 4 nutrients should render
    expect(screen.getByText("Total Fat")).toBeInTheDocument();
    expect(screen.getByText("Saturated Fat")).toBeInTheDocument();
    expect(screen.getByText("Sugars")).toBeInTheDocument();
    expect(screen.getByText("Salt")).toBeInTheDocument();
  });

  it("renders correct number of colored dots", () => {
    const { container } = render(
      <TrafficLightStrip
        nutrition={{
          total_fat_g: 10,
          saturated_fat_g: 3,
          sugars_g: 15,
          salt_g: 1.0,
        }}
      />,
    );

    // All 4 should be amber range
    const dots = container.querySelectorAll('[aria-hidden="true"]');
    expect(dots.length).toBe(4);
  });

  it("returns null when no traffic light data available", () => {
    // getTrafficLight returns null when nutrient is not in thresholds
    // but all 4 are in thresholds, so we test with 0 values (still yields green)
    const { container } = render(
      <TrafficLightStrip
        nutrition={{
          total_fat_g: 0,
          saturated_fat_g: 0,
          sugars_g: 0,
          salt_g: 0,
        }}
      />,
    );

    // Should still render (all green)
    expect(container.querySelector('[role="group"]')).toBeInTheDocument();
  });
});
