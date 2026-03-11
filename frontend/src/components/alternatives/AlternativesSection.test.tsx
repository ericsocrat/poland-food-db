import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import React from "react";
import { describe, expect, it, vi } from "vitest";

import { AlternativesSection } from "@/components/alternatives/AlternativesSection";
import type { ProfileAlternative } from "@/lib/types";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/components/common/NutriScoreBadge", () => ({
  NutriScoreBadge: ({ grade }: { grade: string }) => (
    <span data-testid="nutri-score-badge">{grade}</span>
  ),
}));

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string, params?: Record<string, string | number>) => {
      if (params) {
        let result = key;
        for (const [k, v] of Object.entries(params))
          result += ` ${k}=${v}`;
        return result;
      }
      return key;
    },
  }),
}));

vi.mock("next/link", () => ({
  default: ({
    children,
    href,
    ...rest
  }: {
    children: React.ReactNode;
    href: string;
    [key: string]: unknown;
  }) => (
    <a href={href} {...rest}>
      {children}
    </a>
  ),
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

function makeAlt(
  id: number,
  overrides?: Partial<ProfileAlternative>,
): ProfileAlternative {
  return {
    product_id: id,
    product_name: `Product ${id}`,
    brand: `Brand ${id}`,
    category: "chips",
    unhealthiness_score: 20 + id,
    score_delta: 30 - id,
    nutri_score: "B",
    similarity: 0.5,
    ...overrides,
  };
}

function makeAlternatives(count: number): ProfileAlternative[] {
  return Array.from({ length: count }, (_, i) => makeAlt(i + 1));
}

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("AlternativesSection", () => {
  it("shows empty state when no alternatives", () => {
    render(
      <AlternativesSection alternatives={[]} currentScore={65} />,
    );

    expect(screen.getByText("product.noAlternatives")).toBeInTheDocument();
  });

  it("shows count header", () => {
    render(
      <AlternativesSection
        alternatives={makeAlternatives(2)}
        currentScore={65}
      />,
    );

    expect(
      screen.getByText("product.healthierOptions count=2"),
    ).toBeInTheDocument();
  });

  it("renders all alternatives when count <= initialCount", () => {
    render(
      <AlternativesSection
        alternatives={makeAlternatives(3)}
        currentScore={65}
      />,
    );

    expect(screen.getByText("Product 1")).toBeInTheDocument();
    expect(screen.getByText("Product 2")).toBeInTheDocument();
    expect(screen.getByText("Product 3")).toBeInTheDocument();
    expect(
      screen.queryByTestId("show-more-alternatives"),
    ).not.toBeInTheDocument();
  });

  it("shows only initialCount alternatives by default", () => {
    render(
      <AlternativesSection
        alternatives={makeAlternatives(5)}
        currentScore={65}
      />,
    );

    expect(screen.getByText("Product 1")).toBeInTheDocument();
    expect(screen.getByText("Product 2")).toBeInTheDocument();
    expect(screen.getByText("Product 3")).toBeInTheDocument();
    expect(screen.queryByText("Product 4")).not.toBeInTheDocument();
    expect(screen.queryByText("Product 5")).not.toBeInTheDocument();
  });

  it("shows 'Show more' button with hidden count", () => {
    render(
      <AlternativesSection
        alternatives={makeAlternatives(5)}
        currentScore={65}
      />,
    );

    expect(
      screen.getByText("product.showMoreAlternatives count=2"),
    ).toBeInTheDocument();
  });

  it("expands to show all alternatives on 'Show more' click", async () => {
    const user = userEvent.setup();
    render(
      <AlternativesSection
        alternatives={makeAlternatives(5)}
        currentScore={65}
      />,
    );

    await user.click(screen.getByTestId("show-more-alternatives"));

    expect(screen.getByText("Product 4")).toBeInTheDocument();
    expect(screen.getByText("Product 5")).toBeInTheDocument();
    expect(
      screen.getByText("product.showLessAlternatives"),
    ).toBeInTheDocument();
  });

  it("collapses back on 'Show less' click", async () => {
    const user = userEvent.setup();
    render(
      <AlternativesSection
        alternatives={makeAlternatives(5)}
        currentScore={65}
      />,
    );

    await user.click(screen.getByTestId("show-more-alternatives"));
    await user.click(screen.getByTestId("show-more-alternatives"));

    expect(screen.queryByText("Product 4")).not.toBeInTheDocument();
    expect(
      screen.getByText("product.showMoreAlternatives count=2"),
    ).toBeInTheDocument();
  });

  it("respects custom initialCount prop", () => {
    render(
      <AlternativesSection
        alternatives={makeAlternatives(5)}
        currentScore={65}
        initialCount={2}
      />,
    );

    expect(screen.getByText("Product 1")).toBeInTheDocument();
    expect(screen.getByText("Product 2")).toBeInTheDocument();
    expect(screen.queryByText("Product 3")).not.toBeInTheDocument();
    expect(
      screen.getByText("product.showMoreAlternatives count=3"),
    ).toBeInTheDocument();
  });
});
