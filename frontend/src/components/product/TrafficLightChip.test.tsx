import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { TrafficLightChip, getTrafficLight } from "./TrafficLightChip";

describe("getTrafficLight", () => {
  it("returns null for unknown nutrient", () => {
    expect(getTrafficLight("protein", 50)).toBeNull();
  });

  it("returns null for null value", () => {
    expect(getTrafficLight("salt", null)).toBeNull();
  });

  // ── Total fat thresholds ──────────────────────────────────────────────
  it("total_fat: green when ≤ 3g", () => {
    expect(getTrafficLight("total_fat", 2.5)).toBe("green");
    expect(getTrafficLight("total_fat", 3)).toBe("green");
  });

  it("total_fat: amber when 3.1–17.5g", () => {
    expect(getTrafficLight("total_fat", 3.1)).toBe("amber");
    expect(getTrafficLight("total_fat", 10)).toBe("amber");
    expect(getTrafficLight("total_fat", 17.5)).toBe("amber");
  });

  it("total_fat: red when > 17.5g", () => {
    expect(getTrafficLight("total_fat", 17.6)).toBe("red");
    expect(getTrafficLight("total_fat", 30)).toBe("red");
  });

  // ── Saturated fat thresholds ──────────────────────────────────────────
  it("saturated_fat: green when ≤ 1.5g", () => {
    expect(getTrafficLight("saturated_fat", 1)).toBe("green");
    expect(getTrafficLight("saturated_fat", 1.5)).toBe("green");
  });

  it("saturated_fat: amber when 1.6–5g", () => {
    expect(getTrafficLight("saturated_fat", 2)).toBe("amber");
    expect(getTrafficLight("saturated_fat", 5)).toBe("amber");
  });

  it("saturated_fat: red when > 5g", () => {
    expect(getTrafficLight("saturated_fat", 5.1)).toBe("red");
  });

  // ── Sugars thresholds ─────────────────────────────────────────────────
  it("sugars: green when ≤ 5g", () => {
    expect(getTrafficLight("sugars", 4)).toBe("green");
  });

  it("sugars: amber when 5.1–22.5g", () => {
    expect(getTrafficLight("sugars", 10)).toBe("amber");
  });

  it("sugars: red when > 22.5g", () => {
    expect(getTrafficLight("sugars", 25)).toBe("red");
  });

  // ── Salt thresholds ───────────────────────────────────────────────────
  it("salt: green when ≤ 0.3g", () => {
    expect(getTrafficLight("salt", 0.1)).toBe("green");
  });

  it("salt: amber when 0.31–1.5g", () => {
    expect(getTrafficLight("salt", 0.5)).toBe("amber");
  });

  it("salt: red when > 1.5g", () => {
    expect(getTrafficLight("salt", 2)).toBe("red");
  });
});

describe("TrafficLightChip", () => {
  it("renders green chip with 'Low' label", () => {
    render(<TrafficLightChip level="green" />);
    expect(screen.getByText("Low")).toBeTruthy();
    expect(screen.getByLabelText("Low")).toBeTruthy();
  });

  it("renders amber chip with 'Medium' label", () => {
    render(<TrafficLightChip level="amber" />);
    expect(screen.getByText("Medium")).toBeTruthy();
  });

  it("renders red chip with 'High' label", () => {
    render(<TrafficLightChip level="red" />);
    expect(screen.getByText("High")).toBeTruthy();
  });
});
