import { render, screen } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import SharedComparisonLayout, { generateMetadata } from "./layout";

// ─── Helpers ─────────────────────────────────────────────────────────────────

const mockParams = (token: string) => ({ params: Promise.resolve({ token }) });

beforeEach(() => {
  vi.stubEnv("NEXT_PUBLIC_SUPABASE_URL", "https://test.supabase.co");
  vi.stubEnv("NEXT_PUBLIC_SUPABASE_ANON_KEY", "test-anon-key");
  vi.restoreAllMocks();
});

// ─── Rendering ───────────────────────────────────────────────────────────────

describe("SharedComparisonLayout", () => {
  it("renders children unchanged", () => {
    render(
      <SharedComparisonLayout>
        <p>comparison content</p>
      </SharedComparisonLayout>,
    );
    expect(screen.getByText("comparison content")).toBeInTheDocument();
  });
});

// ─── generateMetadata ────────────────────────────────────────────────────────

describe("generateMetadata", () => {
  it("returns dynamic title with product names when fetch succeeds", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        json: () =>
          Promise.resolve({
            products: [
              { product_name: "Doritos" },
              { product_name: "Lay's" },
            ],
          }),
      }),
    );

    const metadata = await generateMetadata(mockParams("abc123"));
    expect(metadata.title).toBe("Compare: Doritos vs Lay's");
    expect(metadata.description).toContain("Doritos");
    expect(metadata.description).toContain("Lay's");
  });

  it("returns fallback title when fetch fails", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({ ok: false }),
    );

    const metadata = await generateMetadata(mockParams("bad-token"));
    expect(metadata.title).toBe("Product Comparison — TryVit");
  });

  it("returns fallback title when env vars are missing", async () => {
    vi.stubEnv("NEXT_PUBLIC_SUPABASE_URL", "");
    vi.stubEnv("NEXT_PUBLIC_SUPABASE_ANON_KEY", "");

    const metadata = await generateMetadata(mockParams("abc123"));
    expect(metadata.title).toBe("Product Comparison — TryVit");
  });

  it("always sets robots noindex and nofollow", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        json: () =>
          Promise.resolve({
            products: [
              { product_name: "A" },
              { product_name: "B" },
            ],
          }),
      }),
    );

    const metadata = await generateMetadata(mockParams("abc123"));
    const robots = metadata.robots as Record<string, unknown>;
    expect(robots.index).toBe(false);
    expect(robots.follow).toBe(false);

    const googleBot = robots.googleBot as Record<string, unknown>;
    expect(googleBot.index).toBe(false);
    expect(googleBot.follow).toBe(false);
  });

  it("includes openGraph fields", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        json: () =>
          Promise.resolve({
            products: [
              { product_name: "Alpha" },
              { product_name: "Beta" },
            ],
          }),
      }),
    );

    const metadata = await generateMetadata(mockParams("abc123"));
    const og = metadata.openGraph as Record<string, unknown>;
    expect(og.title).toBe("Compare: Alpha vs Beta");
    expect(og.siteName).toBe("TryVit");
    expect(og.type).toBe("website");
  });

  it("truncates to 3 product names when more than 3 products", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        json: () =>
          Promise.resolve({
            products: [
              { product_name: "A" },
              { product_name: "B" },
              { product_name: "C" },
              { product_name: "D" },
            ],
          }),
      }),
    );

    const metadata = await generateMetadata(mockParams("abc123"));
    expect(metadata.title).toBe("Compare: A vs B vs C");
  });
});
