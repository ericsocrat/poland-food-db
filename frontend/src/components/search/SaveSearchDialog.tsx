"use client";

// ─── SaveSearchDialog — save current query + filters ────────────────────────

import { useState } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { createClient } from "@/lib/supabase/client";
import { saveSearch } from "@/lib/api";
import { queryKeys } from "@/lib/query-keys";
import { useAnalytics } from "@/hooks/use-analytics";
import { useTranslation } from "@/lib/i18n";
import type { SearchFilters } from "@/lib/types";

interface SaveSearchDialogProps {
  query: string | null;
  filters: SearchFilters;
  show: boolean;
  onClose: () => void;
}

export function SaveSearchDialog({
  query,
  filters,
  show,
  onClose,
}: Readonly<SaveSearchDialogProps>) {
  const supabase = createClient();
  const queryClient = useQueryClient();
  const [name, setName] = useState("");
  const { track } = useAnalytics();
  const { t } = useTranslation();

  const mutation = useMutation({
    mutationFn: async (searchName: string) => {
      const result = await saveSearch(
        supabase,
        searchName,
        query ?? undefined,
        filters,
      );
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    onSuccess: () => {
      track("search_saved", {
        name,
        query,
        filter_count: Object.keys(filters).length,
      });
      queryClient.invalidateQueries({
        queryKey: queryKeys.savedSearches,
      });
      setName("");
      onClose();
    },
  });

  if (!show) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Backdrop */}
      <button
        type="button"
        className="absolute inset-0 bg-black/30 border-0 p-0 cursor-default"
        aria-label="Close dialog"
        onClick={onClose}
      />
      {/* Dialog */}
      <div className="relative w-full max-w-sm rounded-2xl bg-surface p-6 shadow-xl">
        <h3 className="mb-1 text-base font-semibold text-foreground">
          💾 {t("saveSearchDialog.title")}
        </h3>
        <p className="mb-4 text-sm text-foreground-secondary">
          {query ? `Query: "${query}"` : "Browse mode"}
          {Object.keys(filters).length > 0
            ? ` ${t("saveSearchDialog.plusFilters")}`
            : ""}
        </p>

        <form
          onSubmit={(e) => {
            e.preventDefault();
            if (name.trim().length > 0) {
              mutation.mutate(name.trim());
            }
          }}
        >
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder={t("saveSearchDialog.namePlaceholder")}
            className="input-field mb-4"
            autoFocus
            maxLength={100}
          />

          <div className="flex gap-2">
            <button
              type="button"
              onClick={onClose}
              className="btn-secondary flex-1 py-2 text-sm"
            >
              {t("common.cancel")}
            </button>
            <button
              type="submit"
              disabled={name.trim().length === 0 || mutation.isPending}
              className="btn-primary flex-1 py-2 text-sm disabled:cursor-not-allowed disabled:opacity-50"
            >
              {mutation.isPending ? `${t("common.saving")}` : t("common.save")}
            </button>
          </div>

          {mutation.isError && (
            <p className="mt-2 text-center text-xs text-red-500">
              {mutation.error.message}
            </p>
          )}
        </form>
      </div>
    </div>
  );
}
