"use client";

// ─── Submit Product page — form for adding missing products ─────────────────

import { useState } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import { useMutation } from "@tanstack/react-query";
import { showToast } from "@/lib/toast";
import { eventBus } from "@/lib/events";
import Link from "next/link";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { FileText } from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import { submitProduct } from "@/lib/api";
import { useTranslation } from "@/lib/i18n";
import type { FormSubmitEvent } from "@/lib/types";

export default function SubmitProductPage() {
  const supabase = createClient();
  const router = useRouter();
  const searchParams = useSearchParams();
  const prefillEan = searchParams.get("ean") ?? "";

  const [ean, setEan] = useState(prefillEan);
  const [productName, setProductName] = useState("");
  const [brand, setBrand] = useState("");
  const [category, setCategory] = useState("");
  const [notes, setNotes] = useState("");
  const { t } = useTranslation();

  const mutation = useMutation({
    mutationFn: async () => {
      const result = await submitProduct(supabase, {
        ean,
        productName,
        brand: brand || undefined,
        category: category || undefined,
        notes: notes || undefined,
      });
      if (!result.ok) throw new Error(result.error.message);
      if (result.data.error) throw new Error(result.data.error);
      return result.data;
    },
    onSuccess: () => {
      showToast({ type: "success", messageKey: "submit.successToast" });
      void eventBus.emit({ type: "product.submitted", payload: { ean } });
      router.push("/app/scan/submissions");
    },
    onError: (error: Error) => {
      showToast({ type: "error", message: error.message });
    },
  });

  function handleSubmit(e: FormSubmitEvent) {
    e.preventDefault();
    if (ean.length < 8 || productName.length < 2) return;
    mutation.mutate();
  }

  return (
    <div className="space-y-4">
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "nav.scan", href: "/app/scan" },
          { labelKey: "submit.title" },
        ]}
      />
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-lg font-semibold text-foreground flex items-center gap-1.5">
            <FileText size={18} aria-hidden="true" /> {t("submit.title")}
          </h1>
          <p className="text-sm text-foreground-secondary">
            {t("submit.subtitle")}
          </p>
        </div>
        <Link
          href="/app/scan"
          className="text-sm text-brand hover:text-brand-hover"
        >
          {t("submit.backToScanner")}
        </Link>
      </div>

      <div className="card">
        <form onSubmit={handleSubmit} className="space-y-4">
          {/* EAN (pre-filled, editable) */}
          <div>
            <label
              htmlFor="ean"
              className="mb-1 block text-sm font-medium text-foreground-secondary"
            >
              {t("submit.eanLabel")}
            </label>
            <input
              id="ean"
              type="text"
              value={ean}
              onChange={(e) =>
                setEan(e.target.value.replaceAll(/\D/g, "").slice(0, 13))
              }
              className="input-field font-mono tracking-widest"
              placeholder={t("submit.eanPlaceholder")}
              inputMode="numeric"
              maxLength={13}
              required
              readOnly={!!prefillEan}
            />
          </div>

          {/* Product name */}
          <div>
            <label
              htmlFor="productName"
              className="mb-1 block text-sm font-medium text-foreground-secondary"
            >
              {t("submit.nameLabel")}
            </label>
            <input
              id="productName"
              type="text"
              value={productName}
              onChange={(e) => setProductName(e.target.value)}
              className="input-field"
              placeholder={t("submit.namePlaceholder")}
              maxLength={200}
              required
            />
          </div>

          {/* Brand */}
          <div>
            <label
              htmlFor="brand"
              className="mb-1 block text-sm font-medium text-foreground-secondary"
            >
              {t("submit.brandLabel")}
            </label>
            <input
              id="brand"
              type="text"
              value={brand}
              onChange={(e) => setBrand(e.target.value)}
              className="input-field"
              placeholder={t("submit.brandPlaceholder")}
              maxLength={100}
            />
          </div>

          {/* Category */}
          <div>
            <label
              htmlFor="category"
              className="mb-1 block text-sm font-medium text-foreground-secondary"
            >
              {t("submit.categoryLabel")}
            </label>
            <input
              id="category"
              type="text"
              value={category}
              onChange={(e) => setCategory(e.target.value)}
              className="input-field"
              placeholder={t("submit.categoryPlaceholder")}
              maxLength={100}
            />
          </div>

          {/* Notes */}
          <div>
            <label
              htmlFor="notes"
              className="mb-1 block text-sm font-medium text-foreground-secondary"
            >
              {t("submit.notesLabel")}
            </label>
            <textarea
              id="notes"
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              className="input-field min-h-[60px] resize-y"
              placeholder={t("submit.notesPlaceholder")}
              maxLength={500}
              rows={2}
            />
          </div>

          <button
            type="submit"
            disabled={
              mutation.isPending || ean.length < 8 || productName.length < 2
            }
            className="btn-primary w-full"
          >
            {mutation.isPending
              ? t("submit.submitting")
              : t("submit.submitButton")}
          </button>
        </form>
      </div>

      <p className="text-center text-xs text-foreground-muted">
        {t("submit.disclaimer")}
      </p>
    </div>
  );
}
