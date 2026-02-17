import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { ProgressBar } from "./ProgressBar";

describe("ProgressBar", () => {
  it("renders with progressbar role", () => {
    render(<ProgressBar value={50} />);
    expect(screen.getByRole("progressbar")).toBeTruthy();
  });

  it("sets aria-valuenow", () => {
    render(<ProgressBar value={75} />);
    const bar = screen.getByRole("progressbar");
    expect(bar.getAttribute("aria-valuenow")).toBe("75");
    expect(bar.getAttribute("aria-valuemin")).toBe("0");
    expect(bar.getAttribute("aria-valuemax")).toBe("100");
  });

  it("clamps value to 0–100", () => {
    const { rerender } = render(<ProgressBar value={-10} />);
    expect(screen.getByRole("progressbar").getAttribute("aria-valuenow")).toBe(
      "0",
    );
    rerender(<ProgressBar value={150} />);
    expect(screen.getByRole("progressbar").getAttribute("aria-valuenow")).toBe(
      "100",
    );
  });

  it("shows label when showLabel is true", () => {
    render(<ProgressBar value={42} showLabel />);
    expect(screen.getByText("42%")).toBeTruthy();
  });

  it("shows custom label text", () => {
    render(<ProgressBar value={60} showLabel label="60/100 points" />);
    expect(screen.getByText("60/100 points")).toBeTruthy();
  });

  it("applies brand variant by default", () => {
    const { container } = render(<ProgressBar value={50} />);
    const fill = container.querySelector("[style]");
    expect(fill).toBeTruthy();
  });

  it("uses score colors for score variant", () => {
    const { container } = render(<ProgressBar value={90} variant="score" />);
    const fill = container.querySelector(".bg-score-darkred");
    expect(fill).toBeTruthy();
  });

  it("uses green for low score variant", () => {
    const { container } = render(<ProgressBar value={15} variant="score" />);
    const fill = container.querySelector(".bg-score-green");
    expect(fill).toBeTruthy();
  });

  it("applies size classes", () => {
    render(<ProgressBar value={50} size="sm" />);
    const bar = screen.getByRole("progressbar");
    expect(bar.className).toContain("h-1.5");
  });

  it("has accessible aria-label", () => {
    render(<ProgressBar value={33} />);
    expect(screen.getByLabelText("Progress: 33%")).toBeTruthy();
  });

  it("accepts custom ariaLabel", () => {
    render(<ProgressBar value={80} ariaLabel="Upload progress: 80%" />);
    expect(screen.getByLabelText("Upload progress: 80%")).toBeTruthy();
  });
});
