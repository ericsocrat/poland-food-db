import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ShareComparison } from "./ShareComparison";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockMutate = vi.fn();

vi.mock("@/hooks/use-compare", () => ({
  useSaveComparison: () => ({
    mutate: mockMutate,
    isPending: false,
  }),
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return function Wrapper({ children }: { children: React.ReactNode }) {
    return (
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    );
  };
}

function renderComponent(props?: { existingShareToken?: string }) {
  return render(<ShareComparison productIds={[1, 2, 3]} {...props} />, {
    wrapper: createWrapper(),
  });
}

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ShareComparison", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    // Mock clipboard API
    Object.assign(navigator, {
      clipboard: { writeText: vi.fn().mockResolvedValue(undefined) },
    });
  });

  it("renders copy URL and save buttons when no existing token", () => {
    renderComponent();
    expect(screen.getByText("Copy URL")).toBeTruthy();
    expect(screen.getByText("Save Comparison")).toBeTruthy();
  });

  it("copies URL to clipboard on copy URL click", async () => {
    renderComponent();
    fireEvent.click(screen.getByText("Copy URL"));
    expect(navigator.clipboard.writeText).toHaveBeenCalledWith(
      expect.stringContaining("ids=1,2,3"),
    );
  });

  it("calls save mutation on save click", () => {
    renderComponent();
    fireEvent.click(screen.getByText("Save Comparison"));
    expect(mockMutate).toHaveBeenCalledWith(
      { productIds: [1, 2, 3] },
      expect.objectContaining({ onSuccess: expect.any(Function) }),
    );
  });

  it("renders share link button when existing token provided", () => {
    renderComponent({ existingShareToken: "tok-abc" });
    expect(screen.getByText("Copy Share Link")).toBeTruthy();
    // Save button should not appear when we already have a token
    expect(screen.queryByText("Save Comparison")).toBeNull();
  });

  it("copies share link on share link button click", async () => {
    renderComponent({ existingShareToken: "tok-abc" });
    fireEvent.click(screen.getByText("Copy Share Link"));
    expect(navigator.clipboard.writeText).toHaveBeenCalledWith(
      expect.stringContaining("/compare/shared/tok-abc"),
    );
  });

  it("shows copied feedback after copy", async () => {
    renderComponent();
    fireEvent.click(screen.getByText("Copy URL"));
    await waitFor(() => {
      // Check icon + "Copied!" text (Lucide Check replaces ✓)
      expect(screen.getByText("Copied!")).toBeTruthy();
    });
  });
});
