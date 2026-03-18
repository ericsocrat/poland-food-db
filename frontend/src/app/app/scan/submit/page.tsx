"use client";

// ─── Submit Product page — form for adding missing products ─────────────────

import { Button } from "@/components/common/Button";
import { usePreferences } from "@/components/common/RouteGuard";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { submitProduct } from "@/lib/api";
import { FOOD_CATEGORIES, getCountryFlag, getCountryName } from "@/lib/constants";
import { eventBus } from "@/lib/events";
import { gs1CountryHint } from "@/lib/gs1";
import { useTranslation } from "@/lib/i18n";
import { createClient } from "@/lib/supabase/client";
import { showToast } from "@/lib/toast";
import type { FormSubmitEvent } from "@/lib/types";
import { useMutation } from "@tanstack/react-query";
import { Camera, FileText, X } from "lucide-react";
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
      <div>
        <h1 className="text-lg font-semibold text-foreground flex items-center gap-1.5">
          <FileText size={18} aria-hidden="true" /> {t("submit.title")}
        </h1>
        <p className="text-sm text-foreground-secondary">
          {t("submit.subtitle")}
        </p>
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
            <select
              id="category"
              value={category}
              onChange={(e) => setCategory(e.target.value)}
              className="input-field"
            >
              <option value="">{t("submit.categoryPlaceholder")}</option>
              {FOOD_CATEGORIES.map((cat) => (
                <option key={cat.slug} value={cat.slug}>
                  {cat.emoji} {t(cat.labelKey)}
                </option>
              ))}
            </select>
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
            </div>
          )}

          {/* Photo */}
          <div>
            <label
              htmlFor="photo"
              className="mb-1 block text-sm font-medium text-foreground-secondary"
            >
              {t("submit.photoLabel")}
            </label>
            {photoPreview && photoPreview.startsWith("blob:") ? (
              <div className="relative inline-block">
                <img
                  src={photoPreview}
                  alt=""
                  className="h-32 w-32 rounded-lg border border-border object-cover"
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
                className="flex cursor-pointer items-center gap-2 rounded-lg border border-dashed border-border px-4 py-3 text-sm text-foreground-secondary hover:border-brand hover:text-brand"
              >
                <Camera size={18} aria-hidden="true" />
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

          <Button
            type="submit"
            fullWidth
            disabled={
              mutation.isPending || ean.length < 8 || productName.length < 2
            }
          >
            {mutation.isPending
              ? t("submit.submitting")
              : t("submit.submitButton")}
          </Button>
        </form>
      </div>

      <p className="text-center text-xs text-foreground-muted">
        {t("submit.disclaimer")}
      </p>
    </div>
  );
}
