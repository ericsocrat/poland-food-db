"use client";

// ─── List detail page ───────────────────────────────────────────────────────
// Shows all products in a list with health scores, supports removing items,
// and has share toggle for custom/favorites lists.

import { useState } from "react";
import { useParams } from "next/navigation";
import Link from "next/link";
import {
  useLists,
  useListItems,
  useRemoveFromList,
  useUpdateList,
  useToggleShare,
  useRevokeShare,
} from "@/hooks/use-lists";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import { EmptyState } from "@/components/common/EmptyState";
import { ConfirmDialog } from "@/components/common/ConfirmDialog";
import { useTranslation } from "@/lib/i18n";
import { SCORE_BANDS, NUTRI_COLORS } from "@/lib/constants";
import type { ListItem, FormSubmitEvent } from "@/lib/types";

export default function ListDetailPage() {
  const { t } = useTranslation();
  const params = useParams();
  const listId = String(params.id ?? "");

  const { data: listsData } = useLists();
  const { data: itemsData, isLoading, error } = useListItems(listId);
  const removeMutation = useRemoveFromList();
  const updateMutation = useUpdateList();
  const toggleShareMutation = useToggleShare();
  const revokeShareMutation = useRevokeShare();

  const [editing, setEditing] = useState(false);
  const [editName, setEditName] = useState("");
  const [editDesc, setEditDesc] = useState("");
  const [showSharePanel, setShowSharePanel] = useState(false);
  const [copied, setCopied] = useState(false);
  const [showRevokeConfirm, setShowRevokeConfirm] = useState(false);

  const list = listsData?.lists?.find((l) => l.id === listId);
  const items: ListItem[] = itemsData?.items ?? [];

  function handleSaveEdit(e: FormSubmitEvent) {
    e.preventDefault();
    if (!editName.trim()) return;
    updateMutation.mutate(
      {
        listId,
        name: editName.trim(),
        description: editDesc.trim() || undefined,
      },
      {
        onSuccess: () => setEditing(false),
      },
    );
  }

  function handleShare(enabled: boolean) {
    toggleShareMutation.mutate({ listId, enabled });
  }

  function handleCopyLink() {
    if (!list?.share_token) return;
    const url = `${globalThis.location.origin}/lists/shared/${list.share_token}`;
    navigator.clipboard.writeText(url).then(() => {
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    });
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
      <div className="space-y-4">
        <BackLink />
        <EmptyState variant="error" titleKey="lists.loadListFailed" />
      </div>
    );
  }

  return (
    <div className="space-y-4">
      <BackLink />

      {/* Header */}
      {list && (
        <div className="card">
          {editing ? (
            <form onSubmit={handleSaveEdit} className="space-y-3">
              <input
                type="text"
                value={editName}
                onChange={(e) => setEditName(e.target.value)}
                className="input-field"
                maxLength={100}
                required
                autoFocus
              />
              <input
                type="text"
                value={editDesc}
                onChange={(e) => setEditDesc(e.target.value)}
                className="input-field"
                placeholder={t("lists.descriptionPlaceholder")}
                maxLength={500}
              />
              <div className="flex gap-2">
                <button
                  type="submit"
                  className="btn-primary text-sm"
                  disabled={updateMutation.isPending}
                >
                  {t("common.save")}
                </button>
                <button
                  type="button"
                  className="btn-secondary text-sm"
                  onClick={() => setEditing(false)}
                >
                  {t("common.cancel")}
                </button>
              </div>
            </form>
          ) : (
            <div className="flex items-start justify-between">
              <div>
                <h1 className="text-lg font-bold text-foreground">
                  {list.list_type === "favorites" && "❤️ "}
                  {list.list_type === "avoid" && "🚫 "}
                  {list.name}
                </h1>
                {list.description && (
                  <p className="mt-1 text-sm text-foreground-secondary">
                    {list.description}
                  </p>
                )}
                <p className="mt-1 text-xs text-foreground-muted">
                  {t("common.items", { count: list.item_count })}
                </p>
              </div>
              <div className="flex gap-1">
                {/* Edit button (not for defaults unless custom) */}
                <button
                  type="button"
                  title={t("lists.editList")}
                  className="flex h-8 w-8 items-center justify-center rounded-full text-sm transition-colors hover:bg-surface-muted"
                  onClick={() => {
                    setEditName(list.name);
                    setEditDesc(list.description ?? "");
                    setEditing(true);
                  }}
                >
                  ✏️
                </button>
                {/* Share button (not for avoid lists) */}
                {list.list_type !== "avoid" && (
                  <button
                    type="button"
                    title={t("lists.shareSettings")}
                    className={`flex h-8 w-8 items-center justify-center rounded-full text-sm transition-colors hover:bg-surface-muted ${
                      list.share_enabled ? "text-blue-600" : ""
                    }`}
                    onClick={() => setShowSharePanel((v) => !v)}
                  >
                    🔗
                  </button>
                )}
              </div>
            </div>
          )}

          {/* Share panel */}
          {showSharePanel && list.list_type !== "avoid" && (
            <div className="mt-3 rounded-lg border border bg-surface-subtle p-3">
              <p className="mb-2 text-sm font-medium text-foreground-secondary">
                {t("lists.sharing")}
              </p>
              <div className="flex items-center gap-3">
                <button
                  type="button"
                  className={`rounded-lg px-3 py-1.5 text-sm font-medium transition-colors ${
                    list.share_enabled
                      ? "bg-blue-100 text-blue-700"
                      : "bg-surface-muted text-foreground-secondary"
                  }`}
                  onClick={() => handleShare(!list.share_enabled)}
                  disabled={toggleShareMutation.isPending}
                >
                  {list.share_enabled ? t("lists.on") : t("lists.off")}
                </button>
                {list.share_enabled && list.share_token && (
                  <>
                    <button
                      type="button"
                      className="btn-secondary text-xs"
                      onClick={handleCopyLink}
                    >
                      {copied ? t("lists.copied") : t("lists.copyLink")}
                    </button>
                    <button
                      type="button"
                      className="text-xs text-red-500 hover:text-red-700"
                      onClick={() => setShowRevokeConfirm(true)}
                    >
                      {t("lists.revoke")}
                    </button>
                  </>
                )}
              </div>
            </div>
          )}
        </div>
      )}

      {/* Empty state */}
      {items.length === 0 && (
        <EmptyState
          variant="no-data"
          icon={<span>📭</span>}
          titleKey="lists.emptyList"
          action={{ labelKey: "lists.searchProducts", href: "/app/search" }}
        />
      )}

      {/* Items */}
      {items.length > 0 && (
        <ul className="space-y-2">
          {items.map((item) => (
            <ListItemRow
              key={item.item_id}
              item={item}
              onRemove={() =>
                removeMutation.mutate({
                  listId,
                  productId: item.product_id,
                  listType: list?.list_type,
                })
              }
              isRemoving={removeMutation.isPending}
            />
          ))}
        </ul>
      )}

      <ConfirmDialog
        open={showRevokeConfirm}
        title={t("lists.revokeSharing")}
        description={t("lists.revokeWarning")}
        confirmLabel={t("lists.revoke")}
        variant="danger"
        onConfirm={() => {
          revokeShareMutation.mutate(listId);
          setShowRevokeConfirm(false);
        }}
        onCancel={() => setShowRevokeConfirm(false)}
      />
    </div>
  );
}

// ─── Helpers ────────────────────────────────────────────────────────────────

function scoreToBandKey(score: number): keyof typeof SCORE_BANDS {
  if (score <= 25) return "low";
  if (score <= 50) return "moderate";
  if (score <= 75) return "high";
  return "very_high";
}

// ─── ListItemRow ────────────────────────────────────────────────────────────

function ListItemRow({
  item,
  onRemove,
  isRemoving,
}: Readonly<{
  item: ListItem;
  onRemove: () => void;
  isRemoving: boolean;
}>) {
  const { t } = useTranslation();
  // Derive score band from unhealthiness_score
  const score = item.unhealthiness_score;
  const bandKey = scoreToBandKey(score);
  const band = SCORE_BANDS[bandKey];

  const nutriClass = item.nutri_score_label
    ? (NUTRI_COLORS[item.nutri_score_label] ?? "bg-surface-muted text-foreground-secondary")
    : "bg-surface-muted text-foreground-secondary";

  return (
    <li className="card flex items-center gap-3 transition-shadow hover:shadow-md">
      <Link
        href={`/app/product/${item.product_id}`}
        className="flex min-w-0 flex-1 items-center gap-3"
      >
        {/* Score badge */}
        <div
          className={`flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-lg text-lg font-bold ${band.bg} ${band.color}`}
        >
          {item.unhealthiness_score}
        </div>

        {/* Product info */}
        <div className="min-w-0 flex-1">
          <p className="truncate font-medium text-foreground">
            {item.product_name}
          </p>
          <p className="truncate text-sm text-foreground-secondary">
            {item.brand}
            {item.category && ` · ${item.category}`}
          </p>
          {item.notes && (
            <p className="mt-0.5 truncate text-xs text-foreground-muted italic">
              {item.notes}
            </p>
          )}
        </div>

        {/* Nutri badge */}
        <span
          className={`flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-full text-sm font-bold ${nutriClass}`}
        >
          {item.nutri_score_label ?? "?"}
        </span>
      </Link>

      {/* Remove button */}
      <button
        type="button"
        title={t("lists.removeFromList")}
        aria-label={`Remove ${item.product_name}`}
        disabled={isRemoving}
        className="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-full text-sm text-foreground-muted transition-colors hover:bg-red-50 hover:text-red-500 disabled:opacity-50"
        onClick={(e) => {
          e.preventDefault();
          e.stopPropagation();
          onRemove();
        }}
      >
        ✕
      </button>
    </li>
  );
}

// ─── BackLink ───────────────────────────────────────────────────────────────

function BackLink() {
  const { t } = useTranslation();
  return (
    <Link
      href="/app/lists"
      className="inline-flex items-center gap-1 text-sm text-foreground-secondary hover:text-foreground"
    >
      {t("lists.backToLists")}
    </Link>
  );
}
