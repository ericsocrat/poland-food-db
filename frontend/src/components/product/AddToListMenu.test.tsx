import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { AddToListMenu } from "./AddToListMenu";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockAddMutate = vi.fn();
const mockRemoveMutate = vi.fn();
const mockMembership =
  vi.fn<() => { data: { list_ids: number[] } | undefined }>();
const mockListsData =
  vi.fn<
    () => {
      data:
        | { lists: Array<{ id: number; name: string; list_type: string }> }
        | undefined;
    }
  >();

vi.mock("@/hooks/use-lists", () => ({
  useLists: () => mockListsData(),
  useAddToList: () => ({ mutate: mockAddMutate, isPending: false }),
  useRemoveFromList: () => ({ mutate: mockRemoveMutate, isPending: false }),
  useProductListMembership: () => mockMembership(),
}));

const mockIsFavorite = vi.fn<(id: number) => boolean>().mockReturnValue(false);
vi.mock("@/stores/favorites-store", () => ({
  useFavoritesStore: (
    selector: (s: { isFavorite: (id: number) => boolean }) => unknown,
  ) => selector({ isFavorite: mockIsFavorite }),
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

const LISTS = [
  { id: 1, name: "Favorites", list_type: "favorites" },
  { id: 2, name: "Avoid", list_type: "avoid" },
  { id: 3, name: "Groceries", list_type: "custom" },
];

function createWrapper() {
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={client}>{children}</QueryClientProvider>
  );
}

beforeEach(() => {
  vi.clearAllMocks();
  mockListsData.mockReturnValue({ data: { lists: LISTS } });
  mockMembership.mockReturnValue({ data: { list_ids: [] } });
});

// ─── Compact mode ───────────────────────────────────────────────────────────

describe("AddToListMenu — compact mode", () => {
  it("renders heart icon for non-favorite", () => {
    mockIsFavorite.mockReturnValue(false);
    render(<AddToListMenu productId={42} compact />, {
      wrapper: createWrapper(),
    });
    expect(
      screen.getByRole("button", { name: "Add to Favorites" }),
    ).toHaveTextContent("🤍");
  });

  it("renders filled heart for favorite", () => {
    mockIsFavorite.mockReturnValue(true);
    render(<AddToListMenu productId={42} compact />, {
      wrapper: createWrapper(),
    });
    expect(
      screen.getByRole("button", { name: "Remove from Favorites" }),
    ).toHaveTextContent("❤️");
  });

  it("calls addMutate when toggling on", () => {
    mockIsFavorite.mockReturnValue(false);
    render(<AddToListMenu productId={42} compact />, {
      wrapper: createWrapper(),
    });
    fireEvent.click(screen.getByRole("button", { name: "Add to Favorites" }));
    expect(mockAddMutate).toHaveBeenCalledWith({
      listId: 1,
      productId: 42,
      listType: "favorites",
    });
  });

  it("calls removeMutate when toggling off", () => {
    mockIsFavorite.mockReturnValue(true);
    render(<AddToListMenu productId={42} compact />, {
      wrapper: createWrapper(),
    });
    fireEvent.click(
      screen.getByRole("button", { name: "Remove from Favorites" }),
    );
    expect(mockRemoveMutate).toHaveBeenCalledWith({
      listId: 1,
      productId: 42,
      listType: "favorites",
    });
  });
});

// ─── Full dropdown mode ─────────────────────────────────────────────────────

describe("AddToListMenu — dropdown mode", () => {
  it("renders add-to-list button", () => {
    render(<AddToListMenu productId={42} />, {
      wrapper: createWrapper(),
    });
    expect(
      screen.getByRole("button", { name: "Add to list" }),
    ).toBeInTheDocument();
  });

  it("opens dropdown on click", () => {
    render(<AddToListMenu productId={42} />, {
      wrapper: createWrapper(),
    });
    fireEvent.click(screen.getByRole("button", { name: "Add to list" }));
    expect(screen.getByRole("menu")).toBeInTheDocument();
    expect(screen.getByText("Favorites")).toBeInTheDocument();
    expect(screen.getByText("Avoid")).toBeInTheDocument();
    expect(screen.getByText("Groceries")).toBeInTheDocument();
  });

  it("toggles dropdown closed on second click", () => {
    render(<AddToListMenu productId={42} />, {
      wrapper: createWrapper(),
    });
    const btn = screen.getByRole("button", { name: "Add to list" });
    fireEvent.click(btn);
    expect(screen.getByRole("menu")).toBeInTheDocument();
    fireEvent.click(btn);
    expect(screen.queryByRole("menu")).not.toBeInTheDocument();
  });

  it("shows 'No lists yet' when empty", () => {
    mockListsData.mockReturnValue({ data: { lists: [] } });
    render(<AddToListMenu productId={42} />, {
      wrapper: createWrapper(),
    });
    fireEvent.click(screen.getByRole("button", { name: "Add to list" }));
    expect(screen.getByText("No lists yet")).toBeInTheDocument();
  });

  it("calls addMutate when clicking a list", () => {
    render(<AddToListMenu productId={42} />, {
      wrapper: createWrapper(),
    });
    fireEvent.click(screen.getByRole("button", { name: "Add to list" }));
    fireEvent.click(screen.getByText("Groceries"));
    expect(mockAddMutate).toHaveBeenCalledWith({
      listId: 3,
      productId: 42,
      listType: "custom",
    });
  });

  it("calls removeMutate for in-list product", () => {
    mockMembership.mockReturnValue({ data: { list_ids: [3] } });
    render(<AddToListMenu productId={42} />, {
      wrapper: createWrapper(),
    });
    fireEvent.click(screen.getByRole("button", { name: "Add to list" }));
    // Product is in Groceries → shows "remove"
    expect(screen.getByText("remove")).toBeInTheDocument();
    fireEvent.click(screen.getByText("Groceries"));
    expect(mockRemoveMutate).toHaveBeenCalledWith({
      listId: 3,
      productId: 42,
      listType: "custom",
    });
  });

  it("sets aria-expanded correctly", () => {
    render(<AddToListMenu productId={42} />, {
      wrapper: createWrapper(),
    });
    const btn = screen.getByRole("button", { name: "Add to list" });
    expect(btn).toHaveAttribute("aria-expanded", "false");
    fireEvent.click(btn);
    expect(btn).toHaveAttribute("aria-expanded", "true");
  });

  it("closes on outside click", async () => {
    render(
      <div>
        <p>Outside</p>
        <AddToListMenu productId={42} />
      </div>,
      { wrapper: createWrapper() },
    );
    fireEvent.click(screen.getByRole("button", { name: "Add to list" }));
    expect(screen.getByRole("menu")).toBeInTheDocument();

    fireEvent.mouseDown(screen.getByText("Outside"));
    await waitFor(() => {
      expect(screen.queryByRole("menu")).not.toBeInTheDocument();
    });
  });
});
