import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import ListDetailPage from "./page";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("next/navigation", () => ({
  useParams: () => ({ id: "list-abc-123" }),
}));

vi.mock("next/link", () => ({
  default: ({
    href,
    children,
    ...rest
  }: {
    href: string;
    children: React.ReactNode;
    className?: string;
  }) => (
    <a href={href} {...rest}>
      {children}
    </a>
  ),
}));

const mockRemoveMutate = vi.fn();
const mockUpdateMutate = vi.fn();
const mockToggleShareMutate = vi.fn();
const mockRevokeMutate = vi.fn();

const mockUseLists = vi.fn();
const mockUseListItems = vi.fn();

vi.mock("@/hooks/use-lists", () => ({
  useLists: () => mockUseLists(),
  useListItems: (id: string) => mockUseListItems(id),
  useRemoveFromList: () => ({
    mutate: mockRemoveMutate,
    isPending: false,
  }),
  useUpdateList: () => ({
    mutate: mockUpdateMutate,
    isPending: false,
  }),
  useToggleShare: () => ({
    mutate: mockToggleShareMutate,
    isPending: false,
  }),
  useRevokeShare: () => ({
    mutate: mockRevokeMutate,
    isPending: false,
  }),
}));

vi.mock("@/components/common/LoadingSpinner", () => ({
  LoadingSpinner: () => <div data-testid="spinner">Loading…</div>,
}));

vi.mock("@/components/common/ConfirmDialog", () => ({
  ConfirmDialog: ({
    open,
    title,
    onConfirm,
    onCancel,
  }: {
    open: boolean;
    title: string;
    onConfirm: () => void;
    onCancel: () => void;
    [key: string]: unknown;
  }) =>
    open ? (
      <div data-testid="confirm-dialog">
        <p>{title}</p>
        <button onClick={onConfirm}>Confirm</button>
        <button onClick={onCancel}>Dialog-Cancel</button>
      </div>
    ) : null,
}));

// ─── Data ───────────────────────────────────────────────────────────────────

const mockList = {
  id: "list-abc-123",
  name: "My Favorites",
  description: "Healthy picks",
  list_type: "favorites" as const,
  is_default: false,
  share_enabled: false,
  share_token: null,
  item_count: 2,
  created_at: "2025-01-01T00:00:00Z",
  updated_at: "2025-01-10T00:00:00Z",
};

const mockItems = [
  {
    item_id: "item-1",
    product_id: 101,
    position: 1,
    notes: "Morning snack",
    added_at: "2025-01-05T12:00:00Z",
    product_name: "Healthy Bar",
    brand: "GoodBrand",
    category: "cereals",
    unhealthiness_score: 18,
    nutri_score_label: "A",
    nova_classification: "1",
    calories: 120,
  },
  {
    item_id: "item-2",
    product_id: 202,
    position: 2,
    notes: null,
    added_at: "2025-01-06T14:00:00Z",
    product_name: "Nice Chips",
    brand: "ChipCo",
    category: "chips",
    unhealthiness_score: 62,
    nutri_score_label: "D",
    nova_classification: "4",
    calories: 540,
  },
];

beforeEach(() => {
  vi.clearAllMocks();
  mockUseLists.mockReturnValue({
    data: { lists: [mockList] },
  });
  mockUseListItems.mockReturnValue({
    data: { items: mockItems },
    isLoading: false,
    error: null,
  });
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ListDetailPage", () => {
  it("shows loading spinner when loading", () => {
    mockUseListItems.mockReturnValue({
      data: undefined,
      isLoading: true,
      error: null,
    });
    render(<ListDetailPage />);
    expect(screen.getByTestId("spinner")).toBeInTheDocument();
  });

  it("shows error state", () => {
    mockUseListItems.mockReturnValue({
      data: undefined,
      isLoading: false,
      error: new Error("fail"),
    });
    render(<ListDetailPage />);
    expect(screen.getByText("Failed to load list.")).toBeInTheDocument();
  });

  it("shows back link", () => {
    render(<ListDetailPage />);
    const link = screen.getByText("← Back to lists");
    expect(link.closest("a")).toHaveAttribute("href", "/app/lists");
  });

  it("renders list name with favorites icon", () => {
    render(<ListDetailPage />);
    expect(screen.getByText(/❤️/)).toBeInTheDocument();
    expect(screen.getByText(/My Favorites/)).toBeInTheDocument();
  });

  it("renders avoid icon for avoid lists", () => {
    mockUseLists.mockReturnValue({
      data: {
        lists: [{ ...mockList, list_type: "avoid", name: "Avoid List" }],
      },
    });
    render(<ListDetailPage />);
    expect(screen.getByText(/🚫/)).toBeInTheDocument();
  });

  it("shows description", () => {
    render(<ListDetailPage />);
    expect(screen.getByText("Healthy picks")).toBeInTheDocument();
  });

  it("shows item count", () => {
    render(<ListDetailPage />);
    expect(screen.getByText("2 item(s)")).toBeInTheDocument();
  });

  it("renders product items", () => {
    render(<ListDetailPage />);
    expect(screen.getByText("Healthy Bar")).toBeInTheDocument();
    expect(screen.getByText("Nice Chips")).toBeInTheDocument();
  });

  it("shows scores on list items", () => {
    render(<ListDetailPage />);
    expect(screen.getByText("18")).toBeInTheDocument();
    expect(screen.getByText("62")).toBeInTheDocument();
  });

  it("shows nutri-score labels", () => {
    render(<ListDetailPage />);
    expect(screen.getByText("A")).toBeInTheDocument();
    expect(screen.getByText("D")).toBeInTheDocument();
  });

  it("shows item notes", () => {
    render(<ListDetailPage />);
    expect(screen.getByText("Morning snack")).toBeInTheDocument();
  });

  it("shows product links", () => {
    render(<ListDetailPage />);
    const links = screen
      .getAllByRole("link")
      .filter((a) => a.getAttribute("href")?.startsWith("/app/product/"));
    expect(links).toHaveLength(2);
    expect(links[0]).toHaveAttribute("href", "/app/product/101");
    expect(links[1]).toHaveAttribute("href", "/app/product/202");
  });

  it("calls remove mutation when clicking remove button", async () => {
    render(<ListDetailPage />);
    const user = userEvent.setup();

    const removeBtn = screen.getByRole("button", {
      name: "Remove Healthy Bar",
    });
    await user.click(removeBtn);

    expect(mockRemoveMutate).toHaveBeenCalledWith(
      expect.objectContaining({
        listId: "list-abc-123",
        productId: 101,
      }),
    );
  });

  it("enters edit mode when clicking edit button", async () => {
    render(<ListDetailPage />);
    const user = userEvent.setup();

    await user.click(screen.getByTitle("Edit list"));

    expect(screen.getByDisplayValue("My Favorites")).toBeInTheDocument();
    expect(screen.getByDisplayValue("Healthy picks")).toBeInTheDocument();
  });

  it("saves edit on form submit", async () => {
    render(<ListDetailPage />);
    const user = userEvent.setup();

    await user.click(screen.getByTitle("Edit list"));

    const nameInput = screen.getByDisplayValue("My Favorites");
    await user.clear(nameInput);
    await user.type(nameInput, "Updated Name");

    await user.click(screen.getByText("Save"));

    expect(mockUpdateMutate).toHaveBeenCalledWith(
      expect.objectContaining({
        listId: "list-abc-123",
        name: "Updated Name",
      }),
      expect.anything(),
    );
  });

  it("cancels edit mode", async () => {
    render(<ListDetailPage />);
    const user = userEvent.setup();

    await user.click(screen.getByTitle("Edit list"));
    expect(screen.getByDisplayValue("My Favorites")).toBeInTheDocument();

    await user.click(screen.getByText("Cancel"));
    // Should be back to display mode
    expect(screen.queryByDisplayValue("My Favorites")).not.toBeInTheDocument();
    expect(screen.getByText(/My Favorites/)).toBeInTheDocument();
  });

  it("opens share panel", async () => {
    render(<ListDetailPage />);
    const user = userEvent.setup();

    await user.click(screen.getByTitle("Share settings"));

    expect(screen.getByText("Sharing")).toBeInTheDocument();
    expect(screen.getByText("Off")).toBeInTheDocument();
  });

  it("toggles share on", async () => {
    render(<ListDetailPage />);
    const user = userEvent.setup();

    await user.click(screen.getByTitle("Share settings"));
    await user.click(screen.getByText("Off"));

    expect(mockToggleShareMutate).toHaveBeenCalledWith({
      listId: "list-abc-123",
      enabled: true,
    });
  });

  it("shows copy link and revoke when sharing enabled", async () => {
    mockUseLists.mockReturnValue({
      data: {
        lists: [
          {
            ...mockList,
            share_enabled: true,
            share_token: "tok-xyz",
          },
        ],
      },
    });
    render(<ListDetailPage />);
    const user = userEvent.setup();

    await user.click(screen.getByTitle("Share settings"));

    expect(screen.getByText("On")).toBeInTheDocument();
    expect(screen.getByText("Copy link")).toBeInTheDocument();
    expect(screen.getByText("Revoke")).toBeInTheDocument();
  });

  it("does not show share button for avoid lists", () => {
    mockUseLists.mockReturnValue({
      data: {
        lists: [{ ...mockList, list_type: "avoid" }],
      },
    });
    render(<ListDetailPage />);
    expect(screen.queryByTitle("Share settings")).not.toBeInTheDocument();
  });

  it("shows empty state when no items", () => {
    mockUseListItems.mockReturnValue({
      data: { items: [] },
      isLoading: false,
      error: null,
    });
    render(<ListDetailPage />);
    expect(screen.getByText(/This list is empty/)).toBeInTheDocument();
    expect(screen.getByText("Search products").closest("a")).toHaveAttribute(
      "href",
      "/app/search",
    );
  });

  it("shows singular item count", () => {
    mockUseLists.mockReturnValue({
      data: { lists: [{ ...mockList, item_count: 1 }] },
    });
    render(<ListDetailPage />);
    expect(screen.getByText("1 item(s)")).toBeInTheDocument();
  });
});
