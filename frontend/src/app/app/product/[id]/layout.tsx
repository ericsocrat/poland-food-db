// ─── Product [id] layout — dynamic metadata + Schema.org JSON-LD ──────────
// Provides og:title, og:description, twitter:card.  The opengraph-image.tsx
// file in this directory automatically sets og:image.
// Also injects Schema.org Product + NutritionInformation structured data.

import type { Metadata } from "next";
import { createServerSupabaseClient } from "@/lib/supabase/server";

/* ---------- helpers ---------- */

interface ProductProfile {
  product?: Record<string, unknown>;
  scores?: Record<string, unknown>;
  nutrition?: Record<string, unknown>;
  images?: { primary?: { url?: string } };
}

async function fetchProfile(productId: number): Promise<ProductProfile | null> {
  try {
    const supabase = await createServerSupabaseClient();
    const { data } = await supabase.rpc("api_get_product_profile", {
      p_product_id: productId,
    });
    return (data as ProductProfile) ?? null;
  } catch {
    return null;
  }
}

/* ---------- metadata ---------- */

export async function generateMetadata({
  params,
}: {
  params: Promise<{ id: string }>;
}): Promise<Metadata> {
  const { id } = await params;
  const profile = await fetchProfile(Number.parseInt(id, 10));

  if (!profile) {
    return { title: "Product" };
  }

  const name =
    (profile.product?.product_name_display as string) ??
    (profile.product?.product_name as string) ??
    "Product";
  const brand = (profile.product?.brand as string) ?? "";
  const score = (profile.scores?.unhealthiness_score as number) ?? 0;

  const brandSuffix = brand ? ` by ${brand}` : "";
  const description = `${name}${brandSuffix} — Health Score: ${score}/100. View detailed nutrition analysis on FoodDB.`;

  return {
    title: name,
    description,
    openGraph: {
      title: `${name} — Health Score: ${score}/100`,
      description,
      type: "article",
    },
    twitter: {
      card: "summary_large_image",
      title: `${name} — Health Score: ${score}/100`,
      description,
    },
  };
}

/* ---------- JSON-LD builder ---------- */

function buildProductJsonLd(
  profile: ProductProfile,
  productId: number,
): Record<string, unknown> {
  const name =
    (profile.product?.product_name_display as string) ??
    (profile.product?.product_name as string) ??
    "Product";
  const brand = (profile.product?.brand as string) ?? undefined;
  const ean = (profile.product?.ean as string) ?? undefined;
  const imageUrl = profile.images?.primary?.url ?? undefined;

  const nutrition = profile.nutrition ?? {};
  const baseUrl =
    process.env.NEXT_PUBLIC_APP_URL ?? "https://poland-food-db.vercel.app";

  // Schema.org NutritionInformation (per 100 g)
  const nutritionInfo: Record<string, unknown> = {
    "@type": "NutritionInformation",
    servingSize: "100 g",
  };

  const nutrientMap: Record<string, string> = {
    energy_kcal: "calories",
    fat: "fatContent",
    saturated_fat: "saturatedFatContent",
    carbohydrates: "carbohydrateContent",
    sugars: "sugarContent",
    fiber: "fiberContent",
    proteins: "proteinContent",
    salt: "sodiumContent",
  };

  for (const [key, schemaKey] of Object.entries(nutrientMap)) {
    const val = nutrition[key];
    if (val != null && typeof val === "number") {
      const unit = key === "energy_kcal" ? " kcal" : " g";
      nutritionInfo[schemaKey] = `${val}${unit}`;
    }
  }

  const jsonLd: Record<string, unknown> = {
    "@context": "https://schema.org",
    "@type": "Product",
    name,
    url: `${baseUrl}/app/product/${productId}`,
    ...(brand && { brand: { "@type": "Brand", name: brand } }),
    ...(ean && { gtin13: ean }),
    ...(imageUrl && { image: imageUrl }),
    nutrition: nutritionInfo,
  };

  return jsonLd;
}

/* ---------- layout component ---------- */

export default async function ProductLayout({
  children,
  params,
}: Readonly<{
  children: React.ReactNode;
  params: Promise<{ id: string }>;
}>) {
  const { id } = await params;
  const productId = Number.parseInt(id, 10);
  const profile = await fetchProfile(productId);

  return (
    <>
      {profile && (
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{
            __html: JSON.stringify(buildProductJsonLd(profile, productId)),
          }}
        />
      )}
      {children}
    </>
  );
}
