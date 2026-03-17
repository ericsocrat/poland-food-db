// ─── TanStack Query hooks for Product Submissions ───────────────────────────

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { createClient } from "@/lib/supabase/client";
import { getMySubmissions, submitProduct } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { showToast } from "@/lib/toast";
import { eventBus } from "@/lib/events";

// ─── Types ──────────────────────────────────────────────────────────────────

export type ContributorTier = "none" | "bronze" | "silver" | "gold";

export interface ContributorStats {
  total: number;
  approved: number;
  pending: number;
  rejected: number;
  merged: number;
  tier: ContributorTier;
}

// ─── Helpers ────────────────────────────────────────────────────────────────

function computeTier(approvedCount: number): ContributorTier {
  if (approvedCount >= 50) return "gold";
  if (approvedCount >= 10) return "silver";
  if (approvedCount >= 1) return "bronze";
  return "none";
}

// ─── Queries ────────────────────────────────────────────────────────────────

/** Paginated submission history. */
export function useSubmissionHistory(page: number = 1, pageSize: number = 20) {
  const supabase = createClient();

  return useQuery({
    queryKey: queryKeys.mySubmissions(page),
    queryFn: async () => {
      const result = await getMySubmissions(supabase, page, pageSize);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.mySubmissions,
  });
}

/**
 * Contributor stats — fetches ALL submissions (page 1, large page size)
 * and derives approved/pending/rejected/merged counts + tier badge.
 */
export function useContributorStats() {
  const supabase = createClient();

  return useQuery({
    queryKey: queryKeys.contributorStats,
    queryFn: async () => {
      // Fetch a large page to get total + submission statuses
      const result = await getMySubmissions(supabase, 1, 200);
      if (!result.ok) throw new Error(result.error.message);

      const subs = result.data.submissions;
      const approved = subs.filter((s) => s.status === "approved").length;
      const merged = subs.filter((s) => s.status === "merged").length;
      const approvedTotal = approved + merged;

      const stats: ContributorStats = {
        total: result.data.total,
        approved: approvedTotal,
        pending: subs.filter((s) => s.status === "pending").length,
        rejected: subs.filter((s) => s.status === "rejected").length,
        merged,
        tier: computeTier(approvedTotal),
      };

      return stats;
    },
    staleTime: staleTimes.contributorStats,
  });
}

// ─── Mutations ──────────────────────────────────────────────────────────────

/** Submit a new product. Invalidates submission caches on success. */
export function useSubmitProduct() {
  const supabase = createClient();
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (params: {
      ean: string;
      productName: string;
      brand?: string;
      category?: string;
      photoUrl?: string;
      notes?: string;
      scanCountry?: string;
      suggestedCountry?: string;
    }) => {
      const result = await submitProduct(supabase, params);
      if (!result.ok) throw new Error(result.error.message);
      if (result.data.error) throw new Error(result.data.error);
      return result.data;
    },
    onSuccess: (_data, variables) => {
      showToast({ type: "success", messageKey: "submit.successToast" });
      void eventBus.emit({
        type: "product.submitted",
        payload: { ean: variables.ean },
      });
      void queryClient.invalidateQueries({
        queryKey: ["my-submissions"],
      });
      void queryClient.invalidateQueries({
        queryKey: queryKeys.contributorStats,
      });
    },
    onError: (error: Error) => {
      showToast({ type: "error", message: error.message });
    },
  });
}
