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
      // ── Coverage ratchet (#718) ────────────────────────────────────
      // Thresholds ratcheted to achieved coverage (rounded down to integer).
      // Actual: lines 92.0, branches 85.9, functions 88.7, statements 90.7
      thresholds: {
        lines: 92,
        branches: 85,
        functions: 88,
        statements: 90,
      },
    },
  },
});
