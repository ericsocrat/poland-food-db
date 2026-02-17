import "@testing-library/jest-dom/vitest";
import { vi } from "vitest";

// ─── Global mock: matchMedia ────────────────────────────────────────────────
// jsdom doesn't implement matchMedia. Provide a minimal stub so hooks like
// useTheme() work in all component tests.
Object.defineProperty(window, "matchMedia", {
  writable: true,
  value: vi.fn().mockImplementation((query: string) => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: vi.fn(),
    removeListener: vi.fn(),
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    dispatchEvent: vi.fn(),
  })),
});

// ─── Global mock: useAnalytics ──────────────────────────────────────────────
// Auto-mock the analytics hook so every component test gets a no-op track().
// Individual test files can override this with their own vi.mock if needed.
vi.mock("@/hooks/use-analytics", () => ({
  useAnalytics: () => ({ track: vi.fn() }),
}));
