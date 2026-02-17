"use client";

// ─── My Submissions page — user's product submissions with status ───────────

import { useState, useCallback } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { getMySubmissions } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import { useTranslation } from "@/lib/i18n";
import type { Submission } from "@/lib/types";

const STATUS_STYLES: Record<
  string,
  { bg: string; text: string; emoji: string; labelKey: string }
> = {
  pending: {
    bg: "bg-amber-100",
    text: "text-amber-700",
    emoji: "⏳",
    labelKey: "scan.statusPending",
  },
  approved: {
    bg: "bg-green-100",
    text: "text-green-700",
    emoji: "✅",
    labelKey: "scan.statusApproved",
  },
  rejected: {
    bg: "bg-red-100",
    text: "text-red-700",
    emoji: "❌",
    labelKey: "scan.statusRejected",
  },
  merged: {
    bg: "bg-blue-100",
    text: "text-blue-700",
    emoji: "🔗",
    labelKey: "scan.statusMerged",
  },
};

export default function MySubmissionsPage() {
  const supabase = createClient();
  const router = useRouter();
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);
  const { t } = useTranslation();

  const { data, isLoading, error } = useQuery({
    queryKey: queryKeys.mySubmissions(page),
    queryFn: async () => {
      const result = await getMySubmissions(supabase, page, 20);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.mySubmissions,
  });

  const handleRetry = useCallback(() => {
    queryClient.invalidateQueries({
      queryKey: queryKeys.mySubmissions(page),
    });
  }, [queryClient, page]);

  return (
    <div className="space-y-4">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-lg font-semibold text-foreground">
            {"📝 "}
            {t("scan.mySubmissions")}
          </h1>
          <p className="text-sm text-foreground-secondary">
            {t("scan.submissionsSubtitle")}
          </p>
        </div>
        <Link
          href="/app/scan"
          className="text-sm text-brand-600 hover:text-brand-700"
        >
          {t("scanHistory.backToScanner")}
        </Link>
      </div>

      {/* Loading */}
      {isLoading && (
        <div className="flex justify-center py-12">
          <LoadingSpinner />
        </div>
      )}

      {/* Error */}
      {error && (
        <div className="card border-red-200 bg-red-50 text-center">
          <p className="mb-2 text-sm text-red-600">
            {t("scan.submissionsLoadFailed")}
          </p>
          <button
            onClick={handleRetry}
            className="text-sm font-medium text-red-700 hover:text-red-800"
          >
            {"🔄 "}
            {t("common.retry")}
          </button>
        </div>
      )}

      {/* Empty */}
      {data?.submissions.length === 0 && (
        <div className="py-12 text-center">
          <p className="mb-2 text-4xl">📝</p>
          <p className="mb-1 text-sm text-foreground-secondary">
            {t("scan.submissionsEmptyTitle")}
          </p>
          <p className="mb-4 text-xs text-foreground-muted">
            {t("scan.submissionsEmptyMessage")}
          </p>
          <Link
            href="/app/scan"
            className="text-sm text-brand-600 hover:text-brand-700"
          >
            {t("scan.startScanning")}
          </Link>
        </div>
      )}

      {/* Submission list */}
      {data && data.submissions.length > 0 && (
        <ul className="space-y-2">
          {data.submissions.map((sub) => (
            <SubmissionRow
              key={sub.id}
              submission={sub}
              onViewProduct={(id) => router.push(`/app/product/${id}`)}
            />
          ))}
        </ul>
      )}

      {/* Pagination */}
      {data && data.pages > 1 && (
        <div className="flex items-center justify-center gap-2 pt-2">
          <button
            onClick={() => setPage((p) => Math.max(1, p - 1))}
            disabled={page <= 1}
            className="btn-secondary px-3 py-1.5 text-sm disabled:opacity-40"
          >
            {t("common.prev")}
          </button>
          <span className="text-sm text-foreground-secondary">
            {t("common.pageOf", { page: data.page, pages: data.pages })}
          </span>
          <button
            onClick={() => setPage((p) => Math.min(data.pages, p + 1))}
            disabled={page >= data.pages}
            className="btn-secondary px-3 py-1.5 text-sm disabled:opacity-40"
          >
            {t("common.next")}
          </button>
        </div>
      )}
    </div>
  );
}

function SubmissionRow({
  submission,
  onViewProduct,
}: Readonly<{
  submission: Submission;
  onViewProduct: (productId: number) => void;
}>) {
  const { t } = useTranslation();
  const style = STATUS_STYLES[submission.status] ?? STATUS_STYLES.pending;
  const date = new Date(submission.created_at).toLocaleDateString();

  return (
    <li className="card">
      <div className="flex items-start gap-3">
        <div className="min-w-0 flex-1">
          <div className="flex items-center gap-2">
            <p className="truncate font-medium text-foreground">
              {submission.product_name}
            </p>
            <span
              className={`inline-flex flex-shrink-0 rounded-full px-2 py-0.5 text-xs font-medium ${style.bg} ${style.text}`}
            >
              {style.emoji} {t(style.labelKey)}
            </span>
          </div>
          <p className="mt-0.5 text-xs text-foreground-secondary">
            {submission.brand && `${submission.brand} · `}
            EAN: <span className="font-mono">{submission.ean}</span>
          </p>
          {submission.category && (
            <p className="text-xs text-foreground-muted">
              {t("scan.categoryLabel", { category: submission.category })}
            </p>
          )}
          <p className="mt-1 text-xs text-foreground-muted">
            {t("scan.submittedDate", { date })}
          </p>
        </div>

        {/* View product link if merged/approved */}
        {submission.merged_product_id && (
          <button
            onClick={() => onViewProduct(submission.merged_product_id ?? 0)}
            className="flex-shrink-0 rounded-lg px-3 py-1.5 text-xs font-medium text-brand-600 hover:bg-brand-50"
          >
            {t("scan.viewProduct")}
          </button>
        )}
      </div>

      {/* Status timeline */}
      <div className="mt-3 flex items-center gap-1 text-xs text-foreground-muted">
        <StatusDot active={true} />
        <span>{t("scan.statusSubmitted")}</span>
        <span className="mx-1">→</span>
        <StatusDot
          active={submission.status !== "pending"}
          color={statusDotColor(submission.status)}
        />
        <span>{t(statusReviewLabelKey(submission.status))}</span>
        {(submission.status === "approved" ||
          submission.status === "merged") && (
          <>
            <span className="mx-1">→</span>
            <StatusDot
              active={submission.status === "merged"}
              color={
                submission.status === "merged" ? "bg-blue-400" : "bg-surface-muted"
              }
            />
            <span>{t("scan.statusLive")}</span>
          </>
        )}
      </div>
    </li>
  );
}

function statusDotColor(status: string): string {
  switch (status) {
    case "rejected":
      return "bg-red-400";
    case "pending":
      return "bg-surface-muted";
    default:
      return "bg-green-400";
  }
}

function statusReviewLabelKey(status: string): string {
  switch (status) {
    case "pending":
      return "scan.statusInReview";
    case "rejected":
      return "scan.statusRejected";
    default:
      return "scan.statusApproved";
  }
}

function StatusDot({
  active,
  color,
}: Readonly<{ active: boolean; color?: string }>) {
  return (
    <span
      className={`inline-block h-2 w-2 rounded-full ${
        color ?? (active ? "bg-green-400" : "bg-surface-muted")
      }`}
    />
  );
}
