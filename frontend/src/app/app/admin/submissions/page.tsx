"use client";

// ─── Admin Submissions Review Queue ─────────────────────────────────────────
// Accessible at /app/admin/submissions — uses SECURITY DEFINER functions
// that bypass RLS. In production, restrict route via middleware or auth check.

import { useState, useCallback, useMemo } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import { createClient } from "@/lib/supabase/client";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import type { AdminSubmission } from "@/lib/types";
import { callRpc } from "@/lib/rpc";
import type { RpcResult } from "@/lib/types";
import type {
  AdminSubmissionsResponse,
  AdminReviewResponse,
} from "@/lib/types";

const STATUS_TABS = [
  { value: "pending", label: "⏳ Pending" },
  { value: "approved", label: "✅ Approved" },
  { value: "rejected", label: "❌ Rejected" },
  { value: "merged", label: "🔗 Merged" },
  { value: "all", label: "All" },
] as const;

export default function AdminSubmissionsPage() {
  const supabase = createClient();
  const queryClient = useQueryClient();
  const [statusFilter, setStatusFilter] = useState("pending");
  const [page, setPage] = useState(1);

  const queryKey = useMemo(
    () => ["admin-submissions", statusFilter, page],
    [statusFilter, page],
  );

  const { data, isLoading, error } = useQuery({
    queryKey,
    queryFn: async () => {
      const result: RpcResult<AdminSubmissionsResponse> =
        await callRpc<AdminSubmissionsResponse>(
          supabase,
          "api_admin_get_submissions",
          {
            p_status: statusFilter,
            p_page: page,
            p_page_size: 20,
          },
        );
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: 30_000,
  });

  const reviewMutation = useMutation({
    mutationFn: async ({
      submissionId,
      action,
      mergedProductId,
    }: {
      submissionId: string;
      action: string;
      mergedProductId?: number;
    }) => {
      const result: RpcResult<AdminReviewResponse> =
        await callRpc<AdminReviewResponse>(
          supabase,
          "api_admin_review_submission",
          {
            p_submission_id: submissionId,
            p_action: action,
            ...(mergedProductId
              ? { p_merged_product_id: mergedProductId }
              : {}),
          },
        );
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    onSuccess: (data) => {
      toast.success(`Submission ${data.status}`);
      queryClient.invalidateQueries({ queryKey: ["admin-submissions"] });
    },
    onError: (err: Error) => {
      toast.error(err.message);
    },
  });

  const handleRetry = useCallback(() => {
    queryClient.invalidateQueries({ queryKey });
  }, [queryClient, queryKey]);

  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-lg font-semibold text-gray-900">
          🛡️ Admin: Submission Review
        </h1>
        <p className="text-sm text-gray-500">
          Review and approve user-submitted products
        </p>
      </div>

      {/* Status tabs */}
      <div className="flex flex-wrap gap-1">
        {STATUS_TABS.map((tab) => (
          <button
            key={tab.value}
            onClick={() => {
              setStatusFilter(tab.value);
              setPage(1);
            }}
            className={`rounded-lg px-3 py-1.5 text-sm font-medium transition-colors ${
              statusFilter === tab.value
                ? "bg-brand-600 text-white"
                : "bg-gray-100 text-gray-600 hover:bg-gray-200"
            }`}
          >
            {tab.label}
          </button>
        ))}
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
          <p className="mb-2 text-sm text-red-600">Failed to load.</p>
          <button
            onClick={handleRetry}
            className="text-sm font-medium text-red-700"
          >
            🔄 Retry
          </button>
        </div>
      )}

      {/* Empty */}
      {data && data.submissions.length === 0 && (
        <div className="py-12 text-center">
          <p className="text-sm text-gray-500">
            No {statusFilter} submissions.
          </p>
        </div>
      )}

      {/* Submission cards */}
      {data && data.submissions.length > 0 && (
        <ul className="space-y-3">
          {data.submissions.map((sub) => (
            <AdminSubmissionCard
              key={sub.id}
              submission={sub}
              onApprove={() =>
                reviewMutation.mutate({
                  submissionId: sub.id,
                  action: "approve",
                })
              }
              onReject={() =>
                reviewMutation.mutate({
                  submissionId: sub.id,
                  action: "reject",
                })
              }
              isPending={reviewMutation.isPending}
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
            {data.page} / {data.pages} ({data.total} total)
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

function AdminSubmissionCard({
  submission,
  onApprove,
  onReject,
  isPending,
}: Readonly<{
  submission: AdminSubmission;
  onApprove: () => void;
  onReject: () => void;
  isPending: boolean;
}>) {
  const date = new Date(submission.created_at).toLocaleString();
  const canReview = submission.status === "pending";

  return (
    <li className="card">
      <div className="space-y-2">
        <div className="flex items-start justify-between">
          <div>
            <p className="font-medium text-gray-900">
              {submission.product_name}
            </p>
            <p className="text-sm text-gray-500">
              {submission.brand && `${submission.brand} · `}
              EAN: <span className="font-mono">{submission.ean}</span>
            </p>
          </div>
          <span
            className={`rounded-full px-2 py-0.5 text-xs font-medium ${
              submission.status === "pending"
                ? "bg-amber-100 text-amber-700"
                : submission.status === "approved"
                  ? "bg-green-100 text-green-700"
                  : submission.status === "rejected"
                    ? "bg-red-100 text-red-700"
                    : "bg-blue-100 text-blue-700"
            }`}
          >
            {submission.status}
          </span>
        </div>

        {submission.category && (
          <p className="text-xs text-gray-500">
            Category: {submission.category}
          </p>
        )}

        {submission.notes && (
          <p className="rounded-md bg-gray-50 p-2 text-xs text-gray-600">
            📝 {submission.notes}
          </p>
        )}

        <div className="flex items-center justify-between text-xs text-gray-400">
          <span>Submitted: {date}</span>
          <span className="font-mono">
            user: {submission.user_id.slice(0, 8)}…
          </span>
        </div>

        {canReview && (
          <div className="flex gap-2 border-t border-gray-100 pt-2">
            <button
              onClick={onApprove}
              disabled={isPending}
              className="flex-1 rounded-lg bg-green-50 px-3 py-2 text-sm font-medium text-green-700 hover:bg-green-100 disabled:opacity-50"
            >
              ✅ Approve
            </button>
            <button
              onClick={onReject}
              disabled={isPending}
              className="flex-1 rounded-lg bg-red-50 px-3 py-2 text-sm font-medium text-red-700 hover:bg-red-100 disabled:opacity-50"
            >
              ❌ Reject
            </button>
          </div>
        )}

        {submission.reviewed_at && (
          <p className="text-xs text-gray-400">
            Reviewed: {new Date(submission.reviewed_at).toLocaleString()}
          </p>
        )}
      </div>
    </li>
  );
}
