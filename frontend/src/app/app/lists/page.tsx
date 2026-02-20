"use client";

// ─── Lists overview page ────────────────────────────────────────────────────
// Shows all user lists with item counts, create-new-list form, and links to
// individual list detail pages. Default lists (Favorites, Avoid) show first.

import { useState } from "react";
import Link from "next/link";
import {
  useLists,
  useCreateList,
  useDeleteList,
  useListPreview,
} from "@/hooks/use-lists";
import {
  Heart,
  Ban,
  FileText,
  Link2,
  Trash2,
  ClipboardList,
} from "lucide-react";
import type { LucideIcon } from "lucide-react";
import { ListViewSkeleton } from "@/components/common/skeletons";
import { EmptyState } from "@/components/common/EmptyState";
import { ConfirmDialog } from "@/components/common/ConfirmDialog";
import { useTranslation } from "@/lib/i18n";
import { SCORE_BANDS, scoreBandFromScore } from "@/lib/constants";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import type { ProductList, ListItem, FormSubmitEvent } from "@/lib/types";

export default function ListsPage() {
  const { t } = useTranslation();
  const { data, isLoading, error } = useLists();
  const createList = useCreateList();
  const deleteList = useDeleteList();

  const [showForm, setShowForm] = useState(false);
  const [newName, setNewName] = useState("");
  const [newDesc, setNewDesc] = useState("");
  const [confirmDeleteId, setConfirmDeleteId] = useState<string | null>(null);

  const lists: ProductList[] = data?.lists ?? [];

  function handleCreate(e: FormSubmitEvent) {
    e.preventDefault();
    if (!newName.trim()) return;
    createList.mutate(
      { name: newName.trim(), description: newDesc.trim() || undefined },
      {
        onSuccess: () => {
          setNewName("");
          setNewDesc("");
          setShowForm(false);
        },
      },
    );
  }

  if (isLoading) {
    return <ListViewSkeleton />;
  }

  if (error) {
    return <EmptyState variant="error" titleKey="lists.loadFailed" />;
  }

  return (
    <div className="space-y-6 lg:space-y-8">
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "nav.lists" },
        ]}
      />
      {/* Header */}
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-bold text-foreground flex items-center gap-1.5 lg:text-2xl">
          <ClipboardList size={20} aria-hidden="true" /> {t("lists.title")}
        </h1>
        <button
          type="button"
          className="btn-primary text-sm"
          onClick={() => setShowForm((v) => !v)}
        >
          {showForm ? t("common.cancel") : t("lists.newList")}
        </button>
      </div>

      {/* Create form */}
      {showForm && (
        <form onSubmit={handleCreate} className="card space-y-3">
          <input
            type="text"
            placeholder={t("lists.namePlaceholder")}
            value={newName}
            onChange={(e) => setNewName(e.target.value)}
            className="input-field"
            maxLength={100}
            required
            autoFocus
          />
          <input
            type="text"
            placeholder={t("lists.descriptionPlaceholder")}
            value={newDesc}
            onChange={(e) => setNewDesc(e.target.value)}
            className="input-field"
            maxLength={500}
          />
          <div className="flex gap-2">
            <button
              type="submit"
              className="btn-primary text-sm"
              disabled={createList.isPending || !newName.trim()}
            >
              {createList.isPending
                ? t("lists.creating")
                : t("lists.createList")}
            </button>
            <button
              type="button"
              className="btn-secondary text-sm"
              onClick={() => setShowForm(false)}
            >
              {t("common.cancel")}
            </button>
          </div>
        </form>
      )}

      {/* Empty state */}
      {lists.length === 0 && (
        <EmptyState variant="no-data" titleKey="lists.emptyState" />
      )}

      {/* List grid */}
      <div className="grid grid-cols-1 gap-3 md:grid-cols-2 xl:grid-cols-3">
        {lists.map((list) => (
          <ListCard
            key={list.id}
            list={list}
            onDelete={
              list.is_default ? undefined : () => setConfirmDeleteId(list.id)
            }
          />
        ))}
      </div>

      <ConfirmDialog
        open={confirmDeleteId !== null}
        title={t("lists.deleteList")}
        description={t("lists.deleteWarning")}
        confirmLabel={t("common.delete")}
        variant="danger"
        onConfirm={() => {
          if (confirmDeleteId) deleteList.mutate(confirmDeleteId);
          setConfirmDeleteId(null);
        }}
        onCancel={() => setConfirmDeleteId(null)}
      />
    </div>
  );
}

// ─── ListCard ───────────────────────────────────────────────────────────────

function listTypeIcon(type: string): LucideIcon {
  switch (type) {
    case "favorites":
      return Heart;
    case "avoid":
      return Ban;
    default:
      return FileText;
  }
}

function ListCard({
  list,
  onDelete,
}: Readonly<{
  list: ProductList;
  onDelete?: () => void;
}>) {
  const { t } = useTranslation();
  const TypeIcon = listTypeIcon(list.list_type);
  const { data: previewData } = useListPreview(list.id, list.item_count);

  const previewItems: ListItem[] = previewData?.items ?? [];

  // Compute health summary from preview items
  const avgScore =
    previewItems.length > 0
      ? Math.round(
          previewItems.reduce((sum, it) => sum + it.unhealthiness_score, 0) /
            previewItems.length,
        )
      : null;
  const avgBand =
    avgScore !== null ? SCORE_BANDS[scoreBandFromScore(avgScore)] : null;

  return (
    <Link href={`/app/lists/${list.id}`}>
      <div className="card hover-lift-press flex flex-col gap-3 transition-all duration-fast">
        {/* Top row — icon, name, meta */}
        <div className="flex items-center gap-3">
          <TypeIcon
            size={24}
            aria-hidden="true"
            className={
              list.list_type === "favorites"
                ? "text-red-500"
                : list.list_type === "avoid"
                  ? "text-red-600"
                  : "text-foreground-muted"
            }
          />

          <div className="min-w-0 flex-1">
            <p className="font-medium text-foreground">{list.name}</p>
            <p className="text-sm text-foreground-secondary">
              {t("common.items", { count: list.item_count })}
              {list.description && ` · ${list.description}`}
            </p>
          </div>

          {list.share_enabled && (
            <span
              title={t("lists.shared")}
              className="rounded-full bg-info/15 px-2 py-0.5 text-xs text-info"
            >
              <Link2 size={12} aria-hidden="true" className="inline" />{" "}
              {t("lists.shared")}
            </span>
          )}

          {onDelete && (
            <button
              type="button"
              title={t("common.delete")}
              aria-label={`${t("common.delete")} ${list.name}`}
              className="touch-target flex h-11 w-11 items-center justify-center rounded-full text-sm text-foreground-muted transition-colors hover:bg-error/10 hover:text-error"
              onClick={(e) => {
                e.preventDefault();
                e.stopPropagation();
                onDelete();
              }}
            >
              <Trash2 size={16} aria-hidden="true" />
            </button>
          )}
        </div>

        {/* Preview thumbnails + health summary */}
        {previewItems.length > 0 && (
          <div
            className="flex items-center gap-2 border-t border-border pt-2"
            data-testid="list-preview"
          >
            {/* Mini score badges for up to 3 products */}
            <div className="flex -space-x-1" data-testid="preview-thumbnails">
              {previewItems.map((item) => {
                const band =
                  SCORE_BANDS[scoreBandFromScore(item.unhealthiness_score)];
                return (
                  <span
                    key={item.item_id}
                    title={item.product_name}
                    className={`flex h-7 w-7 items-center justify-center rounded-full text-xs font-bold ring-2 ring-surface ${band.bg} ${band.color}`}
                  >
                    {item.unhealthiness_score}
                  </span>
                );
              })}
              {list.item_count > previewItems.length && (
                <span
                  className="flex h-7 w-7 items-center justify-center rounded-full bg-surface-muted text-xs text-foreground-secondary ring-2 ring-surface"
                  data-testid="preview-overflow"
                >
                  +{list.item_count - previewItems.length}
                </span>
              )}
            </div>

            {/* Average score summary */}
            {avgBand && avgScore !== null && (
              <span
                className={`ml-auto rounded-full px-2 py-0.5 text-xs font-medium ${avgBand.bg} ${avgBand.color}`}
                data-testid="list-avg-score"
              >
                {t("lists.avgScore", { score: avgScore })}
              </span>
            )}
          </div>
        )}
      </div>
    </Link>
  );
}
