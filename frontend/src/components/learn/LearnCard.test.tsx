import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { LearnCard } from "./LearnCard";
import { Book, GraduationCap } from "lucide-react";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("next/link", () => ({
  default: ({
    href,
    children,
    className,
  }: {
    href: string;
    children: React.ReactNode;
    className?: string;
  }) => (
    <a href={href} className={className}>
      {children}
    </a>
  ),
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("LearnCard", () => {
  it("renders title and description", () => {
    render(
      <LearnCard
        icon={Book}
        title="Nutri-Score"
        description="Learn about the European nutrition label"
        href="/learn/nutri-score"
      />,
    );
    expect(
      screen.getByRole("heading", { name: "Nutri-Score" }),
    ).toBeInTheDocument();
    expect(
      screen.getByText("Learn about the European nutrition label"),
    ).toBeInTheDocument();
  });

  it("links to the topic page", () => {
    render(
      <LearnCard
        icon={Book}
        title="NOVA"
        description="Food processing classification"
        href="/learn/nova"
      />,
    );
    const link = screen.getByRole("link");
    expect(link).toHaveAttribute("href", "/learn/nova");
  });

  it("renders a Lucide icon component", () => {
    const { container } = render(
      <LearnCard
        icon={GraduationCap}
        title="Score"
        description="How scores work"
        href="/learn/score"
      />,
    );
    // Lucide renders as SVG
    expect(container.querySelector("svg")).toBeInTheDocument();
  });

  it("renders a ReactNode icon", () => {
    render(
      <LearnCard
        icon={<span data-testid="custom-icon">🍎</span>}
        title="Additives"
        description="E-number guide"
        href="/learn/additives"
      />,
    );
    expect(screen.getByTestId("custom-icon")).toBeInTheDocument();
    expect(screen.getByText("🍎")).toBeInTheDocument();
  });

  it("applies custom className", () => {
    const { container } = render(
      <LearnCard
        icon={Book}
        title="Test"
        description="Desc"
        href="/learn/test"
        className="my-custom-class"
      />,
    );
    const link = container.querySelector("a");
    expect(link?.classList.contains("my-custom-class")).toBe(true);
  });

  it("icon container has aria-hidden for accessibility", () => {
    const { container } = render(
      <LearnCard
        icon={Book}
        title="Accessible"
        description="Desc"
        href="/learn/a11y"
      />,
    );
    const iconWrapper = container.querySelector("[aria-hidden='true']");
    expect(iconWrapper).toBeInTheDocument();
  });
});
