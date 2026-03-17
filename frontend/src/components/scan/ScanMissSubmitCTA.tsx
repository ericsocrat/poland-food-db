"use client";

import { ButtonLink } from "@/components/common/Button";
import { useTranslation } from "@/lib/i18n";
import { Clock, FileText } from "lucide-react";

interface ScanMissSubmitCTAProps {
  ean: string;
  hasPendingSubmission?: boolean;
  country?: string;
}

/** CTA shown when a scanned barcode is not found in the database. */
export function ScanMissSubmitCTA({
  ean,
  hasPendingSubmission = false,
  country,
}: ScanMissSubmitCTAProps) {
  const { t } = useTranslation();

  if (hasPendingSubmission) {
    return (
      <div className="card border-warning-border bg-warning-bg">
        <p className="text-sm text-warning-text">
          <span className="inline-flex items-center gap-1">
            <Clock size={16} aria-hidden="true" />{" "}
            {t("scan.alreadySubmitted")}
          </span>
        </p>
      </div>
    );
  }

  const submitHref = country
    ? `/app/scan/submit?ean=${ean}&country=${country}`
    : `/app/scan/submit?ean=${ean}`;

  return (
    <div className="space-y-2">
      <ButtonLink
        href={submitHref}
        fullWidth
        icon={<FileText size={16} aria-hidden="true" />}
      >
        {t("scan.helpAdd")}
      </ButtonLink>
      <p className="text-center text-xs text-foreground-muted">
        {t("scan.helpAddHint")}
      </p>
    </div>
  );
}
