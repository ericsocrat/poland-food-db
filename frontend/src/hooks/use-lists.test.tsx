import {
    useAddToList,
    useAvoidProductIds,
    useCreateList,
    useDeleteList,
    useFavoriteProductIds,
    useListItems,
    useListPreview,
    useLists,
    useProductListMembership,
    useRemoveFromList,
    useReorderList,
    useRevokeShare,
    useSharedList,
    useToggleShare,
    useUpdateList,
} from "@/hooks/use-lists";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { renderHook, waitFor } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockGetLists = vi.fn();
const mockGetListItems = vi.fn();
const mockGetSharedList = vi.fn();
const mockGetAvoidProductIds = vi.fn();
const mockGetFavoriteProductIds = vi.fn();
const mockGetProductListMembership = vi.fn();
const mockCreateList = vi.fn();
const mockUpdateList = vi.fn();
const mockDeleteList = vi.fn();
const mockAddToList = vi.fn();
const mockRemoveFromList = vi.fn();
const mockReorderList = vi.fn();
const mockToggleShare = vi.fn();
const mockRevokeShare = vi.fn();

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

vi.mock("@/lib/api", () => ({
  getLists: (...args: unknown[]) => mockGetLists(...args),
  getListItems: (...args: unknown[]) => mockGetListItems(...args),
  getSharedList: (...args: unknown[]) => mockGetSharedList(...args),
  getAvoidProductIds: (...args: unknown[]) => mockGetAvoidProductIds(...args),
  getFavoriteProductIds: (...args: unknown[]) =>
    mockGetFavoriteProductIds(...args),
  getProductListMembership: (...args: unknown[]) =>
    mockGetProductListMembership(...args),
  createList: (...args: unknown[]) => mockCreateList(...args),
  updateList: (...args: unknown[]) => mockUpdateList(...args),
  deleteList: (...args: unknown[]) => mockDeleteList(...args),
  addToList: (...args: unknown[]) => mockAddToList(...args),
  removeFromList: (...args: unknown[]) => mockRemoveFromList(...args),
  reorderList: (...args: unknown[]) => mockReorderList(...args),
  toggleShare: (...args: unknown[]) => mockToggleShare(...args),
  revokeShare: (...args: unknown[]) => mockRevokeShare(...args),
}));

const mockSetAvoidedIds = vi.fn();
const mockAddAvoided = vi.fn();
const mockRemoveAvoided = vi.fn();

vi.mock("@/stores/avoid-store", () => ({
  useAvoidStore: (selector: (s: Record<string, unknown>) => unknown) =>
    selector({
      setAvoidedIds: mockSetAvoidedIds,
      addAvoided: mockAddAvoided,
      removeAvoided: mockRemoveAvoided,
    }),
}));

const mockSetFavoriteIds = vi.fn();
const mockAddFavorite = vi.fn();
const mockRemoveFavorite = vi.fn();

vi.mock("@/stores/favorites-store", () => ({
  useFavoritesStore: (selector: (s: Record<string, unknown>) => unknown) =>
    selector({
      setFavoriteIds: mockSetFavoriteIds,
      addFavorite: mockAddFavorite,
      removeFavorite: mockRemoveFavorite,
    }),
}));

const mockTrack = vi.fn();
vi.mock("@/hooks/use-analytics", () => ({
  useAnalytics: () => ({ track: mockTrack }),
}));

const mockEventBusEmit = vi.fn().mockResolvedValue(undefined);
vi.mock("@/lib/events", () => ({
  eventBus: { emit: (...args: unknown[]) => mockEventBusEmit(...args) },
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

// ─── Query tests ────────────────────────────────────────────────────────────

describe("useLists", () => {
  beforeEach(() => vi.clearAllMocks());

  it("fetches all lists", async () => {
    const data = { lists: [{ id: "l1", name: "Favorites" }] };
    mockGetLists.mockResolvedValue({ ok: true, data });

    const { result } = renderHook(() => useLists(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(data);
  });

  it("throws on error", async () => {
    mockGetLists.mockResolvedValue({
      ok: false,
      error: { code: "ERR", message: "unauthorized" },
    });

    const { result } = renderHook(() => useLists(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.message).toBe("unauthorized");
  });
});

describe("useListItems", () => {
  beforeEach(() => vi.clearAllMocks());

  it("fetches items for a list", async () => {
    const data = { items: [{ product_id: 42 }] };
    mockGetListItems.mockResolvedValue({ ok: true, data });

    const { result } = renderHook(() => useListItems("list-1"), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(data);
  });

  it("does not fetch when listId is undefined", () => {
    const { result } = renderHook(() => useListItems(undefined), {
      wrapper: createWrapper(),
    });
    expect(result.current.fetchStatus).toBe("idle");
  });
});

describe("useSharedList", () => {
  beforeEach(() => vi.clearAllMocks());

  it("fetches shared list by token", async () => {
    const data = { items: [], list_name: "Shared" };
    mockGetSharedList.mockResolvedValue({ ok: true, data });

    const { result } = renderHook(() => useSharedList("tok-abc"), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(data);
  });

  it("does not fetch when token is undefined", () => {
    const { result } = renderHook(() => useSharedList(undefined), {
      wrapper: createWrapper(),
    });
    expect(result.current.fetchStatus).toBe("idle");
  });
});

describe("useAvoidProductIds", () => {
  beforeEach(() => vi.clearAllMocks());

  it("fetches avoid IDs and syncs to store", async () => {
    const data = { product_ids: [1, 2, 3] };
    mockGetAvoidProductIds.mockResolvedValue({ ok: true, data });

    const { result } = renderHook(() => useAvoidProductIds(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockSetAvoidedIds).toHaveBeenCalledWith([1, 2, 3]);
  });
});

describe("useFavoriteProductIds", () => {
  beforeEach(() => vi.clearAllMocks());

  it("fetches favorite IDs and syncs to store", async () => {
    const data = { product_ids: [10, 20] };
    mockGetFavoriteProductIds.mockResolvedValue({ ok: true, data });

    const { result } = renderHook(() => useFavoriteProductIds(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockSetFavoriteIds).toHaveBeenCalledWith([10, 20]);
  });
});

describe("useProductListMembership", () => {
  beforeEach(() => vi.clearAllMocks());

  it("fetches list membership for a product", async () => {
    const data = { lists: [{ list_id: "l1", list_type: "favorites" }] };
    mockGetProductListMembership.mockResolvedValue({ ok: true, data });

    const { result } = renderHook(() => useProductListMembership(42), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(data);
  });

  it("does not fetch when disabled", () => {
    const { result } = renderHook(() => useProductListMembership(42, false), {
      wrapper: createWrapper(),
    });
    expect(result.current.fetchStatus).toBe("idle");
  });
});

describe("useListPreview", () => {
  beforeEach(() => vi.clearAllMocks());

  it("fetches first 3 items for a list preview", async () => {
    const data = { items: [{ product_id: 1 }, { product_id: 2 }] };
    mockGetListItems.mockResolvedValue({ ok: true, data });

    const { result } = renderHook(() => useListPreview("list-1", 5), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(data);
    expect(mockGetListItems).toHaveBeenCalledWith(
      expect.anything(),
      "list-1",
      3,
      0,
    );
  });

  it("does not fetch when listId is undefined", () => {
    const { result } = renderHook(() => useListPreview(undefined, 5), {
      wrapper: createWrapper(),
    });
    expect(result.current.fetchStatus).toBe("idle");
  });

  it("does not fetch when itemCount is 0", () => {
    const { result } = renderHook(() => useListPreview("list-1", 0), {
      wrapper: createWrapper(),
    });
    expect(result.current.fetchStatus).toBe("idle");
  });

  it("handles error from API", async () => {
    mockGetListItems.mockResolvedValue({
      ok: false,
      error: { code: "ERR", message: "access denied" },
    });

    const { result } = renderHook(() => useListPreview("list-1", 3), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.message).toBe("access denied");
  });
});

// ─── Mutation tests ─────────────────────────────────────────────────────────

describe("useCreateList", () => {
  beforeEach(() => vi.clearAllMocks());

  it("calls createList API", async () => {
    mockCreateList.mockResolvedValue({
      ok: true,
      data: { list_id: "new-1" },
    });

    const { result } = renderHook(() => useCreateList(), {
      wrapper: createWrapper(),
    });

    result.current.mutate({ name: "My List" });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockCreateList).toHaveBeenCalled();
  });

  it("tracks analytics and emits event on success", async () => {
    mockCreateList.mockResolvedValue({
      ok: true,
      data: { list_id: "new-2" },
    });

    const { result } = renderHook(() => useCreateList(), {
      wrapper: createWrapper(),
    });

    result.current.mutate({ name: "Tracked List", listType: "custom" });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockTrack).toHaveBeenCalledWith("list_created", {
      name: "Tracked List",
      list_type: "custom",
    });
    expect(mockEventBusEmit).toHaveBeenCalledWith({
      type: "list.created",
      payload: {},
    });
  });

  it("handles API rejection", async () => {
    mockCreateList.mockRejectedValue(new Error("network error"));

    const { result } = renderHook(() => useCreateList(), {
      wrapper: createWrapper(),
    });

    result.current.mutate({ name: "Fail" });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.message).toBe("network error");
  });
});

describe("useUpdateList", () => {
  beforeEach(() => vi.clearAllMocks());

  it("calls updateList API", async () => {
    mockUpdateList.mockResolvedValue({
      ok: true,
      data: { success: true },
    });

    const { result } = renderHook(() => useUpdateList(), {
      wrapper: createWrapper(),
    });

    result.current.mutate({ listId: "l1", name: "Renamed" });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockUpdateList).toHaveBeenCalled();
  });

  it("handles API rejection", async () => {
    mockUpdateList.mockRejectedValue(new Error("update failed"));

    const { result } = renderHook(() => useUpdateList(), {
      wrapper: createWrapper(),
    });

    result.current.mutate({ listId: "l1", name: "Fail" });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.message).toBe("update failed");
  });
});

describe("useDeleteList", () => {
  beforeEach(() => vi.clearAllMocks());

  it("calls deleteList API", async () => {
    mockDeleteList.mockResolvedValue({
      ok: true,
      data: { success: true },
    });

    const { result } = renderHook(() => useDeleteList(), {
      wrapper: createWrapper(),
    });

    result.current.mutate("l1");

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockDeleteList).toHaveBeenCalled();
  });

  it("handles API rejection", async () => {
    mockDeleteList.mockRejectedValue(new Error("delete failed"));

    const { result } = renderHook(() => useDeleteList(), {
      wrapper: createWrapper(),
    });

    result.current.mutate("l1");

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.message).toBe("delete failed");
  });
});

describe("useAddToList", () => {
  beforeEach(() => vi.clearAllMocks());

  it("calls addToList API", async () => {
    mockAddToList.mockResolvedValue({
      ok: true,
      data: { added: true, list_type: "custom" },
    });

    const { result } = renderHook(() => useAddToList(), {
      wrapper: createWrapper(),
    });

    result.current.mutate({ listId: "l1", productId: 42 });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockAddToList).toHaveBeenCalled();
  });

  it("syncs avoid store on avoid list add", async () => {
    mockAddToList.mockResolvedValue({
      ok: true,
      data: { added: true, list_type: "avoid" },
    });

    const { result } = renderHook(() => useAddToList(), {
      wrapper: createWrapper(),
    });

    result.current.mutate({ listId: "l1", productId: 42, listType: "avoid" });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockAddAvoided).toHaveBeenCalledWith(42);
  });

  it("syncs favorites store on favorites list add", async () => {
    mockAddToList.mockResolvedValue({
      ok: true,
      data: { added: true, list_type: "favorites" },
    });

    const { result } = renderHook(() => useAddToList(), {
      wrapper: createWrapper(),
    });

    result.current.mutate({
      listId: "l1",
      productId: 42,
      listType: "favorites",
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockAddFavorite).toHaveBeenCalledWith(42);
  });

  it("tracks analytics and emits event on success", async () => {
    mockAddToList.mockResolvedValue({
      ok: true,
      data: { added: true, list_type: "custom" },
    });

    const { result } = renderHook(() => useAddToList(), {
      wrapper: createWrapper(),
    });

    result.current.mutate({ listId: "l1", productId: 99, listType: "custom" });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockTrack).toHaveBeenCalledWith("list_item_added", {
      list_id: "l1",
      product_id: 99,
      list_type: "custom",
    });
    expect(mockEventBusEmit).toHaveBeenCalledWith({
      type: "product.added_to_list",
      payload: { productId: 99, listId: "l1" },
    });
  });

  it("handles API rejection", async () => {
    mockAddToList.mockRejectedValue(new Error("add failed"));

    const { result } = renderHook(() => useAddToList(), {
      wrapper: createWrapper(),
    });

    result.current.mutate({ listId: "l1", productId: 42 });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.message).toBe("add failed");
  });
});

describe("useRemoveFromList", () => {
  beforeEach(() => vi.clearAllMocks());

  it("calls removeFromList API", async () => {
    mockRemoveFromList.mockResolvedValue({
      ok: true,
      data: { success: true },
    });

    const { result } = renderHook(() => useRemoveFromList(), {
      wrapper: createWrapper(),
    });

    result.current.mutate({ listId: "l1", productId: 42 });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
  });

  it("syncs avoid store on avoid list remove", async () => {
    mockRemoveFromList.mockResolvedValue({
      ok: true,
      data: { success: true },
    });

    const { result } = renderHook(() => useRemoveFromList(), {
      wrapper: createWrapper(),
    });

    result.current.mutate({
      listId: "l1",
      productId: 42,
      listType: "avoid",
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockRemoveAvoided).toHaveBeenCalledWith(42);
  });

  it("syncs favorites store on favorites list remove", async () => {
    mockRemoveFromList.mockResolvedValue({
      ok: true,
      data: { success: true },
    });

    const { result } = renderHook(() => useRemoveFromList(), {
      wrapper: createWrapper(),
    });

    result.current.mutate({
      listId: "l1",
      productId: 42,
      listType: "favorites",
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockRemoveFavorite).toHaveBeenCalledWith(42);
  });

  it("handles API rejection", async () => {
    mockRemoveFromList.mockRejectedValue(new Error("remove failed"));

    const { result } = renderHook(() => useRemoveFromList(), {
      wrapper: createWrapper(),
    });

    result.current.mutate({ listId: "l1", productId: 42 });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.message).toBe("remove failed");
  });
});

describe("useReorderList", () => {
  beforeEach(() => vi.clearAllMocks());

  it("calls reorderList API", async () => {
    mockReorderList.mockResolvedValue({
      ok: true,
      data: { success: true },
    });

    const { result } = renderHook(() => useReorderList(), {
      wrapper: createWrapper(),
    });

    result.current.mutate({ listId: "l1", productIds: [3, 1, 2] });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockReorderList).toHaveBeenCalled();
  });

  it("handles API rejection", async () => {
    mockReorderList.mockRejectedValue(new Error("reorder failed"));

    const { result } = renderHook(() => useReorderList(), {
      wrapper: createWrapper(),
    });

    result.current.mutate({ listId: "l1", productIds: [1, 2] });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.message).toBe("reorder failed");
  });
});

describe("useToggleShare", () => {
  beforeEach(() => vi.clearAllMocks());

  it("calls toggleShare API", async () => {
    mockToggleShare.mockResolvedValue({
      ok: true,
      data: { share_token: "tok" },
    });

    const { result } = renderHook(() => useToggleShare(), {
      wrapper: createWrapper(),
    });

    result.current.mutate({ listId: "l1", enabled: true });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockToggleShare).toHaveBeenCalled();
  });

  it("handles API rejection", async () => {
    mockToggleShare.mockRejectedValue(new Error("share failed"));

    const { result } = renderHook(() => useToggleShare(), {
      wrapper: createWrapper(),
    });

    result.current.mutate({ listId: "l1", enabled: true });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.message).toBe("share failed");
  });
});

describe("useRevokeShare", () => {
  beforeEach(() => vi.clearAllMocks());

  it("calls revokeShare API", async () => {
    mockRevokeShare.mockResolvedValue({
      ok: true,
      data: { success: true },
    });

    const { result } = renderHook(() => useRevokeShare(), {
      wrapper: createWrapper(),
    });

    result.current.mutate("l1");

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockRevokeShare).toHaveBeenCalled();
  });

  it("handles API rejection", async () => {
    mockRevokeShare.mockRejectedValue(new Error("revoke failed"));

    const { result } = renderHook(() => useRevokeShare(), {
      wrapper: createWrapper(),
    });

    result.current.mutate("l1");

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error?.message).toBe("revoke failed");
  });
});
