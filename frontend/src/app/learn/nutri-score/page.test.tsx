import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import NutriScorePage from "./page";

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

describe("NutriScorePage", () => {
  it("renders the page title", () => {
    render(<NutriScorePage />);
    expect(screen.getByText("learn.nutriScore.title")).toBeInTheDocument();
  });

  it("renders the summary block", () => {
    render(<NutriScorePage />);
    expect(screen.getByText("learn.nutriScore.summary")).toBeInTheDocument();
  });

  it("renders whatIs section", () => {
    render(<NutriScorePage />);
    expect(
      screen.getByText("learn.nutriScore.whatIsTitle"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("learn.nutriScore.whatIsText"),
    ).toBeInTheDocument();
  });

  it("renders howItWorks section", () => {
    render(<NutriScorePage />);
    expect(
      screen.getByText("learn.nutriScore.howItWorksTitle"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("learn.nutriScore.howItWorksText"),
    ).toBeInTheDocument();
  });

  it("renders negative and positive factor cards", () => {
    render(<NutriScorePage />);
    expect(
      screen.getByText("learn.nutriScore.negativeLabel"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("learn.nutriScore.positiveLabel"),
    ).toBeInTheDocument();
  });

  it("renders all 5 grade items (A–E)", () => {
    render(<NutriScorePage />);
    for (const grade of ["A", "B", "C", "D", "E"]) {
      expect(
        screen.getByText(`learn.nutriScore.grade${grade}`),
      ).toBeInTheDocument();
    }
  });

  it("renders limitations section", () => {
    render(<NutriScorePage />);
    expect(
      screen.getByText("learn.nutriScore.limitationsTitle"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("learn.nutriScore.limitationsText"),
    ).toBeInTheDocument();
  });

  it("renders unknown score section", () => {
    render(<NutriScorePage />);
    expect(
      screen.getByText("learn.nutriScore.unknownTitle"),
    ).toBeInTheDocument();
  });

  it("renders our approach section", () => {
    render(<NutriScorePage />);
    expect(
      screen.getByText("learn.nutriScore.ourApproachTitle"),
    ).toBeInTheDocument();
  });

  it("renders layout components", () => {
    render(<NutriScorePage />);
    expect(screen.getByTestId("header")).toBeInTheDocument();
    expect(screen.getByTestId("footer")).toBeInTheDocument();
    expect(screen.getByTestId("learn-sidebar")).toBeInTheDocument();
    expect(screen.getByTestId("disclaimer")).toBeInTheDocument();
  });

  it("renders source citations", () => {
    render(<NutriScorePage />);
    const citations = screen.getAllByTestId("source-citation");
    expect(citations).toHaveLength(2);
  });

  it("renders back-to-hub link", () => {
    render(<NutriScorePage />);
    const backLink = screen.getByText("learn.backToHub");
    expect(backLink.closest("a")).toHaveAttribute("href", "/learn");
  });
});
