import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import TryVitScorePage from "./page";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("next/link", () => ({
  default: ({
    children,
    href,
  }: {
    children: React.ReactNode;
    href: string;
  }) => <a href={href}>{children}</a>,
}));

vi.mock("@/components/layout/Header", () => ({
  Header: () => <header data-testid="header" />,
}));

vi.mock("@/components/layout/Footer", () => ({
  Footer: () => <footer data-testid="footer" />,
}));

vi.mock("@/components/common/SkipLink", () => ({
  SkipLink: () => <div data-testid="skip-link" />,
}));

vi.mock("@/components/learn/LearnSidebar", () => ({
  LearnSidebar: () => <nav data-testid="learn-sidebar" />,
}));

vi.mock("@/components/learn/LearnTopicNav", () => ({
  LearnTopicNav: () => <nav data-testid="topic-nav" />,
}));

vi.mock("@/components/learn/Disclaimer", () => ({
  Disclaimer: () => <div data-testid="disclaimer" />,
}));

vi.mock("@/components/learn/SourceCitation", () => ({
  SourceCitation: ({ title }: { title: string }) => (
    <div data-testid="source-citation">{title}</div>
  ),
}));

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => key,
  }),
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("TryVitScorePage", () => {
  it("renders the page title", () => {
    render(<TryVitScorePage />);
    expect(
      screen.getByText("learn.tryvitScore.title"),
    ).toBeInTheDocument();
  });

  it("renders the summary block", () => {
    render(<TryVitScorePage />);
    expect(
      screen.getByText("learn.tryvitScore.summary"),
    ).toBeInTheDocument();
  });

  it("renders whatIs section", () => {
    render(<TryVitScorePage />);
    expect(
      screen.getByText("learn.tryvitScore.whatIsTitle"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("learn.tryvitScore.whatIsText"),
    ).toBeInTheDocument();
  });

  it("renders all 9 penalty factor cards", () => {
    render(<TryVitScorePage />);
    const expectedKeys = [
      "factorSatFat",
      "factorSugars",
      "factorSalt",
      "factorCalories",
      "factorTransFat",
      "factorAdditives",
      "factorPrepMethod",
      "factorControversies",
      "factorConcern",
    ];
    for (const key of expectedKeys) {
      expect(
        screen.getByText(`learn.tryvitScore.${key}`),
      ).toBeInTheDocument();
    }
  });

  it("renders the nutrient density bonus card", () => {
    render(<TryVitScorePage />);
    expect(
      screen.getByText("learn.tryvitScore.factorNutrientDensity"),
    ).toBeInTheDocument();
  });

  it("renders bonus section title", () => {
    render(<TryVitScorePage />);
    expect(
      screen.getByText("learn.tryvitScore.bonusTitle"),
    ).toBeInTheDocument();
  });

  it("renders penalty factors title", () => {
    render(<TryVitScorePage />);
    expect(
      screen.getByText("learn.tryvitScore.factorsTitle"),
    ).toBeInTheDocument();
  });

  it("displays weight percentages for penalty factors", () => {
    render(<TryVitScorePage />);
    // The 9 penalty weights: 17, 17, 17, 10, 11, 7, 8, 8, 5
    expect(screen.getAllByText("17%")).toHaveLength(3);
    expect(screen.getByText("10%")).toBeInTheDocument();
    expect(screen.getByText("11%")).toBeInTheDocument();
    expect(screen.getByText("7%")).toBeInTheDocument();
    expect(screen.getAllByText("8%")).toHaveLength(2);
    expect(screen.getByText("5%")).toBeInTheDocument();
  });

  it("displays negative weight for the bonus factor", () => {
    render(<TryVitScorePage />);
    expect(screen.getByText("−8%")).toBeInTheDocument();
  });

  it("renders bonus card with green styling", () => {
    render(<TryVitScorePage />);
    const bonusText = screen.getByText(
      "learn.tryvitScore.factorNutrientDensity",
    );
    const card = bonusText.closest("div.rounded-lg");
    expect(card?.className).toContain("border-success-border");
    expect(card?.className).toContain("bg-success-bg");
  });

  it("renders all 5 score band cards", () => {
    render(<TryVitScorePage />);
    for (let i = 1; i <= 5; i++) {
      expect(
        screen.getByText(`learn.tryvitScore.band${i}`),
      ).toBeInTheDocument();
    }
  });

  it("renders formula section", () => {
    render(<TryVitScorePage />);
    expect(
      screen.getByText("learn.tryvitScore.formulaTitle"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("learn.tryvitScore.formulaText"),
    ).toBeInTheDocument();
  });

  it("renders whyDifferent section", () => {
    render(<TryVitScorePage />);
    expect(
      screen.getByText("learn.tryvitScore.whyDifferentTitle"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("learn.tryvitScore.whyDifferentText"),
    ).toBeInTheDocument();
  });

  it("renders layout components", () => {
    render(<TryVitScorePage />);
    expect(screen.getByTestId("header")).toBeInTheDocument();
    expect(screen.getByTestId("learn-sidebar")).toBeInTheDocument();
    expect(screen.getByTestId("disclaimer")).toBeInTheDocument();
  });

  it("renders source citations", () => {
    render(<TryVitScorePage />);
    const citations = screen.getAllByTestId("source-citation");
    expect(citations.length).toBeGreaterThanOrEqual(3);
  });

  it("renders back-to-hub link", () => {
    render(<TryVitScorePage />);
    const backLink = screen.getByText("learn.backToHub");
    expect(backLink.closest("a")).toHaveAttribute("href", "/learn");
  });
});
