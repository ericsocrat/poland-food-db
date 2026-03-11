import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import NovaGroupsPage from "./page";

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

describe("NovaGroupsPage", () => {
  it("renders the page title", () => {
    render(<NovaGroupsPage />);
    expect(screen.getByText("learn.novaGroups.title")).toBeInTheDocument();
  });

  it("renders the summary block", () => {
    render(<NovaGroupsPage />);
    expect(screen.getByText("learn.novaGroups.summary")).toBeInTheDocument();
  });

  it("renders whatIs section", () => {
    render(<NovaGroupsPage />);
    expect(
      screen.getByText("learn.novaGroups.whatIsTitle"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("learn.novaGroups.whatIsText"),
    ).toBeInTheDocument();
  });

  it("renders all 4 NOVA group cards", () => {
    render(<NovaGroupsPage />);
    for (const n of ["1", "2", "3", "4"]) {
      expect(
        screen.getByText(`learn.novaGroups.group${n}Title`),
      ).toBeInTheDocument();
      expect(
        screen.getByText(`learn.novaGroups.group${n}Text`),
      ).toBeInTheDocument();
    }
  });

  it("applies correct color styling to group cards", () => {
    render(<NovaGroupsPage />);
    const group1 = screen.getByText("learn.novaGroups.group1Title").closest("div.rounded-lg");
    expect(group1?.className).toContain("bg-success-bg");

    const group4 = screen.getByText("learn.novaGroups.group4Title").closest("div.rounded-lg");
    expect(group4?.className).toContain("bg-error-bg");
  });

  it("renders whyItMatters section", () => {
    render(<NovaGroupsPage />);
    expect(
      screen.getByText("learn.novaGroups.whyItMattersTitle"),
    ).toBeInTheDocument();
  });

  it("renders polishContext section", () => {
    render(<NovaGroupsPage />);
    expect(
      screen.getByText("learn.novaGroups.polishContextTitle"),
    ).toBeInTheDocument();
  });

  it("renders processingRisk section", () => {
    render(<NovaGroupsPage />);
    expect(
      screen.getByText("learn.novaGroups.processingRiskTitle"),
    ).toBeInTheDocument();
  });

  it("renders layout components", () => {
    render(<NovaGroupsPage />);
    expect(screen.getByTestId("header")).toBeInTheDocument();
    expect(screen.getByTestId("footer")).toBeInTheDocument();
    expect(screen.getByTestId("learn-sidebar")).toBeInTheDocument();
    expect(screen.getByTestId("disclaimer")).toBeInTheDocument();
  });

  it("renders source citations", () => {
    render(<NovaGroupsPage />);
    const citations = screen.getAllByTestId("source-citation");
    expect(citations).toHaveLength(3);
  });

  it("renders back-to-hub link", () => {
    render(<NovaGroupsPage />);
    const backLink = screen.getByText("learn.backToHub");
    expect(backLink.closest("a")).toHaveAttribute("href", "/learn");
  });
});
