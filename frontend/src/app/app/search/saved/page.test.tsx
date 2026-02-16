import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import SavedSearchesPage from "./page";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

const mockPush = vi.fn();
vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: mockPush }),
}));

vi.mock("next/link", () => ({
  default: ({
    href,
    children,
  }: {
    href: string;
    children: React.ReactNode;
  }) => <a href={href}>{children}</a>,
}));

const mockGetSavedSearches = vi.fn();
const mockDeleteSavedSearch = vi.fn();
vi.mock("@/lib/api", () => ({
  getSavedSearches: (...args: unknown[]) => mockGetSavedSearches(...args),
  deleteSavedSearch: (...args: unknown[]) => mockDeleteSavedSearch(...args),
}));

vi.mock("@/components/common/LoadingSpinner", () => ({
  LoadingSpinner: () => <div data-testid="spinner">Loading…</div>,
}));

vi.mock("@/components/common/ConfirmDialog", () => ({
  ConfirmDialog: ({
    open,
    onConfirm,
    onCancel,
    title,
  }: {
    open: boolean;
    onConfirm: () => void;
    onCancel: () => void;
    title: string;
  }) =>
    open ? (
      <div data-testid="confirm-dialog">
        <p>{title}</p>
        <button onClick={onConfirm}>Confirm</button>
        <button onClick={onCancel}>Cancel Dialog</button>
      </div>
    ) : null,
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

function Wrapper({ children }: Readonly<{ children: React.ReactNode }>) {
  const [client] = useState(
    () =>
      new QueryClient({
        defaultOptions: { queries: { retry: false, staleTime: 0 } },
      }),
  );
  return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
}

function createWrapper() {
  return Wrapper;
}

const mockSearches = [
  {
    id: "s1",
    name: "Healthy drinks",
    query: "juice",
    filters: {
      category: ["drinks"],
      nutri_score: ["A", "B"],
      allergen_free: ["en:gluten"],
      max_unhealthiness: 40,
      sort_by: "unhealthiness" as const,
    },
    created_at: "2025-02-01T00:00:00Z",
  },
  {
    id: "s2",
    name: "Browse all",
    query: null,
    filters: {},
    created_at: "2025-01-15T00:00:00Z",
  },
];

beforeEach(() => {
  vi.clearAllMocks();
  mockGetSavedSearches.mockResolvedValue({
    ok: true,
    data: { searches: mockSearches },
  });
  mockDeleteSavedSearch.mockResolvedValue({
    ok: true,
    data: { success: true },
  });
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("SavedSearchesPage", () => {
  it("renders page title and subtitle", async () => {
    render(<SavedSearchesPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("📋 Saved Searches")).toBeInTheDocument();
    });
    expect(
      screen.getByText("Your saved search configurations"),
    ).toBeInTheDocument();
  });

  it("links back to search page", async () => {
    render(<SavedSearchesPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("← Back to Search")).toBeInTheDocument();
    });
    expect(screen.getByText("← Back to Search").closest("a")).toHaveAttribute(
      "href",
      "/app/search",
    );
  });

  it("shows loading spinner", () => {
    mockGetSavedSearches.mockReturnValue(new Promise(() => {}));
    render(<SavedSearchesPage />, { wrapper: createWrapper() });
    expect(screen.getByTestId("spinner")).toBeInTheDocument();
  });

  it("shows error state with retry button", async () => {
    mockGetSavedSearches.mockResolvedValue({
      ok: false,
      error: { message: "Server error" },
    });
    render(<SavedSearchesPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(
        screen.getByText("Failed to load saved searches."),
      ).toBeInTheDocument();
    });
    expect(screen.getByText("🔄 Retry")).toBeInTheDocument();
  });

  it("shows empty state when no saved searches", async () => {
    mockGetSavedSearches.mockResolvedValue({
      ok: true,
      data: { searches: [] },
    });
    render(<SavedSearchesPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("No saved searches yet")).toBeInTheDocument();
    });
    expect(screen.getByText("Go to Search →").closest("a")).toHaveAttribute(
      "href",
      "/app/search",
    );
  });

  it("renders saved search names", async () => {
    render(<SavedSearchesPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Healthy drinks")).toBeInTheDocument();
    });
    expect(screen.getByText("Browse all")).toBeInTheDocument();
  });

  it("shows query text when present", async () => {
    render(<SavedSearchesPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText(/juice/)).toBeInTheDocument();
    });
  });

  it("shows browse mode label when no query", async () => {
    render(<SavedSearchesPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Browse mode")).toBeInTheDocument();
    });
  });

  it("renders filter summary chips", async () => {
    render(<SavedSearchesPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("1 categories")).toBeInTheDocument();
    });
    expect(screen.getByText("Nutri: A, B")).toBeInTheDocument();
    expect(screen.getByText(/Free:.*Gluten/)).toBeInTheDocument();
    expect(screen.getByText("Score ≤ 40")).toBeInTheDocument();
    expect(screen.getByText("Sort: unhealthiness")).toBeInTheDocument();
  });

  it("navigates to search URL on Apply click", async () => {
    render(<SavedSearchesPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("Healthy drinks")).toBeInTheDocument();
    });

    const applyButtons = screen.getAllByText("Apply");
    await user.click(applyButtons[0]);

    expect(mockPush).toHaveBeenCalledWith(
      expect.stringContaining("/app/search?"),
    );
    expect(mockPush).toHaveBeenCalledWith(expect.stringContaining("q=juice"));
  });

  it("navigates when clicking on search card", async () => {
    render(<SavedSearchesPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("Healthy drinks")).toBeInTheDocument();
    });

    await user.click(screen.getByText("Healthy drinks"));
    expect(mockPush).toHaveBeenCalled();
  });

  it("opens confirm dialog before deleting", async () => {
    render(<SavedSearchesPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("Healthy drinks")).toBeInTheDocument();
    });

    const deleteButtons = screen.getAllByText("🗑️");
    await user.click(deleteButtons[0]);
    expect(screen.getByTestId("confirm-dialog")).toBeInTheDocument();
    expect(screen.getByText("Delete saved search?")).toBeInTheDocument();
  });

  it("cancels delete dialog", async () => {
    render(<SavedSearchesPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("Healthy drinks")).toBeInTheDocument();
    });

    const deleteButtons = screen.getAllByText("🗑️");
    await user.click(deleteButtons[0]);
    await user.click(screen.getByText("Cancel Dialog"));
    expect(screen.queryByTestId("confirm-dialog")).not.toBeInTheDocument();
  });
});
