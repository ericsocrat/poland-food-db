import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { NovaIndicator } from "./NovaIndicator";

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => {
      const msgs: Record<string, string> = {
        "product.novaGroup1": "Unprocessed",
        "product.novaGroup2": "Processed ingredient",
        "product.novaGroup3": "Processed food",
        "product.novaGroup4": "Ultra-processed",
      };
      return msgs[key] ?? key;
    },
  }),
}));

describe("NovaIndicator", () => {
  it("renders NOVA group label", () => {
    render(<NovaIndicator novaGroup="1" />);
    expect(screen.getByText("NOVA 1")).toBeTruthy();
    expect(screen.getByText("Unprocessed")).toBeTruthy();
  });

  it("highlights correct group for NOVA 4", () => {
    render(<NovaIndicator novaGroup="4" />);
    expect(screen.getByText("NOVA 4")).toBeTruthy();
    expect(screen.getByText("Ultra-processed")).toBeTruthy();
  });

  it("has accessible figure element with aria-label", () => {
    render(<NovaIndicator novaGroup="3" />);
    const indicator = screen.getByRole("figure");
    expect(indicator).toBeTruthy();
    expect(indicator.getAttribute("aria-label")).toContain("NOVA Group 3");
  });

  it("renders 4 coloured bar segments", () => {
    const { container } = render(<NovaIndicator novaGroup="2" />);
    // Bars are direct children of the flex-col container (no aria-hidden wrapper now)
    const barContainer = container.querySelector(".flex-col");
    const bars = barContainer?.children;
    expect(bars?.length).toBe(4);
  });

  it("gives active bar full opacity and inactive bars reduced opacity", () => {
    const { container } = render(<NovaIndicator novaGroup="1" />);
    const bars = container.querySelector(".flex-col")?.children;
    expect(bars).toBeTruthy();
    if (!bars) return;
    // First bar (group 1) should be active
    expect(bars[0].className).toContain("opacity-100");
    expect(bars[0].className).toContain("bg-green-500");
    // Other bars should be dim
    expect(bars[1].className).toContain("opacity-25");
    expect(bars[2].className).toContain("opacity-25");
    expect(bars[3].className).toContain("opacity-25");
  });

  it("all bars retain their group colour (green, lime, amber, red)", () => {
    const { container } = render(<NovaIndicator novaGroup="3" />);
    const bars = container.querySelector(".flex-col")?.children;
    expect(bars).toBeTruthy();
    if (!bars) return;
    expect(bars[0].className).toContain("bg-green-500");
    expect(bars[1].className).toContain("bg-lime-500");
    expect(bars[2].className).toContain("bg-amber-500");
    expect(bars[3].className).toContain("bg-red-500");
  });

  it.each(["1", "2", "3", "4"])(
    "NOVA %s highlights only the correct bar",
    (group) => {
      const { container } = render(<NovaIndicator novaGroup={group} />);
      const bars = container.querySelector(".flex-col")?.children;
      expect(bars).toBeTruthy();
      if (!bars) return;
      const idx = parseInt(group) - 1;
      for (let i = 0; i < 4; i++) {
        if (i === idx) {
          expect(bars[i].className).toContain("opacity-100");
        } else {
          expect(bars[i].className).toContain("opacity-25");
        }
      }
    },
  );
});
