import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { Tooltip } from "./Tooltip";

describe("Tooltip", () => {
  it("renders children", () => {
    render(
      <Tooltip content="Help text">
        <button>Hover me</button>
      </Tooltip>,
    );
    expect(screen.getByText("Hover me")).toBeTruthy();
  });

  it("renders tooltip content with tooltip role", () => {
    render(
      <Tooltip content="More info">
        <span>Target</span>
      </Tooltip>,
    );
    expect(screen.getByRole("tooltip")).toHaveTextContent("More info");
  });

  it("links wrapper to tooltip via aria-describedby", () => {
    render(
      <Tooltip content="Description">
        <span>Target</span>
      </Tooltip>,
    );
    const tooltip = screen.getByRole("tooltip");
    const wrapper = tooltip.closest("[aria-describedby]");
    expect(wrapper).toBeTruthy();
    expect(wrapper!.getAttribute("aria-describedby")).toBe(tooltip.id);
  });

  it("tooltip starts hidden (opacity-0)", () => {
    render(
      <Tooltip content="Hidden">
        <span>Target</span>
      </Tooltip>,
    );
    const tooltip = screen.getByRole("tooltip");
    expect(tooltip.className).toContain("opacity-0");
  });

  it("has group-hover:opacity-100 class", () => {
    render(
      <Tooltip content="Show">
        <span>Target</span>
      </Tooltip>,
    );
    const tooltip = screen.getByRole("tooltip");
    expect(tooltip.className).toContain("group-hover:opacity-100");
  });

  it("applies top positioning by default", () => {
    render(
      <Tooltip content="Top">
        <span>Target</span>
      </Tooltip>,
    );
    const tooltip = screen.getByRole("tooltip");
    expect(tooltip.className).toContain("bottom-full");
  });

  it.each(["top", "bottom", "left", "right"] as const)(
    "applies %s positioning",
    (side) => {
      render(
        <Tooltip content="Tip" side={side}>
          <span>Target</span>
        </Tooltip>,
      );
      const tooltip = screen.getByRole("tooltip");
      // Each side has a unique class
      if (side === "top") expect(tooltip.className).toContain("bottom-full");
      if (side === "bottom") expect(tooltip.className).toContain("top-full");
      if (side === "left") expect(tooltip.className).toContain("right-full");
      if (side === "right") expect(tooltip.className).toContain("left-full");
    },
  );
});
