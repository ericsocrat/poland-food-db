"use client";

// ─── useCrossCountryLinks — fetch linked products from other countries ──────
// Issue #605: Cross-country product linking via EAN matching

import { getCrossCountryLinks } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { createClient } from "@/lib/supabase/client";
import { useQuery } from "@tanstack/react-query";

/**
 * Fetch cross-country product links for a given product.
 *
 * Returns an array of linked products from other countries (e.g., PL↔DE),
 * with link type (identical/equivalent/variant/related) and confidence level.
 *
 * @param productId - The product to find cross-country links for
 * @param enabled - Whether to enable the query (default: true)
 */
export function useCrossCountryLinks(productId: number, enabled = true) {
  const supabase = createClient();

  return useQuery({
    queryKey: queryKeys.crossCountryLinks(productId),
    queryFn: async () => {
      const result = await getCrossCountryLinks(supabase, productId);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.crossCountryLinks,
    enabled,
  });
}
