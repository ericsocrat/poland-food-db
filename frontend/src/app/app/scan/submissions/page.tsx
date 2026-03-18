"use client";

// ─── My Submissions page — user's product submissions with status ───────────

import { Button } from "@/components/common/Button";
import { EmptyStateIllustration } from "@/components/common/EmptyStateIllustration";
import { SubmissionsSkeleton } from "@/components/common/skeletons";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { getMySubmissions } from "@/lib/api";
import { useTranslation } from "@/lib/i18n";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { createClient } from "@/lib/supabase/client";
import type { Submission } from "@/lib/types";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { ContributorBadge } from "@/components/scan/ContributorBadge";
import {
    ArrowLeft,
    CheckCircle,
    Clock,
    FileText,
    Link2,
    RefreshCw,
    XCircle,
    type LucideIcon,
} from "lucide-react";
import { useRouter } from "next/navigation";
import { useCallback, useState } from "react";

const STATUS_STYLES: Record<
  string,
  { bg: string; text: string; icon: LucideIcon; labelKey: string }
> = {
  pending: {
    bg: "bg-warning-bg",
    text: "text-warning-text",
    icon: Clock,
    labelKey: "scan.statusPending",
  },
  approved: {
    bg: "bg-success-bg",
    text: "text-success-text",
    icon: CheckCircle,
    labelKey: "scan.statusApproved",
  },
  rejected: {
    bg: "bg-error-bg",
    text: "text-error-text",
    icon: XCircle,
    labelKey: "scan.statusRejected",
  },
  merged: {
    bg: "bg-info-bg",
    text: "text-info-text",
    icon: Link2,
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
      <div className="hidden md:block">
        <Breadcrumbs
          items={[
            { labelKey: "nav.home", href: "/app" },
            { labelKey: "nav.scan", href: "/app/scan" },
            { labelKey: "scan.mySubmissions" },
          ]}
        />
      </div>
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <div className="flex items-center gap-2">
            <button
              onClick={() => router.back()}
              className="inline-flex items-center justify-center rounded-lg p-1.5 text-foreground-secondary hover:bg-surface-muted md:hidden"
              aria-label={t("common.back")}
            >
              <ArrowLeft size={20} />
            </button>
            <h1 className="text-lg font-semibold text-foreground flex items-center gap-1.5">
              <FileText size={18} aria-hidden="true" />
              {t("scan.mySubmissions")}
            </h1>
          </div>
          <p className="text-sm text-foreground-secondary">
            {t("scan.submissionsSubtitle")}
          </p>
          <ContributorBadge />
        </div>
      </div>

      {/* Loading */}
      {isLoading && <SubmissionsSkeleton />}

      {/* Error */}
      {error && (
        <div className="card border-error-border bg-error-bg text-center">
          <p className="mb-2 text-sm text-error-text">
            {t("scan.submissionsLoadFailed")}
          </p>
          <button
            onClick={handleRetry}
            className="text-sm font-medium text-error-text hover:text-error-text"
          >
            <RefreshCw size={14} aria-hidden="true" className="inline" />{" "}
            {t("common.retry")}
          </button>
        </div>
      )}

      {/* Empty — R10: illustration + contributor teaser */}
      {data?.submissions.length === 0 && (
        <EmptyStateIllustration
          type="no-submissions"
          titleKey="scan.submissionsEmptyTitle"
          descriptionKey="scan.submissionsEmptyMessage"
          action={{ labelKey: "scan.startScanning", href: "/app/scan" }}
        />
      )}

      {/* Submission list */}
      {data && data.submissions.length > 0 && (
        <ul className="space-y-2">
          {data.submissions.map((sub, idx) => (
            <SubmissionRow
              key={sub.id}
              submission={sub}
              index={idx}
              onViewProduct={(id) => router.push(`/app/product/${id}`)}
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
            {t("common.pageOf", { page: data.page, pages: data.pages })}
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

function SubmissionRow({
  submission,
  index,
  onViewProduct,
}: Readonly<{
  submission: Submission;
  index: number;
  onViewProduct: (productId: number) => void;
}>) {
  const { t } = useTranslation();
  const style = STATUS_STYLES[submission.status] ?? STATUS_STYLES.pending;
  const date = new Date(submission.created_at).toLocaleDateString();

  return (
    <li
      className="card animate-[fadeInUp_0.3s_ease-out_both]"
      style={{ animationDelay: `${index * 60}ms` }}
    >
      <div className="flex items-start gap-3">
        <div className="min-w-0 flex-1">
          <div className="flex items-center gap-2">
            <p className="truncate font-medium text-foreground">
              {submission.product_name}
            </p>
            <span
              className={`inline-flex shrink-0 rounded-full px-2 py-0.5 text-xs font-medium ${style.bg} ${style.text}`}
            >
              {(() => {
                const StatusIcon = style.icon;
                return <StatusIcon size={14} aria-hidden="true" />;
              })()}{" "}
              {t(style.labelKey)}
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
            className="shrink-0 rounded-lg px-3 py-1.5 text-xs font-medium text-brand hover:bg-brand-subtle"
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
                submission.status === "merged"
                  ? "bg-info"
                  : "bg-surface-muted"
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
      return "bg-error";
    case "pending":
      return "bg-surface-muted";
    default:
      return "bg-success";
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
        color ?? (active ? "bg-success" : "bg-surface-muted")
      }`}
    />
  );
}
