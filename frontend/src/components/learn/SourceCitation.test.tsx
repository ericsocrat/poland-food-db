import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { SourceCitation } from "./SourceCitation";

// ─── Mocks ──────────────────────────────────────────────────────────────────

// No mocks needed — pure presentational component

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("SourceCitation", () => {
  it("renders author and title", () => {
    render(<SourceCitation author="WHO" title="Nutrition Guidelines" />);
    expect(screen.getByText("WHO")).toBeInTheDocument();
    expect(screen.getByText("Nutrition Guidelines")).toBeInTheDocument();
  });

  it("renders as a <cite> element", () => {
    const { container } = render(
      <SourceCitation author="EFSA" title="Food Additives Report" />,
    );
    expect(container.querySelector("cite")).toBeInTheDocument();
  });

  it("includes year when provided", () => {
    render(
      <SourceCitation author="EFSA" title="Additive Safety" year={2023} />,
    );
    expect(screen.getByText(/2023/)).toBeInTheDocument();
  });

  it("accepts string year", () => {
    render(<SourceCitation author="EFSA" title="Report" year="2024" />);
    expect(screen.getByText(/2024/)).toBeInTheDocument();
  });

  it("omits year text when not provided", () => {
    const { container } = render(
      <SourceCitation author="EFSA" title="Report" />,
    );
    expect(container.textContent).not.toMatch(/\(\d{4}\)/);
  });

  it("renders link when URL is provided", () => {
    render(
      <SourceCitation
        author="EFSA"
        title="Report"
        url="https://efsa.europa.eu/report"
      />,
    );
    const link = screen.getByRole("link", { name: /Link/ });
    expect(link).toHaveAttribute("href", "https://efsa.europa.eu/report");
    expect(link).toHaveAttribute("target", "_blank");
    expect(link).toHaveAttribute("rel", "noopener noreferrer");
  });

  it("does not render link when URL is absent", () => {
    render(<SourceCitation author="EFSA" title="Report" />);
    expect(screen.queryByRole("link")).not.toBeInTheDocument();
  });

  it("applies custom className", () => {
    const { container } = render(
      <SourceCitation author="EFSA" title="Report" className="mt-4" />,
    );
    const cite = container.querySelector("cite");
    expect(cite?.classList.contains("mt-4")).toBe(true);
  });

  it("renders all props together", () => {
    render(
      <SourceCitation
        author="World Health Organization"
        title="Guideline: Sugars intake for adults and children"
        url="https://who.int/sugars"
        year={2015}
        className="mb-2"
      />,
    );
    expect(screen.getByText("World Health Organization")).toBeInTheDocument();
    expect(
      screen.getByText("Guideline: Sugars intake for adults and children"),
    ).toBeInTheDocument();
    expect(screen.getByText(/2015/)).toBeInTheDocument();
    expect(screen.getByRole("link")).toHaveAttribute(
      "href",
      "https://who.int/sugars",
    );
  });
});
