import type { Config } from "tailwindcss";
import containerQueries from "@tailwindcss/container-queries";

const config: Config = {
  content: ["./src/**/*.{js,ts,jsx,tsx,mdx}"],
  theme: {
    screens: {
      xs: "375px",
      sm: "640px",
      md: "768px",
      lg: "1024px",
      xl: "1280px",
      "2xl": "1440px",
    },
    extend: {
      colors: {
        // ── Existing brand palette (preserved for backward compatibility) ──
        brand: {
          DEFAULT: "var(--color-brand)",
          hover: "var(--color-brand-hover)",
          subtle: "var(--color-brand-subtle)",
          50: "#f0fdf4",
          100: "#dcfce7",
          200: "#bbf7d0",
          300: "#86efac",
          400: "#4ade80",
          500: "#22c55e",
          600: "#16a34a",
          700: "#15803d",
          800: "#166534",
          900: "#14532d",
        },

        // ── Existing Nutri-Score colors (preserved) ──
        nutri: {
          A: "var(--color-nutri-A)",
          B: "var(--color-nutri-B)",
          C: "var(--color-nutri-C)",
          D: "var(--color-nutri-D)",
          E: "var(--color-nutri-E)",
        },

        // ── Surface & Background ──
        surface: {
          DEFAULT: "var(--color-surface)",
          subtle: "var(--color-surface-subtle)",
          muted: "var(--color-surface-muted)",
          overlay: "var(--color-surface-overlay)",
        },

        // ── Foreground (text colors) ──
        foreground: {
          DEFAULT: "var(--color-text-primary)",
          secondary: "var(--color-text-secondary)",
          muted: "var(--color-text-muted)",
          inverse: "var(--color-text-inverse)",
        },

        // ── Health Score Bands ──
        score: {
          green: "var(--color-score-green)",
          yellow: "var(--color-score-yellow)",
          orange: "var(--color-score-orange)",
          red: "var(--color-score-red)",
          darkred: "var(--color-score-darkred)",
        },

        // ── Nutrition Traffic Light (FSA/EFSA) ──
        nutrient: {
          low: "var(--color-nutrient-low)",
          medium: "var(--color-nutrient-medium)",
          high: "var(--color-nutrient-high)",
        },

        // ── NOVA Processing Groups ──
        nova: {
          1: "var(--color-nova-1)",
          2: "var(--color-nova-2)",
          3: "var(--color-nova-3)",
          4: "var(--color-nova-4)",
        },

        // ── Confidence Bands ──
        confidence: {
          high: "var(--color-confidence-high)",
          medium: "var(--color-confidence-medium)",
          low: "var(--color-confidence-low)",
        },

        // ── Allergen Severity ──
        allergen: {
          present: "var(--color-allergen-present)",
          traces: "var(--color-allergen-traces)",
          free: "var(--color-allergen-free)",
        },

        // ── Semantic Feedback ──
        success: "var(--color-success)",
        warning: "var(--color-warning)",
        error: "var(--color-error)",
        info: "var(--color-info)",
      },

      // ── Border colors ──
      borderColor: {
        DEFAULT: "var(--color-border)",
        strong: "var(--color-border-strong)",
      },

      // ── Shadows (theme-aware) ──
      boxShadow: {
        sm: "var(--shadow-sm)",
        md: "var(--shadow-md)",
        lg: "var(--shadow-lg)",
      },

      // ── Border Radius tokens ──
      borderRadius: {
        sm: "var(--radius-sm)",
        md: "var(--radius-md)",
        lg: "var(--radius-lg)",
        xl: "var(--radius-xl)",
      },
    },
  },
  plugins: [require("@tailwindcss/typography"), containerQueries],
};

export default config;
