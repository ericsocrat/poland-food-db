// ─── Dynamic OpenGraph image for shared comparison cards ──────────────────────
// Generates a 1200×630 PNG showing compared products with their TryVit scores.
// Edge-cached for 1 hour.  Uses Next.js ImageResponse (Satori).

import { ImageResponse } from "next/og";
import { getScoreHex } from "@/lib/score-utils";

/* ---------- route configuration ---------- */
export const runtime = "nodejs";
export const alt = "Product comparison card";
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
        <div style={{ fontSize: 64, marginBottom: 16 }}>⚖️</div>
        <div style={{ fontSize: 32, fontWeight: 700, color: "#111827" }}>
          TryVit
        </div>
        <div style={{ fontSize: 18, color: "#6b7280", marginTop: 8 }}>
          Comparison not available
        </div>
      </div>
    </div>
  );
}

/* ---------- product score row ---------- */
interface ProductRowProps {
  name: string;
  brand: string;
  score: number;
  scoreColor: string;
}

function ProductRow({ name, brand, score, scoreColor }: ProductRowProps) {
  return (
    <div
      style={{
        display: "flex",
        alignItems: "center",
        gap: 20,
        padding: "16px 24px",
        backgroundColor: "#f9fafb",
        borderRadius: 16,
      }}
    >
      {/* Score circle */}
      <div
        style={{
          width: 64,
          height: 64,
          borderRadius: "50%",
          backgroundColor: scoreColor,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          color: "#ffffff",
          fontSize: 28,
          fontWeight: 700,
          flexShrink: 0,
        }}
      >
        {score}
      </div>

      {/* Product info */}
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
            fontSize: 22,
            fontWeight: 700,
            color: "#111827",
            lineHeight: 1.2,
          }}
        >
          {truncate(name, 45)}
        </div>
        {brand && (
          <div style={{ fontSize: 16, color: "#6b7280", marginTop: 4 }}>
            {truncate(brand, 35)}
          </div>
        )}
      </div>

      {/* Score bar */}
      <div
        style={{
          display: "flex",
          width: 200,
          height: 12,
          backgroundColor: "#e5e7eb",
          borderRadius: 6,
          overflow: "hidden",
          flexShrink: 0,
        }}
      >
        <div
          style={{
            width: `${Math.min(score, 100)}%`,
            height: "100%",
            backgroundColor: scoreColor,
            borderRadius: 6,
          }}
        />
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

  /* ---- fetch comparison data (anon key — public read) ---- */
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let comparison: any;
  try {
    const res = await fetch(
      `${process.env.NEXT_PUBLIC_SUPABASE_URL}/rest/v1/rpc/api_get_shared_comparison`,
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
    comparison = await res.json();
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

  /* ---- extract product data ---- */
  const products: { product_name: string; brand: string; unhealthiness_score: number }[] =
    comparison?.products ?? [];

  if (products.length < 2) {
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

  const title = comparison.title ?? "Product Comparison";
  const displayProducts = products.slice(0, 4); // max 4 products

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
          alignItems: "center",
          marginBottom: 32,
        }}
      >
        <div style={{ display: "flex", flexDirection: "column" }}>
          <div
            style={{
              fontSize: 14,
              color: "#9ca3af",
              textTransform: "uppercase" as const,
              letterSpacing: "0.08em",
              marginBottom: 4,
            }}
          >
            Product Comparison
          </div>
          <div
            style={{
              fontSize: 32,
              fontWeight: 700,
              color: "#111827",
              lineHeight: 1.2,
            }}
          >
            {truncate(title, 50)}
          </div>
        </div>

        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 8,
            fontSize: 22,
            fontWeight: 700,
            color: "#16a34a",
          }}
        >
          ⚖️ TryVit
        </div>
      </div>

      {/* Product rows */}
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          gap: 12,
          flex: 1,
        }}
      >
        {displayProducts.map((p, i) => (
          <ProductRow
            key={i}
            name={p.product_name}
            brand={p.brand}
            score={p.unhealthiness_score}
            scoreColor={getScoreColor(p.unhealthiness_score)}
          />
        ))}
      </div>

      {/* Footer */}
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "flex-end",
          marginTop: 24,
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
          Compare on TryVit →
        </div>

        <div style={{ fontSize: 16, color: "#9ca3af" }}>
          {products.length} products compared
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
