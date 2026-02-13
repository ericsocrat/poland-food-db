import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./src/**/*.{js,ts,jsx,tsx,mdx}"],
  theme: {
    extend: {
      colors: {
        brand: {
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
        // Score band colors
        score: {
          low: "#22c55e",
          moderate: "#f59e0b",
          high: "#f97316",
          "very-high": "#ef4444",
        },
        // Nutri-Score colors
        nutri: {
          A: "#038141",
          B: "#85BB2F",
          C: "#FECB02",
          D: "#EE8100",
          E: "#E63E11",
        },
      },
    },
  },
  plugins: [],
};

export default config;
