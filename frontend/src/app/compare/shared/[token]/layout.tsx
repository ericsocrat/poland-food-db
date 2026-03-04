import type { Metadata } from "next";

/* ---------- dynamic OG metadata ---------- */

async function fetchComparison(token: string) {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
  if (!url || !key) return null;

  try {
    const res = await fetch(`${url}/rest/v1/rpc/api_get_shared_comparison`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        apikey: key,
        Authorization: `Bearer ${key}`,
      },
      body: JSON.stringify({ p_share_token: token }),
      next: { revalidate: 3600 },
    });
    if (!res.ok) return null;
    return await res.json();
  } catch {
    return null;
  }
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ token: string }>;
}): Promise<Metadata> {
  const { token } = await params;
  const comparison = await fetchComparison(token);

  const productNames: string[] = (comparison?.products ?? []).map(
    (p: { product_name: string }) => p.product_name,
  );
  const title =
    productNames.length >= 2
      ? `Compare: ${productNames.slice(0, 3).join(" vs ")}`
      : "Product Comparison — TryVit";
  const description =
    productNames.length >= 2
      ? `See how ${productNames[0]} compares to ${productNames[1]} on TryVit`
      : "Compare food products with multi-axis health scoring on TryVit";

  return {
    title,
    description,
    robots: {
      index: false,
      follow: false,
      googleBot: { index: false, follow: false },
    },
    openGraph: {
      title,
      description,
      type: "website",
      siteName: "TryVit",
    },
  };
}

export default function SharedComparisonLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return children;
}
