// ─── TanStack Query hooks for Product Lists ─────────────────────────────────
// Encapsulates all list-related queries and mutations with proper cache
// invalidation patterns. Uses avoid + favorites stores for optimistic updates.

"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { createClient } from "@/lib/supabase/client";
import { eventBus } from "@/lib/events";
import {
  addToList,
  createList,
  deleteList,
  getAvoidProductIds,
  getFavoriteProductIds,
  getListItems,
  getLists,
  getProductListMembership,
  getSharedList,
  removeFromList,
  reorderList,
  revokeShare,
  toggleShare,
  updateList,
} from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { useAvoidStore } from "@/stores/avoid-store";
import { useFavoritesStore } from "@/stores/favorites-store";
import { useAnalytics } from "@/hooks/use-analytics";
import { useEffect } from "react";

// ─── Queries ────────────────────────────────────────────────────────────────

/** Fetch all lists for the authenticated user */
export function useLists() {
  const supabase = createClient();
  return useQuery({
    queryKey: queryKeys.lists,
    queryFn: async () => {
      const result = await getLists(supabase);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.lists,
  });
}

/** Fetch items in a specific list with product details */
export function useListItems(listId: string | undefined) {
  const supabase = createClient();
  return useQuery({
    queryKey: queryKeys.listItems(listId ?? ""),
    queryFn: async () => {
      if (!listId) throw new Error("List ID required");
      const result = await getListItems(supabase, listId);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    enabled: !!listId,
    staleTime: staleTimes.listItems,
  });
}

/**
 * Fetch a lightweight preview (first 3 items) for a list card.
 * Skipped when item_count is 0 to avoid unnecessary requests.
 */
export function useListPreview(
  listId: string | undefined,
  itemCount: number,
) {
  const supabase = createClient();
  return useQuery({
    queryKey: queryKeys.listPreview(listId ?? ""),
    queryFn: async () => {
      if (!listId) throw new Error("List ID required");
      const result = await getListItems(supabase, listId, 3, 0);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    enabled: !!listId && itemCount > 0,
    staleTime: staleTimes.listPreview,
  });
}

/** Fetch a shared list by token (no auth required) */
export function useSharedList(token: string | undefined) {
  const supabase = createClient();
  return useQuery({
    queryKey: queryKeys.sharedList(token ?? ""),
    queryFn: async () => {
      if (!token) throw new Error("Share token required");
      const result = await getSharedList(supabase, token);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    enabled: !!token,
    staleTime: staleTimes.sharedList,
  });
}

/** Fetch avoided product IDs and sync to Zustand store */
export function useAvoidProductIds() {
  const supabase = createClient();
  const setAvoidedIds = useAvoidStore((s) => s.setAvoidedIds);

  const query = useQuery({
    queryKey: queryKeys.avoidProductIds,
    queryFn: async () => {
      const result = await getAvoidProductIds(supabase);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.avoidProductIds,
  });

  // Sync to Zustand store when data arrives
  useEffect(() => {
    if (query.data?.product_ids) {
      setAvoidedIds(query.data.product_ids);
    }
  }, [query.data, setAvoidedIds]);

  return query;
}

/** Fetch favorite product IDs and sync to Zustand store */
export function useFavoriteProductIds() {
  const supabase = createClient();
  const setFavoriteIds = useFavoritesStore((s) => s.setFavoriteIds);

  const query = useQuery({
    queryKey: queryKeys.favoriteProductIds,
    queryFn: async () => {
      const result = await getFavoriteProductIds(supabase);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.favoriteProductIds,
  });

  // Sync to Zustand store when data arrives
  useEffect(() => {
    if (query.data?.product_ids) {
      setFavoriteIds(query.data.product_ids);
    }
  }, [query.data, setFavoriteIds]);

  return query;
}

/** Check which lists contain a specific product (lazy, for dropdown) */
export function useProductListMembership(
  productId: number,
  enabled: boolean = true,
) {
  const supabase = createClient();
  return useQuery({
    queryKey: queryKeys.productListMembership(productId),
    queryFn: async () => {
      const result = await getProductListMembership(supabase, productId);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.productListMembership,
    enabled,
  });
}

// ─── Mutations ──────────────────────────────────────────────────────────────

/** Create a new list */
export function useCreateList() {
  const supabase = createClient();
  const queryClient = useQueryClient();
  const { track } = useAnalytics();

  return useMutation({
    mutationFn: (params: {
      name: string;
      description?: string;
      listType?: string;
    }) => createList(supabase, params.name, params.description, params.listType),
    onSuccess: (_data, variables) => {
      track("list_created", { name: variables.name, list_type: variables.listType });
      void eventBus.emit({ type: "list.created", payload: {} });
      queryClient.invalidateQueries({ queryKey: queryKeys.lists });
    },
  });
}

/** Update a list's name or description */
export function useUpdateList() {
  const supabase = createClient();
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (params: {
      listId: string;
      name?: string;
      description?: string;
    }) => updateList(supabase, params.listId, params.name, params.description),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.lists });
    },
  });
}

/** Delete a custom list */
export function useDeleteList() {
  const supabase = createClient();
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (listId: string) => deleteList(supabase, listId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.lists });
    },
  });
}

/** Add a product to a list (with optimistic avoid store update) */
export function useAddToList() {
  const supabase = createClient();
  const queryClient = useQueryClient();
  const addAvoided = useAvoidStore((s) => s.addAvoided);
  const addFavorite = useFavoritesStore((s) => s.addFavorite);
  const { track } = useAnalytics();

  return useMutation({
    mutationFn: (params: {
      listId: string;
      productId: number;
      notes?: string;
      listType?: string;
    }) => addToList(supabase, params.listId, params.productId, params.notes),
    onSuccess: (result, variables) => {
      queryClient.invalidateQueries({
        queryKey: queryKeys.listItems(variables.listId),
      });
      queryClient.invalidateQueries({ queryKey: queryKeys.lists });
      queryClient.invalidateQueries({
        queryKey: queryKeys.productListMembership(variables.productId),
      });
      track("list_item_added", { list_id: variables.listId, product_id: variables.productId, list_type: variables.listType });
      void eventBus.emit({
        type: "product.added_to_list",
        payload: { productId: variables.productId, listId: variables.listId },
      });

      const listType =
        variables.listType ?? (result.ok ? result.data.list_type : undefined);

      // Optimistic avoid store update
      if (listType === "avoid") {
        addAvoided(variables.productId);
        queryClient.invalidateQueries({
          queryKey: queryKeys.avoidProductIds,
        });
      }
      // Optimistic favorites store update
      if (listType === "favorites") {
        addFavorite(variables.productId);
        queryClient.invalidateQueries({
          queryKey: queryKeys.favoriteProductIds,
        });
      }
    },
  });
}

/** Remove a product from a list (with optimistic avoid store update) */
export function useRemoveFromList() {
  const supabase = createClient();
  const queryClient = useQueryClient();
  const removeAvoided = useAvoidStore((s) => s.removeAvoided);
  const removeFavorite = useFavoritesStore((s) => s.removeFavorite);

  return useMutation({
    mutationFn: (params: {
      listId: string;
      productId: number;
      listType?: string;
    }) => removeFromList(supabase, params.listId, params.productId),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({
        queryKey: queryKeys.listItems(variables.listId),
      });
      queryClient.invalidateQueries({ queryKey: queryKeys.lists });
      queryClient.invalidateQueries({
        queryKey: queryKeys.productListMembership(variables.productId),
      });

      // Optimistic avoid store update
      if (variables.listType === "avoid") {
        removeAvoided(variables.productId);
        queryClient.invalidateQueries({
          queryKey: queryKeys.avoidProductIds,
        });
      }
      // Optimistic favorites store update
      if (variables.listType === "favorites") {
        removeFavorite(variables.productId);
        queryClient.invalidateQueries({
          queryKey: queryKeys.favoriteProductIds,
        });
      }
    },
  });
}

/** Reorder items in a list */
export function useReorderList() {
  const supabase = createClient();
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (params: { listId: string; productIds: number[] }) =>
      reorderList(supabase, params.listId, params.productIds),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({
        queryKey: queryKeys.listItems(variables.listId),
      });
    },
  });
}

/** Toggle sharing on/off for a list */
export function useToggleShare() {
  const supabase = createClient();
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (params: { listId: string; enabled: boolean }) =>
      toggleShare(supabase, params.listId, params.enabled),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.lists });
    },
  });
}

/** Revoke sharing for a list (regenerates token, old links break) */
export function useRevokeShare() {
  const supabase = createClient();
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (listId: string) => revokeShare(supabase, listId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.lists });
    },
  });
}
