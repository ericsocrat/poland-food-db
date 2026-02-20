"use client";

/**
 * DidYouMean — fuzzy search suggestions for zero-results state (#62).
 *
 * When a search query returns no results, this component queries the
 * `api_search_did_you_mean` RPC (pg_trgm similarity) and displays
 * clickable suggestion links. Falls back to the autocomplete endpoint
 * if the dedicated function is not yet deployed.
 */

import { useQuery } from "@tanstack/react-query";
import { createClient } from "@/lib/supabase/client";
import { searchDidYouMean } from "@/lib/api";
import { useTranslation } from "@/lib/i18n";

const DID_YOU_MEAN_QUERY_KEY = "did-you-mean";
const DID_YOU_MEAN_STALE_TIME_MS = 2 * 60 * 1000;

interface DidYouMeanProps {
  /** The original search query that returned zero results. */
  readonly query: string;
  /** Called when user clicks a suggestion — re-runs search with new query. */
  readonly onSuggestionClick: (suggestion: string) => void;
}

export function DidYouMean({ query, onSuggestionClick }: DidYouMeanProps) {
  const { t } = useTranslation();
  const supabase = createClient();

  const { data } = useQuery({
    queryKey: [DID_YOU_MEAN_QUERY_KEY, query],
    queryFn: async () => {
      const result = await searchDidYouMean(supabase, query, 3);
      if (!result.ok) return null;
      return result.data;
    },
    enabled: query.length >= 2,
    staleTime: DID_YOU_MEAN_STALE_TIME_MS,
    retry: false,
  });

  const suggestions = data?.suggestions ?? [];
  if (suggestions.length === 0) return null;

  // Deduplicate by product_name (in case multiple products share the same name)
  const unique = Array.from(
    new Map(suggestions.map((s) => [s.product_name.toLowerCase(), s])).values(),
  );

  return (
    <div
      className="mt-3 rounded-lg border border-brand/20 bg-brand/5 px-4 py-3"
      data-testid="did-you-mean"
    >
      <p className="text-sm text-foreground-secondary">
        {t("search.didYouMean")}
        {": "}
        {unique.map((s, i) => (
          <span key={s.product_id}>
            {i > 0 && ", "}
            <button
              type="button"
              className="font-semibold text-brand hover:text-brand-hover hover:underline"
              onClick={() => onSuggestionClick(s.product_name)}
              data-testid={`did-you-mean-link-${i}`}
            >
              &ldquo;{s.product_name}&rdquo;
            </button>
          </span>
        ))}
        ?
      </p>
    </div>
  );
}
