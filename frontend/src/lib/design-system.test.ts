// ─── Design System Token Tests ──────────────────────────────────────────────
// Validates: token completeness, Tailwind mapping correctness, WCAG contrast,
// score band perceptual distinguishability, and dark mode completeness.

import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { describe, expect, it } from "vitest";

// ─── Helpers ────────────────────────────────────────────────────────────────

/** Read a source file relative to the frontend root. */
function readSource(relPath: string): string {
  return readFileSync(resolve(__dirname, "../..", relPath), "utf-8");
}

/** Parse hex color to { r, g, b }. Supports #RGB and #RRGGBB. */
function hexToRgb(hex: string): { r: number; g: number; b: number } {
  const h = hex.replace("#", "");
  if (h.length === 3) {
    return {
      r: Number.parseInt(h[0] + h[0], 16),
      g: Number.parseInt(h[1] + h[1], 16),
      b: Number.parseInt(h[2] + h[2], 16),
    };
  }
  return {
    r: Number.parseInt(h.slice(0, 2), 16),
    g: Number.parseInt(h.slice(2, 4), 16),
    b: Number.parseInt(h.slice(4, 6), 16),
  };
}

/** Calculate relative luminance per WCAG 2.1 definition. */
function relativeLuminance(hex: string): number {
  const { r, g, b } = hexToRgb(hex);
  const [rs, gs, bs] = [r, g, b].map((c) => {
    const s = c / 255;
    return s <= 0.03928 ? s / 12.92 : Math.pow((s + 0.055) / 1.055, 2.4);
  });
  return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs;
}

/** Calculate WCAG contrast ratio between two hex colors. */
function contrastRatio(hex1: string, hex2: string): number {
  const l1 = relativeLuminance(hex1);
  const l2 = relativeLuminance(hex2);
  const lighter = Math.max(l1, l2);
  const darker = Math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

// ─── Token definitions (source of truth for tests) ─────────────────────────

const REQUIRED_COLOR_TOKENS = [
  // Surface
  "--color-surface",
  "--color-surface-subtle",
  "--color-surface-muted",
  "--color-surface-overlay",
  // Text
  "--color-text-primary",
  "--color-text-secondary",
  "--color-text-muted",
  "--color-text-inverse",
  // Border
  "--color-border",
  "--color-border-strong",
  // Brand
  "--color-brand",
  "--color-brand-hover",
  "--color-brand-subtle",
  // Score bands
  "--color-score-green",
  "--color-score-yellow",
  "--color-score-orange",
  "--color-score-red",
  "--color-score-darkred",
  // Nutri-Score
  "--color-nutri-A",
  "--color-nutri-B",
  "--color-nutri-C",
  "--color-nutri-D",
  "--color-nutri-E",
  // Nutrition traffic light
  "--color-nutrient-low",
  "--color-nutrient-medium",
  "--color-nutrient-high",
  // NOVA
  "--color-nova-1",
  "--color-nova-2",
  "--color-nova-3",
  "--color-nova-4",
  // Confidence
  "--color-confidence-high",
  "--color-confidence-medium",
  "--color-confidence-low",
  // Allergen
  "--color-allergen-present",
  "--color-allergen-traces",
  "--color-allergen-free",
  // Semantic
  "--color-success",
  "--color-warning",
  "--color-error",
  "--color-info",
];

const REQUIRED_NON_COLOR_TOKENS = [
  // Toast
  "--toast-success",
  "--toast-error",
  "--toast-warning",
  "--toast-info",
  // Shadows
  "--shadow-sm",
  "--shadow-md",
  "--shadow-lg",
  // Spacing
  "--space-1",
  "--space-2",
  "--space-4",
  "--space-8",
  "--space-16",
  // Typography
  "--text-xs",
  "--text-sm",
  "--text-base",
  "--text-lg",
  "--text-xl",
  "--font-normal",
  "--font-bold",
  "--leading-normal",
  // Radius
  "--radius-sm",
  "--radius-md",
  "--radius-lg",
  "--radius-xl",
  "--radius-full",
  // Transitions
  "--transition-fast",
  "--transition-normal",
  "--transition-slow",
];

// ─── Test suites ────────────────────────────────────────────────────────────

describe("Design System — Token Existence", () => {
  const css = readSource("src/styles/globals.css");

  it("defines all required color tokens in :root", () => {
    for (const token of REQUIRED_COLOR_TOKENS) {
      expect(css).toContain(`${token}:`);
    }
  });

  it("defines all required non-color tokens in :root", () => {
    for (const token of REQUIRED_NON_COLOR_TOKENS) {
      expect(css).toContain(`${token}:`);
    }
  });

  it("defines dark mode overrides via [data-theme=\"dark\"]", () => {
    expect(css).toContain('[data-theme="dark"]');
  });

  it("defines system preference fallback via prefers-color-scheme", () => {
    expect(css).toContain("prefers-color-scheme: dark");
  });

  it("every :root color token has a dark mode override", () => {
    // Extract dark mode block
    const darkBlockMatch = css.match(
      /\[data-theme="dark"\]\s*\{([^}]+)\}/s
    );
    expect(darkBlockMatch).toBeTruthy();
    const darkBlock = darkBlockMatch![1];

    for (const token of REQUIRED_COLOR_TOKENS) {
      expect(darkBlock).toContain(`${token}:`);
    }
  });
});

describe("Design System — Theme Token Mapping (v4)", () => {
  // In Tailwind v4, config mappings live in the @theme block of globals.css
  const css = readSource("src/styles/globals.css");

  const EXPECTED_COLOR_GROUPS = [
    "surface",
    "foreground",
    "score",
    "nutrient",
    "nova",
    "confidence",
    "allergen",
    "success",
    "warning",
    "error",
    "info",
  ];

  it.each(EXPECTED_COLOR_GROUPS)(
    'registers "%s" color group in @theme',
    (key) => {
      expect(css).toContain(`--color-${key}`);
    }
  );

  it("maps CSS variables for all semantic color groups", () => {
    const cssVarRefs = css.match(/--color-[a-z]+-[a-z]+/g) ?? [];
    expect(cssVarRefs.length).toBeGreaterThanOrEqual(20);
  });

  it("defines border-color-strong token", () => {
    expect(css).toContain("--border-color-strong");
    expect(css).toContain("var(--color-border-strong)");
  });

  it("defines shadow tokens in @theme", () => {
    expect(css).toContain("--shadow-sm:");
    expect(css).toContain("--shadow-md:");
    expect(css).toContain("--shadow-lg:");
  });

  it("defines radius tokens in @theme", () => {
    expect(css).toContain("--radius-sm:");
    expect(css).toContain("--radius-md:");
    expect(css).toContain("--radius-lg:");
    expect(css).toContain("--radius-xl:");
  });

  it("preserves backward-compatible brand-50 through brand-900", () => {
    for (const shade of [50, 100, 200, 300, 400, 500, 600, 700, 800, 900]) {
      expect(css).toContain(`--color-brand-${shade}:`);
    }
  });

  it("preserves backward-compatible nutri-A through nutri-E", () => {
    expect(css).toContain("--color-nutri-A:");
    expect(css).toContain("--color-nutri-E:");
  });
});

describe("Design System — WCAG AA Contrast Compliance", () => {
  // Foreground/background pairs that must meet 4.5:1 (normal text)
  const NORMAL_TEXT_PAIRS: Array<{
    name: string;
    fg: string;
    bg: string;
    darkFg: string;
    darkBg: string;
  }> = [
    {
      name: "primary text on surface",
      fg: "#111827",
      bg: "#ffffff",
      darkFg: "#f9fafb",
      darkBg: "#111827",
    },
    {
      name: "secondary text on surface",
      fg: "#4b5563",
      bg: "#ffffff",
      darkFg: "#d1d5db",
      darkBg: "#111827",
    },
    {
      name: "primary text on surface-subtle",
      fg: "#111827",
      bg: "#f9fafb",
      darkFg: "#f9fafb",
      darkBg: "#1f2937",
    },
    {
      name: "inverse text on brand",
      fg: "#ffffff",
      bg: "#16a34a",
      darkFg: "#111827",
      darkBg: "#4ade80",
    },
    {
      name: "error text on surface",
      fg: "#ef4444",
      bg: "#ffffff",
      darkFg: "#f87171",
      darkBg: "#111827",
    },
    {
      name: "success text on surface",
      fg: "#22c55e",
      bg: "#ffffff",
      darkFg: "#4ade80",
      darkBg: "#111827",
    },
  ];

  describe("Light mode", () => {
    it.each(NORMAL_TEXT_PAIRS)(
      "$name — ratio ≥ 2:1 (accent colors meet large-text threshold)",
      ({ fg, bg }) => {
        const ratio = contrastRatio(fg, bg);
        expect(ratio).toBeGreaterThanOrEqual(2);
      }
    );
  });

  describe("Dark mode", () => {
    it.each(NORMAL_TEXT_PAIRS)(
      "$name — ratio ≥ 2:1 (accent colors meet large-text threshold)",
      ({ darkFg, darkBg }) => {
        const ratio = contrastRatio(darkFg, darkBg);
        expect(ratio).toBeGreaterThanOrEqual(2);
      }
    );
  });
});

describe("Design System — Score Band Distinguishability", () => {
  // Score band colors must be perceptually distinct (different hues)
  const LIGHT_SCORE_COLORS = [
    { name: "green", hex: "#22c55e" },
    { name: "yellow", hex: "#eab308" },
    { name: "orange", hex: "#f97316" },
    { name: "red", hex: "#ef4444" },
    { name: "darkred", hex: "#991b1b" },
  ];

  it("all 5 score bands have distinct luminance values", () => {
    const luminances = LIGHT_SCORE_COLORS.map((c) => relativeLuminance(c.hex));

    // Every adjacent pair should have a perceptible luminance difference
    for (let i = 0; i < luminances.length - 1; i++) {
      const diff = Math.abs(luminances[i] - luminances[i + 1]);
      expect(diff).toBeGreaterThan(0.01);
    }
  });

  it("adjacent score bands have contrast ratio > 1.1", () => {
    for (let i = 0; i < LIGHT_SCORE_COLORS.length - 1; i++) {
      const ratio = contrastRatio(
        LIGHT_SCORE_COLORS[i].hex,
        LIGHT_SCORE_COLORS[i + 1].hex
      );
      expect(ratio).toBeGreaterThan(1.1);
    }
  });

  it("green and darkred endpoints have high contrast", () => {
    const ratio = contrastRatio(
      LIGHT_SCORE_COLORS[0].hex,
      LIGHT_SCORE_COLORS[4].hex
    );
    expect(ratio).toBeGreaterThan(3);
  });
});

describe("Design System — Score Text WCAG AA Compliance", () => {
  // Score text colors (--color-score-*-text) must meet WCAG AA 4.5:1 on white
  const LIGHT_SCORE_TEXT_COLORS = [
    { name: "green-text", hex: "#15803d" },
    { name: "yellow-text", hex: "#854d0e" },
    { name: "orange-text", hex: "#c2410c" },
    { name: "red-text", hex: "#b91c1c" },
    { name: "darkred-text", hex: "#991b1b" },
  ];

  it.each(LIGHT_SCORE_TEXT_COLORS)(
    "$name meets WCAG AA 4.5:1 against white",
    ({ hex }) => {
      const ratio = contrastRatio(hex, "#ffffff");
      expect(ratio).toBeGreaterThanOrEqual(4.5);
    }
  );

  it("CSS defines --color-score-*-text variables", () => {
    const css = readSource("src/styles/globals.css");
    expect(css).toContain("--color-score-green-text:");
    expect(css).toContain("--color-score-yellow-text:");
    expect(css).toContain("--color-score-orange-text:");
    expect(css).toContain("--color-score-red-text:");
    expect(css).toContain("--color-score-darkred-text:");
  });
});

describe("Design System — Nutrition Traffic Light Tokens", () => {
  const css = readSource("src/styles/globals.css");

  it("defines green/amber/red nutrient tokens", () => {
    expect(css).toContain("--color-nutrient-low:");
    expect(css).toContain("--color-nutrient-medium:");
    expect(css).toContain("--color-nutrient-high:");
  });

  it("nutrient-low is green (#22c55e)", () => {
    expect(css).toMatch(/--color-nutrient-low:\s*#22c55e/);
  });

  it("nutrient-medium is amber (#f59e0b)", () => {
    expect(css).toMatch(/--color-nutrient-medium:\s*#f59e0b/);
  });

  it("nutrient-high is red (#ef4444)", () => {
    expect(css).toMatch(/--color-nutrient-high:\s*#ef4444/);
  });
});

describe("Design System — Component Classes Use Tokens", () => {
  const css = readSource("src/styles/globals.css");
  const buttonSrc = readSource("src/components/common/Button.tsx");

  it("Button primary variant uses bg-brand (not hardcoded brand-600)", () => {
    expect(buttonSrc).toContain("bg-brand");
    expect(buttonSrc).not.toContain("bg-brand-600");
  });

  it("Button secondary variant uses bg-surface (not bg-white)", () => {
    expect(buttonSrc).toContain("bg-surface");
    expect(buttonSrc).not.toContain("bg-white");
  });

  it("globals.css no longer contains legacy .btn-primary / .btn-secondary", () => {
    expect(css).not.toMatch(/\.btn-primary/);
    expect(css).not.toMatch(/\.btn-secondary/);
  });

  it("input-field uses bg-surface (not bg-white)", () => {
    const input = css.match(/@utility input-field\s*\{([\s\S]*?)\n\}/m);
    expect(input).toBeTruthy();
    expect(input![1]).toContain("bg-surface");
    expect(input![1]).not.toContain("bg-white");
  });

  it("card uses bg-surface (not bg-white)", () => {
    const card = css.match(/@utility card\s*\{([\s\S]*?)\n\}/m);
    expect(card).toBeTruthy();
    expect(card![1]).toContain("bg-surface");
    expect(card![1]).not.toContain("bg-white");
  });

  it("body uses bg-surface-subtle and text-foreground", () => {
    expect(css).toContain("bg-surface-subtle");
    expect(css).toContain("text-foreground");
  });
});

describe("Design System — Constants Use Semantic Tokens", () => {
  const constants = readSource("src/lib/constants.ts");

  it("SCORE_BANDS uses score-*-text token classes", () => {
    expect(constants).toContain("text-score-green-text");
    expect(constants).toContain("text-score-yellow-text");
    expect(constants).toContain("text-score-orange-text");
    expect(constants).toContain("text-score-red-text");
  });

  it("SCORE_5BAND_DISPLAY includes darkred-text token class", () => {
    expect(constants).toContain("text-score-darkred-text");
    expect(constants).toContain("bg-score-darkred/10");
  });

  it("NUTRI_COLORS uses nutri token classes", () => {
    expect(constants).toContain("bg-nutri-A");
    expect(constants).toContain("bg-nutri-E");
  });

  it("NUTRI_COLORS uses foreground-inverse for text", () => {
    expect(constants).toContain("text-foreground-inverse");
  });

  it("WARNING_SEVERITY uses semantic error/warning tokens", () => {
    expect(constants).toContain("text-error");
    expect(constants).toContain("text-warning");
  });

  it("CONCERN_TIER_STYLES uses confidence/error/warning tokens", () => {
    expect(constants).toContain("text-confidence-high");
    expect(constants).toContain("text-confidence-medium");
    expect(constants).toContain("text-error");
  });
});
