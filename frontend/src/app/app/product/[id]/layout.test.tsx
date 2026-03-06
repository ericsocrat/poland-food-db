import { render, screen } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import ProductLayout, { generateMetadata } from "./layout";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockRpc = vi.fn();

vi.mock("@/lib/supabase/server", () => ({
  createServerSupabaseClient: vi.fn().mockResolvedValue({
    rpc: (...args: unknown[]) => mockRpc(...args),
  }),
}));

vi.mock("@/lib/query-keys", () => ({
  queryKeys: {
    productProfile: (id: number) => ["product", "profile", id],
  },
}));

vi.mock("@tanstack/react-query", () => ({
  QueryClient: class {
    setQueryData = vi.fn();
  },
  dehydrate: vi.fn().mockReturnValue({}),
  HydrationBoundary: ({ children }: { children: React.ReactNode }) => (
    <>{children}</>
  ),
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

const mockParams = (id: string) => ({ params: Promise.resolve({ id }) });

const FULL_PROFILE = {
  product: {
    product_name: "Piątnica Skyr Naturalny",
    product_name_display: "Piątnica Skyr",
    brand: "Piątnica",
    ean: "5900820012345",
  },
  scores: { unhealthiness_score: 5 },
  nutrition: {
    energy_kcal: 59,
    fat: 0.2,
    saturated_fat: 0.1,
    carbohydrates: 6.0,
    sugars: 3.5,
    fiber: 0.0,
    proteins: 10.0,
    salt: 0.1,
  },
  images: { primary: { url: "https://example.com/skyr.jpg" } },
};

beforeEach(() => {
  vi.clearAllMocks();
  mockRpc.mockResolvedValue({ data: FULL_PROFILE });
});

// ─── generateMetadata ───────────────────────────────────────────────────────

describe("generateMetadata", () => {
  it("returns product name as title when profile loads", async () => {
    const metadata = await generateMetadata(mockParams("42"));
    expect(metadata.title).toBe("Piątnica Skyr");
  });

  it("returns description with brand and score", async () => {
    const metadata = await generateMetadata(mockParams("42"));
    expect(metadata.description).toContain("Piątnica Skyr");
    expect(metadata.description).toContain("by Piątnica");
    expect(metadata.description).toContain("Health Score: 5/100");
  });

  it("returns openGraph metadata", async () => {
    const metadata = await generateMetadata(mockParams("42"));
    const og = metadata.openGraph as Record<string, unknown>;
    expect(og.title).toBe("Piątnica Skyr — Health Score: 5/100");
    expect(og.type).toBe("article");
  });

  it("returns twitter card metadata", async () => {
    const metadata = await generateMetadata(mockParams("42"));
    const twitter = metadata.twitter as Record<string, unknown>;
    expect(twitter.card).toBe("summary_large_image");
    expect(twitter.title).toBe("Piątnica Skyr — Health Score: 5/100");
  });

  it("falls back to product_name when display name is missing", async () => {
    mockRpc.mockResolvedValue({
      data: {
        product: { product_name: "Raw Name", brand: "" },
        scores: { unhealthiness_score: 10 },
      },
    });

    const metadata = await generateMetadata(mockParams("99"));
    expect(metadata.title).toBe("Raw Name");
  });

  it("omits brand suffix when brand is empty", async () => {
    mockRpc.mockResolvedValue({
      data: {
        product: { product_name: "No Brand Product" },
        scores: { unhealthiness_score: 20 },
      },
    });

    const metadata = await generateMetadata(mockParams("99"));
    expect(metadata.description).not.toContain(" by ");
  });

  it("returns fallback title when profile is null", async () => {
    mockRpc.mockResolvedValue({ data: null });

    const metadata = await generateMetadata(mockParams("999"));
    expect(metadata.title).toBe("Product");
    expect(metadata.description).toBeUndefined();
  });

  it("returns fallback title when RPC throws", async () => {
    mockRpc.mockRejectedValue(new Error("connection failed"));

    const metadata = await generateMetadata(mockParams("999"));
    expect(metadata.title).toBe("Product");
  });

  it("defaults score to 0 when scores object is missing", async () => {
    mockRpc.mockResolvedValue({
      data: { product: { product_name: "Test" } },
    });

    const metadata = await generateMetadata(mockParams("1"));
    expect(metadata.description).toContain("Health Score: 0/100");
  });
});

// ─── ProductLayout ──────────────────────────────────────────────────────────

describe("ProductLayout", () => {
  it("renders children", async () => {
    const ui = await ProductLayout({
      children: <p>product detail content</p>,
      params: Promise.resolve({ id: "42" }),
    });

    render(<>{ui}</>);
    expect(screen.getByText("product detail content")).toBeInTheDocument();
  });

  it("injects JSON-LD script when profile exists", async () => {
    const ui = await ProductLayout({
      children: <p>child</p>,
      params: Promise.resolve({ id: "42" }),
    });

    const { container } = render(<>{ui}</>);
    const script = container.querySelector('script[type="application/ld+json"]');
    expect(script).not.toBeNull();

    const jsonLd = JSON.parse(script!.textContent ?? "{}");
    expect(jsonLd["@context"]).toBe("https://schema.org");
    expect(jsonLd["@type"]).toBe("Product");
    expect(jsonLd.name).toBe("Piątnica Skyr");
    expect(jsonLd.gtin13).toBe("5900820012345");
    expect(jsonLd.image).toBe("https://example.com/skyr.jpg");
    expect(jsonLd.brand).toEqual({ "@type": "Brand", name: "Piątnica" });
  });

  it("includes nutrition information in JSON-LD", async () => {
    const ui = await ProductLayout({
      children: <p>child</p>,
      params: Promise.resolve({ id: "42" }),
    });

    const { container } = render(<>{ui}</>);
    const script = container.querySelector('script[type="application/ld+json"]');
    const jsonLd = JSON.parse(script!.textContent ?? "{}");

    expect(jsonLd.nutrition["@type"]).toBe("NutritionInformation");
    expect(jsonLd.nutrition.servingSize).toBe("100 g");
    expect(jsonLd.nutrition.calories).toBe("59 kcal");
    expect(jsonLd.nutrition.fatContent).toBe("0.2 g");
    expect(jsonLd.nutrition.proteinContent).toBe("10 g");
  });

  it("omits JSON-LD script when profile is null", async () => {
    mockRpc.mockResolvedValue({ data: null });

    const ui = await ProductLayout({
      children: <p>no profile</p>,
      params: Promise.resolve({ id: "999" }),
    });

    const { container } = render(<>{ui}</>);
    const script = container.querySelector('script[type="application/ld+json"]');
    expect(script).toBeNull();
    expect(screen.getByText("no profile")).toBeInTheDocument();
  });

  it("omits optional JSON-LD fields when missing", async () => {
    mockRpc.mockResolvedValue({
      data: {
        product: { product_name: "Minimal Product" },
        scores: {},
      },
    });

    const ui = await ProductLayout({
      children: <p>child</p>,
      params: Promise.resolve({ id: "1" }),
    });

    const { container } = render(<>{ui}</>);
    const script = container.querySelector('script[type="application/ld+json"]');
    const jsonLd = JSON.parse(script!.textContent ?? "{}");

    expect(jsonLd.name).toBe("Minimal Product");
    expect(jsonLd.brand).toBeUndefined();
    expect(jsonLd.gtin13).toBeUndefined();
    expect(jsonLd.image).toBeUndefined();
  });
});
