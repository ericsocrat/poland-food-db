import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import ListsPage from "./page";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockUseLists = vi.fn();
const mockCreateMutate = vi.fn();
const mockDeleteMutate = vi.fn();
const mockUseListPreview = vi.fn();

vi.mock("@/hooks/use-lists", () => ({
  useLists: () => mockUseLists(),
  useCreateList: () => ({ mutate: mockCreateMutate, isPending: false }),
  useDeleteList: () => ({ mutate: mockDeleteMutate }),
  useListPreview: (...args: unknown[]) => mockUseListPreview(...args),
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

vi.mock("@/components/common/skeletons", () => ({
  ListViewSkeleton: () => (
    <div data-testid="skeleton" role="status" aria-busy="true" />
  ),
}));

// Stub ConfirmDialog to make testing easy
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

const mockLists = [
  {
    id: "fav-1",
    name: "Favorites",
    description: null,
    list_type: "favorites",
    is_default: true,
    share_enabled: false,
    share_token: null,
    item_count: 5,
    created_at: "2025-01-01T00:00:00Z",
    updated_at: "2025-01-01T00:00:00Z",
  },
  {
    id: "avoid-1",
    name: "Avoid",
    description: null,
    list_type: "avoid",
    is_default: true,
    share_enabled: false,
    share_token: null,
    item_count: 2,
    created_at: "2025-01-01T00:00:00Z",
    updated_at: "2025-01-01T00:00:00Z",
  },
  {
    id: "custom-1",
    name: "Healthy Snacks",
    description: "My healthy picks",
    list_type: "custom",
    is_default: false,
    share_enabled: true,
    share_token: "tok-share",
    item_count: 1,
    created_at: "2025-01-01T00:00:00Z",
    updated_at: "2025-01-01T00:00:00Z",
  },
];

const mockPreviewItems = [
  {
    item_id: "item-1",
    product_id: 101,
    position: 1,
    notes: null,
    added_at: "2025-01-01T00:00:00Z",
    product_name: "Lay's Classic",
    brand: "Lay's",
    category: "chips",
    unhealthiness_score: 65,
    nutri_score_label: "D",
    nova_classification: "4",
    calories: 536,
  },
  {
    item_id: "item-2",
    product_id: 102,
    position: 2,
    notes: null,
    added_at: "2025-01-01T00:00:00Z",
    product_name: "Oat Bar",
    brand: "Nature Valley",
    category: "cereals",
    unhealthiness_score: 25,
    nutri_score_label: "B",
    nova_classification: "3",
    calories: 200,
  },
  {
    item_id: "item-3",
    product_id: 103,
    position: 3,
    notes: null,
    added_at: "2025-01-01T00:00:00Z",
    product_name: "Cola Zero",
    brand: "Coca-Cola",
    category: "drinks",
    unhealthiness_score: 30,
    nutri_score_label: "C",
    nova_classification: "4",
    calories: 0,
  },
];

beforeEach(() => {
  vi.clearAllMocks();
  mockUseLists.mockReturnValue({
    data: { lists: mockLists },
    isLoading: false,
    error: null,
  });
  // Default: return preview items for fav-1 (5 items), empty for others
  mockUseListPreview.mockImplementation((listId: string, itemCount: number) => {
    if (listId === "fav-1" && itemCount > 0) {
      return {
        data: { items: mockPreviewItems },
        isLoading: false,
        error: null,
      };
    }
    return { data: undefined, isLoading: false, error: null };
  });
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ListsPage", () => {
  it("renders page title", () => {
    render(<ListsPage />, { wrapper: createWrapper() });
    expect(screen.getByText("My Lists")).toBeInTheDocument();
  });

  it("shows skeleton loading state", () => {
    mockUseLists.mockReturnValue({
      data: undefined,
      isLoading: true,
      error: null,
    });
    render(<ListsPage />, { wrapper: createWrapper() });
    expect(screen.getByTestId("skeleton")).toBeInTheDocument();
  });

  it("shows error state", () => {
    mockUseLists.mockReturnValue({
      data: undefined,
      isLoading: false,
      error: new Error("Oops"),
    });
    render(<ListsPage />, { wrapper: createWrapper() });
    expect(screen.getByText("Failed to load lists.")).toBeInTheDocument();
  });

  it("shows empty state when no lists", () => {
    mockUseLists.mockReturnValue({
      data: { lists: [] },
      isLoading: false,
      error: null,
    });
    render(<ListsPage />, { wrapper: createWrapper() });
    expect(screen.getByText(/No lists yet/)).toBeInTheDocument();
  });

  it("renders list cards with names and icons", () => {
    const { container } = render(<ListsPage />, { wrapper: createWrapper() });
    expect(screen.getByText("Favorites")).toBeInTheDocument();
    expect(screen.getByText("Avoid")).toBeInTheDocument();
    expect(screen.getByText("Healthy Snacks")).toBeInTheDocument();
    // Type icons
    // List type icons are now Lucide SVGs
    const svgs = container.querySelectorAll("svg");
    expect(svgs.length).toBeGreaterThanOrEqual(3);
  });

  it("shows correct item counts with singular/plural", () => {
    render(<ListsPage />, { wrapper: createWrapper() });
    expect(screen.getByText(/5 item\(s\)/)).toBeInTheDocument();
    expect(screen.getByText(/2 item\(s\)/)).toBeInTheDocument();
    expect(screen.getByText(/1 item\(s\)/)).toBeInTheDocument();
  });

  it("shows shared badge for shared lists", () => {
    render(<ListsPage />, { wrapper: createWrapper() });
    expect(screen.getByText("Shared")).toBeInTheDocument();
  });

  it("links cards to list detail pages", () => {
    render(<ListsPage />, { wrapper: createWrapper() });
    const link = screen.getByText("Favorites").closest("a");
    expect(link).toHaveAttribute("href", "/app/lists/fav-1");
  });

  it("does not show delete button for default lists", () => {
    render(<ListsPage />, { wrapper: createWrapper() });
    // Default lists don't have delete buttons
    expect(screen.queryByLabelText("Delete Favorites")).not.toBeInTheDocument();
    expect(screen.queryByLabelText("Delete Avoid")).not.toBeInTheDocument();
    // Custom list has delete
    expect(screen.getByLabelText("Delete Healthy Snacks")).toBeInTheDocument();
  });

  it("shows confirm dialog when delete clicked and deletes on confirm", async () => {
    render(<ListsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await user.click(screen.getByLabelText("Delete Healthy Snacks"));
    expect(screen.getByTestId("confirm-dialog")).toBeInTheDocument();
    expect(screen.getByText("Delete list?")).toBeInTheDocument();

    await user.click(screen.getByText("Confirm"));
    expect(mockDeleteMutate).toHaveBeenCalledWith("custom-1");
  });

  it("cancels confirm dialog", async () => {
    render(<ListsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await user.click(screen.getByLabelText("Delete Healthy Snacks"));
    await user.click(screen.getByText("Cancel Dialog"));
    expect(screen.queryByTestId("confirm-dialog")).not.toBeInTheDocument();
  });

  it("toggles create form visibility", async () => {
    render(<ListsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    expect(screen.queryByPlaceholderText("List name")).not.toBeInTheDocument();

    await user.click(screen.getByText("+ New List"));
    expect(screen.getByPlaceholderText("List name")).toBeInTheDocument();
    expect(
      screen.getByPlaceholderText("Description (optional)"),
    ).toBeInTheDocument();

    // Toggle back — the header button now says "Cancel" too
    const cancelButtons = screen.getAllByText("Cancel");
    await user.click(cancelButtons[0]);
    expect(screen.queryByPlaceholderText("List name")).not.toBeInTheDocument();
  });

  it("disables create button when name is empty", async () => {
    render(<ListsPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await user.click(screen.getByText("+ New List"));
    expect(screen.getByRole("button", { name: "Create List" })).toBeDisabled();
  });

  it("shows description in list card", () => {
    render(<ListsPage />, { wrapper: createWrapper() });
    expect(screen.getByText(/My healthy picks/)).toBeInTheDocument();
  });

  it("renders responsive grid layout for list cards", () => {
    render(<ListsPage />, { wrapper: createWrapper() });

    const grid = screen.getByText("Favorites").closest("a")!.parentElement!;
    expect(grid.className).toContain("grid");
    expect(grid.className).toContain("md:grid-cols-2");
    expect(grid.className).toContain("xl:grid-cols-3");
  });

  it("list cards have transition classes for hover states", () => {
    render(<ListsPage />, { wrapper: createWrapper() });

    const card = screen.getByText("Favorites").closest(".card")!;
    expect(card.className).toContain("transition-all");
    expect(card.className).toContain("duration-fast");
  });

  // ── Preview thumbnails & health summary (§3.3) ───────────────────────────

  it("renders preview thumbnails with score badges", () => {
    render(<ListsPage />, { wrapper: createWrapper() });
    const previews = screen.getAllByTestId("list-preview");
    expect(previews.length).toBeGreaterThanOrEqual(1);

    const thumbs = screen.getAllByTestId("preview-thumbnails");
    expect(thumbs.length).toBeGreaterThanOrEqual(1);

    // Check the first preview has 3 score badges (matching mock data)
    const favPreview = previews[0];
    expect(favPreview).toHaveTextContent("65");
    expect(favPreview).toHaveTextContent("25");
    expect(favPreview).toHaveTextContent("30");
  });

  it("shows overflow count when list has more items than previewed", () => {
    render(<ListsPage />, { wrapper: createWrapper() });
    // fav-1 has item_count=5, preview has 3 items → "+2"
    const overflow = screen.getByTestId("preview-overflow");
    expect(overflow).toHaveTextContent("+2");
  });

  it("shows average score badge for lists with preview items", () => {
    render(<ListsPage />, { wrapper: createWrapper() });
    // Avg of 65 + 25 + 30 = 120 / 3 = 40
    const avgBadge = screen.getByTestId("list-avg-score");
    expect(avgBadge).toHaveTextContent("Avg 40");
  });

  it("does not show preview for empty lists", () => {
    mockUseLists.mockReturnValue({
      data: {
        lists: [
          {
            ...mockLists[0],
            id: "empty-list",
            item_count: 0,
          },
        ],
      },
      isLoading: false,
      error: null,
    });
    mockUseListPreview.mockReturnValue({
      data: undefined,
      isLoading: false,
      error: null,
    });
    render(<ListsPage />, { wrapper: createWrapper() });
    expect(screen.queryByTestId("list-preview")).not.toBeInTheDocument();
  });

  it("does not show preview when preview data is loading", () => {
    mockUseListPreview.mockReturnValue({
      data: undefined,
      isLoading: true,
      error: null,
    });
    render(<ListsPage />, { wrapper: createWrapper() });
    expect(screen.queryByTestId("list-preview")).not.toBeInTheDocument();
  });

  it("preview score badges have correct title attributes", () => {
    render(<ListsPage />, { wrapper: createWrapper() });
    expect(screen.getByTitle("Lay's Classic")).toBeInTheDocument();
    expect(screen.getByTitle("Oat Bar")).toBeInTheDocument();
    expect(screen.getByTitle("Cola Zero")).toBeInTheDocument();
  });
});
