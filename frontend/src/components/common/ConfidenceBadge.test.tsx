import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import * as TooltipPrimitive from "@radix-ui/react-tooltip";
import { ConfidenceBadge } from "./ConfidenceBadge";

describe("ConfidenceBadge", () => {
  // ─── Valid levels ───────────────────────────────────────────────────────

  describe("valid levels", () => {
    it("renders Verified for high level", () => {
      render(<ConfidenceBadge level="high" />);
      expect(screen.getByText("Verified")).toBeTruthy();
    });

    it("renders Estimated for medium level", () => {
      render(<ConfidenceBadge level="medium" />);
      expect(screen.getByText("Estimated")).toBeTruthy();
    });

    it("renders Low for low level", () => {
      render(<ConfidenceBadge level="low" />);
      expect(screen.getByText("Low")).toBeTruthy();
    });

    it("maps high to confidence-high color", () => {
      render(<ConfidenceBadge level="high" />);
      const badge = screen.getByText("Verified").closest("span")!;
      expect(badge.className).toContain("text-confidence-high");
      expect(badge.className).toContain("bg-confidence-high/10");
    });

    it("maps low to confidence-low color", () => {
      render(<ConfidenceBadge level="low" />);
      expect(screen.getByText("Low").closest("span")!.className).toContain(
        "text-confidence-low",
      );
    });
  });

  // ─── DB value aliases ───────────────────────────────────────────────────

  describe("DB value aliases", () => {
    it("maps 'verified' (DB value) to high/Verified", () => {
      render(<ConfidenceBadge level="verified" />);
      expect(screen.getByText("Verified")).toBeTruthy();
    });

    it("maps 'estimated' (DB value) to medium/Estimated", () => {
      render(<ConfidenceBadge level="estimated" />);
      expect(screen.getByText("Estimated")).toBeTruthy();
    });

    it("maps 'low' from DB directly", () => {
      render(<ConfidenceBadge level="low" />);
      expect(screen.getByText("Low")).toBeTruthy();
    });
  });

  // ─── Shield icons ──────────────────────────────────────────────────────

  describe("shield icons", () => {
    it("renders shield SVG icon for all levels", () => {
      const { container } = render(<ConfidenceBadge level="high" />);
      const shields = container.querySelectorAll('[data-testid="shield-icon"]');
      expect(shields.length).toBe(1);
    });

    it("renders ✓ symbol inside shield for high", () => {
      render(<ConfidenceBadge level="high" />);
      const shield = screen.getByTestId("shield-icon");
      const text = shield.querySelector("text");
      expect(text?.textContent).toBe("✓");
    });

    it("renders ~ symbol inside shield for medium", () => {
      render(<ConfidenceBadge level="medium" />);
      const shield = screen.getByTestId("shield-icon");
      const text = shield.querySelector("text");
      expect(text?.textContent).toBe("~");
    });

    it("renders ! symbol inside shield for low", () => {
      render(<ConfidenceBadge level="low" />);
      const shield = screen.getByTestId("shield-icon");
      const text = shield.querySelector("text");
      expect(text?.textContent).toBe("!");
    });

    it("renders ? symbol inside shield for null", () => {
      render(<ConfidenceBadge level={null} />);
      const shield = screen.getByTestId("shield-icon");
      const text = shield.querySelector("text");
      expect(text?.textContent).toBe("?");
    });

    it("shield is aria-hidden", () => {
      render(<ConfidenceBadge level="high" />);
      const shield = screen.getByTestId("shield-icon");
      expect(shield.getAttribute("aria-hidden")).toBe("true");
    });
  });

  // ─── showLabel ──────────────────────────────────────────────────────────

  describe("showLabel prop", () => {
    it("shows label by default", () => {
      render(<ConfidenceBadge level="high" />);
      expect(screen.getByText("Verified")).toBeTruthy();
    });

    it("hides label when showLabel is false", () => {
      render(<ConfidenceBadge level="high" showLabel={false} />);
      expect(screen.queryByText("Verified")).toBeNull();
    });
  });

  // ─── Null handling ──────────────────────────────────────────────────────

  describe("null handling", () => {
    it("renders Unknown for null level", () => {
      render(<ConfidenceBadge level={null} />);
      expect(screen.getByText("Unknown")).toBeTruthy();
      expect(screen.getByText("Unknown").closest("span")!.className).toContain(
        "text-foreground-muted",
      );
    });
  });

  // ─── Percentage ─────────────────────────────────────────────────────────

  describe("percentage", () => {
    it("shows percentage when provided", () => {
      render(<ConfidenceBadge level="high" percentage={85} />);
      expect(screen.getByText("85%")).toBeTruthy();
    });

    it("hides percentage for invalid values", () => {
      render(<ConfidenceBadge level="high" percentage={-1} />);
      expect(screen.queryByText("-1%")).toBeNull();
    });
  });

  // ─── Accessibility ──────────────────────────────────────────────────────

  describe("accessibility", () => {
    it("has accessible aria-label with percentage", () => {
      render(<ConfidenceBadge level="medium" percentage={60} />);
      expect(screen.getByLabelText("Confidence: Estimated (60%)")).toBeTruthy();
    });

    it("has accessible aria-label without percentage", () => {
      render(<ConfidenceBadge level="high" />);
      expect(screen.getByLabelText("Confidence: Verified")).toBeTruthy();
    });
  });

  // ─── Tooltip ────────────────────────────────────────────────────────────

  describe("tooltip", () => {
    it("shows tooltip on hover when showTooltip is true", async () => {
      const user = userEvent.setup();
      render(
        <TooltipPrimitive.Provider delayDuration={0}>
          <ConfidenceBadge level="high" showTooltip />
        </TooltipPrimitive.Provider>,
      );

      await user.hover(screen.getByText("Verified"));
      const tooltip = await screen.findByRole("tooltip");
      expect(tooltip.textContent).toContain("High confidence");
    });
  });
});
