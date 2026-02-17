import { render, screen } from "@testing-library/react";
import { NutritionDVBar } from "./NutritionDVBar";
import type { NutrientDV } from "@/lib/types";

describe("NutritionDVBar", () => {
  const lowDV: NutrientDV = {
    value: 3,
    daily_value: 90,
    pct: 3.3,
    level: "low",
  };

  const moderateDV: NutrientDV = {
    value: 52,
    daily_value: 260,
    pct: 20,
    level: "moderate",
  };

  const highDV: NutrientDV = {
    value: 33,
    daily_value: 70,
    pct: 47.1,
    level: "high",
  };

  it("renders label and raw value", () => {
    render(
      <table>
        <tbody>
          <NutritionDVBar label="Total Fat" rawValue="33 g" dv={highDV} />
        </tbody>
      </table>,
    );
    expect(screen.getByText("Total Fat")).toBeInTheDocument();
    expect(screen.getByText("33 g")).toBeInTheDocument();
  });

  it("renders percentage text", () => {
    render(
      <table>
        <tbody>
          <NutritionDVBar label="Total Fat" rawValue="33 g" dv={highDV} />
        </tbody>
      </table>,
    );
    expect(screen.getByText("47.1%")).toBeInTheDocument();
  });

  it("renders progress element with correct value", () => {
    render(
      <table>
        <tbody>
          <NutritionDVBar label="Total Fat" rawValue="33 g" dv={highDV} />
        </tbody>
      </table>,
    );
    const bar = screen.getByRole("progressbar");
    expect(bar).toHaveAttribute("value", "47.1");
  });

  it("uses green color for low level", () => {
    render(
      <table>
        <tbody>
          <NutritionDVBar label="Sugars" rawValue="3 g" dv={lowDV} />
        </tbody>
      </table>,
    );
    expect(screen.getByText("3.3%")).toHaveClass("text-green-700");
  });

  it("uses amber color for moderate level", () => {
    render(
      <table>
        <tbody>
          <NutritionDVBar label="Carbs" rawValue="52 g" dv={moderateDV} />
        </tbody>
      </table>,
    );
    expect(screen.getByText("20%")).toHaveClass("text-amber-700");
  });

  it("uses red color for high level", () => {
    render(
      <table>
        <tbody>
          <NutritionDVBar label="Total Fat" rawValue="33 g" dv={highDV} />
        </tbody>
      </table>,
    );
    expect(screen.getByText("47.1%")).toHaveClass("text-red-700");
  });

  it("renders without progress bar when dv is null", () => {
    render(
      <table>
        <tbody>
          <NutritionDVBar label="Trans Fat" rawValue="—" dv={null} />
        </tbody>
      </table>,
    );
    expect(screen.getByText("Trans Fat")).toBeInTheDocument();
    expect(screen.getByText("—")).toBeInTheDocument();
    expect(screen.queryByRole("progressbar")).not.toBeInTheDocument();
  });

  it("caps progress bar width at 100%", () => {
    const overDV: NutrientDV = {
      value: 150,
      daily_value: 70,
      pct: 214.3,
      level: "high",
    };
    render(
      <table>
        <tbody>
          <NutritionDVBar label="Fat" rawValue="150 g" dv={overDV} />
        </tbody>
      </table>,
    );
    expect(screen.getByText("214.3%")).toBeInTheDocument();
  });
});
