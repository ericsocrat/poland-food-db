// ─── TanStack Query hooks for Product Comparisons ───────────────────────────

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { createClient } from "@/lib/supabase/client";
import {
  getProductsForCompare,
  saveComparison,
  getSavedComparisons,
  getSharedComparison,
  deleteComparison,
} from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";

// ─── Queries ────────────────────────────────────────────────────────────────

/** Fetch full product data for 2-4 products for the comparison grid. */
export function useCompareProducts(productIds: number[]) {
  const supabase = createClient();
  const sorted = [...productIds].sort((a, b) => a - b);

  return useQuery({
    queryKey: queryKeys.compareProducts(sorted),
    queryFn: async () => {
      const result = await getProductsForCompare(supabase, productIds);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    enabled: productIds.length >= 2 && productIds.length <= 4,
    staleTime: staleTimes.compareProducts,
  });
}

/** Fetch the user's saved comparisons (paginated). */
export function useSavedComparisons(
  limit?: number,
  offset?: number,
) {
  const supabase = createClient();

  return useQuery({
    queryKey: queryKeys.savedComparisons,
    queryFn: async () => {
      const result = await getSavedComparisons(supabase, limit, offset);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.savedComparisons,
  });
}

/** Fetch a shared comparison by token (public — no auth needed). */
export function useSharedComparison(token: string) {
  const supabase = createClient();

  return useQuery({
    queryKey: queryKeys.sharedComparison(token),
    queryFn: async () => {
      const result = await getSharedComparison(supabase, token);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    enabled: !!token,
    staleTime: staleTimes.sharedComparison,
  });
}

// ─── Mutations ──────────────────────────────────────────────────────────────

/** Save a comparison (authenticated). */
export function useSaveComparison() {
  const supabase = createClient();
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({
      productIds,
      title,
    }: {
      productIds: number[];
      title?: string;
    }) => {
      const result = await saveComparison(supabase, productIds, title);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: queryKeys.savedComparisons,
      });
    },
  });
}

/** Delete a saved comparison. */
export function useDeleteComparison() {
  const supabase = createClient();
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (comparisonId: string) => {
      const result = await deleteComparison(supabase, comparisonId);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: queryKeys.savedComparisons,
      });
    },
  });
}
