import "@testing-library/jest-dom/vitest";
import { vi } from "vitest";

// ─── Global mock: useAnalytics ──────────────────────────────────────────────
// Auto-mock the analytics hook so every component test gets a no-op track().
// Individual test files can override this with their own vi.mock if needed.
vi.mock("@/hooks/use-analytics", () => ({
  useAnalytics: () => ({ track: vi.fn() }),
}));
