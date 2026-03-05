"use client";

import { useQuery } from "@tanstack/react-query";

import { getBetterAlternativesV2 } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { createClient } from "@/lib/supabase/client";

// ─── Hook params ────────────────────────────────────────────────────────────

export interface UseAlternativesV2Options {
  productId: number;
  crossCategory?: boolean;
  limit?: number;
  healthProfileId?: string;
  preferNoPalmOil?: boolean;
  maxConcernTier?: number;
  dietPreference?: string;
  avoidAllergens?: string[];
  strictDiet?: boolean;
  strictAllergen?: boolean;
  treatMayContain?: boolean;
  enabled?: boolean;
}

// ─── Hook ───────────────────────────────────────────────────────────────────

export function useAlternativesV2({
  productId,
  crossCategory = false,
  limit = 5,
  healthProfileId,
  preferNoPalmOil = false,
  maxConcernTier,
  dietPreference,
  avoidAllergens,
  strictDiet,
  strictAllergen,
  treatMayContain,
  enabled = true,
}: UseAlternativesV2Options) {
  const supabase = createClient();

  return useQuery({
    queryKey: queryKeys.alternativesV2(productId),
    queryFn: async () => {
      const result = await getBetterAlternativesV2(supabase, productId, {
        p_cross_category: crossCategory,
        p_limit: limit,
        p_health_profile_id: healthProfileId,
        p_prefer_no_palm_oil: preferNoPalmOil,
        p_max_concern_tier: maxConcernTier,
        p_diet_preference: dietPreference,
        p_avoid_allergens: avoidAllergens,
        p_strict_diet: strictDiet,
        p_strict_allergen: strictAllergen,
        p_treat_may_contain: treatMayContain,
      });
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.alternativesV2,
    enabled: enabled && !Number.isNaN(productId),
  });
}
