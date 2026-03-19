"use client";

// ─── Submit Product page — form for adding missing products ─────────────────

import { Button } from "@/components/common/Button";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import { usePreferences } from "@/components/common/RouteGuard";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { CategoryPicker } from "@/components/scan/CategoryPicker";
import { submitProduct } from "@/lib/api";
import { getCountryFlag, getCountryName } from "@/lib/constants";
import { eventBus } from "@/lib/events";
import { gs1CountryHint } from "@/lib/gs1";
import { useTranslation } from "@/lib/i18n";
import { createClient } from "@/lib/supabase/client";
import { showToast } from "@/lib/toast";
import type { FormSubmitEvent } from "@/lib/types";
import { isValidEan, isValidEanChecksum } from "@/lib/validation";
import { useMutation } from "@tanstack/react-query";
import { ArrowLeft, Camera, CheckCircle, FileText, Lock, X } from "lucide-react";
import { useRouter, useSearchParams } from "next/navigation";
import { useEffect, useRef, useState } from "react";

const MAX_PHOTO_BYTES = 5 * 1024 * 1024; // 5 MB
const ALLOWED_IMAGE_TYPES = new Set(["image/jpeg", "image/png", "image/webp", "image/heic"]);

export default function SubmitProductPage() {
  const supabase = createClient();
  const router = useRouter();
  const searchParams = useSearchParams();
  const prefillEan = searchParams.get("ean") ?? "";
  const urlCountry = searchParams.get("country") ?? undefined;
  const prefs = usePreferences();
  const scanCountry = urlCountry ?? prefs?.country ?? undefined;

  const [ean, setEan] = useState(prefillEan);
  const [productName, setProductName] = useState("");
  const [brand, setBrand] = useState("");
  const [category, setCategory] = useState("");
  const [notes, setNotes] = useState("");
  const [photoFile, setPhotoFile] = useState<File | null>(null);
  const [photoPreview, setPhotoPreview] = useState<string | null>(null);
  const [checksumWarn, setChecksumWarn] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);
  const { t } = useTranslation();
  const gs1Hint = ean.length >= 8 ? gs1CountryHint(ean) : null;
  const photoPreviewRef = useRef(photoPreview);
  photoPreviewRef.current = photoPreview;

  // Revoke blob URL on unmount to prevent memory leaks
  useEffect(() => {
    return () => {
      if (photoPreviewRef.current) URL.revokeObjectURL(photoPreviewRef.current);
    };
  }, []);

  function handlePhotoChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0] ?? null;
    if (file) {
      if (!ALLOWED_IMAGE_TYPES.has(file.type)) {
        showToast({ type: "error", messageKey: "submit.photoInvalidType" });
        return;
      }
      if (file.size > MAX_PHOTO_BYTES) {
        showToast({ type: "error", messageKey: "submit.photoTooLarge" });
        return;
      }
    }
    setPhotoFile(file);
    if (photoPreview) URL.revokeObjectURL(photoPreview);
    if (file) {
      const objectUrl = URL.createObjectURL(file);
      // Only allow blob: scheme URLs — prevents DOM-XSS (CodeQL js/xss-through-dom)
      setPhotoPreview(objectUrl.startsWith("blob:") ? objectUrl : null);
    } else {
      setPhotoPreview(null);
    }
  }

  function removePhoto() {
    setPhotoFile(null);
    if (photoPreview) URL.revokeObjectURL(photoPreview);
    setPhotoPreview(null);
  }

  const mutation = useMutation({
    mutationFn: async () => {
      let photoUrl: string | undefined;

      if (photoFile) {
        const rawExt = photoFile.name.split(".").pop()?.toLowerCase() ?? "jpg";
        const ext = ["jpg", "jpeg", "png", "webp", "heic"].includes(rawExt) ? rawExt : "jpg";
        const path = `submissions/${ean}-${Date.now()}.${ext}`;
        const { error: uploadErr } = await supabase.storage
          .from("product-photos")
          .upload(path, photoFile, { contentType: photoFile.type });
        if (uploadErr) throw new Error(`Photo upload failed: ${uploadErr.message}`);
        const { data: urlData } = supabase.storage
          .from("product-photos")
          .getPublicUrl(path);
        photoUrl = urlData.publicUrl;
      }

      const result = await submitProduct(supabase, {
        ean,
        productName,
        brand: brand || undefined,
        category: category || undefined,
        photoUrl,
        notes: notes || undefined,
        scanCountry,
        suggestedCountry: scanCountry,
      });
      if (!result.ok) throw new Error(result.error.message);
      if (result.data.error) throw new Error(result.data.error);
      return result.data;
    },
    onSuccess: () => {
      showToast({ type: "success", messageKey: "submit.successToast" });
      void eventBus.emit({ type: "product.submitted", payload: { ean } });
      setShowSuccess(true);
      setTimeout(() => router.push("/app/scan/submissions"), 1500);
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
      <div className="hidden md:block">
        <Breadcrumbs
          items={[
            { labelKey: "nav.home", href: "/app" },
            { labelKey: "nav.scan", href: "/app/scan" },
            { labelKey: "submit.title" },
          ]}
        />
      </div>
      {/* Header */}
      <div>
        <h1 className="text-lg font-semibold text-foreground flex items-center gap-1.5">
          <button
            onClick={() => router.back()}
            className="md:hidden rounded-lg p-1 text-foreground-secondary hover:bg-surface-muted"
            aria-label={t("common.back")}
          >
            <ArrowLeft size={18} />
          </button>
          <FileText size={18} aria-hidden="true" /> {t("submit.title")}
        </h1>
        <p className="text-sm text-foreground-secondary">
          {t("submit.subtitle")}
        </p>
      </div>

      {/* R6: Progress indicator */}
      <div className="flex items-center gap-2" aria-label={t("submit.progressLabel")}>
        <div className="h-1 flex-1 rounded-full bg-brand" />
        <div className={`h-1 flex-1 rounded-full ${productName.length >= 2 ? "bg-brand" : "bg-border"}`} />
        <p className="text-xs text-foreground-muted">{t("submit.stepIndicator")}</p>
      </div>

      <div className="card">
        <form id="submit-product-form" onSubmit={handleSubmit} className="space-y-5">
          {/* ─── Section: Required ──────────────────────────── */}
          <fieldset className="space-y-4">
            <legend className="text-xs font-semibold uppercase tracking-wider text-foreground-muted">
              {t("submit.sectionRequired")}
            </legend>

          {/* EAN (pre-filled, editable) */}
          <div>
            <label
              htmlFor="ean"
              className="mb-1 block text-sm font-medium text-foreground-secondary"
            >
              {t("submit.eanLabel")}
            </label>
            <div className="relative">
              <input
                id="ean"
                type="text"
                value={ean}
                onChange={(e) => {
                  const v = e.target.value.replaceAll(/\D/g, "").slice(0, 13);
                  setEan(v);
                  setChecksumWarn(v.length >= 8 && isValidEan(v) && !isValidEanChecksum(v));
                }}
                className={`input-field font-mono tracking-widest ${prefillEan ? "bg-surface-muted pr-9" : ""}`}
                placeholder={t("submit.eanPlaceholder")}
                inputMode="numeric"
                maxLength={13}
                required
                readOnly={!!prefillEan}
              />
              {!!prefillEan && (
                <span className="absolute right-2 top-1/2 -translate-y-1/2 inline-flex items-center gap-1 rounded-full bg-brand/10 px-2 py-0.5 text-xs font-medium text-brand">
                  <Lock size={12} aria-hidden="true" />
                  {t("submit.eanLockedBadge")}
                </span>
              )}
            </div>
            {checksumWarn && (
              <p className="mt-1 text-xs text-warning-text">
                {t("scan.checksumWarning")}
              </p>
            )}
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

          </fieldset>

          {/* ─── Section: Optional details ──────────────────── */}
          <fieldset className="space-y-4">
            <legend className="text-xs font-semibold uppercase tracking-wider text-foreground-muted">
              {t("submit.sectionOptional")}
            </legend>

          {/* Brand */}
          <div>
            <label
              htmlFor="brand"
              className="mb-1 block text-sm font-medium text-foreground-secondary"
            >
              {t("submit.brandLabel")}{" "}
              <span className="font-normal text-foreground-muted">{t("common.optional")}</span>
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
              className="mb-1 block text-sm font-medium text-foreground-secondary"
            >
              {t("submit.categoryLabel")}{" "}
              <span className="font-normal text-foreground-muted">{t("common.optional")}</span>
            </label>
            <CategoryPicker value={category} onChange={setCategory} />
          </div>

          {/* Country hint */}
          {scanCountry && (
            <div>
              <span className="mb-1 block text-sm font-medium text-foreground-secondary">
                {t("submit.countryLabel")}
              </span>
              <p className="inline-flex items-center gap-1.5 rounded-full bg-gray-100 px-3 py-1 text-sm dark:bg-gray-800">
                <span aria-hidden="true">{getCountryFlag(scanCountry)}</span>
                {getCountryName(scanCountry)}
                {gs1Hint && gs1Hint.code !== scanCountry && (
                  <span className="ml-1 text-xs text-foreground-muted">
                    ({t("scan.gs1Hint", { country: gs1Hint.name })})
                  </span>
                )}
              </p>
              <p className="mt-1 text-xs text-foreground-muted">
                {t("submit.countryExplainer")}
              </p>
            </div>
          )}

          {/* Photo */}
          <div>
            <label
              htmlFor="photo"
              className="mb-1 block text-sm font-medium text-foreground-secondary"
            >
              {t("submit.photoLabel")}{" "}
              <span className="font-normal text-foreground-muted">{t("common.optional")}</span>
            </label>
            {photoPreview && photoPreview.startsWith("blob:") ? (
              <div className="relative inline-block animate-scale-in">
                <img
                  src={photoPreview}
                  alt=""
                  className="h-40 w-40 rounded-xl border border-border object-cover shadow-sm"
                />
                <button
                  type="button"
                  onClick={removePhoto}
                  className="absolute -right-2 -top-2 rounded-full bg-red-500 p-0.5 text-white shadow-sm hover:bg-red-600"
                  aria-label={t("submit.photoRemove")}
                >
                  <X size={14} />
                </button>
              </div>
            ) : (
              <label
                htmlFor="photo"
                className="flex cursor-pointer flex-col items-center justify-center gap-2 rounded-lg border border-dashed border-border px-4 py-5 text-sm text-foreground-secondary hover:border-brand hover:text-brand"
              >
                <Camera size={24} aria-hidden="true" />
                {t("submit.photoHint")}
              </label>
            )}
            <input
              id="photo"
              type="file"
              accept="image/*"
              capture="environment"
              onChange={handlePhotoChange}
              className="hidden"
            />
          </div>

          {/* Notes */}
          <div>
            <label
              htmlFor="notes"
              className="mb-1 block text-sm font-medium text-foreground-secondary"
            >
              {t("submit.notesLabel")}{" "}
              <span className="font-normal text-foreground-muted">{t("common.optional")}</span>
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
            <p className="mt-1 text-right text-xs text-foreground-muted">
              {notes.length}/500
            </p>
          </div>

          </fieldset>
        </form>
      </div>

      <p className="text-center text-xs text-foreground-muted pb-20">
        {t("submit.disclaimer")}
      </p>

      {/* R1: Sticky submit bar with glassmorphism */}
      <div className="fixed inset-x-0 bottom-0 z-30 border-t border-border/50 bg-background/80 px-4 pb-[env(safe-area-inset-bottom,8px)] pt-3 backdrop-blur-lg md:sticky md:bottom-auto md:border-t-0 md:bg-transparent md:px-0 md:pb-0 md:pt-0 md:backdrop-blur-none">
        {showSuccess ? (
          <div className="flex flex-col items-center justify-center gap-1 py-3 animate-fade-in-up">
            <CheckCircle size={28} className="animate-scale-in text-score-green-text" />
            <span className="font-medium text-score-green-text">{t("submit.submitted")}</span>
            <span className="text-xs text-foreground-muted">{t("submit.redirecting")}</span>
          </div>
        ) : (
          <>
            <Button
              type="submit"
              form="submit-product-form"
              fullWidth
              disabled={
                mutation.isPending || mutation.isSuccess || ean.length < 8 || productName.length < 2
              }
            >
              {mutation.isPending ? (
                <span className="inline-flex items-center gap-2">
                  <LoadingSpinner size="sm" />
                  {t("submit.submitting")}
                </span>
              ) : (
                t("submit.submitButton")
              )}
            </Button>
            {(ean.length < 8 || productName.length < 2) && !mutation.isPending && (
              <p className="mt-1 text-center text-xs text-foreground-muted">
                {t("submit.disabledHint")}
              </p>
            )}
          </>
        )}
      </div>
    </div>
  );
}
