import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import * as TooltipPrimitive from "@radix-ui/react-tooltip";
import { NutriScoreBadge } from "./NutriScoreBadge";

describe("NutriScoreBadge", () => {
  // ─── sm: single-letter badge ────────────────────────────────────────────

  describe("sm size (single letter)", () => {
    it.each(["A", "B", "C", "D", "E"] as const)(
      "renders grade %s with correct EU color",
      (grade) => {
        render(<NutriScoreBadge grade={grade} size="sm" />);
        const badge = screen.getByText(grade);
        expect(badge).toBeTruthy();
        expect(badge.className).toContain(`bg-nutri-${grade}`);
      },
    );

    it("normalizes lowercase grades", () => {
      render(<NutriScoreBadge grade="b" size="sm" />);
      expect(screen.getByText("B")).toBeTruthy();
      expect(screen.getByText("B").className).toContain("bg-nutri-B");
    });

    it("renders ? for null grade", () => {
      render(<NutriScoreBadge grade={null} size="sm" />);
      expect(screen.getByText("?")).toBeTruthy();
      expect(screen.getByText("?").className).toContain("bg-surface-muted");
    });

    it("renders ? for invalid grade", () => {
      render(<NutriScoreBadge grade="X" size="sm" />);
      expect(screen.getByText("?")).toBeTruthy();
      expect(screen.getByText("?").className).toContain(
        "text-foreground-muted",
      );
    });

    it("renders – for UNKNOWN grade", () => {
      render(<NutriScoreBadge grade="UNKNOWN" size="sm" />);
      expect(screen.getByText("–")).toBeTruthy();
    });

    it("renders – for NOT-APPLICABLE grade", () => {
      render(<NutriScoreBadge grade="NOT-APPLICABLE" size="sm" />);
      expect(screen.getByText("–")).toBeTruthy();
    });

    it("applies A text as foreground-inverse", () => {
      render(<NutriScoreBadge grade="A" size="sm" />);
      expect(screen.getByText("A").className).toContain(
        "text-foreground-inverse",
      );
    });

    it("applies C text as foreground (not inverse, since C is yellow)", () => {
      render(<NutriScoreBadge grade="C" size="sm" />);
      const el = screen.getByText("C");
      expect(el.className).toContain("text-foreground");
      expect(el.className).not.toContain("text-foreground-inverse");
    });
  });

  // ─── md/lg: horizontal strip ────────────────────────────────────────────

  describe("md size (5-letter strip)", () => {
    it("renders all 5 letters in a strip", () => {
      render(<NutriScoreBadge grade="B" size="md" />);
      for (const g of ["A", "B", "C", "D", "E"]) {
        expect(screen.getByText(g)).toBeTruthy();
      }
    });

    it("highlights the active grade with filled background", () => {
      render(<NutriScoreBadge grade="B" size="md" />);
      const b = screen.getByText("B");
      expect(b.className).toContain("bg-nutri-B");
      expect(b.className).toContain("text-foreground-inverse");
    });

    it("renders inactive grades with tinted background", () => {
      render(<NutriScoreBadge grade="B" size="md" />);
      const a = screen.getByText("A");
      expect(a.className).toContain("bg-nutri-A/15");
      expect(a.className).toContain("text-nutri-A");
    });

    it("makes active letter larger than inactive", () => {
      render(<NutriScoreBadge grade="C" size="md" />);
      const active = screen.getByText("C");
      const inactive = screen.getByText("A");
      expect(active.className).toContain("h-7");
      expect(inactive.className).toContain("h-5");
    });

    it("renders strip container with role=img", () => {
      render(<NutriScoreBadge grade="A" size="md" />);
      expect(screen.getByRole("img")).toBeTruthy();
    });

    it("renders null grade without active letter (all faded)", () => {
      render(<NutriScoreBadge grade={null} size="md" />);
      for (const g of ["A", "B", "C", "D", "E"]) {
        const letter = screen.getByText(g);
        expect(letter.className).toContain("/15");
      }
    });
  });

  describe("lg size (larger strip)", () => {
    it("renders larger active and inactive letters", () => {
      render(<NutriScoreBadge grade="D" size="lg" />);
      const active = screen.getByText("D");
      const inactive = screen.getByText("A");
      expect(active.className).toContain("h-9");
      expect(inactive.className).toContain("h-7");
    });
  });

  // ─── Special grades (UNKNOWN / NOT-APPLICABLE) ─────────────────────────

  describe("special grades", () => {
    it("renders ? label for UNKNOWN in md strip", () => {
      render(<NutriScoreBadge grade="UNKNOWN" size="md" />);
      expect(screen.getByText("?")).toBeTruthy();
      expect(screen.getByRole("img")).toBeTruthy();
    });

    it("renders N/A label for NOT-APPLICABLE in md strip", () => {
      render(<NutriScoreBadge grade="NOT-APPLICABLE" size="md" />);
      expect(screen.getByText("N/A")).toBeTruthy();
    });

    it("does NOT render 5-letter strip for UNKNOWN", () => {
      render(<NutriScoreBadge grade="UNKNOWN" size="md" />);
      expect(screen.queryByText("A")).toBeNull();
    });
  });

  // ─── Accessibility ──────────────────────────────────────────────────────

  describe("accessibility", () => {
    it("has aria-label for valid grade (sm)", () => {
      render(<NutriScoreBadge grade="A" size="sm" />);
      expect(screen.getByLabelText("Nutri-Score A")).toBeTruthy();
    });

    it("has aria-label for unknown (sm)", () => {
      render(<NutriScoreBadge grade={null} size="sm" />);
      expect(screen.getByLabelText("Nutri-Score unknown")).toBeTruthy();
    });

    it("has aria-label for UNKNOWN special", () => {
      render(<NutriScoreBadge grade="UNKNOWN" size="md" />);
      expect(screen.getByLabelText("Nutri-Score not available")).toBeTruthy();
    });

    it("has aria-label for NOT-APPLICABLE special", () => {
      render(<NutriScoreBadge grade="NOT-APPLICABLE" size="md" />);
      expect(screen.getByLabelText("Nutri-Score not applicable")).toBeTruthy();
    });

    it("marks inactive letters aria-hidden in strip", () => {
      render(<NutriScoreBadge grade="C" size="md" />);
      const a = screen.getByText("A");
      expect(a.getAttribute("aria-hidden")).toBe("true");
      const c = screen.getByText("C");
      expect(c.getAttribute("aria-hidden")).toBe("false");
    });
  });

  // ─── Tooltip ────────────────────────────────────────────────────────────

  describe("tooltip", () => {
    it("shows tooltip on hover when showTooltip is true (sm)", async () => {
      const user = userEvent.setup();
      render(
        <TooltipPrimitive.Provider delayDuration={0}>
          <NutriScoreBadge grade="A" size="sm" showTooltip />
        </TooltipPrimitive.Provider>,
      );

      await user.hover(screen.getByText("A"));
      const tooltip = await screen.findByRole("tooltip");
      expect(tooltip.textContent).toContain("Nutri-Score A");
    });
  });
});
