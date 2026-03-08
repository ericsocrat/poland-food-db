import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { PullToRefresh } from "./PullToRefresh";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => {
      const map: Record<string, string> = {
        "pwa.pullToRefresh": "Pull to refresh",
        "pwa.releaseToRefresh": "Release to refresh",
        "pwa.refreshing": "Refreshing…",
      };
      return map[key] ?? key;
    },
  }),
}));

const mockUseReducedMotion = vi.fn(() => false);
vi.mock("@/hooks/use-reduced-motion", () => ({
  useReducedMotion: () => mockUseReducedMotion(),
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

function pullDown(
  el: HTMLElement,
  startY: number,
  endY: number,
  release = true,
) {
  fireEvent.touchStart(el, {
    touches: [{ clientX: 0, clientY: startY }],
  });
  fireEvent.touchMove(el, {
    touches: [{ clientX: 0, clientY: endY }],
  });
  if (release) {
    fireEvent.touchEnd(el);
  }
}

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("PullToRefresh", () => {
  let onRefresh: ReturnType<typeof vi.fn>;

  beforeEach(() => {
    vi.clearAllMocks();
    onRefresh = vi.fn(() => Promise.resolve());
    // Default: scrolled to top
    Object.defineProperty(window, "scrollY", { value: 0, writable: true });
  });

  // ── Rendering ───────────────────────────────────────────────────────────

  it("renders children content", () => {
    render(
      <PullToRefresh onRefresh={onRefresh}>
        <p>Page content</p>
      </PullToRefresh>,
    );
    expect(screen.getByText("Page content")).toBeInTheDocument();
  });

  it("does not show indicator in idle state", () => {
    render(
      <PullToRefresh onRefresh={onRefresh}>
        <p>Content</p>
      </PullToRefresh>,
    );
    expect(screen.queryByText("Pull to refresh")).not.toBeInTheDocument();
  });

  it("applies custom className", () => {
    const { container } = render(
      <PullToRefresh onRefresh={onRefresh} className="test-cls">
        <p>Content</p>
      </PullToRefresh>,
    );
    expect(container.firstElementChild).toHaveClass("test-cls");
  });

  // ── Pull gesture ────────────────────────────────────────────────────────

  it("shows pull indicator on touch pull down", () => {
    const { container } = render(
      <PullToRefresh onRefresh={onRefresh}>
        <p>Content</p>
      </PullToRefresh>,
    );
    const wrapper = container.firstElementChild as HTMLElement;

    // Pull down 80px (40px dampened at 0.5x) — below threshold
    pullDown(wrapper, 100, 180, false);
    expect(screen.getByText("Pull to refresh")).toBeInTheDocument();
  });

  it("shows release text when pulled past threshold", () => {
    const { container } = render(
      <PullToRefresh onRefresh={onRefresh}>
        <p>Content</p>
      </PullToRefresh>,
    );
    const wrapper = container.firstElementChild as HTMLElement;

    // Pull 200px → dampened to 100px, over 60px threshold
    pullDown(wrapper, 100, 300, false);
    expect(screen.getByText("Release to refresh")).toBeInTheDocument();
  });

  it("triggers onRefresh when pulled past threshold and released", async () => {
    const { container } = render(
      <PullToRefresh onRefresh={onRefresh}>
        <p>Content</p>
      </PullToRefresh>,
    );
    const wrapper = container.firstElementChild as HTMLElement;

    // Pull past threshold and release
    pullDown(wrapper, 100, 300);

    await waitFor(() => {
      expect(onRefresh).toHaveBeenCalledTimes(1);
    });
  });

  it("shows refreshing state text during refresh", async () => {
    // onRefresh that we can control when it resolves
    let resolveRefresh!: () => void;
    const slowRefresh = vi.fn(
      () =>
        new Promise<void>((resolve) => {
          resolveRefresh = resolve;
        }),
    );

    const { container } = render(
      <PullToRefresh onRefresh={slowRefresh}>
        <p>Content</p>
      </PullToRefresh>,
    );
    const wrapper = container.firstElementChild as HTMLElement;

    pullDown(wrapper, 100, 300);

    await waitFor(() => {
      expect(screen.getAllByText("Refreshing…").length).toBeGreaterThan(0);
    });

    // Resolve the refresh
    resolveRefresh();
    await waitFor(() => {
      expect(screen.queryAllByText("Refreshing…")).toHaveLength(0);
    });
  });

  it("resets state after refresh completes", async () => {
    const { container } = render(
      <PullToRefresh onRefresh={onRefresh}>
        <p>Content</p>
      </PullToRefresh>,
    );
    const wrapper = container.firstElementChild as HTMLElement;

    pullDown(wrapper, 100, 300);

    await waitFor(() => {
      // After resolve, indicator should disappear
      expect(screen.queryByText("Pull to refresh")).not.toBeInTheDocument();
      expect(
        screen.queryByText("Release to refresh"),
      ).not.toBeInTheDocument();
      expect(screen.queryAllByText("Refreshing…")).toHaveLength(0);
    });
  });

  it("does not trigger when pull is below threshold", async () => {
    const { container } = render(
      <PullToRefresh onRefresh={onRefresh}>
        <p>Content</p>
      </PullToRefresh>,
    );
    const wrapper = container.firstElementChild as HTMLElement;

    // Pull 40px → dampened to 20px, below 60px threshold
    pullDown(wrapper, 100, 140);

    // Wait a tick and confirm not called
    await new Promise((r) => setTimeout(r, 50));
    expect(onRefresh).not.toHaveBeenCalled();
  });

  // ── Scroll position guard ──────────────────────────────────────────────

  it("does not trigger when page is scrolled down", async () => {
    Object.defineProperty(window, "scrollY", { value: 100, writable: true });

    const { container } = render(
      <PullToRefresh onRefresh={onRefresh}>
        <p>Content</p>
      </PullToRefresh>,
    );
    const wrapper = container.firstElementChild as HTMLElement;

    pullDown(wrapper, 100, 300);

    await new Promise((r) => setTimeout(r, 50));
    expect(onRefresh).not.toHaveBeenCalled();
  });

  // ── Reduced motion ────────────────────────────────────────────────────

  it("does not apply animate-spin when reduced motion is preferred", async () => {
    mockUseReducedMotion.mockReturnValue(true);

    let resolveRefresh!: () => void;
    const slowRefresh = vi.fn(
      () =>
        new Promise<void>((resolve) => {
          resolveRefresh = resolve;
        }),
    );

    const { container } = render(
      <PullToRefresh onRefresh={slowRefresh}>
        <p>Content</p>
      </PullToRefresh>,
    );
    const wrapper = container.firstElementChild as HTMLElement;

    pullDown(wrapper, 100, 300);

    await waitFor(() => {
      expect(screen.getAllByText("Refreshing…").length).toBeGreaterThan(0);
    });

    const svg = container.querySelector("svg");
    expect(svg).not.toHaveClass("animate-spin");

    resolveRefresh();
    await waitFor(() => {
      expect(screen.queryAllByText("Refreshing…")).toHaveLength(0);
    });
  });

  // ── Accessibility ─────────────────────────────────────────────────────

  it("announces refreshing state to screen readers", async () => {
    let resolveRefresh!: () => void;
    const slowRefresh = vi.fn(
      () =>
        new Promise<void>((resolve) => {
          resolveRefresh = resolve;
        }),
    );

    const { container } = render(
      <PullToRefresh onRefresh={slowRefresh}>
        <p>Content</p>
      </PullToRefresh>,
    );
    const wrapper = container.firstElementChild as HTMLElement;

    pullDown(wrapper, 100, 300);

    await waitFor(() => {
      const status = container.querySelector('[role="status"]');
      expect(status).toBeInTheDocument();
      expect(status).toHaveTextContent("Refreshing…");
    });

    resolveRefresh();
    await waitFor(() => {
      expect(container.querySelector('[role="status"]')).not.toBeInTheDocument();
    });
  });

  it("has aria-live on indicator area", () => {
    const { container } = render(
      <PullToRefresh onRefresh={onRefresh}>
        <p>Content</p>
      </PullToRefresh>,
    );
    const wrapper = container.firstElementChild as HTMLElement;

    // Trigger indicator to appear
    pullDown(wrapper, 100, 180, false);

    const live = container.querySelector('[aria-live="polite"]');
    expect(live).toBeInTheDocument();
  });

  // ── Error resilience ──────────────────────────────────────────────────

  it("resets state even if onRefresh rejects", async () => {
    const failRefresh = vi.fn(() => Promise.reject(new Error("fail")));

    const { container } = render(
      <PullToRefresh onRefresh={failRefresh}>
        <p>Content</p>
      </PullToRefresh>,
    );
    const wrapper = container.firstElementChild as HTMLElement;

    pullDown(wrapper, 100, 300);

    await waitFor(() => {
      // State should reset even after error
      expect(screen.queryAllByText("Refreshing…")).toHaveLength(0);
    });
  });

  // ── Upward pull ignored ───────────────────────────────────────────────

  it("does not show indicator when pulling upward", () => {
    const { container } = render(
      <PullToRefresh onRefresh={onRefresh}>
        <p>Content</p>
      </PullToRefresh>,
    );
    const wrapper = container.firstElementChild as HTMLElement;

    // Pull upward (delta negative)
    pullDown(wrapper, 300, 100, false);

    // Indicator container should have zero height (not visible)
    const indicator = container.querySelector("[aria-live]");
    if (indicator) {
      expect(parseInt((indicator as HTMLElement).style.height, 10)).toBe(0);
    }
    expect(onRefresh).not.toHaveBeenCalled();
  });
});
