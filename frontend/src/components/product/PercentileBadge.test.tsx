import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { PercentileBadge } from "./PercentileBadge";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string, params?: Record<string, unknown>) => {
      const map: Record<string, string> = {
        "product.betterThan": `Better than ${params?.pct ?? ""}%`,
        "product.percentileTooltip": `#${params?.rank ?? ""} of ${params?.total ?? ""}`,
      };
      return map[key] ?? key;
    },
  }),
}));

vi.mock("@/components/common/Icon", () => ({
  Icon: ({ icon: _icon, ...props }: Record<string, unknown>) => (
    <span data-testid="mock-icon" {...props} />
  ),
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("PercentileBadge", () => {
  // ─── Null / invalid guards ──────────────────────────────────────────────

  it("renders nothing when rank is null", () => {
    const { container } = render(
      <PercentileBadge rank={null} total={100} />,
    );
    expect(container.innerHTML).toBe("");
  });

  it("renders nothing when total is null", () => {
    const { container } = render(
      <PercentileBadge rank={5} total={null} />,
    );
    expect(container.innerHTML).toBe("");
  });

  it("renders nothing when rank is undefined", () => {
    const { container } = render(
      <PercentileBadge rank={undefined} total={100} />,
    );
    expect(container.innerHTML).toBe("");
  });

  it("renders nothing when rank is 0", () => {
    const { container } = render(
      <PercentileBadge rank={0} total={50} />,
    );
    expect(container.innerHTML).toBe("");
  });

  it("renders nothing when total is 0", () => {
    const { container } = render(
      <PercentileBadge rank={1} total={0} />,
    );
    expect(container.innerHTML).toBe("");
  });

  it("renders nothing when total is negative", () => {
    const { container } = render(
      <PercentileBadge rank={1} total={-5} />,
    );
    expect(container.innerHTML).toBe("");
  });

  // ─── Percentile computation ─────────────────────────────────────────────

  it("shows 100% for rank 1 of 100 (best in category)", () => {
    render(<PercentileBadge rank={1} total={100} />);
    const badge = screen.getByTestId("percentile-badge");
    expect(badge.textContent).toContain("Better than 100%");
  });

  it("shows 50% for rank 51 of 101", () => {
    render(<PercentileBadge rank={51} total={101} />);
    const badge = screen.getByTestId("percentile-badge");
    expect(badge.textContent).toContain("Better than 50%");
  });

  it("shows 0% for rank equal to total", () => {
    render(<PercentileBadge rank={100} total={100} />);
    const badge = screen.getByTestId("percentile-badge");
    expect(badge.textContent).toContain("Better than 0%");
  });

  it("shows 100% for sole product (rank 1 of 1)", () => {
    render(<PercentileBadge rank={1} total={1} />);
    const badge = screen.getByTestId("percentile-badge");
    expect(badge.textContent).toContain("Better than 100%");
  });

  it("shows 50% for rank 2 of 3", () => {
    render(<PercentileBadge rank={2} total={3} />);
    const badge = screen.getByTestId("percentile-badge");
    expect(badge.textContent).toContain("Better than 50%");
  });

  // ─── Visual styling ────────────────────────────────────────────────────

  it("uses green styling for top 25% (pct ≥ 75)", () => {
    render(<PercentileBadge rank={1} total={100} />); // 99%
    const badge = screen.getByTestId("percentile-badge");
    expect(badge.className).toContain("bg-score-green/10");
    expect(badge.className).toContain("text-score-green-text");
  });

  it("uses yellow styling for middle 50% (25 ≤ pct < 75)", () => {
    render(<PercentileBadge rank={51} total={101} />); // 50%
    const badge = screen.getByTestId("percentile-badge");
    expect(badge.className).toContain("bg-score-yellow/10");
    expect(badge.className).toContain("text-score-yellow-text");
  });

  it("uses muted styling for bottom 25% (pct < 25)", () => {
    render(<PercentileBadge rank={100} total={100} />); // 0%
    const badge = screen.getByTestId("percentile-badge");
    expect(badge.className).toContain("bg-surface-muted");
    expect(badge.className).toContain("text-foreground-secondary");
  });

  // ─── Tooltip ────────────────────────────────────────────────────────────

  it("sets title attribute with rank tooltip", () => {
    render(<PercentileBadge rank={3} total={67} />);
    const badge = screen.getByTestId("percentile-badge");
    expect(badge.getAttribute("title")).toBe("#3 of 67");
  });

  // ─── Icon ───────────────────────────────────────────────────────────────

  it("renders an icon", () => {
    render(<PercentileBadge rank={1} total={50} />);
    expect(screen.getByTestId("mock-icon")).toBeInTheDocument();
  });

  // ─── Custom className ──────────────────────────────────────────────────

  it("applies custom className", () => {
    render(<PercentileBadge rank={1} total={50} className="my-custom" />);
    const badge = screen.getByTestId("percentile-badge");
    expect(badge.className).toContain("my-custom");
  });
});
