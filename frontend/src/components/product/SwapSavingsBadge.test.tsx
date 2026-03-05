import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";

import type { SwapSavings } from "@/lib/types";

import { SwapSavingsBadge } from "./SwapSavingsBadge";

// ─── Fixtures ───────────────────────────────────────────────────────────────

const baseSavings: SwapSavings = {
  score_delta: -28,
  sat_fat_saved_g: 4.5,
  sugar_saved_g: 12.0,
  salt_saved_g: 0.9,
  calories_saved: 150,
  headline: "28 points healthier — 91% less sugar",
};

const zeroSavings: SwapSavings = {
  score_delta: -5,
  sat_fat_saved_g: 0,
  sugar_saved_g: 0,
  salt_saved_g: 0,
  calories_saved: 0,
  headline: "5 points healthier",
};

// ─── Rendering ──────────────────────────────────────────────────────────────

describe("SwapSavingsBadge", () => {
  it("renders the headline text", () => {
    render(<SwapSavingsBadge savings={baseSavings} />);
    expect(
      screen.getByText("28 points healthier — 91% less sugar"),
    ).toBeVisible();
  });

  it("renders nutrient savings chips when values are positive", () => {
    render(<SwapSavingsBadge savings={baseSavings} />);
    expect(screen.getByText("-150 kcal")).toBeVisible();
    expect(screen.getByText("-12.0g sugar")).toBeVisible();
    expect(screen.getByText("-4.5g sat fat")).toBeVisible();
    expect(screen.getByText("-0.9g salt")).toBeVisible();
  });

  it("hides nutrient chips when savings are zero", () => {
    render(<SwapSavingsBadge savings={zeroSavings} />);
    expect(screen.queryByText(/-\d.*kcal/)).not.toBeInTheDocument();
    expect(screen.queryByText(/-.*sugar/)).not.toBeInTheDocument();
    expect(screen.queryByText(/-.*sat fat/)).not.toBeInTheDocument();
    expect(screen.queryByText(/-.*salt/)).not.toBeInTheDocument();
  });

  it("shows cross-category tag when isCrossCategory is true", () => {
    render(<SwapSavingsBadge savings={baseSavings} isCrossCategory />);
    expect(screen.getByText("Cross-category")).toBeVisible();
  });

  it("shows palm-oil-free tag when palmOilFree is true", () => {
    render(<SwapSavingsBadge savings={baseSavings} palmOilFree />);
    expect(screen.getByText("No palm oil")).toBeVisible();
  });

  it("hides tags row when both isCrossCategory and palmOilFree are false", () => {
    render(<SwapSavingsBadge savings={baseSavings} />);
    expect(screen.queryByText("Cross-category")).not.toBeInTheDocument();
    expect(screen.queryByText("No palm oil")).not.toBeInTheDocument();
  });

  it("shows both tags simultaneously", () => {
    render(
      <SwapSavingsBadge savings={baseSavings} isCrossCategory palmOilFree />,
    );
    expect(screen.getByText("Cross-category")).toBeVisible();
    expect(screen.getByText("No palm oil")).toBeVisible();
  });

  it("falls back to score delta when headline is empty", () => {
    const noHeadline: SwapSavings = { ...baseSavings, headline: "" };
    render(<SwapSavingsBadge savings={noHeadline} />);
    expect(screen.getByText("28 points healthier")).toBeVisible();
  });
});
