import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { NovaDistributionChart } from "./NovaDistribution";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => key,
  }),
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("NovaDistributionChart", () => {
  it("renders nothing when all counts are 0", () => {
    const { container } = render(
      <NovaDistributionChart
        distribution={{ "1": 0, "2": 0, "3": 0, "4": 0 }}
      />,
    );
    expect(container.innerHTML).toBe("");
  });

  it("renders nothing for empty/undefined distribution values", () => {
    const { container } = render(
       
      <NovaDistributionChart distribution={{} as any} />,
    );
    expect(container.innerHTML).toBe("");
  });

  it("renders the chart when at least one count > 0", () => {
    render(
      <NovaDistributionChart
        distribution={{ "1": 5, "2": 0, "3": 0, "4": 0 }}
      />,
    );
    expect(screen.getByTestId("nova-distribution")).toBeInTheDocument();
  });

  it("displays title", () => {
    render(
      <NovaDistributionChart
        distribution={{ "1": 3, "2": 2, "3": 1, "4": 4 }}
      />,
    );
    expect(screen.getByText("dashboard.novaTitle")).toBeInTheDocument();
  });

  it("renders an SVG with accessible title", () => {
    render(
      <NovaDistributionChart
        distribution={{ "1": 3, "2": 2, "3": 1, "4": 4 }}
      />,
    );
    const svg = screen.getByLabelText("dashboard.novaAria");
    expect(svg).toBeInTheDocument();
    expect(svg.tagName.toLowerCase()).toBe("svg");
  });

  it("renders 4 bars via data-testid", () => {
    render(
      <NovaDistributionChart
        distribution={{ "1": 3, "2": 2, "3": 1, "4": 4 }}
      />,
    );
    expect(screen.getByTestId("nova-bar-1")).toBeInTheDocument();
    expect(screen.getByTestId("nova-bar-2")).toBeInTheDocument();
    expect(screen.getByTestId("nova-bar-3")).toBeInTheDocument();
    expect(screen.getByTestId("nova-bar-4")).toBeInTheDocument();
  });

  it("sets opacity=1 for non-zero bars and opacity=0.2 for zero bars", () => {
    render(
      <NovaDistributionChart
        distribution={{ "1": 5, "2": 0, "3": 3, "4": 0 }}
      />,
    );
    expect(screen.getByTestId("nova-bar-1")).toHaveAttribute("opacity", "1");
    expect(screen.getByTestId("nova-bar-2")).toHaveAttribute("opacity", "0.2");
    expect(screen.getByTestId("nova-bar-3")).toHaveAttribute("opacity", "1");
    expect(screen.getByTestId("nova-bar-4")).toHaveAttribute("opacity", "0.2");
  });

  // ─── Percentage Computation ───────────────────────────────────────────

  it("computes correct percentages", () => {
    // 5+5+0+0 = 10 total → 50%, 50%, 0%, 0%
    render(
      <NovaDistributionChart
        distribution={{ "1": 5, "2": 5, "3": 0, "4": 0 }}
      />,
    );
    const pctLabels = screen.getAllByText(/^\d+%$/);
    const pctTexts = pctLabels.map((el) => el.textContent);
    expect(pctTexts).toEqual(["50%", "50%", "0%", "0%"]);
  });

  it("computes percentages rounding to integers", () => {
    // 1+1+1+0 = 3 total → 33%, 33%, 33%, 0%
    render(
      <NovaDistributionChart
        distribution={{ "1": 1, "2": 1, "3": 1, "4": 0 }}
      />,
    );
    const pctLabels = screen.getAllByText(/^\d+%$/);
    const pctTexts = pctLabels.map((el) => el.textContent);
    expect(pctTexts).toEqual(["33%", "33%", "33%", "0%"]);
  });

  // ─── Legend ───────────────────────────────────────────────────────────

  it("renders legend with counts for each NOVA group", () => {
    render(
      <NovaDistributionChart
        distribution={{ "1": 3, "2": 2, "3": 1, "4": 4 }}
      />,
    );
    expect(screen.getByText(/dashboard\.nova\.1.*\(3\)/)).toBeInTheDocument();
    expect(screen.getByText(/dashboard\.nova\.2.*\(2\)/)).toBeInTheDocument();
    expect(screen.getByText(/dashboard\.nova\.3.*\(1\)/)).toBeInTheDocument();
    expect(screen.getByText(/dashboard\.nova\.4.*\(4\)/)).toBeInTheDocument();
  });

  // ─── Bar Height ───────────────────────────────────────────────────────

  it("gives tallest bar max height and others proportional", () => {
    render(
      <NovaDistributionChart
        distribution={{ "1": 10, "2": 5, "3": 0, "4": 0 }}
      />,
    );
    const bar1 = screen.getByTestId("nova-bar-1");
    const bar2 = screen.getByTestId("nova-bar-2");
    // bar1 is the max → height = MAX_HEIGHT = 44
    expect(Number(bar1.getAttribute("height"))).toBe(44);
    // bar2 is 50% of max → height = 22
    expect(Number(bar2.getAttribute("height"))).toBe(22);
  });

  it("uses minimum height of 4 for non-zero bars that would be too short", () => {
    render(
      <NovaDistributionChart
        distribution={{ "1": 100, "2": 1, "3": 0, "4": 0 }}
      />,
    );
    const bar2 = screen.getByTestId("nova-bar-2");
    // 1/100 * 44 = 0.44 → clamped to minimum 4
    expect(Number(bar2.getAttribute("height"))).toBe(4);
  });
});
