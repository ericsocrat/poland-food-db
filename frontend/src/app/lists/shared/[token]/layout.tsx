import type { Metadata } from "next";

/* ---------- dynamic OG metadata ---------- */

async function fetchSharedList(token: string) {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
  if (!url || !key) return null;

  try {
    const res = await fetch(`${url}/rest/v1/rpc/api_get_shared_list`, {
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
  const listData = await fetchSharedList(token);

  const listName: string = listData?.list_name ?? "Product List";
  const totalCount: number = listData?.total_count ?? 0;

  const title = `${listName} — TryVit List`;
  const description =
    totalCount > 0
      ? `A curated list of ${totalCount} food products on TryVit`
      : "A curated product list on TryVit";

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

export default function SharedListLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return children;
}
