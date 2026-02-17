// ─── Product [id] layout — dynamic metadata for sharing / SEO ─────────────
// Provides og:title, og:description, twitter:card.  The opengraph-image.tsx
// file in this directory automatically sets og:image.

import type { Metadata } from "next";
import { createServerSupabaseClient } from "@/lib/supabase/server";

export async function generateMetadata({
  params,
}: {
  params: Promise<{ id: string }>;
}): Promise<Metadata> {
  const { id } = await params;
  const productId = Number.parseInt(id, 10);

  try {
    const supabase = await createServerSupabaseClient();
    const { data } = await supabase.rpc("api_get_product_profile", {
      p_product_id: productId,
    });

    if (!data) {
      return { title: "Product — FoodDB" };
    }

    const profile = data as Record<string, Record<string, unknown>>;
    const name =
      (profile.product?.product_name_display as string) ??
      (profile.product?.product_name as string) ??
      "Product";
    const brand = (profile.product?.brand as string) ?? "";
    const score = (profile.scores?.unhealthiness_score as number) ?? 0;

    const brandSuffix = brand ? ` by ${brand}` : "";
    const description = `${name}${brandSuffix} — Health Score: ${score}/100. View detailed nutrition analysis on FoodDB.`;

    return {
      title: `${name} — FoodDB`,
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
  } catch {
    return { title: "Product — FoodDB" };
  }
}

export default function ProductLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return children;
}
