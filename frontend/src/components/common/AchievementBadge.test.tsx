import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import {
  AchievementBadge,
  getAchievementTypes,
  getAchievementMeta,
} from "./AchievementBadge";
import type { AchievementType } from "./AchievementBadge";

describe("AchievementBadge", () => {
  // ── Rendering ─────────────────────────────────────────────────────────────

  it("renders an image for a known achievement type", () => {
    render(<AchievementBadge type="first-scan" unlocked={true} />);
    const img = screen.getByRole("img");
    expect(img).toBeTruthy();
  });

  it("uses the correct SVG source path", () => {
    render(<AchievementBadge type="list-builder" unlocked={true} />);
    const img = screen.getByRole("img");
    expect(img.getAttribute("src")).toContain("list-builder");
  });

  // ── All 5 types render ────────────────────────────────────────────────────

  const TYPES: AchievementType[] = [
    "first-scan",
    "list-builder",
    "health-explorer",
    "comparison-pro",
    "profile-complete",
  ];

  it.each(TYPES)("renders unlocked badge for type: %s", (type) => {
    const { container } = render(
      <AchievementBadge type={type} unlocked={true} />,
    );
    expect(container.querySelector("img")).toBeTruthy();
  });

  it.each(TYPES)("renders locked badge for type: %s", (type) => {
    const { container } = render(
      <AchievementBadge type={type} unlocked={false} />,
    );
    expect(container.querySelector("img")).toBeTruthy();
  });

  // ── Unlocked vs Locked states ─────────────────────────────────────────────

  it("applies achievement-unlocked class when unlocked", () => {
    render(<AchievementBadge type="first-scan" unlocked={true} />);
    const img = screen.getByRole("img");
    expect(img.className).toContain("achievement-unlocked");
    expect(img.className).not.toContain("grayscale");
  });

  it("applies grayscale + opacity classes when locked", () => {
    render(<AchievementBadge type="first-scan" unlocked={false} />);
    const img = screen.getByRole("img");
    expect(img.className).toContain("achievement-locked");
    expect(img.className).toContain("grayscale");
    expect(img.className).toContain("opacity-50");
  });

  it("sets data-unlocked attribute based on state", () => {
    const { container: unlockedContainer } = render(
      <AchievementBadge type="first-scan" unlocked={true} />,
    );
    expect(
      unlockedContainer
        .querySelector("[data-achievement]")
        ?.getAttribute("data-unlocked"),
    ).toBe("true");

    const { container: lockedContainer } = render(
      <AchievementBadge type="first-scan" unlocked={false} />,
    );
    expect(
      lockedContainer
        .querySelector("[data-achievement]")
        ?.getAttribute("data-unlocked"),
    ).toBe("false");
  });

  // ── Size variants ─────────────────────────────────────────────────────────

  it("renders sm size (32px)", () => {
    render(<AchievementBadge type="first-scan" unlocked={true} size="sm" />);
    const img = screen.getByRole("img");
    expect(img.getAttribute("width")).toBe("32");
    expect(img.getAttribute("height")).toBe("32");
  });

  it("defaults to md size (48px)", () => {
    render(<AchievementBadge type="first-scan" unlocked={true} />);
    const img = screen.getByRole("img");
    expect(img.getAttribute("width")).toBe("48");
    expect(img.getAttribute("height")).toBe("48");
  });

  it("renders lg size (96px)", () => {
    render(<AchievementBadge type="first-scan" unlocked={true} size="lg" />);
    const img = screen.getByRole("img");
    expect(img.getAttribute("width")).toBe("96");
    expect(img.getAttribute("height")).toBe("96");
  });

  // ── Accessibility ─────────────────────────────────────────────────────────

  it("includes achievement name and state in alt text (unlocked)", () => {
    render(<AchievementBadge type="first-scan" unlocked={true} />);
    const img = screen.getByRole("img");
    const alt = img.getAttribute("alt") ?? "";
    expect(alt).toContain("First Scan");
    expect(alt).toContain("Unlocked");
  });

  it("includes achievement name and state in alt text (locked)", () => {
    render(<AchievementBadge type="first-scan" unlocked={false} />);
    const img = screen.getByRole("img");
    const alt = img.getAttribute("alt") ?? "";
    expect(alt).toContain("First Scan");
    expect(alt).toContain("Locked");
  });

  it("includes achievement description in alt text", () => {
    render(<AchievementBadge type="health-explorer" unlocked={true} />);
    const img = screen.getByRole("img");
    const alt = img.getAttribute("alt") ?? "";
    expect(alt).toContain("Viewed 50 or more product details");
  });

  // ── Label display ─────────────────────────────────────────────────────────

  it("shows label text when showLabel is true", () => {
    render(
      <AchievementBadge type="first-scan" unlocked={true} showLabel={true} />,
    );
    expect(screen.getByText("First Scan")).toBeTruthy();
  });

  it("does not show label text when showLabel is false", () => {
    render(
      <AchievementBadge
        type="first-scan"
        unlocked={true}
        showLabel={false}
      />,
    );
    expect(screen.queryByText("First Scan")).toBeNull();
  });

  it("does not show label by default", () => {
    render(<AchievementBadge type="first-scan" unlocked={true} />);
    expect(screen.queryByText("First Scan")).toBeNull();
  });

  // ── CSS className passthrough ─────────────────────────────────────────────

  it("applies custom className to wrapper", () => {
    const { container } = render(
      <AchievementBadge
        type="first-scan"
        unlocked={true}
        className="my-custom-class"
      />,
    );
    const wrapper = container.querySelector("[data-achievement]")!;
    expect(wrapper.className).toContain("my-custom-class");
  });

  // ── data-achievement attribute ────────────────────────────────────────────

  it("sets data-achievement attribute to the type", () => {
    const { container } = render(
      <AchievementBadge type="comparison-pro" unlocked={true} />,
    );
    expect(
      container
        .querySelector("[data-achievement]")
        ?.getAttribute("data-achievement"),
    ).toBe("comparison-pro");
  });

  // ── Utility: getAchievementTypes ──────────────────────────────────────────

  it("getAchievementTypes returns all 5 types", () => {
    const types = getAchievementTypes();
    expect(types).toHaveLength(5);
    expect(types).toContain("first-scan");
    expect(types).toContain("list-builder");
    expect(types).toContain("health-explorer");
    expect(types).toContain("comparison-pro");
    expect(types).toContain("profile-complete");
  });

  // ── Utility: getAchievementMeta ───────────────────────────────────────────

  it("getAchievementMeta returns label and description", () => {
    const meta = getAchievementMeta("first-scan");
    expect(meta.label).toBe("First Scan");
    expect(meta.description).toBe("Scanned your first product barcode");
    expect(meta.src).toContain("first-scan.svg");
  });

  it("getAchievementMeta returns correct data for all types", () => {
    for (const type of getAchievementTypes()) {
      const meta = getAchievementMeta(type);
      expect(meta.label).toBeTruthy();
      expect(meta.description).toBeTruthy();
      expect(meta.src).toContain(".svg");
    }
  });
});
