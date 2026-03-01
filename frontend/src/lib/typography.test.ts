import { describe, it, expect } from "vitest";
import { typography, spacing } from "./typography";

// ─── Typography ─────────────────────────────────────────────────────────────

describe("typography", () => {
  it("exports all semantic roles", () => {
    const expectedKeys = [
      "pageTitle",
      "greeting",
      "sectionHeading",
      "cardHeading",
      "statValue",
      "body",
      "bodySecondary",
      "caption",
      "muted",
      "label",
      "sectionLink",
    ];
    expect(Object.keys(typography)).toEqual(
      expect.arrayContaining(expectedKeys),
    );
    expect(Object.keys(typography).length).toBe(expectedKeys.length);
  });

  it("each value is a non-empty string", () => {
    for (const [, value] of Object.entries(typography)) {
      expect(typeof value).toBe("string");
      expect(value.length).toBeGreaterThan(0);
    }
  });

  it("desktop entries include lg: responsive prefix", () => {
    const desktopScaled = [
      "pageTitle",
      "greeting",
      "sectionHeading",
      "cardHeading",
      "statValue",
      "body",
      "caption",
    ];
    for (const key of desktopScaled) {
      expect(typography[key as keyof typeof typography]).toContain("lg:");
    }
  });

  it("non-scaling entries omit lg: prefix", () => {
    const staticEntries = ["bodySecondary", "muted", "label"];
    for (const key of staticEntries) {
      expect(typography[key as keyof typeof typography]).not.toContain("lg:");
    }
  });
});

// ─── Spacing ────────────────────────────────────────────────────────────────

describe("spacing", () => {
  it("exports all spacing keys", () => {
    const expectedKeys = [
      "pageStack",
      "sectionStack",
      "gridGap",
      "sectionHeadingMargin",
    ];
    expect(Object.keys(spacing)).toEqual(
      expect.arrayContaining(expectedKeys),
    );
    expect(Object.keys(spacing).length).toBe(expectedKeys.length);
  });

  it("each value is a non-empty string", () => {
    for (const [, value] of Object.entries(spacing)) {
      expect(typeof value).toBe("string");
      expect(value.length).toBeGreaterThan(0);
    }
  });

  it("all spacing values include desktop lg: responsive prefix", () => {
    for (const [, value] of Object.entries(spacing)) {
      expect(value).toContain("lg:");
    }
  });
});
