import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { IngredientProfile } from "@/lib/types";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockGetIngredientProfile = vi.fn();

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

vi.mock("@/lib/api", () => ({
  getIngredientProfile: (...args: unknown[]) =>
    mockGetIngredientProfile(...args),
}));

vi.mock("next/navigation", () => ({
  useParams: () => ({ id: "42" }),
}));

// ─── Import after mocks ────────────────────────────────────────────────────

import IngredientProfilePage from "./page";

// ─── Helpers ────────────────────────────────────────────────────────────────

function createWrapper() {
  const qc = new QueryClient({
    defaultOptions: { queries: { retry: false, staleTime: 0 } },
  });
  return function Wrapper({ children }: { children: React.ReactNode }) {
    return <QueryClientProvider client={qc}>{children}</QueryClientProvider>;
  };
}

const SAMPLE_PROFILE: IngredientProfile = {
  api_version: "1.0",
  ingredient: {
    ingredient_id: 42,
    taxonomy_id: "en:salt",
    name_en: "Salt",
    name_display: "Salt",
    is_additive: false,
    additive_code: null,
    concern_tier: 1,
    concern_tier_label: "Low concern",
    concern_reason: "High sodium content",
    concern_description: "Excessive sodium can raise blood pressure.",
    efsa_guidance: "Limit to 5g per day.",
    score_impact: "-2 per 100g",
    vegan: "yes",
    vegetarian: "yes",
    from_palm_oil: "no",
  },
  usage: {
    product_count: 1234,
    category_breakdown: [
      { category: "Snacks", count: 500 },
      { category: "Cereals", count: 300 },
    ],
    top_products: [
      {
        product_id: 10,
        product_name: "SuperChips",
        brand: "Lays",
        score: 45,
        category: "Snacks",
      },
    ],
  },
  related_ingredients: [
    {
      ingredient_id: 99,
      name_en: "Sugar",
      is_additive: false,
      concern_tier: 2,
      co_occurrence_count: 800,
    },
  ],
};

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("IngredientProfilePage", () => {
  beforeEach(() => vi.clearAllMocks());

  it("shows loading state", () => {
    // Never resolve — keep loading
    mockGetIngredientProfile.mockReturnValue(new Promise(() => {}));
    render(<IngredientProfilePage />, { wrapper: createWrapper() });
    expect(screen.getByText("Loading…")).toBeInTheDocument();
  });

  it("shows not-found when API returns error", async () => {
    mockGetIngredientProfile.mockResolvedValue({
      ok: true,
      data: { error: "Ingredient not found", ingredient_id: 42 },
    });
    render(<IngredientProfilePage />, { wrapper: createWrapper() });
    expect(
      await screen.findByText("Ingredient not found."),
    ).toBeInTheDocument();
  });

  it("renders ingredient name as heading", async () => {
    mockGetIngredientProfile.mockResolvedValue({
      ok: true,
      data: SAMPLE_PROFILE,
    });
    render(<IngredientProfilePage />, { wrapper: createWrapper() });
    expect(await screen.findByText("Salt")).toBeInTheDocument();
  });

  it("renders concern badge", async () => {
    mockGetIngredientProfile.mockResolvedValue({
      ok: true,
      data: SAMPLE_PROFILE,
    });
    render(<IngredientProfilePage />, { wrapper: createWrapper() });
    const badges = await screen.findAllByTestId("concern-badge");
    expect(badges[0]).toHaveTextContent("Low concern");
  });

  it("renders concern details section", async () => {
    mockGetIngredientProfile.mockResolvedValue({
      ok: true,
      data: SAMPLE_PROFILE,
    });
    render(<IngredientProfilePage />, { wrapper: createWrapper() });
    expect(
      await screen.findByText("Excessive sodium can raise blood pressure."),
    ).toBeInTheDocument();
    expect(screen.getByText("High sodium content")).toBeInTheDocument();
  });

  it("renders EFSA guidance", async () => {
    mockGetIngredientProfile.mockResolvedValue({
      ok: true,
      data: SAMPLE_PROFILE,
    });
    render(<IngredientProfilePage />, { wrapper: createWrapper() });
    expect(await screen.findByText("Limit to 5g per day.")).toBeInTheDocument();
  });

  it("renders product count", async () => {
    mockGetIngredientProfile.mockResolvedValue({
      ok: true,
      data: SAMPLE_PROFILE,
    });
    render(<IngredientProfilePage />, { wrapper: createWrapper() });
    expect(await screen.findByText("1,234")).toBeInTheDocument();
  });

  it("renders category breakdown", async () => {
    mockGetIngredientProfile.mockResolvedValue({
      ok: true,
      data: SAMPLE_PROFILE,
    });
    render(<IngredientProfilePage />, { wrapper: createWrapper() });
    expect(await screen.findByText("Snacks")).toBeInTheDocument();
    expect(screen.getByText("Cereals")).toBeInTheDocument();
  });

  it("renders top products as links", async () => {
    mockGetIngredientProfile.mockResolvedValue({
      ok: true,
      data: SAMPLE_PROFILE,
    });
    render(<IngredientProfilePage />, { wrapper: createWrapper() });
    const link = await screen.findByRole("link", { name: /SuperChips/i });
    expect(link).toHaveAttribute("href", "/app/product/10");
  });

  it("renders related ingredients as links", async () => {
    mockGetIngredientProfile.mockResolvedValue({
      ok: true,
      data: SAMPLE_PROFILE,
    });
    render(<IngredientProfilePage />, { wrapper: createWrapper() });
    const link = await screen.findByRole("link", { name: /Sugar/i });
    expect(link).toHaveAttribute("href", "/app/ingredient/99");
  });

  it("renders dietary flags", async () => {
    mockGetIngredientProfile.mockResolvedValue({
      ok: true,
      data: SAMPLE_PROFILE,
    });
    render(<IngredientProfilePage />, { wrapper: createWrapper() });
    await screen.findByText("Salt");
    const flags = screen.getAllByTestId("dietary-flag");
    expect(flags.length).toBeGreaterThanOrEqual(2);
  });

  it("renders 🌿 icon in header for non-additive", async () => {
    mockGetIngredientProfile.mockResolvedValue({
      ok: true,
      data: SAMPLE_PROFILE,
    });
    render(<IngredientProfilePage />, { wrapper: createWrapper() });
    await screen.findByText("Salt");
    // The header icon is inside the 14×14 avatar circle
    const allIcons = screen.getAllByText("🌿");
    expect(allIcons.length).toBeGreaterThanOrEqual(1);
  });

  it("renders 🧪 for additive", async () => {
    const additive = {
      ...SAMPLE_PROFILE,
      ingredient: {
        ...SAMPLE_PROFILE.ingredient,
        is_additive: true,
        additive_code: "E621",
      },
    };
    mockGetIngredientProfile.mockResolvedValue({
      ok: true,
      data: additive,
    });
    render(<IngredientProfilePage />, { wrapper: createWrapper() });
    expect(await screen.findByText("🧪")).toBeInTheDocument();
    expect(screen.getByText("E621")).toBeInTheDocument();
  });

  it("hides concern details when none present", async () => {
    const noConcern = {
      ...SAMPLE_PROFILE,
      ingredient: {
        ...SAMPLE_PROFILE.ingredient,
        concern_tier: 0,
        concern_reason: null,
        concern_description: null,
        efsa_guidance: null,
        score_impact: null,
      },
    };
    mockGetIngredientProfile.mockResolvedValue({
      ok: true,
      data: noConcern,
    });
    render(<IngredientProfilePage />, { wrapper: createWrapper() });
    await screen.findByText("Salt");
    expect(
      screen.queryByText("Excessive sodium can raise blood pressure."),
    ).not.toBeInTheDocument();
  });
});
