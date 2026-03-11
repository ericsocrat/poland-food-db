import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => key,
  }),
}));

import { ProductScoreHero } from "./ProductScoreHero";

// ── Rendering ────────────────────────────────────────────────────────────────

describe("ProductScoreHero", () => {
  it("renders the TryVit score (inverted from unhealthiness)", () => {
    render(
      <ProductScoreHero unhealthinessScore={20} headline="Low risk product" />,
    );
    // TryVit score = 100 - 20 = 80
    expect(screen.getByText("80")).toBeInTheDocument();
  });

  it("renders the score verdict translation key", () => {
    render(
      <ProductScoreHero unhealthinessScore={10} headline="Very healthy" />,
    );
    // score band for unhealthiness 10 = green → scoreInterpretation.green
    expect(screen.getByText("scoreInterpretation.green")).toBeInTheDocument();
  });

  it("renders the headline text", () => {
    render(
      <ProductScoreHero
        unhealthinessScore={50}
        headline="Moderate health impact"
      />,
    );
    expect(screen.getByText("Moderate health impact")).toBeInTheDocument();
  });

  it("renders the ScoreGauge SVG element", () => {
    render(
      <ProductScoreHero unhealthinessScore={30} headline="Some headline" />,
    );
    expect(document.querySelector("svg")).toBeInTheDocument();
  });

  // ── Score bands ──────────────────────────────────────────────────────────

  it("uses green verdict for unhealthiness <= 20", () => {
    render(
      <ProductScoreHero unhealthinessScore={15} headline="Low risk" />,
    );
    expect(screen.getByText("scoreInterpretation.green")).toBeInTheDocument();
  });

  it("uses yellow verdict for unhealthiness 21-40", () => {
    render(
      <ProductScoreHero unhealthinessScore={30} headline="Moderate" />,
    );
    expect(screen.getByText("scoreInterpretation.yellow")).toBeInTheDocument();
  });

  it("uses orange verdict for unhealthiness 41-60", () => {
    render(
      <ProductScoreHero unhealthinessScore={50} headline="Elevated" />,
    );
    expect(screen.getByText("scoreInterpretation.orange")).toBeInTheDocument();
  });

  it("uses red verdict for unhealthiness 61-80", () => {
    render(
      <ProductScoreHero unhealthinessScore={70} headline="High risk" />,
    );
    expect(screen.getByText("scoreInterpretation.red")).toBeInTheDocument();
  });

  it("uses darkRed verdict for unhealthiness > 80", () => {
    render(
      <ProductScoreHero unhealthinessScore={90} headline="Very high risk" />,
    );
    expect(
      screen.getByText("scoreInterpretation.darkRed"),
    ).toBeInTheDocument();
  });
});
