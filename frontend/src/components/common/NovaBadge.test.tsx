import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import * as TooltipPrimitive from "@radix-ui/react-tooltip";
import { NovaBadge } from "./NovaBadge";

describe("NovaBadge", () => {
  // ─── sm/md: pill badge ──────────────────────────────────────────────────

  describe("pill badge (sm/md)", () => {
    it.each([1, 2, 3, 4] as const)("renders group %i", (group) => {
      render(<NovaBadge group={group} />);
      expect(screen.getByText(String(group))).toBeTruthy();
    });

    it("maps group 1 to nova-1 color", () => {
      render(<NovaBadge group={1} />);
      const badge = screen.getByText("1");
      expect(badge.className).toContain("text-nova-1");
      expect(badge.className).toContain("bg-nova-1/10");
    });

    it("maps group 4 to nova-4 color", () => {
      render(<NovaBadge group={4} />);
      const badge = screen.getByText("4");
      expect(badge.className).toContain("text-nova-4");
    });

    it("renders ? for null group", () => {
      render(<NovaBadge group={null} />);
      expect(screen.getByText("?")).toBeTruthy();
      expect(screen.getByText("?").className).toContain(
        "text-foreground-muted",
      );
    });

    it("renders ? for invalid group", () => {
      render(<NovaBadge group={5} />);
      expect(screen.getByText("?")).toBeTruthy();
    });

    it("shows label when showLabel is true", () => {
      render(<NovaBadge group={1} showLabel />);
      expect(screen.getByText("Unprocessed")).toBeTruthy();
    });

    it("shows Ultra-processed label for group 4", () => {
      render(<NovaBadge group={4} showLabel />);
      expect(screen.getByText("Ultra-processed")).toBeTruthy();
    });
  });

  // ─── lg: circular SVG ──────────────────────────────────────────────────

  describe("circle badge (lg)", () => {
    it("renders SVG circle for valid group", () => {
      render(<NovaBadge group={1} size="lg" />);
      const svg = screen.getByTestId("nova-circle");
      expect(svg.tagName).toBe("svg");
      expect(svg.querySelector("circle")).toBeTruthy();
    });

    it("fills circle with group color", () => {
      render(<NovaBadge group={4} size="lg" />);
      const circle = screen.getByTestId("nova-circle").querySelector("circle");
      expect(circle?.getAttribute("fill")).toContain("--color-nova-4");
    });

    it("renders group number inside circle", () => {
      render(<NovaBadge group={3} size="lg" />);
      const text = screen.getByTestId("nova-circle").querySelector("text");
      expect(text?.textContent).toBe("3");
    });

    it("uses inverse text for groups 1 and 4 (dark backgrounds)", () => {
      render(<NovaBadge group={1} size="lg" />);
      const text = screen.getByTestId("nova-circle").querySelector("text");
      expect(text?.getAttribute("fill")).toContain("--color-text-inverse");
    });

    it("uses primary text for groups 2 and 3 (light backgrounds)", () => {
      render(<NovaBadge group={2} size="lg" />);
      const text = screen.getByTestId("nova-circle").querySelector("text");
      expect(text?.getAttribute("fill")).toContain("--color-text-primary");
    });

    it("renders ? for null group (lg)", () => {
      render(<NovaBadge group={null} size="lg" />);
      const text = screen.getByTestId("nova-circle").querySelector("text");
      expect(text?.textContent).toBe("?");
    });

    it("renders muted fill for null group (lg)", () => {
      render(<NovaBadge group={null} size="lg" />);
      const circle = screen.getByTestId("nova-circle").querySelector("circle");
      expect(circle?.getAttribute("fill")).toContain("--color-surface-muted");
    });

    it("shows label below circle when showLabel is true", () => {
      render(<NovaBadge group={1} size="lg" showLabel />);
      expect(screen.getByText("Unprocessed")).toBeTruthy();
    });

    it("does not show label below circle by default", () => {
      render(<NovaBadge group={1} size="lg" />);
      expect(screen.queryByText("Unprocessed")).toBeNull();
    });

    it("has role=img on lg container", () => {
      render(<NovaBadge group={1} size="lg" />);
      expect(screen.getByRole("img")).toBeTruthy();
    });
  });

  // ─── Accessibility ──────────────────────────────────────────────────────

  describe("accessibility", () => {
    it("has accessible aria-label for valid group", () => {
      render(<NovaBadge group={2} />);
      expect(
        screen.getByLabelText("NOVA Group 2: Processed ingredients"),
      ).toBeTruthy();
    });

    it("has accessible aria-label for unknown group", () => {
      render(<NovaBadge group={null} />);
      expect(screen.getByLabelText("NOVA unknown")).toBeTruthy();
    });
  });

  // ─── Tooltip ────────────────────────────────────────────────────────────

  describe("tooltip", () => {
    it("shows tooltip on hover when showTooltip is true", async () => {
      const user = userEvent.setup();
      render(
        <TooltipPrimitive.Provider delayDuration={0}>
          <NovaBadge group={4} showTooltip />
        </TooltipPrimitive.Provider>,
      );

      await user.hover(screen.getByText("4"));
      const tooltip = await screen.findByRole("tooltip");
      expect(tooltip.textContent).toContain("NOVA 4");
    });
  });
});
