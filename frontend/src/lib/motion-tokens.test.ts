import { readFileSync } from "fs";
import { join } from "path";
import { describe, expect, it } from "vitest";

// ─── Motion token compliance tests (#61) ─────────────────────────────────────
// Verify motion tokens exist in globals.css and follow design system rules.
// These tests validate the CSS source, not runtime computed styles.

const cssPath = join(__dirname, "../styles/globals.css");
const css = readFileSync(cssPath, "utf-8");

// In Tailwind v4, config mappings live in the @theme block of globals.css
// (tailwind.config.ts was removed during the v4 migration).

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
    it("defines hover-lift utility", () => {
      expect(css).toContain("@utility hover-lift");
      expect(css).toContain("&:hover");
    });

    it("defines press-scale utility", () => {
      expect(css).toContain("@utility press-scale");
      expect(css).toContain("&:active");
    });

    it("defines hover-lift-press utility", () => {
      expect(css).toContain("@utility hover-lift-press");
    });

    it("defines transition-interactive utility", () => {
      expect(css).toContain("@utility transition-interactive");
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
      // In v4, @utility hover-lift uses nested &:hover syntax
      const hoverLiftBlock = css.match(
        /@utility hover-lift\s*\{([\s\S]*?)\n\}/,
      );
      expect(hoverLiftBlock).not.toBeNull();
      const block = hoverLiftBlock![1];
      expect(block).toContain("transform");
      expect(block).not.toContain("top:");
      expect(block).not.toContain("left:");
      expect(block).not.toContain("margin");
    });

    it("press-scale uses transform (not width/height)", () => {
      // In v4, @utility press-scale uses nested &:active syntax
      const pressScaleBlock = css.match(
        /@utility press-scale\s*\{([\s\S]*?)\n\}/,
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

  describe("@theme motion extensions (v4)", () => {
    describe("transitionDuration tokens", () => {
      const requiredDurations = [
        "instant",
        "fast",
        "normal",
        "slow",
      ];
      for (const name of requiredDurations) {
        it(`maps ${name} → --transition-duration-${name}`, () => {
          expect(css).toContain(`--transition-duration-${name}: var(--duration-${name})`);
        });
      }
    });

    describe("transitionTimingFunction tokens", () => {
      const requiredEasings = [
        "standard",
        "decelerate",
        "accelerate",
        "spring",
      ];
      for (const name of requiredEasings) {
        it(`maps ${name} → --ease-${name}`, () => {
          expect(css).toContain(`--ease-${name}:`);
        });
      }
    });

    describe("keyframes and animations", () => {
      const requiredAnimations = [
        "fade-in-up",
        "scale-in",
        "chip-enter",
      ];
      for (const name of requiredAnimations) {
        it(`defines animation "${name}"`, () => {
          expect(css).toContain(`--animate-${name}:`);
        });
      }
    });
  });
});
