import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import AdditivesPage from "./page";

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

describe("AdditivesPage", () => {
  it("renders the page title", () => {
    render(<AdditivesPage />);
    expect(screen.getByText("learn.additives.title")).toBeInTheDocument();
  });

  it("renders the summary block", () => {
    render(<AdditivesPage />);
    expect(screen.getByText("learn.additives.summary")).toBeInTheDocument();
  });

  it("renders whatAre section", () => {
    render(<AdditivesPage />);
    expect(
      screen.getByText("learn.additives.whatAreTitle"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("learn.additives.whatAreText"),
    ).toBeInTheDocument();
  });

  it("renders notDangerous section", () => {
    render(<AdditivesPage />);
    expect(
      screen.getByText("learn.additives.notDangerousTitle"),
    ).toBeInTheDocument();
  });

  it("renders all 4 concern tier cards", () => {
    render(<AdditivesPage />);
    for (let i = 0; i <= 3; i++) {
      expect(
        screen.getByText(`learn.additives.concernTier${i}`),
      ).toBeInTheDocument();
    }
  });

  it("applies correct color styling to tier cards", () => {
    render(<AdditivesPage />);
    const tier0 = screen
      .getByText("learn.additives.concernTier0")
      .closest("div.rounded-lg");
    expect(tier0?.className).toContain("bg-success-bg");

    const tier3 = screen
      .getByText("learn.additives.concernTier3")
      .closest("div.rounded-lg");
    expect(tier3?.className).toContain("bg-error-bg");
  });

  it("renders howWeUse section", () => {
    render(<AdditivesPage />);
    expect(
      screen.getByText("learn.additives.howWeUseTitle"),
    ).toBeInTheDocument();
  });

  it("renders polishContext section", () => {
    render(<AdditivesPage />);
    expect(
      screen.getByText("learn.additives.polishContextTitle"),
    ).toBeInTheDocument();
  });

  it("renders layout components", () => {
    render(<AdditivesPage />);
    expect(screen.getByTestId("header")).toBeInTheDocument();
    expect(screen.getByTestId("footer")).toBeInTheDocument();
    expect(screen.getByTestId("learn-sidebar")).toBeInTheDocument();
    expect(screen.getByTestId("disclaimer")).toBeInTheDocument();
  });

  it("renders source citations", () => {
    render(<AdditivesPage />);
    const citations = screen.getAllByTestId("source-citation");
    expect(citations).toHaveLength(2);
  });

  it("renders back-to-hub link", () => {
    render(<AdditivesPage />);
    const backLink = screen.getByText("learn.backToHub");
    expect(backLink.closest("a")).toHaveAttribute("href", "/learn");
  });
});
