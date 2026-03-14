import { dirname } from "path";
import { fileURLToPath } from "url";
import { FlatCompat } from "@eslint/eslintrc";
import js from "@eslint/js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const compat = new FlatCompat({
  baseDirectory: __dirname,
  recommendedConfig: js.configs.recommended,
});

const eslintConfig = [
  ...compat.extends("next/core-web-vitals", "next/typescript"),
  {
    rules: {
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

  // Logger & metrics utilities — intentional console usage
  {
    files: ["**/logger.ts", "**/monitoring/**", "**/web-vitals.ts"],
    rules: {
      "no-console": "off",
    },
  },
];

export default eslintConfig;
