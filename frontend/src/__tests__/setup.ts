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

// ─── Global mock: ResizeObserver ────────────────────────────────────────────
// jsdom doesn't implement ResizeObserver. Required by Radix UI Tooltip/Popper.
class ResizeObserverStub {
  observe() {}
  unobserve() {}
  disconnect() {}
}
globalThis.ResizeObserver = ResizeObserverStub as unknown as typeof ResizeObserver;

// ─── Global mock: DOMRect ───────────────────────────────────────────────────
// Radix Popper calls getBoundingClientRect which returns a stub in jsdom.
// Provide a proper DOMRect for positioning calculations.
if (!globalThis.DOMRect) {
  globalThis.DOMRect = class DOMRect {
    x = 0;
    y = 0;
    width = 0;
    height = 0;
    top = 0;
    right = 0;
    bottom = 0;
    left = 0;
    constructor(x = 0, y = 0, width = 0, height = 0) {
      this.x = x;
      this.y = y;
      this.width = width;
      this.height = height;
      this.top = y;
      this.right = x + width;
      this.bottom = y + height;
      this.left = x;
    }
    toJSON() {
      return { x: this.x, y: this.y, width: this.width, height: this.height, top: this.top, right: this.right, bottom: this.bottom, left: this.left };
    }
    static fromRect(rect?: { x?: number; y?: number; width?: number; height?: number }) {
      return new DOMRect(rect?.x, rect?.y, rect?.width, rect?.height);
    }
  } as unknown as typeof DOMRect;
}

// Ensure Element.prototype.hasPointerCapture exists (needed by Radix)
if (!Element.prototype.hasPointerCapture) {
  Element.prototype.hasPointerCapture = () => false;
}
if (!Element.prototype.setPointerCapture) {
  Element.prototype.setPointerCapture = () => {};
}
if (!Element.prototype.releasePointerCapture) {
  Element.prototype.releasePointerCapture = () => {};
}
