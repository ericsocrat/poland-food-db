// ─── Dynamic OpenGraph image for shared list cards ────────────────────────────
// Generates a 1200×630 PNG showing list name, product count, average score,
// and top items.  Edge-cached for 1 hour.  Uses Next.js ImageResponse (Satori).

import { ImageResponse } from "next/og";
import { getScoreHex } from "@/lib/score-utils";

/* ---------- route configuration ---------- */
export const runtime = "nodejs";
export const alt = "Shared product list card";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";
export const revalidate = 3600; // 1 hour edge cache

/* ---------- helpers ---------- */

/** OG-specific score colour (not Tailwind — raw hex for Satori). */
export const getScoreColor = getScoreHex;

/** Truncate a string to `max` characters with an ellipsis. */
export function truncate(text: string, max: number): string {
  if (text.length <= max) return text;
  return text.slice(0, max - 1) + "…";
}

/** Compute average score from an array of items. */
export function averageScore(
  items: { unhealthiness_score: number }[],
): number {
  if (items.length === 0) return 0;
  const sum = items.reduce((acc, it) => acc + it.unhealthiness_score, 0);
  return Math.round(sum / items.length);
}

/* ---------- font loader ---------- */
let interBoldPromise: Promise<ArrayBuffer> | null = null;
function getInterBoldFont(): Promise<ArrayBuffer> {
  interBoldPromise ??= fetch(
    "https://fonts.gstatic.com/s/inter/v18/UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuFuYAZ9hiA.ttf",
  ).then((r) => r.arrayBuffer());
  return interBoldPromise;
}

/* ---------- fallback card ---------- */
function FallbackCard() {
  return (
    <div
      style={{
        width: "100%",
        height: "100%",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        backgroundColor: "#f9fafb",
        fontFamily: "Inter",
      }}
    >
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
        }}
      >
        <div style={{ fontSize: 64, marginBottom: 16 }}>📋</div>
        <div style={{ fontSize: 32, fontWeight: 700, color: "#111827" }}>
          TryVit
        </div>
        <div style={{ fontSize: 18, color: "#6b7280", marginTop: 8 }}>
          List not available
        </div>
      </div>
    </div>
  );
}

/* ---------- list item row ---------- */
interface ItemRowProps {
  name: string;
  brand: string;
  score: number;
  scoreColor: string;
}

function ItemRow({ name, brand, score, scoreColor }: ItemRowProps) {
  return (
    <div
      style={{
        display: "flex",
        alignItems: "center",
        gap: 16,
        padding: "12px 20px",
        backgroundColor: "#f9fafb",
        borderRadius: 12,
      }}
    >
      <div
        style={{
          width: 48,
          height: 48,
          borderRadius: "50%",
          backgroundColor: scoreColor,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          color: "#ffffff",
          fontSize: 20,
          fontWeight: 700,
          flexShrink: 0,
        }}
      >
        {score}
      </div>
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          flex: 1,
          minWidth: 0,
        }}
      >
        <div
          style={{
            fontSize: 18,
            fontWeight: 700,
            color: "#111827",
            lineHeight: 1.2,
          }}
        >
          {truncate(name, 50)}
        </div>
        {brand && (
          <div style={{ fontSize: 14, color: "#6b7280", marginTop: 2 }}>
            {truncate(brand, 40)}
          </div>
        )}
      </div>
    </div>
  );
}

/* ---------- main image handler ---------- */
export default async function OGImage({
  params,
}: {
  params: Promise<{ token: string }>;
}) {
  const { token } = await params;
  const fontData = await getInterBoldFont();

  /* ---- fetch list data (anon key — public read) ---- */
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let listData: any;
  try {
    const res = await fetch(
      `${process.env.NEXT_PUBLIC_SUPABASE_URL}/rest/v1/rpc/api_get_shared_list`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          apikey: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ?? "",
          Authorization: `Bearer ${process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ?? ""}`,
        },
        body: JSON.stringify({ p_share_token: token }),
        next: { revalidate: 3600 },
      },
    );
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    listData = await res.json();
  } catch {
    return new ImageResponse(<FallbackCard />, {
      ...size,
      fonts: [
        {
          name: "Inter",
          data: fontData,
          weight: 700,
          style: "normal" as const,
        },
      ],
    });
  }

  /* ---- extract data ---- */
  const listName: string = listData?.list_name ?? "Product List";
  const description: string | null = listData?.description ?? null;
  const totalCount: number = listData?.total_count ?? 0;
  const items: { product_name: string; brand: string; unhealthiness_score: number }[] =
    listData?.items ?? [];

  if (items.length === 0) {
    return new ImageResponse(<FallbackCard />, {
      ...size,
      fonts: [
        {
          name: "Inter",
          data: fontData,
          weight: 700,
          style: "normal" as const,
        },
      ],
    });
  }

  const avgScore = averageScore(items);
  const avgColor = getScoreColor(avgScore);
  const displayItems = items.slice(0, 5); // show up to 5 items
  const remaining = totalCount - displayItems.length;

  /* ---- render card ---- */
  return new ImageResponse(
    <div
      style={{
        width: "100%",
        height: "100%",
        display: "flex",
        flexDirection: "column",
        backgroundColor: "#ffffff",
        fontFamily: "Inter",
        padding: 48,
      }}
    >
      {/* Brand bar */}
      <div
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          right: 0,
          height: 8,
          backgroundColor: "#16a34a",
        }}
      />

      {/* Header */}
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "flex-start",
          marginBottom: 28,
        }}
      >
        <div style={{ display: "flex", flexDirection: "column", flex: 1 }}>
          <div
            style={{
              fontSize: 14,
              color: "#9ca3af",
              textTransform: "uppercase" as const,
              letterSpacing: "0.08em",
              marginBottom: 4,
            }}
          >
            Shared List
          </div>
          <div
            style={{
              fontSize: 32,
              fontWeight: 700,
              color: "#111827",
              lineHeight: 1.2,
            }}
          >
            {truncate(listName, 40)}
          </div>
          {description && (
            <div
              style={{
                fontSize: 16,
                color: "#6b7280",
                marginTop: 4,
              }}
            >
              {truncate(description, 60)}
            </div>
          )}
        </div>

        {/* Average score circle */}
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            gap: 6,
            flexShrink: 0,
          }}
        >
          <div
            style={{
              width: 80,
              height: 80,
              borderRadius: "50%",
              backgroundColor: avgColor,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              color: "#ffffff",
              fontSize: 32,
              fontWeight: 700,
            }}
          >
            {avgScore}
          </div>
          <div style={{ fontSize: 12, color: "#9ca3af" }}>avg score</div>
        </div>
      </div>

      {/* Product list items */}
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          gap: 8,
          flex: 1,
        }}
      >
        {displayItems.map((item, i) => (
          <ItemRow
            key={i}
            name={item.product_name}
            brand={item.brand}
            score={item.unhealthiness_score}
            scoreColor={getScoreColor(item.unhealthiness_score)}
          />
        ))}
        {remaining > 0 && (
          <div
            style={{
              fontSize: 14,
              color: "#9ca3af",
              textAlign: "center",
              padding: "8px 0",
            }}
          >
            + {remaining} more products
          </div>
        )}
      </div>

      {/* Footer */}
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "flex-end",
          marginTop: 16,
        }}
      >
        <div
          style={{
            backgroundColor: "#16a34a",
            color: "#ffffff",
            padding: "10px 24px",
            borderRadius: 999,
            fontSize: 16,
            fontWeight: 700,
          }}
        >
          View on TryVit →
        </div>

        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 8,
            fontSize: 16,
            color: "#9ca3af",
          }}
        >
          📋 TryVit — {totalCount} products
        </div>
      </div>
    </div>,
    {
      ...size,
      fonts: [
        {
          name: "Inter",
          data: fontData,
          weight: 700,
          style: "normal" as const,
        },
      ],
    },
  );
}
