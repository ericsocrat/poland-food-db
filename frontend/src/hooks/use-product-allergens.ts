// ─── Hook: batch-fetch & match product allergens against user preferences ───
// Returns a map of productId → AllergenWarning[] for the current page of results.
// Only fetches when user has allergen preferences configured.

import { useMemo } from "react";
import { useQuery } from "@tanstack/react-query";
import { createClient } from "@/lib/supabase/client";
import { usePreferences } from "@/components/common/RouteGuard";
import { getProductAllergens } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import {
  matchProductAllergens,
  type AllergenWarning,
} from "@/lib/allergen-matching";

/** Map of product_id → matched allergen warnings */
export type AllergenWarningMap = Readonly<Record<number, AllergenWarning[]>>;

/**
 * Batch-fetch allergen data for a page of products and match against user preferences.
 *
 * @param productIds - Array of product IDs from the current page of search/category/dashboard results
 * @returns Map of productId → AllergenWarning[] (empty map when no preferences or no data)
 *
 * @example
 * ```tsx
 * const products = searchData?.results ?? [];
 * const allergenMap = useProductAllergenWarnings(products.map(p => p.product_id));
 * // Then for each product: allergenMap[product.product_id] ?? []
 * ```
 */
export function useProductAllergenWarnings(
  productIds: number[],
): AllergenWarningMap {
  const supabase = createClient();
  const prefs = usePreferences();

  const avoidAllergens = useMemo(
    () => prefs?.avoid_allergens ?? [],
    [prefs?.avoid_allergens],
  );
  const treatMayContainAsUnsafe =
    prefs?.treat_may_contain_as_unsafe ?? false;
  const hasAllergenPrefs = avoidAllergens.length > 0;

  const { data: rawAllergenMap } = useQuery({
    queryKey: queryKeys.productAllergens(productIds),
    queryFn: async () => {
      const result = await getProductAllergens(supabase, productIds);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    enabled: productIds.length > 0 && hasAllergenPrefs,
    staleTime: staleTimes.productAllergens,
  });

  // Memoize the matching computation (runs when raw data or preferences change)
  return useMemo(() => {
    if (!rawAllergenMap || !hasAllergenPrefs) return {};

    const result: Record<number, AllergenWarning[]> = {};
    for (const [idStr, allergens] of Object.entries(rawAllergenMap)) {
      const warnings = matchProductAllergens(
        allergens,
        avoidAllergens,
        treatMayContainAsUnsafe,
      );
      if (warnings.length > 0) {
        result[Number(idStr)] = warnings;
      }
    }
    return result;
  }, [rawAllergenMap, avoidAllergens, treatMayContainAsUnsafe, hasAllergenPrefs]);
}
