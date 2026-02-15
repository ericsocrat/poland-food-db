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
import type { Submission } from "@/lib/types";

const STATUS_STYLES: Record<
  string,
  { bg: string; text: string; label: string }
> = {
  pending: { bg: "bg-amber-100", text: "text-amber-700", label: "⏳ Pending" },
  approved: {
    bg: "bg-green-100",
    text: "text-green-700",
    label: "✅ Approved",
  },
  rejected: { bg: "bg-red-100", text: "text-red-700", label: "❌ Rejected" },
  merged: { bg: "bg-blue-100", text: "text-blue-700", label: "🔗 Merged" },
};

export default function MySubmissionsPage() {
  const supabase = createClient();
  const router = useRouter();
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);

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
          <h1 className="text-lg font-semibold text-gray-900">
            📝 My Submissions
          </h1>
          <p className="text-sm text-gray-500">
            Products you&apos;ve submitted for review
          </p>
        </div>
        <Link
          href="/app/scan"
          className="text-sm text-brand-600 hover:text-brand-700"
        >
          ← Back to Scanner
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
            Failed to load submissions.
          </p>
          <button
            onClick={handleRetry}
            className="text-sm font-medium text-red-700 hover:text-red-800"
          >
            🔄 Retry
          </button>
        </div>
      )}

      {/* Empty */}
      {data?.submissions.length === 0 && (
        <div className="py-12 text-center">
          <p className="mb-2 text-4xl">📝</p>
          <p className="mb-1 text-sm text-gray-500">No submissions yet</p>
          <p className="mb-4 text-xs text-gray-400">
            When you scan a product not in our database, you can submit it for
            review.
          </p>
          <Link
            href="/app/scan"
            className="text-sm text-brand-600 hover:text-brand-700"
          >
            Start scanning →
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
            ← Prev
          </button>
          <span className="text-sm text-gray-500">
            Page {data.page} of {data.pages}
          </span>
          <button
            onClick={() => setPage((p) => Math.min(data.pages, p + 1))}
            disabled={page >= data.pages}
            className="btn-secondary px-3 py-1.5 text-sm disabled:opacity-40"
          >
            Next →
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
  const style = STATUS_STYLES[submission.status] ?? STATUS_STYLES.pending;
  const date = new Date(submission.created_at).toLocaleDateString();

  return (
    <li className="card">
      <div className="flex items-start gap-3">
        <div className="min-w-0 flex-1">
          <div className="flex items-center gap-2">
            <p className="truncate font-medium text-gray-900">
              {submission.product_name}
            </p>
            <span
              className={`inline-flex flex-shrink-0 rounded-full px-2 py-0.5 text-xs font-medium ${style.bg} ${style.text}`}
            >
              {style.label}
            </span>
          </div>
          <p className="mt-0.5 text-xs text-gray-500">
            {submission.brand && `${submission.brand} · `}
            EAN: <span className="font-mono">{submission.ean}</span>
          </p>
          {submission.category && (
            <p className="text-xs text-gray-400">
              Category: {submission.category}
            </p>
          )}
          <p className="mt-1 text-xs text-gray-400">Submitted {date}</p>
        </div>

        {/* View product link if merged/approved */}
        {submission.merged_product_id && (
          <button
            onClick={() => onViewProduct(submission.merged_product_id!)}
            className="flex-shrink-0 rounded-lg px-3 py-1.5 text-xs font-medium text-brand-600 hover:bg-brand-50"
          >
            View →
          </button>
        )}
      </div>

      {/* Status timeline */}
      <div className="mt-3 flex items-center gap-1 text-xs text-gray-400">
        <StatusDot active={true} />
        <span>Submitted</span>
        <span className="mx-1">→</span>
        <StatusDot
          active={submission.status !== "pending"}
          color={statusDotColor(submission.status)}
        />
        <span>{statusReviewLabel(submission.status)}</span>
        {(submission.status === "approved" ||
          submission.status === "merged") && (
          <>
            <span className="mx-1">→</span>
            <StatusDot
              active={submission.status === "merged"}
              color={
                submission.status === "merged" ? "bg-blue-400" : "bg-gray-300"
              }
            />
            <span>Live</span>
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
      return "bg-gray-300";
    default:
      return "bg-green-400";
  }
}

function statusReviewLabel(status: string): string {
  switch (status) {
    case "pending":
      return "In Review";
    case "rejected":
      return "Rejected";
    default:
      return "Approved";
  }
}

function StatusDot({
  active,
  color,
}: Readonly<{ active: boolean; color?: string }>) {
  return (
    <span
      className={`inline-block h-2 w-2 rounded-full ${
        color ?? (active ? "bg-green-400" : "bg-gray-300")
      }`}
    />
  );
}
