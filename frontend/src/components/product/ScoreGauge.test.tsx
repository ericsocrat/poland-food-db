import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { ScoreGauge } from "./ScoreGauge";

describe("ScoreGauge", () => {
  // ── Rendering ─────────────────────────────────────────────────────────────

  it("renders score text and /100 label", () => {
    render(<ScoreGauge score={42} />);
    expect(screen.getByText("42")).toBeInTheDocument();
    expect(screen.getByText("/100")).toBeInTheDocument();
  });

  it("renders dash when score is null", () => {
    render(<ScoreGauge score={null} />);
    expect(screen.getByText("—")).toBeInTheDocument();
    expect(screen.queryByText("/100")).not.toBeInTheDocument();
  });

  it("renders dash when score is undefined", () => {
    render(<ScoreGauge score={undefined} />);
    expect(screen.getByText("—")).toBeInTheDocument();
  });

  // ── SVG arc ───────────────────────────────────────────────────────────────

  it("renders gauge arc when score is provided", () => {
    render(<ScoreGauge score={50} />);
    const arc = screen.getByTestId("gauge-arc");
    expect(arc).toBeInTheDocument();
    expect(arc.getAttribute("stroke-dasharray")).toBeTruthy();
  });

  it("does not render gauge arc when score is null", () => {
    render(<ScoreGauge score={null} />);
    expect(screen.queryByTestId("gauge-arc")).not.toBeInTheDocument();
  });

  // ── Score band colors ─────────────────────────────────────────────────────

  it("uses green color for low score (10)", () => {
    render(<ScoreGauge score={10} />);
    const arc = screen.getByTestId("gauge-arc");
    expect(arc.getAttribute("stroke")).toBe("var(--color-score-green)");
  });

  it("uses yellow color for moderate score (30)", () => {
    render(<ScoreGauge score={30} />);
    const arc = screen.getByTestId("gauge-arc");
    expect(arc.getAttribute("stroke")).toBe("var(--color-score-yellow)");
  });

  it("uses orange color for high score (60)", () => {
    render(<ScoreGauge score={60} />);
    const arc = screen.getByTestId("gauge-arc");
    expect(arc.getAttribute("stroke")).toBe("var(--color-score-orange)");
  });

  it("uses red color for very high score (85)", () => {
    render(<ScoreGauge score={85} />);
    const arc = screen.getByTestId("gauge-arc");
    expect(arc.getAttribute("stroke")).toBe("var(--color-score-red)");
  });

  // ── Sizes ─────────────────────────────────────────────────────────────────

  it("renders with small size", () => {
    render(<ScoreGauge score={50} size="sm" />);
    const wrapper = screen.getByRole("img");
    expect(wrapper).toHaveStyle({ width: "48px", height: "48px" });
  });

  it("renders with large size", () => {
    render(<ScoreGauge score={50} size="lg" />);
    const wrapper = screen.getByRole("img");
    expect(wrapper).toHaveStyle({ width: "80px", height: "80px" });
  });

  // ── Accessibility ─────────────────────────────────────────────────────────

  it("has aria-label with score value", () => {
    render(<ScoreGauge score={65} />);
    const wrapper = screen.getByRole("img");
    expect(wrapper).toHaveAttribute(
      "aria-label",
      expect.stringContaining("65"),
    );
  });

  it("has neutral aria-label when score is null", () => {
    render(<ScoreGauge score={null} />);
    const wrapper = screen.getByRole("img");
    expect(wrapper.getAttribute("aria-label")).toBeTruthy();
  });

  // ── Edge cases ────────────────────────────────────────────────────────────

  it("clamps score at 100 for arc calculation", () => {
    render(<ScoreGauge score={150} />);
    expect(screen.getByText("150")).toBeInTheDocument();
    // Arc should still render (clamped internally)
    expect(screen.getByTestId("gauge-arc")).toBeInTheDocument();
  });

  it("clamps score at 0 for arc calculation", () => {
    render(<ScoreGauge score={0} />);
    expect(screen.getByText("0")).toBeInTheDocument();
    expect(screen.getByTestId("gauge-arc")).toBeInTheDocument();
  });

  it("applies custom className", () => {
    render(<ScoreGauge score={50} className="my-custom-class" />);
    const wrapper = screen.getByRole("img");
    expect(wrapper).toHaveClass("my-custom-class");
  });
});
