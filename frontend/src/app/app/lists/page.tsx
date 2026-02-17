"use client";

// ─── Lists overview page ────────────────────────────────────────────────────
// Shows all user lists with item counts, create-new-list form, and links to
// individual list detail pages. Default lists (Favorites, Avoid) show first.

import { useState } from "react";
import Link from "next/link";
import { useLists, useCreateList, useDeleteList } from "@/hooks/use-lists";
import { ListViewSkeleton } from "@/components/common/skeletons";
import { EmptyState } from "@/components/common/EmptyState";
import { ConfirmDialog } from "@/components/common/ConfirmDialog";
import { useTranslation } from "@/lib/i18n";
import type { ProductList, FormSubmitEvent } from "@/lib/types";

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
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-bold text-foreground">
          📋 {t("lists.title")}
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
      <div className="space-y-2">
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

function listTypeIcon(type: string): string {
  switch (type) {
    case "favorites":
      return "❤️";
    case "avoid":
      return "🚫";
    default:
      return "📝";
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
  const typeIcon = listTypeIcon(list.list_type);

  return (
    <Link href={`/app/lists/${list.id}`}>
      <div className="card hover-lift-press flex items-center gap-3">
        <span className="text-2xl">{typeIcon}</span>

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
            className="rounded-full bg-blue-50 px-2 py-0.5 text-xs text-blue-600"
          >
            🔗 {t("lists.shared")}
          </span>
        )}

        {onDelete && (
          <button
            type="button"
            title={t("common.delete")}
            aria-label={`${t("common.delete")} ${list.name}`}
            className="touch-target flex h-11 w-11 items-center justify-center rounded-full text-sm text-foreground-muted transition-colors hover:bg-red-50 hover:text-red-500"
            onClick={(e) => {
              e.preventDefault();
              e.stopPropagation();
              onDelete();
            }}
          >
            🗑️
          </button>
        )}
      </div>
    </Link>
  );
}
