"use client";

// ─── SaveSearchDialog — save current query + filters ────────────────────────
//
// ⚠️  IMPORTANT: The <dialog> element is conditionally rendered (mounted only
// when show=true, unmounted when closed). Android Chrome resolves box dimensions
// of closed <dialog> elements, inflating the layout viewport on mobile devices.
// See PR #92.

import { useState, useRef, useEffect, useCallback } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { Save } from "lucide-react";
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

/**
 * Conditionally rendered wrapper — prevents closed <dialog> elements from
 * expanding the mobile layout viewport on Android Chrome. See PR #92.
 */
export function SaveSearchDialog(props: Readonly<SaveSearchDialogProps>) {
  if (!props.show) return null;
  return <SaveSearchDialogInner {...props} />;
}

function SaveSearchDialogInner({
  query,
  filters,
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

  const dialogRef = useRef<HTMLDialogElement>(null);

  // Show as modal immediately on mount
  useEffect(() => {
    const el = dialogRef.current;
    if (el && !el.open) {
      el.showModal();
    }
  }, []);

  const handleCancel = useCallback(() => {
    onClose();
  }, [onClose]);

  // Native <dialog> fires "cancel" on Escape
  useEffect(() => {
    const el = dialogRef.current;
    if (!el) return;
    el.addEventListener("cancel", handleCancel);
    return () => el.removeEventListener("cancel", handleCancel);
  }, [handleCancel]);

  return (
    <dialog
      ref={dialogRef}
      aria-labelledby="save-search-title"
      className="fixed inset-0 z-50 m-auto w-full max-w-sm rounded-2xl bg-surface p-6 shadow-xl backdrop:bg-black/30"
    >
      <h3
        id="save-search-title"
        className="mb-1 text-base font-semibold text-foreground"
      >
        <Save size={16} aria-hidden="true" className="inline" />{" "}
        {t("saveSearchDialog.title")}
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
        <label htmlFor="save-search-name" className="sr-only">
          {t("a11y.saveSearchName")}
        </label>
        <input
          id="save-search-name"
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
          <p className="mt-2 text-center text-xs text-red-500" role="alert">
            {mutation.error.message}
          </p>
        )}
      </form>
    </dialog>
  );
}
