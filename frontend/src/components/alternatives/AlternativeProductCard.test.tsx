import { render, screen } from "@testing-library/react";
import React from "react";
import { describe, expect, it, vi } from "vitest";

import { AlternativeProductCard } from "@/components/alternatives/AlternativeProductCard";
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

function makeAlt(overrides?: Partial<ProfileAlternative>): ProfileAlternative {
  return {
    product_id: 99,
    product_name: "Healthy Veggie Sticks",
    brand: "HealthBrand",
    category: "chips",
    unhealthiness_score: 25,
    score_delta: 40,
    nutri_score: "B",
    similarity: 0.8,
    ...overrides,
  };
}

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("AlternativeProductCard", () => {
  it("renders product name and brand", () => {
    render(<AlternativeProductCard alt={makeAlt()} currentScore={65} />);

    expect(screen.getByText("Healthy Veggie Sticks")).toBeInTheDocument();
    expect(screen.getByText("HealthBrand")).toBeInTheDocument();
  });

  it("renders TryVit score badge", () => {
    // unhealthiness 25 → TryVit 75
    render(<AlternativeProductCard alt={makeAlt()} currentScore={65} />);

    // The score badge is the one in the 12x12 rounded-lg container
    const badges = screen.getAllByText("75");
    expect(badges.length).toBeGreaterThanOrEqual(1);
  });

  it("renders delta text with translation key", () => {
    render(<AlternativeProductCard alt={makeAlt()} currentScore={65} />);

    expect(
      screen.getByText("product.pointsBetter points=40"),
    ).toBeInTheDocument();
  });

  it("renders 'Much healthier' verdict for delta >= 20", () => {
    render(
      <AlternativeProductCard
        alt={makeAlt({ score_delta: 25 })}
        currentScore={65}
      />,
    );

    expect(
      screen.getByText("product.verdictMuchHealthier"),
    ).toBeInTheDocument();
  });

  it("renders 'Healthier' verdict for delta 10-19", () => {
    render(
      <AlternativeProductCard
        alt={makeAlt({ score_delta: 15 })}
        currentScore={65}
      />,
    );

    expect(screen.getByText("product.verdictHealthier")).toBeInTheDocument();
  });

  it("renders 'Slightly healthier' verdict for delta < 10", () => {
    render(
      <AlternativeProductCard
        alt={makeAlt({ score_delta: 5 })}
        currentScore={65}
      />,
    );

    expect(
      screen.getByText("product.verdictSlightlyHealthier"),
    ).toBeInTheDocument();
  });

  it("renders similarity badge as percentage", () => {
    render(
      <AlternativeProductCard
        alt={makeAlt({ similarity: 0.73 })}
        currentScore={65}
      />,
    );

    expect(
      screen.getByText("73% product.ingredientMatch"),
    ).toBeInTheDocument();
  });

  it("hides similarity badge when similarity is zero", () => {
    render(
      <AlternativeProductCard
        alt={makeAlt({ similarity: 0 })}
        currentScore={65}
      />,
    );

    expect(
      screen.queryByText(/product\.ingredientMatch/),
    ).not.toBeInTheDocument();
  });

  it("links to the alternative product page", () => {
    render(<AlternativeProductCard alt={makeAlt()} currentScore={65} />);

    const link = screen.getByRole("link");
    expect(link).toHaveAttribute("href", "/app/product/99");
  });

  it("renders comparison bar with correct scores", () => {
    render(<AlternativeProductCard alt={makeAlt()} currentScore={65} />);

    // Comparison bar is present with aria-label
    expect(
      screen.getByRole("img", {
        name: "Score comparison: alternative 75 vs current 35",
      }),
    ).toBeInTheDocument();
  });

  it("renders NutriScore badge", () => {
    render(<AlternativeProductCard alt={makeAlt()} currentScore={65} />);

    // NutriScoreBadge renders with the grade
    expect(screen.getByText("B")).toBeInTheDocument();
  });
});
