import { describe, it, expect } from "vitest";

// ─── Motion token compliance tests (#61) ─────────────────────────────────────
// Verify motion tokens exist in globals.css and follow design system rules.
// These tests validate the CSS source, not runtime computed styles.

import { readFileSync } from "fs";
import { join } from "path";

const cssPath = join(__dirname, "../styles/globals.css");
const css = readFileSync(cssPath, "utf-8");

describe("Motion Tokens (#61)", () => {
  describe("easing curves exist in :root", () => {
    const requiredEasings = [
      "--ease-standard",
      "--ease-decelerate",
      "--ease-accelerate",
      "--ease-spring",
    ];
    for (const token of requiredEasings) {
      it(`defines ${token}`, () => {
        expect(css).toContain(token);
      });
    }
  });

  describe("duration tokens exist in :root", () => {
    const requiredDurations = [
      "--duration-instant",
      "--duration-fast",
      "--duration-normal",
      "--duration-slow",
    ];
    for (const token of requiredDurations) {
      it(`defines ${token}`, () => {
        expect(css).toContain(token);
      });
    }
  });

  describe("reduced motion compliance", () => {
    it("overrides all duration tokens to 0ms for prefers-reduced-motion", () => {
      // The CSS should contain a @media block that sets all durations to 0ms
      const reducedMotionBlock = css.match(
        /@media\s*\(prefers-reduced-motion:\s*reduce\)\s*\{[\s\S]*?:root\s*\{([\s\S]*?)\}/,
      );
      expect(reducedMotionBlock).not.toBeNull();
      const rootBlock = reducedMotionBlock![1];
      expect(rootBlock).toContain("--duration-instant: 0ms");
      expect(rootBlock).toContain("--duration-fast: 0ms");
      expect(rootBlock).toContain("--duration-normal: 0ms");
      expect(rootBlock).toContain("--duration-slow: 0ms");
    });

    it("has a global kill-switch for animation-duration and transition-duration", () => {
      expect(css).toContain("animation-duration: 0.01ms !important");
      expect(css).toContain("transition-duration: 0.01ms !important");
    });
  });

  describe("utility classes exist", () => {
    it("defines .hover-lift", () => {
      expect(css).toContain(".hover-lift");
      expect(css).toContain(".hover-lift:hover");
    });

    it("defines .press-scale", () => {
      expect(css).toContain(".press-scale");
      expect(css).toContain(".press-scale:active");
    });

    it("defines .hover-lift-press", () => {
      expect(css).toContain(".hover-lift-press");
      expect(css).toContain(".hover-lift-press:hover");
      expect(css).toContain(".hover-lift-press:active");
    });

    it("defines .transition-interactive", () => {
      expect(css).toContain(".transition-interactive");
    });
  });

  describe("keyframes exist", () => {
    const requiredKeyframes = [
      "dialogIn",
      "backdropIn",
      "slideInRight",
      "fadeInUp",
    ];
    for (const name of requiredKeyframes) {
      it(`defines @keyframes ${name}`, () => {
        expect(css).toContain(`@keyframes ${name}`);
      });
    }
  });

  describe("GPU-composited properties only", () => {
    it("hover-lift uses transform (not top/left/margin)", () => {
      const hoverLiftBlock = css.match(
        /\.hover-lift:hover\s*\{([\s\S]*?)\}/,
      );
      expect(hoverLiftBlock).not.toBeNull();
      const block = hoverLiftBlock![1];
      expect(block).toContain("transform");
      expect(block).not.toContain("top:");
      expect(block).not.toContain("left:");
      expect(block).not.toContain("margin");
    });

    it("press-scale uses transform (not width/height)", () => {
      const pressScaleBlock = css.match(
        /\.press-scale:active\s*\{([\s\S]*?)\}/,
      );
      expect(pressScaleBlock).not.toBeNull();
      const block = pressScaleBlock![1];
      expect(block).toContain("scale(0.97)");
      expect(block).not.toContain("width:");
      expect(block).not.toContain("height:");
    });
  });

  describe("duration budget", () => {
    it("no duration token exceeds 300ms", () => {
      const durations = css.matchAll(
        /--duration-\w+:\s*(\d+)ms/g,
      );
      for (const match of durations) {
        const ms = parseInt(match[1], 10);
        expect(ms).toBeLessThanOrEqual(300);
      }
    });
  });
});
