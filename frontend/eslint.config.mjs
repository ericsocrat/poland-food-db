import nextCoreWebVitals from "eslint-config-next/core-web-vitals";
import nextTypescript from "eslint-config-next/typescript";

const eslintConfig = [
  ...nextCoreWebVitals,
  ...nextTypescript,
  {
    rules: {
      // ── React Compiler rules (new in Next.js 16) ────────────────────
      // Downgraded to warn — existing code predates these rules.
      // Address in a dedicated cleanup pass.
      "react-hooks/set-state-in-effect": "warn",
      "react-hooks/preserve-manual-memoization": "warn",
      "react-hooks/refs": "warn",
      "react-hooks/static-components": "warn",

      // ── TypeScript strictness ───────────────────────────────────────
      "@typescript-eslint/no-unused-vars": [
        "error",
        { argsIgnorePattern: "^_", varsIgnorePattern: "^_" },
      ],
      "@typescript-eslint/no-explicit-any": "warn",
      "@typescript-eslint/consistent-type-imports": [
        "error",
        { prefer: "type-imports" },
      ],
      "@typescript-eslint/no-non-null-assertion": "warn",

      // ── Code quality ────────────────────────────────────────────────
      "no-console": ["warn", { allow: ["warn", "error"] }],
      "prefer-const": "error",
      "no-var": "error",
      eqeqeq: ["error", "smart"],
      "no-duplicate-imports": "error",
      "no-unreachable": "error",
      "no-unused-expressions": "error",

      // ── Import restrictions ─────────────────────────────────────────
      "no-restricted-imports": [
        "error",
        {
          patterns: [
            {
              group: ["../*"],
              message:
                "Use path aliases (@/) instead of relative parent imports",
            },
          ],
        },
      ],
    },
  },

  // Test files — relax console and any restrictions
  {
    files: [
      "**/*.test.ts",
      "**/*.test.tsx",
      "**/*.spec.ts",
      "**/*.spec.tsx",
      "**/e2e/**",
    ],
    rules: {
      "no-console": "off",
      "@typescript-eslint/no-explicit-any": "off",
      "@typescript-eslint/no-non-null-assertion": "off",
    },
  },

  // OG image generators — Satori requires plain <img>, not next/image
  {
    files: ["**/opengraph-image.tsx"],
    rules: {
      "@next/next/no-img-element": "off",
    },
  },

  // Logger & metrics utilities — intentional console usage
  {
    files: ["**/logger.ts", "**/monitoring/**", "**/web-vitals.ts"],
    rules: {
      "no-console": "off",
    },
  },
];

export default eslintConfig;
