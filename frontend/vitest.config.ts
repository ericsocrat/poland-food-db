import react from "@vitejs/plugin-react";
import { resolve } from "path";
import { defineConfig } from "vitest/config";

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": resolve(__dirname, "src"),
    },
  },
  test: {
    environment: "jsdom",
    globals: true,
    testTimeout: 15_000,
    hookTimeout: 15_000,
    setupFiles: ["./src/__tests__/setup.ts"],
    include: ["src/**/*.test.{ts,tsx}", "tests/**/*.test.{ts,tsx}"],
    coverage: {
      provider: "v8",
      reporter: ["text", "lcov", "json-summary"],
      reportsDirectory: "./coverage",
      include: ["src/**/*.{ts,tsx}"],
      exclude: [
        "src/**/*.test.{ts,tsx}",
        "src/**/*.spec.{ts,tsx}",
        "src/__tests__/**",
        "src/**/types.ts",
      ],
      // ── Coverage ratchet (#592) ────────────────────────────────────
      // Thresholds set at current baseline (rounded down).
      // Target: lines 90, branches 85, functions 88, statements 90
      // after merging #586 (hooks), #587 (components), #588 (lib).
      thresholds: {
        lines: 87,
        branches: 82,
        functions: 84,
        statements: 86,
      },
    },
  },
});
