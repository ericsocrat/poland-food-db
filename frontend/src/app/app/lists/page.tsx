"use client";

// ─── Lists overview page ────────────────────────────────────────────────────
// Shows all user lists with item counts, create-new-list form, and links to
// individual list detail pages. Default lists (Favorites, Avoid) show first.

import { useState } from "react";
import Link from "next/link";
import { useLists, useCreateList, useDeleteList } from "@/hooks/use-lists";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import { ConfirmDialog } from "@/components/common/ConfirmDialog";
import type { ProductList, FormSubmitEvent } from "@/lib/types";

export default function ListsPage() {
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
    return (
      <div className="flex justify-center py-12">
        <LoadingSpinner />
      </div>
    );
  }

  if (error) {
    return (
      <div className="card border-red-200 bg-red-50 py-8 text-center">
        <p className="mb-3 text-sm text-red-600">Failed to load lists.</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-bold text-gray-900">📋 My Lists</h1>
        <button
          type="button"
          className="btn-primary text-sm"
          onClick={() => setShowForm((v) => !v)}
        >
          {showForm ? "Cancel" : "+ New List"}
        </button>
      </div>

      {/* Create form */}
      {showForm && (
        <form onSubmit={handleCreate} className="card space-y-3">
          <input
            type="text"
            placeholder="List name"
            value={newName}
            onChange={(e) => setNewName(e.target.value)}
            className="input-field"
            maxLength={100}
            required
            autoFocus
          />
          <input
            type="text"
            placeholder="Description (optional)"
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
              {createList.isPending ? "Creating…" : "Create List"}
            </button>
            <button
              type="button"
              className="btn-secondary text-sm"
              onClick={() => setShowForm(false)}
            >
              Cancel
            </button>
          </div>
        </form>
      )}

      {/* Empty state */}
      {lists.length === 0 && (
        <div className="py-12 text-center">
          <p className="mb-2 text-4xl">📋</p>
          <p className="text-sm text-gray-500">
            No lists yet. Create one to start organizing products.
          </p>
        </div>
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
        title="Delete list?"
        description="This cannot be undone."
        confirmLabel="Delete"
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
  const typeIcon = listTypeIcon(list.list_type);

  return (
    <Link href={`/app/lists/${list.id}`}>
      <div className="card flex items-center gap-3 transition-shadow hover:shadow-md">
        <span className="text-2xl">{typeIcon}</span>

        <div className="min-w-0 flex-1">
          <p className="font-medium text-gray-900">{list.name}</p>
          <p className="text-sm text-gray-500">
            {list.item_count} {list.item_count === 1 ? "item" : "items"}
            {list.description && ` · ${list.description}`}
          </p>
        </div>

        {list.share_enabled && (
          <span
            title="Shared"
            className="rounded-full bg-blue-50 px-2 py-0.5 text-xs text-blue-600"
          >
            🔗 Shared
          </span>
        )}

        {onDelete && (
          <button
            type="button"
            title="Delete list"
            aria-label={`Delete ${list.name}`}
            className="flex h-8 w-8 items-center justify-center rounded-full text-sm text-gray-400 transition-colors hover:bg-red-50 hover:text-red-500"
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
