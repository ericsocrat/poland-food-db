import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import ConfidencePage from "./page";

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
    <cite data-testid="source-citation">{title}</cite>
  ),
}));

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => key,
  }),
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ConfidencePage", () => {
  it("renders the page title", () => {
    render(<ConfidencePage />);
    expect(screen.getByText("learn.confidence.title")).toBeInTheDocument();
  });

  it("renders the summary block", () => {
    render(<ConfidencePage />);
    expect(screen.getByText("learn.confidence.summary")).toBeInTheDocument();
  });

  it("renders why section", () => {
    render(<ConfidencePage />);
    expect(
      screen.getByText("learn.confidence.whyTitle"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("learn.confidence.whyText"),
    ).toBeInTheDocument();
  });

  it("renders all 3 confidence level cards", () => {
    render(<ConfidencePage />);
    expect(
      screen.getByText("learn.confidence.levelVerified"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("learn.confidence.levelEstimated"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("learn.confidence.levelLow"),
    ).toBeInTheDocument();
  });

  it("applies correct color styling to level cards", () => {
    render(<ConfidencePage />);
    const verified = screen
      .getByText("learn.confidence.levelVerified")
      .closest("div.rounded-lg");
    expect(verified?.className).toContain("bg-success-bg");

    const low = screen
      .getByText("learn.confidence.levelLow")
      .closest("div.rounded-lg");
    expect(low?.className).toContain("bg-error-bg");
  });

  it("renders completeness section", () => {
    render(<ConfidencePage />);
    expect(
      screen.getByText("learn.confidence.completenessTitle"),
    ).toBeInTheDocument();
  });

  it("renders howWeImprove section", () => {
    render(<ConfidencePage />);
    expect(
      screen.getByText("learn.confidence.howWeImproveTitle"),
    ).toBeInTheDocument();
  });

  it("renders whatYouCanDo section", () => {
    render(<ConfidencePage />);
    expect(
      screen.getByText("learn.confidence.whatYouCanDoTitle"),
    ).toBeInTheDocument();
  });

  it("renders layout components", () => {
    render(<ConfidencePage />);
    expect(screen.getByTestId("header")).toBeInTheDocument();
    expect(screen.getByTestId("footer")).toBeInTheDocument();
    expect(screen.getByTestId("learn-sidebar")).toBeInTheDocument();
    expect(screen.getByTestId("disclaimer")).toBeInTheDocument();
  });

  it("renders back-to-hub link", () => {
    render(<ConfidencePage />);
    const backLink = screen.getByText("learn.backToHub");
    expect(backLink.closest("a")).toHaveAttribute("href", "/learn");
  });
});
