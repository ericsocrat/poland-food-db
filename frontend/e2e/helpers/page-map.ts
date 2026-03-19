// ─── Page Map — File-to-URL Mapping for Smart PR Screenshots ────────────────
// Maps source file paths to page URLs so that `pr-screenshots.spec.ts` can
// capture only pages whose source files were modified in the current branch.
//
// Used by:
//   - frontend/e2e/pr-screenshots.spec.ts (Playwright spec)
//   - RUN_PR_SCREENSHOTS.ps1 (local runner — sets CHANGED_FILES env var)
//   - .github/workflows/pr-screenshots.yml (CI runner — sets CHANGED_FILES)
//
// To add a new page: add an entry to PAGE_MAP with the file patterns that
// should trigger a screenshot, the URL to visit, label for the filename,
// and whether authentication is required.

import { execSync } from "node:child_process";

/* ── Types ───────────────────────────────────────────────────────────────── */

export interface PageEntry {
  /** Glob-like path prefixes (relative to frontend/src/ or frontend/messages/) */
  patterns: string[];
  /** URL path to screenshot */
  url: string;
  /** Short label used as the screenshot filename (e.g. "scanner", "submit") */
  label: string;
  /** Whether the page requires authentication */
  auth: boolean;
}

/* ── Page Map ────────────────────────────────────────────────────────────── */

export const PAGE_MAP: PageEntry[] = [
  // ── Public pages ────────────────────────────────────────────────────────
  {
    patterns: ["src/app/page.tsx", "src/app/LandingSections.tsx"],
    url: "/",
    label: "landing",
    auth: false,
  },
  {
    patterns: ["src/app/auth/"],
    url: "/auth/login",
    label: "login",
    auth: false,
  },
  {
    patterns: ["src/app/contact/"],
    url: "/contact",
    label: "contact",
    auth: false,
  },
  {
    patterns: ["src/app/privacy/"],
    url: "/privacy",
    label: "privacy",
    auth: false,
  },
  {
    patterns: ["src/app/terms/"],
    url: "/terms",
    label: "terms",
    auth: false,
  },
  {
    patterns: ["src/app/learn/"],
    url: "/learn",
    label: "learn",
    auth: false,
  },

  // ── Authenticated pages ─────────────────────────────────────────────────
  {
    patterns: ["src/app/app/page.tsx", "src/components/layout/", "src/components/dashboard/"],
    url: "/app",
    label: "dashboard",
    auth: true,
  },
  {
    patterns: ["src/app/app/categories/"],
    url: "/app/categories",
    label: "categories",
    auth: true,
  },
  {
    patterns: ["src/app/app/search/", "src/components/search/"],
    url: "/app/search",
    label: "search",
    auth: true,
  },
  {
    patterns: [
      "src/app/app/scan/page.tsx",
      "src/app/app/scan/layout.tsx",
      "src/components/scan/ScanResultView.tsx",
      "src/components/scan/ScanMissSubmitCTA.tsx",
      "src/components/scan/ScannerErrorState.tsx",
    ],
    url: "/app/scan",
    label: "scanner",
    auth: true,
  },
  {
    patterns: ["src/app/app/scan/submit/"],
    url: "/app/scan/submit",
    label: "submit",
    auth: true,
  },
  {
    patterns: ["src/app/app/scan/history/"],
    url: "/app/scan/history",
    label: "scan-history",
    auth: true,
  },
  {
    patterns: ["src/app/app/scan/submissions/"],
    url: "/app/scan/submissions",
    label: "submissions",
    auth: true,
  },
  {
    patterns: ["src/app/app/compare/", "src/components/compare/"],
    url: "/app/compare",
    label: "compare",
    auth: true,
  },
  {
    patterns: ["src/app/app/lists/"],
    url: "/app/lists",
    label: "lists",
    auth: true,
  },
  {
    patterns: ["src/app/app/settings/", "src/components/settings/"],
    url: "/app/settings",
    label: "settings",
    auth: true,
  },
  {
    patterns: ["src/app/app/recipes/"],
    url: "/app/recipes",
    label: "recipes",
    auth: true,
  },
  {
    patterns: ["src/app/app/achievements/"],
    url: "/app/achievements",
    label: "achievements",
    auth: true,
  },
  {
    patterns: ["src/app/app/watchlist/"],
    url: "/app/watchlist",
    label: "watchlist",
    auth: true,
  },
  {
    patterns: ["src/app/app/admin/"],
    url: "/app/admin",
    label: "admin",
    auth: true,
  },
  {
    patterns: ["src/app/app/product/"],
    url: "/app/categories",
    label: "product-list",
    auth: true,
  },
  {
    patterns: ["src/app/app/ingredient/"],
    url: "/app/categories",
    label: "ingredient-page",
    auth: true,
  },
  {
    patterns: ["src/app/app/image-search/"],
    url: "/app/image-search",
    label: "image-search",
    auth: true,
  },

  // ── Global styles / shared components ───────────────────────────────────
  // Changes to global CSS or shared components screenshot a representative
  // set of pages to catch cascading visual regressions.
  {
    patterns: ["src/styles/globals.css"],
    url: "/app",
    label: "global-dashboard",
    auth: true,
  },
  {
    patterns: ["src/styles/globals.css"],
    url: "/app/scan",
    label: "global-scanner",
    auth: true,
  },
  {
    patterns: ["src/components/common/"],
    url: "/app",
    label: "common-dashboard",
    auth: true,
  },

  // ── i18n files ──────────────────────────────────────────────────────────
  // Changes to translation files screenshot a representative page.
  {
    patterns: ["messages/en.json", "messages/pl.json", "messages/de.json"],
    url: "/app",
    label: "i18n-dashboard",
    auth: true,
  },
];

/* ── Matching Logic ──────────────────────────────────────────────────────── */

/**
 * Given a list of changed file paths (relative to the repo root, e.g.
 * "frontend/src/app/app/scan/page.tsx"), returns the deduplicated set of
 * PageEntry items whose patterns match at least one changed file.
 */
export function getMatchingPages(changedFiles: string[]): PageEntry[] {
  // Normalize: strip "frontend/" prefix if present (patterns are relative to frontend/)
  const normalized = changedFiles.map((f) =>
    f.startsWith("frontend/") ? f.slice("frontend/".length) : f,
  );

  const matched = new Set<string>();
  const result: PageEntry[] = [];

  for (const entry of PAGE_MAP) {
    if (matched.has(entry.label)) continue;

    const hits = entry.patterns.some((pattern) =>
      normalized.some((file) => file.startsWith(pattern)),
    );

    if (hits) {
      matched.add(entry.label);
      result.push(entry);
    }
  }

  return result;
}

/**
 * Reads the CHANGED_FILES environment variable (newline-separated file paths)
 * and returns matching pages. Falls back to git diff against main if the
 * env var is not set.
 */
export function getChangedPages(): PageEntry[] {
  const envFiles = process.env.CHANGED_FILES;

  if (envFiles) {
    const files = envFiles
      .split("\n")
      .map((f) => f.trim())
      .filter(Boolean);
    return getMatchingPages(files);
  }

  // Fallback: detect via git diff against main
  try {
    const diff = execSync("git diff --name-only main...HEAD", {
      encoding: "utf-8",
      timeout: 10_000,
    });
    const files = diff
      .split("\n")
      .map((f) => f.trim())
      .filter(Boolean);

    // If no diff (e.g. on main), also check uncommitted changes
    if (files.length === 0) {
      const uncommitted = execSync("git diff --name-only HEAD", {
        encoding: "utf-8",
        timeout: 10_000,
      });
      const uncommittedFiles = uncommitted
        .split("\n")
        .map((f) => f.trim())
        .filter(Boolean);
      return getMatchingPages(uncommittedFiles);
    }

    return getMatchingPages(files);
  } catch {
    // If git commands fail, return empty — caller decides what to do
    return [];
  }
}
