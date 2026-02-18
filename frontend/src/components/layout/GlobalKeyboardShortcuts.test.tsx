import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, fireEvent } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { GlobalKeyboardShortcuts } from "./GlobalKeyboardShortcuts";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockPush = vi.fn();
let mockPathname = "/app";

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: mockPush }),
  usePathname: () => mockPathname,
}));

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

vi.mock("@/lib/api", () => ({
  getRecentlyViewed: () =>
    Promise.resolve({ ok: true, data: { products: [] } }),
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

function renderShortcuts() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, staleTime: 0 } },
  });
  return render(
    <QueryClientProvider client={queryClient}>
      <GlobalKeyboardShortcuts />
    </QueryClientProvider>,
  );
}

// ─── Stubs ──────────────────────────────────────────────────────────────────

beforeEach(() => {
  HTMLDialogElement.prototype.showModal = vi.fn();
  HTMLDialogElement.prototype.close = vi.fn();
  Element.prototype.scrollIntoView = vi.fn();
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("GlobalKeyboardShortcuts", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockPathname = "/app";
  });

  // ─── / key (search) ──────────────────────────────────────────────

  it("navigates to /app/search when / is pressed", () => {
    renderShortcuts();
    fireEvent.keyDown(document, { key: "/" });
    expect(mockPush).toHaveBeenCalledWith("/app/search");
  });

  it("focuses input instead of navigating when already on search page", () => {
    mockPathname = "/app/search";
    const input = document.createElement("input");
    input.type = "text";
    input.setAttribute("aria-label", "Search");
    document.body.appendChild(input);

    renderShortcuts();
    fireEvent.keyDown(document, { key: "/" });

    expect(mockPush).not.toHaveBeenCalled();
    expect(document.activeElement).toBe(input);

    document.body.removeChild(input);
  });

  it("does not trigger when typing in an input", () => {
    renderShortcuts();
    const input = document.createElement("input");
    document.body.appendChild(input);

    fireEvent.keyDown(input, { key: "/" });
    expect(mockPush).not.toHaveBeenCalled();

    document.body.removeChild(input);
  });

  it("does not trigger when typing in a textarea", () => {
    renderShortcuts();
    const textarea = document.createElement("textarea");
    document.body.appendChild(textarea);

    fireEvent.keyDown(textarea, { key: "/" });
    expect(mockPush).not.toHaveBeenCalled();

    document.body.removeChild(textarea);
  });

  // ─── H key (dashboard) ───────────────────────────────────────────

  it("navigates to /app when H is pressed", () => {
    renderShortcuts();
    fireEvent.keyDown(document, { key: "H" });
    expect(mockPush).toHaveBeenCalledWith("/app");
  });

  it("navigates to /app when h is pressed (lowercase)", () => {
    renderShortcuts();
    fireEvent.keyDown(document, { key: "h" });
    expect(mockPush).toHaveBeenCalledWith("/app");
  });

  // ─── L key (lists) ───────────────────────────────────────────────

  it("navigates to /app/lists when L is pressed", () => {
    renderShortcuts();
    fireEvent.keyDown(document, { key: "L" });
    expect(mockPush).toHaveBeenCalledWith("/app/lists");
  });

  // ─── S key (scanner) ─────────────────────────────────────────────

  it("navigates to /app/scan when S is pressed", () => {
    renderShortcuts();
    fireEvent.keyDown(document, { key: "S" });
    expect(mockPush).toHaveBeenCalledWith("/app/scan");
  });

  // ─── Ctrl+K (command palette) ─────────────────────────────────────

  it("opens command palette on Ctrl+K", () => {
    renderShortcuts();
    fireEvent.keyDown(document, { key: "k", ctrlKey: true });
    expect(HTMLDialogElement.prototype.showModal).toHaveBeenCalled();
  });

  it("opens command palette on Meta+K (Mac)", () => {
    renderShortcuts();
    fireEvent.keyDown(document, { key: "k", metaKey: true });
    expect(HTMLDialogElement.prototype.showModal).toHaveBeenCalled();
  });

  it("Ctrl+K works even when typing in an input", () => {
    renderShortcuts();
    const input = document.createElement("input");
    document.body.appendChild(input);

    fireEvent.keyDown(input, { key: "k", ctrlKey: true });
    expect(HTMLDialogElement.prototype.showModal).toHaveBeenCalled();

    document.body.removeChild(input);
  });

  // ─── ? key (shortcuts help) ──────────────────────────────────────

  it("opens shortcuts help on ? key", () => {
    renderShortcuts();
    fireEvent.keyDown(document, { key: "?" });
    // When shortcuts open, showModal is called for the shortcuts dialog
    expect(HTMLDialogElement.prototype.showModal).toHaveBeenCalled();
  });

  // ─── input guard ─────────────────────────────────────────────────

  it("does not trigger single-key shortcuts when typing in an input", () => {
    renderShortcuts();
    const input = document.createElement("input");
    document.body.appendChild(input);

    fireEvent.keyDown(input, { key: "H" });
    fireEvent.keyDown(input, { key: "L" });
    fireEvent.keyDown(input, { key: "S" });
    expect(mockPush).not.toHaveBeenCalled();

    document.body.removeChild(input);
  });

  // ─── modifier guard ──────────────────────────────────────────────

  it("does not trigger navigation when modifier keys are held (except Ctrl+K)", () => {
    renderShortcuts();
    fireEvent.keyDown(document, { key: "H", ctrlKey: true });
    fireEvent.keyDown(document, { key: "L", altKey: true });
    expect(mockPush).not.toHaveBeenCalled();
  });
});
