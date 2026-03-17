"use client";

// ─── Admin Submissions Review Queue ─────────────────────────────────────────
// Accessible at /app/admin/submissions — uses SECURITY DEFINER functions
// that bypass RLS. In production, restrict route via middleware or auth check.

import { Button } from "@/components/common/Button";
import { CountryChip } from "@/components/common/CountryChip";
import { EmptyStateIllustration } from "@/components/common/EmptyStateIllustration";
import { SubmissionsSkeleton } from "@/components/common/skeletons";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { COUNTRIES } from "@/lib/constants";
import { useTranslation } from "@/lib/i18n";
import { callRpc } from "@/lib/rpc";
import { createClient } from "@/lib/supabase/client";
import { showToast } from "@/lib/toast";
import type {
  AdminBatchRejectResponse,
  AdminReviewResponse,
  AdminSubmission,
  AdminSubmissionsResponse,
  AdminVelocityResponse,
  RpcResult,
} from "@/lib/types";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  Activity,
  Ban,
  CheckCircle,
  Clock,
  FileText,
  Link2,
  RefreshCw,
  ShieldAlert,
  ShieldCheck,
  XCircle,
} from "lucide-react";
import { useCallback, useMemo, useState } from "react";

const TAB_KEYS: Record<string, string> = {
  pending: "admin.pendingTab",
  approved: "admin.approvedTab",
  rejected: "admin.rejectedTab",
  merged: "admin.mergedTab",
  all: "admin.allTab",
};

const STATUS_TABS = [
  { value: "pending", icon: Clock },
  { value: "approved", icon: CheckCircle },
  { value: "rejected", icon: XCircle },
  { value: "merged", icon: Link2 },
  { value: "all", icon: null },
] as const;

export default function AdminSubmissionsPage() {
  const { t } = useTranslation();
  const supabase = createClient();
  const queryClient = useQueryClient();
  const [statusFilter, setStatusFilter] = useState("pending");
  const [countryFilter, setCountryFilter] = useState<string | null>(null);
  const [page, setPage] = useState(1);

  const queryKey = useMemo(
    () => ["admin-submissions", statusFilter, countryFilter, page],
    [statusFilter, countryFilter, page],
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
            p_country: countryFilter,
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
      showToast({
        type: "success",
        messageKey: "toast.submissionStatus",
        messageParams: { status: data.status },
      });
      queryClient.invalidateQueries({ queryKey: ["admin-submissions"] });
    },
    onError: (err: Error) => {
      showToast({ type: "error", message: err.message });
    },
  });

  const { data: velocityData } = useQuery({
    queryKey: ["admin-velocity"],
    queryFn: async () => {
      const result: RpcResult<AdminVelocityResponse> =
        await callRpc<AdminVelocityResponse>(
          supabase,
          "api_admin_submission_velocity",
          {},
        );
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: 60_000,
  });

  const batchRejectMutation = useMutation({
    mutationFn: async ({
      userId,
      reason,
    }: {
      userId: string;
      reason?: string;
    }) => {
      const result: RpcResult<AdminBatchRejectResponse> =
        await callRpc<AdminBatchRejectResponse>(
          supabase,
          "api_admin_batch_reject_user",
          {
            p_user_id: userId,
            ...(reason ? { p_reason: reason } : {}),
          },
        );
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    onSuccess: (data) => {
      showToast({
        type: "success",
        message: `Rejected ${data.rejected_count} submissions, user flagged`,
      });
      queryClient.invalidateQueries({ queryKey: ["admin-submissions"] });
      queryClient.invalidateQueries({ queryKey: ["admin-velocity"] });
    },
    onError: (err: Error) => {
      showToast({ type: "error", message: err.message });
    },
  });

  const handleRetry = useCallback(() => {
    queryClient.invalidateQueries({ queryKey });
  }, [queryClient, queryKey]);

  return (
    <div className="space-y-4">
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "nav.admin", href: "/app/admin/submissions" },
          { labelKey: "admin.submissionReview" },
        ]}
      />
      <div>
        <h1 className="flex items-center gap-2 text-lg font-semibold text-foreground">
          <ShieldCheck size={20} aria-hidden="true" />
          {t("admin.submissionReview")}
        </h1>
        <p className="text-sm text-foreground-secondary">
          {t("admin.reviewSubtitle")}
        </p>
      </div>

      {/* Velocity widget (#474) */}
      {velocityData && (
        <div
          className="grid grid-cols-2 gap-2 sm:grid-cols-4"
          data-testid="velocity-widget"
        >
          <div className="card p-3 text-center">
            <p className="text-2xl font-bold text-foreground">
              {velocityData.pending_count}
            </p>
            <p className="text-xs text-foreground-secondary">
              <Clock size={12} aria-hidden="true" className="mr-1 inline" />
              Pending
            </p>
          </div>
          <div className="card p-3 text-center">
            <p className="text-2xl font-bold text-foreground">
              {velocityData.last_24h}
            </p>
            <p className="text-xs text-foreground-secondary">
              <Activity size={12} aria-hidden="true" className="mr-1 inline" />
              Last 24h
            </p>
          </div>
          <div className="card p-3 text-center">
            <p className="text-2xl font-bold text-foreground">
              {velocityData.last_7d}
            </p>
            <p className="text-xs text-foreground-secondary">Last 7d</p>
          </div>
          <div className="card p-3 text-center">
            <p className="text-2xl font-bold text-error">
              {velocityData.auto_rejected_24h}
            </p>
            <p className="text-xs text-foreground-secondary">
              <Ban size={12} aria-hidden="true" className="mr-1 inline" />
              Auto-rejected 24h
            </p>
          </div>
        </div>
      )}

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
                ? "bg-brand text-white"
                : "bg-surface-muted text-foreground-secondary hover:bg-surface-muted"
            }`}
          >
            {tab.icon &&
              (() => {
                const TabIcon = tab.icon;
                return (
                  <TabIcon size={14} aria-hidden="true" className="inline" />
                );
              })()}{" "}
            {t(TAB_KEYS[tab.value])}
          </button>
        ))}
      </div>

      {/* Country filter */}
      <div className="flex items-center gap-2">
        <span className="text-sm text-foreground-secondary">
          {t("admin.countryLabel")}
        </span>
        <select
          value={countryFilter ?? ""}
          onChange={(e) => {
            setCountryFilter(e.target.value || null);
            setPage(1);
          }}
          className="rounded-lg border bg-surface px-2 py-1 text-sm text-foreground"
          data-testid="country-filter"
        >
          <option value="">{t("admin.allCountries")}</option>
          {COUNTRIES.map((c) => (
            <option key={c.code} value={c.code}>
              {c.code}
            </option>
          ))}
          <option value="__none__">{t("admin.noCountry")}</option>
        </select>
      </div>

      {/* Loading */}
      {isLoading && <SubmissionsSkeleton />}

      {/* Error */}
      {error && (
        <div className="card border-error-border bg-error-bg text-center">
          <p className="mb-2 text-sm text-error-text">{t("admin.loadFailed")}</p>
          <button
            onClick={handleRetry}
            className="text-sm font-medium text-error-text"
          >
            <RefreshCw size={14} aria-hidden="true" className="inline" />{" "}
            {t("common.retry")}
          </button>
        </div>
      )}

      {/* Empty */}
      {data?.submissions.length === 0 && (
        <EmptyStateIllustration
          type="no-submissions"
          titleKey="admin.noSubmissions"
          titleParams={{ status: statusFilter }}
        />
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
              onBatchReject={() =>
                batchRejectMutation.mutate({ userId: sub.user_id })
              }
              isPending={
                reviewMutation.isPending || batchRejectMutation.isPending
              }
            />
          ))}
        </ul>
      )}

      {/* Pagination */}
      {data && data.pages > 1 && (
        <div className="flex items-center justify-center gap-2 pt-2">
          <Button
            variant="secondary"
            size="sm"
            onClick={() => setPage((p) => Math.max(1, p - 1))}
            disabled={page <= 1}
          >
            {t("common.prev")}
          </Button>
          <span className="text-sm text-foreground-secondary">
            {data.page} / {data.pages} ({data.total} total)
          </span>
          <Button
            variant="secondary"
            size="sm"
            onClick={() => setPage((p) => Math.min(data.pages, p + 1))}
            disabled={page >= data.pages}
          >
            {t("common.next")}
          </Button>
        </div>
      )}
    </div>
  );
}

function statusBadgeClass(status: string): string {
  switch (status) {
    case "pending":
      return "bg-warning-bg text-warning-text";
    case "approved":
      return "bg-success-bg text-success-text";
    case "rejected":
      return "bg-error-bg text-error-text";
    default:
      return "bg-info-bg text-info-text";
  }
}

function trustBadgeClass(score: number | null): string {
  if (score === null) return "bg-surface-muted text-foreground-secondary";
  if (score >= 80) return "bg-success-bg text-success-text";
  if (score < 20) return "bg-error-bg text-error-text";
  if (score < 40) return "bg-warning-bg text-warning-text";
  return "bg-surface-muted text-foreground-secondary";
}

function AdminSubmissionCard({
  submission,
  onApprove,
  onReject,
  onBatchReject,
  isPending,
}: Readonly<{
  submission: AdminSubmission;
  onApprove: () => void;
  onReject: () => void;
  onBatchReject: () => void;
  isPending: boolean;
}>) {
  const { t } = useTranslation();
  const date = new Date(submission.created_at).toLocaleString();
  const canReview = submission.status === "pending";
  const effectiveCountry = submission.suggested_country ?? submission.scan_country;

  return (
    <li className="card">
      <div className="space-y-2">
        <div className="flex items-start justify-between">
          <div>
            <p className="font-medium text-foreground">
              {submission.product_name}
              {submission.user_flagged && (
                <ShieldAlert
                  size={14}
                  aria-label={t("a11y.flaggedUser")}
                  className="ml-1 inline text-error"
                />
              )}
            </p>
            <p className="text-sm text-foreground-secondary">
              {submission.brand && `${submission.brand} · `}
              {t("admin.eanLabel")}{" "}
              <span className="font-mono">{submission.ean}</span>
            </p>
          </div>
          <div className="flex items-center gap-2">
            <CountryChip
              country={effectiveCountry}
              size="sm"
              nullLabel={t("admin.noCountry")}
            />
            {submission.user_trust_score !== null &&
              submission.user_trust_score !== undefined && (
                <span
                  className={`rounded-full px-2 py-0.5 text-xs font-medium ${trustBadgeClass(submission.user_trust_score)}`}
                >
                  Trust {submission.user_trust_score}
                </span>
              )}
            <span
              className={`rounded-full px-2 py-0.5 text-xs font-medium ${statusBadgeClass(submission.status)}`}
            >
              {submission.status}
            </span>
          </div>
        </div>

        {submission.category && (
          <p className="text-xs text-foreground-secondary">
            {t("admin.categoryLabel")} {submission.category}
          </p>
        )}

        {/* Legacy help text for null-country submissions */}
        {!effectiveCountry && (
          <p className="text-xs italic text-foreground-muted" data-testid="no-country-info">
            ℹ {t("admin.noCountryHint")}
          </p>
        )}

        {submission.existing_product_match && (
          <p className="text-xs text-warning-text">
            ⚠ Possible duplicate — existing product #{submission.existing_product_match.product_id}{" "}
            ({submission.existing_product_match.product_name})
          </p>
        )}

        {/* GS1 country mismatch badge (#929) */}
        {submission.gs1_hint &&
          submission.gs1_hint.code !== "UNKNOWN" &&
          submission.gs1_hint.code !== "STORE" &&
          effectiveCountry &&
          submission.gs1_hint.code !== effectiveCountry && (
            <p className="text-xs text-warning-text" data-testid="gs1-mismatch-badge">
              ⚠ {t("admin.gs1Mismatch", {
                gs1Country: submission.gs1_hint.name,
                effectiveCountry: effectiveCountry,
              })}
            </p>
          )}

        {/* GS1 informational hint for legacy null-country submissions */}
        {!effectiveCountry &&
          submission.gs1_hint &&
          submission.gs1_hint.code !== "UNKNOWN" &&
          submission.gs1_hint.code !== "STORE" && (
            <p className="text-xs text-foreground-secondary" data-testid="gs1-info-hint">
              ℹ {t("admin.gs1InfoHint", { gs1Country: submission.gs1_hint.name })}
            </p>
          )}

        {/* Region mismatch badge (#929) */}
        {submission.scan_country &&
          submission.suggested_country &&
          submission.scan_country !== submission.suggested_country && (
            <p className="text-xs text-info-text" data-testid="region-mismatch-badge">
              ℹ {t("admin.regionMismatch", {
                scanCountry: submission.scan_country,
                suggestedCountry: submission.suggested_country,
              })}
            </p>
          )}

        {/* Cross-country product badge (#929) */}
        {submission.cross_country_products.length > 0 && (
          <p className="text-xs text-info-text" data-testid="cross-country-badge">
            ℹ {t("admin.crossCountryProducts", {
              count: submission.cross_country_products.length,
              countries: submission.cross_country_products
                .map((p) => p.country)
                .filter((v, i, a) => a.indexOf(v) === i)
                .join(", "),
            })}
          </p>
        )}

        {submission.review_notes && (
          <p className="rounded-md bg-warning-bg p-2 text-xs text-warning-text">
            <ShieldAlert size={14} aria-hidden="true" className="mr-1 inline" />
            {submission.review_notes}
          </p>
        )}

        {submission.notes && (
          <p className="rounded-md bg-surface-subtle p-2 text-xs text-foreground-secondary">
            <FileText size={14} aria-hidden="true" className="inline" />{" "}
            {submission.notes}
          </p>
        )}

        <div className="flex items-center justify-between text-xs text-foreground-muted">
          <span>
            {t("admin.submittedLabel")} {date}
            {submission.user_total_submissions != null && (
              <span className="ml-2">
                ({submission.user_total_submissions} total,{" "}
                {submission.user_approved_pct ?? 0}% approved)
              </span>
            )}
          </span>
          <span className="font-mono">
            user: {submission.user_id.slice(0, 8)}…
          </span>
        </div>

        {canReview && (
          <div className="flex gap-2 border-t border pt-2">
            <button
              onClick={onApprove}
              disabled={isPending}
              className="flex-1 rounded-lg bg-success-bg px-3 py-2 text-sm font-medium text-success-text hover:bg-success-bg disabled:opacity-50"
            >
              {t("admin.approve")}
            </button>
            <button
              onClick={onReject}
              disabled={isPending}
              className="flex-1 rounded-lg bg-error-bg px-3 py-2 text-sm font-medium text-error-text hover:bg-error-bg disabled:opacity-50"
            >
              {t("admin.reject")}
            </button>
            <button
              onClick={onBatchReject}
              disabled={isPending}
              className="rounded-lg bg-error-bg px-3 py-2 text-sm font-medium text-error-text hover:bg-error-bg disabled:opacity-50"
              title="Reject all pending submissions from this user and flag account"
            >
              <Ban size={14} aria-hidden="true" className="mr-1 inline" />
              Reject All
            </button>
          </div>
        )}

        {submission.reviewed_at && (
          <p className="text-xs text-foreground-muted">
            {t("admin.reviewedLabel")}{" "}
            {new Date(submission.reviewed_at).toLocaleString()}
          </p>
        )}
      </div>
    </li>
  );
}
