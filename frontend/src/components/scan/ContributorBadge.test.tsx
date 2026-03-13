import { render, screen } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { ContributorBadge } from "./ContributorBadge";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockUseContributorStats = vi.fn();

vi.mock("@/hooks/use-submissions", () => ({
  useContributorStats: () => mockUseContributorStats(),
  // Re-export type to satisfy the import
}));

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => key,
  }),
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ContributorBadge", () => {
  beforeEach(() => vi.clearAllMocks());

  // ─── Null rendering cases ──────────────────────────────────────────────

  it("renders nothing when loading", () => {
    mockUseContributorStats.mockReturnValue({
      data: undefined,
      isLoading: true,
    });
    const { container } = render(<ContributorBadge />);
    expect(container.innerHTML).toBe("");
  });

  it("renders nothing when stats is null", () => {
    mockUseContributorStats.mockReturnValue({
      data: null,
      isLoading: false,
    });
    const { container } = render(<ContributorBadge />);
    expect(container.innerHTML).toBe("");
  });

  it("renders nothing when tier is none", () => {
    mockUseContributorStats.mockReturnValue({
      data: { tier: "none", approved: 0, total: 0, pending: 0, rejected: 0, merged: 0 },
      isLoading: false,
    });
    const { container } = render(<ContributorBadge />);
    expect(container.innerHTML).toBe("");
  });

  // ─── Badge rendering ──────────────────────────────────────────────────

  it("renders bronze badge with approved count", () => {
    mockUseContributorStats.mockReturnValue({
      data: { tier: "bronze", approved: 3, total: 5, pending: 2, rejected: 0, merged: 0 },
      isLoading: false,
    });
    render(<ContributorBadge />);
    expect(screen.getByText(/contributor\.bronze/)).toBeTruthy();
    expect(screen.getByText(/3/)).toBeTruthy();
  });

  it("renders silver badge", () => {
    mockUseContributorStats.mockReturnValue({
      data: { tier: "silver", approved: 15, total: 20, pending: 3, rejected: 2, merged: 0 },
      isLoading: false,
    });
    render(<ContributorBadge />);
    expect(screen.getByText(/contributor\.silver/)).toBeTruthy();
  });

  it("renders gold badge", () => {
    mockUseContributorStats.mockReturnValue({
      data: { tier: "gold", approved: 55, total: 60, pending: 3, rejected: 2, merged: 0 },
      isLoading: false,
    });
    render(<ContributorBadge />);
    expect(screen.getByText(/contributor\.gold/)).toBeTruthy();
    expect(screen.getByText(/55/)).toBeTruthy();
  });
});
