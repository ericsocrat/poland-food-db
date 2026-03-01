import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { ReformulationBadge } from "./ReformulationBadge";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => {
      const map: Record<string, string> = {
        "watchlist.reformulated": "Reformulated",
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

describe("ReformulationBadge", () => {
  it("renders nothing when detected is false", () => {
    const { container } = render(<ReformulationBadge detected={false} />);
    expect(container.innerHTML).toBe("");
  });

  it("renders badge when detected is true", () => {
    render(<ReformulationBadge detected={true} />);
    const badge = screen.getByTestId("reformulation-badge");
    expect(badge).toBeInTheDocument();
    expect(badge.textContent).toContain("Reformulated");
  });

  it("renders an icon", () => {
    render(<ReformulationBadge detected={true} />);
    expect(screen.getByTestId("mock-icon")).toBeInTheDocument();
  });

  it("applies custom className", () => {
    render(<ReformulationBadge detected={true} className="my-class" />);
    const badge = screen.getByTestId("reformulation-badge");
    expect(badge.className).toContain("my-class");
  });

  it("includes warning styling", () => {
    render(<ReformulationBadge detected={true} />);
    const badge = screen.getByTestId("reformulation-badge");
    expect(badge.className).toContain("text-warning");
  });
});
