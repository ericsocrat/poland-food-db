import { describe, it, expect, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { EmptyState } from "./EmptyState";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("next/link", () => ({
  default: ({
    href,
    children,
    ...rest
  }: {
    href: string;
    children: React.ReactNode;
  }) => (
    <a href={href} {...rest}>
      {children}
    </a>
  ),
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("EmptyState", () => {
  // ── Rendering ───────────────────────────────────────────────────────────

  it("renders title from i18n key", () => {
    render(<EmptyState variant="no-data" titleKey="common.noResults" />);
    expect(screen.getByText("No results found")).toBeInTheDocument();
  });

  it("renders description when descriptionKey is provided", () => {
    render(
      <EmptyState
        variant="error"
        titleKey="common.error"
        descriptionKey="common.errorDescription"
      />,
    );
    expect(screen.getByText("Something went wrong")).toBeInTheDocument();
    expect(
      screen.getByText("An unexpected error occurred. Please try again."),
    ).toBeInTheDocument();
  });

  it("does not render description when descriptionKey is omitted", () => {
    const { container } = render(
      <EmptyState variant="no-data" titleKey="common.noResults" />,
    );
    // Only the icon and title — no <p> description element
    const paragraphs = container.querySelectorAll("p");
    // 1 = icon paragraph only
    expect(paragraphs).toHaveLength(1);
  });

  // ── Default icons ─────────────────────────────────────────────────────

  it("renders 📋 for no-data variant", () => {
    render(<EmptyState variant="no-data" titleKey="common.noResults" />);
    expect(screen.getByText("📋")).toBeInTheDocument();
  });

  it("renders 🔍 for no-results variant", () => {
    render(<EmptyState variant="no-results" titleKey="common.noResults" />);
    expect(screen.getByText("🔍")).toBeInTheDocument();
  });

  it("renders ⚠️ for error variant", () => {
    render(<EmptyState variant="error" titleKey="common.error" />);
    expect(screen.getByText("⚠️")).toBeInTheDocument();
  });

  it("renders 📡 for offline variant", () => {
    render(<EmptyState variant="offline" titleKey="common.offlineTitle" />);
    expect(screen.getByText("📡")).toBeInTheDocument();
  });

  // ── Custom icon ───────────────────────────────────────────────────────

  it("renders custom icon when provided", () => {
    render(
      <EmptyState
        variant="no-data"
        titleKey="common.noResults"
        icon={<span data-testid="custom-icon">🎉</span>}
      />,
    );
    expect(screen.getByTestId("custom-icon")).toBeInTheDocument();
    expect(screen.queryByText("📋")).not.toBeInTheDocument();
  });

  // ── Icon accessibility ────────────────────────────────────────────────

  it("icon container has aria-hidden=true", () => {
    render(<EmptyState variant="no-data" titleKey="common.noResults" />);
    const icon = screen.getByText("📋").closest("p");
    expect(icon).toHaveAttribute("aria-hidden", "true");
  });

  // ── Primary CTA ───────────────────────────────────────────────────────

  it("renders primary CTA as link when href is provided", () => {
    render(
      <EmptyState
        variant="no-data"
        titleKey="common.noResults"
        action={{ labelKey: "common.retry", href: "/app/search" }}
      />,
    );
    const link = screen.getByRole("link", { name: "Retry" });
    expect(link).toHaveAttribute("href", "/app/search");
  });

  it("renders primary CTA as button when onClick is provided", () => {
    const onClick = vi.fn();
    render(
      <EmptyState
        variant="error"
        titleKey="common.error"
        action={{ labelKey: "common.tryAgain", onClick }}
      />,
    );
    const button = screen.getByRole("button", { name: "Try again" });
    fireEvent.click(button);
    expect(onClick).toHaveBeenCalledOnce();
  });

  // ── Secondary action ──────────────────────────────────────────────────

  it("renders secondary action when provided", () => {
    render(
      <EmptyState
        variant="no-results"
        titleKey="common.noResults"
        action={{ labelKey: "common.clear", href: "/app/search" }}
        secondaryAction={{ labelKey: "common.back", href: "/app" }}
      />,
    );
    expect(screen.getByRole("link", { name: "Clear" })).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "Back" })).toBeInTheDocument();
  });

  // ── No CTA ────────────────────────────────────────────────────────────

  it("renders no CTA when action is not provided", () => {
    render(<EmptyState variant="no-data" titleKey="common.noResults" />);
    expect(screen.queryByRole("button")).not.toBeInTheDocument();
    expect(screen.queryByRole("link")).not.toBeInTheDocument();
  });

  // ── Data attributes ───────────────────────────────────────────────────

  it("sets data-variant attribute matching the variant prop", () => {
    render(<EmptyState variant="error" titleKey="common.error" />);
    expect(screen.getByTestId("empty-state")).toHaveAttribute(
      "data-variant",
      "error",
    );
  });

  // ── Custom className ──────────────────────────────────────────────────

  it("merges custom className onto root element", () => {
    render(
      <EmptyState
        variant="no-data"
        titleKey="common.noResults"
        className="bg-surface-subtle"
      />,
    );
    expect(screen.getByTestId("empty-state").className).toContain(
      "bg-surface-subtle",
    );
  });

  // ── Interpolation params ──────────────────────────────────────────────

  it("passes titleParams to i18n interpolation", () => {
    render(
      <EmptyState
        variant="no-data"
        titleKey="common.items"
        titleParams={{ count: 0 }}
      />,
    );
    expect(screen.getByText("0 item(s)")).toBeInTheDocument();
  });
});
