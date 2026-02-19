import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { Disclaimer } from "./Disclaimer";

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => {
      const msgs: Record<string, string> = {
        "learn.disclaimerLabel": "Disclaimer",
        "learn.disclaimer":
          "This content is for informational purposes only and not medical advice.",
      };
      return msgs[key] ?? key;
    },
  }),
}));

describe("Disclaimer", () => {
  it("renders the disclaimer banner", () => {
    render(<Disclaimer />);
    expect(screen.getByRole("note")).toBeInTheDocument();
    expect(
      screen.getByText(
        "This content is for informational purposes only and not medical advice.",
      ),
    ).toBeInTheDocument();
  });

  it("sets accessible aria-label", () => {
    render(<Disclaimer />);
    expect(screen.getByRole("note")).toHaveAttribute(
      "aria-label",
      "Disclaimer",
    );
  });

  it("applies custom className", () => {
    render(<Disclaimer className="mt-8" />);
    expect(screen.getByRole("note")).toHaveClass("mt-8");
  });

  it("uses amber styling", () => {
    render(<Disclaimer />);
    const aside = screen.getByRole("note");
    expect(aside.className).toContain("border-amber-200");
    expect(aside.className).toContain("bg-amber-50");
  });

  it("renders warning icon as decorative", () => {
    render(<Disclaimer />);
    // Lucide icons with aria-hidden
    const svg = screen.getByRole("note").querySelector("svg");
    expect(svg).toHaveAttribute("aria-hidden", "true");
  });
});
