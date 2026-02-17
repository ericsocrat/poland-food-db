import { render, screen } from "@testing-library/react";
import { DVLegend } from "./DVLegend";

describe("DVLegend", () => {
  it("renders three traffic light levels", () => {
    render(<DVLegend />);
    expect(screen.getByText(/Low/)).toBeInTheDocument();
    expect(screen.getByText(/Moderate/)).toBeInTheDocument();
    expect(screen.getByText(/High/)).toBeInTheDocument();
  });

  it("renders colored dots", () => {
    const { container } = render(<DVLegend />);
    expect(container.querySelector(".bg-green-500")).toBeInTheDocument();
    expect(container.querySelector(".bg-amber-500")).toBeInTheDocument();
    expect(container.querySelector(".bg-red-500")).toBeInTheDocument();
  });
});
