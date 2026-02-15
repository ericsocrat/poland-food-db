"use client";

// ─── Submit Product page — form for adding missing products ─────────────────

import { useState } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import { useMutation } from "@tanstack/react-query";
import { toast } from "sonner";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import { submitProduct } from "@/lib/api";

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
      toast.success("Product submitted! We'll review it soon.");
      router.push("/app/scan/submissions");
    },
    onError: (error: Error) => {
      toast.error(error.message);
    },
  });

  function handleSubmit(e: { preventDefault: () => void }) {
    e.preventDefault();
    if (ean.length < 8 || productName.length < 2) return;
    mutation.mutate();
  }

  return (
    <div className="space-y-4">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-lg font-semibold text-gray-900">
            📝 Submit Product
          </h1>
          <p className="text-sm text-gray-500">Help us add a missing product</p>
        </div>
        <Link
          href="/app/scan"
          className="text-sm text-brand-600 hover:text-brand-700"
        >
          ← Back to Scanner
        </Link>
      </div>

      <div className="card">
        <form onSubmit={handleSubmit} className="space-y-4">
          {/* EAN (pre-filled, editable) */}
          <div>
            <label
              htmlFor="ean"
              className="mb-1 block text-sm font-medium text-gray-700"
            >
              EAN Barcode *
            </label>
            <input
              id="ean"
              type="text"
              value={ean}
              onChange={(e) =>
                setEan(e.target.value.replaceAll(/\D/g, "").slice(0, 13))
              }
              className="input-field font-mono tracking-widest"
              placeholder="8 or 13 digits"
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
              className="mb-1 block text-sm font-medium text-gray-700"
            >
              Product Name *
            </label>
            <input
              id="productName"
              type="text"
              value={productName}
              onChange={(e) => setProductName(e.target.value)}
              className="input-field"
              placeholder="e.g. Lay's Paprika Chips 150g"
              maxLength={200}
              required
            />
          </div>

          {/* Brand */}
          <div>
            <label
              htmlFor="brand"
              className="mb-1 block text-sm font-medium text-gray-700"
            >
              Brand
            </label>
            <input
              id="brand"
              type="text"
              value={brand}
              onChange={(e) => setBrand(e.target.value)}
              className="input-field"
              placeholder="e.g. Lay's"
              maxLength={100}
            />
          </div>

          {/* Category */}
          <div>
            <label
              htmlFor="category"
              className="mb-1 block text-sm font-medium text-gray-700"
            >
              Category
            </label>
            <input
              id="category"
              type="text"
              value={category}
              onChange={(e) => setCategory(e.target.value)}
              className="input-field"
              placeholder="e.g. chips, drinks, cereal"
              maxLength={100}
            />
          </div>

          {/* Notes */}
          <div>
            <label
              htmlFor="notes"
              className="mb-1 block text-sm font-medium text-gray-700"
            >
              Notes
            </label>
            <textarea
              id="notes"
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              className="input-field min-h-[60px] resize-y"
              placeholder="Any additional info about this product…"
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
            {mutation.isPending ? "Submitting…" : "Submit Product"}
          </button>
        </form>
      </div>

      <p className="text-center text-xs text-gray-400">
        Submissions are reviewed before being added to the database.
      </p>
    </div>
  );
}
