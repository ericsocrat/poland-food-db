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

vi.mock("@/hooks/use-lists", () => ({
  useLists: () => mockUseLists(),
  useCreateList: () => ({ mutate: mockCreateMutate, isPending: false }),
  useDeleteList: () => ({ mutate: mockDeleteMutate }),
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

vi.mock("@/components/common/LoadingSpinner", () => ({
  LoadingSpinner: () => <div data-testid="spinner">Loading…</div>,
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

beforeEach(() => {
  vi.clearAllMocks();
  mockUseLists.mockReturnValue({
    data: { lists: mockLists },
    isLoading: false,
    error: null,
  });
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ListsPage", () => {
  it("renders page title", () => {
    render(<ListsPage />, { wrapper: createWrapper() });
    expect(screen.getByText("📋 My Lists")).toBeInTheDocument();
  });

  it("shows loading spinner", () => {
    mockUseLists.mockReturnValue({
      data: undefined,
      isLoading: true,
      error: null,
    });
    render(<ListsPage />, { wrapper: createWrapper() });
    expect(screen.getByTestId("spinner")).toBeInTheDocument();
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
    render(<ListsPage />, { wrapper: createWrapper() });
    expect(screen.getByText("Favorites")).toBeInTheDocument();
    expect(screen.getByText("Avoid")).toBeInTheDocument();
    expect(screen.getByText("Healthy Snacks")).toBeInTheDocument();
    // Type icons
    expect(screen.getByText("❤️")).toBeInTheDocument();
    expect(screen.getByText("🚫")).toBeInTheDocument();
    expect(screen.getByText("📝")).toBeInTheDocument();
  });

  it("shows correct item counts with singular/plural", () => {
    render(<ListsPage />, { wrapper: createWrapper() });
    expect(screen.getByText(/5 items/)).toBeInTheDocument();
    expect(screen.getByText(/2 items/)).toBeInTheDocument();
    expect(screen.getByText(/1 item(?!s)/)).toBeInTheDocument();
  });

  it("shows shared badge for shared lists", () => {
    render(<ListsPage />, { wrapper: createWrapper() });
    expect(screen.getByText("🔗 Shared")).toBeInTheDocument();
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
});
