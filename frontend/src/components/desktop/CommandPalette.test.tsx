import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { CommandPalette } from "./CommandPalette";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockPush = vi.fn();

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: mockPush }),
}));

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

vi.mock("@/lib/api", () => ({
  getRecentlyViewed: () =>
    Promise.resolve({ ok: true, data: { products: [] } }),
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, staleTime: 0 } },
  });
  return function Wrapper({ children }: { children: React.ReactNode }) {
    return (
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    );
  };
}

function renderPalette(open = true) {
  const onClose = vi.fn();
  const result = render(<CommandPalette open={open} onClose={onClose} />, {
    wrapper: createWrapper(),
  });
  return { onClose, ...result };
}

// ─── Stubs ──────────────────────────────────────────────────────────────────

beforeEach(() => {
  HTMLDialogElement.prototype.showModal = vi.fn();
  HTMLDialogElement.prototype.close = vi.fn();
  Element.prototype.scrollIntoView = vi.fn();
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("CommandPalette", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("calls showModal when open is true", () => {
    renderPalette(true);
    expect(HTMLDialogElement.prototype.showModal).toHaveBeenCalled();
  });

  it("does not call showModal when open is false", () => {
    renderPalette(false);
    expect(HTMLDialogElement.prototype.showModal).not.toHaveBeenCalled();
  });

  it("renders navigation items", () => {
    renderPalette();
    expect(screen.getByText("Go to Dashboard")).toBeTruthy();
    expect(screen.getByText("Search Products")).toBeTruthy();
    expect(screen.getByText("Scan Barcode")).toBeTruthy();
    expect(screen.getByText("My Lists")).toBeTruthy();
    expect(screen.getByText("Browse Categories")).toBeTruthy();
    expect(screen.getByText("Compare Products")).toBeTruthy();
    expect(screen.getByText("Settings")).toBeTruthy();
  });

  it("renders search input with placeholder", () => {
    renderPalette();
    expect(screen.getByPlaceholderText("Search or jump to…")).toBeTruthy();
  });

  it("renders navigation section label", () => {
    renderPalette();
    expect(screen.getByText("Navigation")).toBeTruthy();
  });

  it("filters items by query", () => {
    renderPalette();
    const input = screen.getByPlaceholderText("Search or jump to…");
    fireEvent.change(input, { target: { value: "dashboard" } });
    expect(screen.getByText("Go to Dashboard")).toBeTruthy();
    // Other items should be filtered out
    expect(screen.queryByText("Search Products")).toBeNull();
    expect(screen.queryByText("Settings")).toBeNull();
  });

  it("shows search fallback for unmatched query", () => {
    renderPalette();
    const input = screen.getByPlaceholderText("Search or jump to…");
    fireEvent.change(input, { target: { value: "zzzzzzz" } });
    // When no nav items match, a "Search for …" fallback is added
    expect(screen.getByText("Search for 'zzzzzzz'")).toBeTruthy();
  });

  it("navigates on item click", () => {
    renderPalette();
    fireEvent.click(screen.getByText("Go to Dashboard"));
    expect(mockPush).toHaveBeenCalledWith("/app");
  });

  it("calls onClose on item click", () => {
    const { onClose } = renderPalette();
    fireEvent.click(screen.getByText("Go to Dashboard"));
    expect(onClose).toHaveBeenCalledTimes(1);
  });

  it("navigates to correct path for each nav item", () => {
    renderPalette();

    const items: [string, string][] = [
      ["Go to Dashboard", "/app"],
      ["Search Products", "/app/search"],
      ["Scan Barcode", "/app/scan"],
      ["My Lists", "/app/lists"],
      ["Browse Categories", "/app/categories"],
      ["Compare Products", "/app/compare"],
      ["Settings", "/app/settings"],
    ];

    for (const [label, path] of items) {
      mockPush.mockClear();
      fireEvent.click(screen.getByText(label));
      expect(mockPush).toHaveBeenCalledWith(path);
    }
  });

  it("supports ArrowDown keyboard navigation", () => {
    renderPalette();
    const input = screen.getByPlaceholderText("Search or jump to…");

    // First item is active by default
    const firstButton = screen.getByText("Go to Dashboard").closest("button");
    expect(firstButton!.getAttribute("data-active")).toBe("true");

    // Arrow down moves to next item
    fireEvent.keyDown(input, { key: "ArrowDown" });
    const secondButton = screen.getByText("Search Products").closest("button");
    expect(secondButton!.getAttribute("data-active")).toBe("true");
  });

  it("supports ArrowUp keyboard navigation", () => {
    renderPalette();
    const input = screen.getByPlaceholderText("Search or jump to…");

    // Move down first, then up
    fireEvent.keyDown(input, { key: "ArrowDown" });
    fireEvent.keyDown(input, { key: "ArrowUp" });
    const firstButton = screen.getByText("Go to Dashboard").closest("button");
    expect(firstButton!.getAttribute("data-active")).toBe("true");
  });

  it("selects item on Enter", () => {
    renderPalette();
    const input = screen.getByPlaceholderText("Search or jump to…");
    fireEvent.keyDown(input, { key: "Enter" });
    expect(mockPush).toHaveBeenCalledWith("/app");
  });

  it("calls onClose on backdrop click", () => {
    const { onClose } = renderPalette();
    const dialog = document.querySelector("dialog");
    fireEvent.click(dialog!);
    expect(onClose).toHaveBeenCalledTimes(1);
  });

  it("does not call onClose when clicking inside the dialog content", () => {
    const { onClose } = renderPalette();
    fireEvent.click(screen.getByText("Navigation"));
    expect(onClose).not.toHaveBeenCalled();
  });

  it("renders ESC kbd indicator", () => {
    renderPalette();
    expect(screen.getByText("ESC")).toBeTruthy();
  });
});
