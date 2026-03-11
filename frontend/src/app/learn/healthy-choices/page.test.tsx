import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import HealthyChoicesPage from "./page";

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

vi.mock("@/components/learn/Disclaimer", () => ({
  Disclaimer: () => <div data-testid="disclaimer" />,
}));

vi.mock("@/components/learn/LearnTopicNav", () => ({
  LearnTopicNav: () => <nav data-testid="topic-nav" />,
}));

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => key,
  }),
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("HealthyChoicesPage", () => {
  it("renders the page title", () => {
    render(<HealthyChoicesPage />);
    expect(
      screen.getByText("learn.healthyChoices.title"),
    ).toBeInTheDocument();
  });

  it("renders the summary block", () => {
    render(<HealthyChoicesPage />);
    expect(
      screen.getByText("learn.healthyChoices.summary"),
    ).toBeInTheDocument();
  });

  it("renders all 6 content sections", () => {
    render(<HealthyChoicesPage />);
    expect(
      screen.getByText("learn.healthyChoices.startSmallTitle"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("learn.healthyChoices.compareTitle"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("learn.healthyChoices.readLabelsTitle"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("learn.healthyChoices.processingTitle"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("learn.healthyChoices.allergenTitle"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("learn.healthyChoices.habitsTitle"),
    ).toBeInTheDocument();
  });

  it("renders header and footer", () => {
    render(<HealthyChoicesPage />);
    expect(screen.getByTestId("header")).toBeInTheDocument();
    expect(screen.getByTestId("footer")).toBeInTheDocument();
  });

  it("renders sidebar and topic nav", () => {
    render(<HealthyChoicesPage />);
    expect(screen.getByTestId("learn-sidebar")).toBeInTheDocument();
    expect(screen.getByTestId("topic-nav")).toBeInTheDocument();
  });

  it("renders disclaimer", () => {
    render(<HealthyChoicesPage />);
    expect(screen.getByTestId("disclaimer")).toBeInTheDocument();
  });

  it("renders back-to-hub link", () => {
    render(<HealthyChoicesPage />);
    const backLink = screen.getByText("learn.backToHub");
    expect(backLink).toHaveAttribute("href", "/learn");
  });
});
