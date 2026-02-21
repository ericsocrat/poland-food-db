import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import RecipeDetailPage from "./page";
import type { RecipeDetail } from "@/lib/types";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

vi.mock("next/navigation", () => ({
  useParams: () => ({ slug: "overnight-oats" }),
}));

vi.mock("next/link", () => ({
  default: ({
    href,
    children,
    className,
  }: {
    href: string;
    children: React.ReactNode;
    className?: string;
  }) => (
    <a href={href} className={className}>
      {children}
    </a>
  ),
}));

const mockGetRecipeDetail = vi.fn();
vi.mock("@/lib/api", () => ({
  getRecipeDetail: (...args: unknown[]) => mockGetRecipeDetail(...args),
}));

vi.mock("@/components/common/skeletons", () => ({
  RecipeGridSkeleton: () => (
    <div data-testid="skeleton" role="status" aria-busy="true" />
  ),
}));

vi.mock("@/components/recipes", () => ({
  IngredientProductList: ({ products }: { products: unknown[] }) => (
    <div data-testid="ingredient-product-list">{products.length} products</div>
  ),
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

function Wrapper({ children }: Readonly<{ children: React.ReactNode }>) {
  const [client] = useState(
    () =>
      new QueryClient({
        defaultOptions: { queries: { retry: false, staleTime: 0 } },
      }),
  );
  return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
}

function createWrapper() {
  return Wrapper;
}

const mockRecipe: RecipeDetail = {
  id: "r1",
  slug: "overnight-oats",
  title_key: "recipes.items.overnight-oats.title",
  description_key: "recipes.items.overnight-oats.description",
  category: "breakfast",
  difficulty: "easy",
  prep_time_min: 5,
  cook_time_min: 0,
  servings: 1,
  image_url: null,
  country: "PL",
  tags: ["quick", "healthy"],
  steps: [
    {
      step_number: 1,
      content_key: "recipes.items.overnight-oats.steps.1",
    },
    {
      step_number: 2,
      content_key: "recipes.items.overnight-oats.steps.2",
    },
    {
      step_number: 3,
      content_key: "recipes.items.overnight-oats.steps.3",
    },
  ],
  ingredients: [
    { name_key: "recipes.items.overnight-oats.ingredients.1", optional: false },
    { name_key: "recipes.items.overnight-oats.ingredients.2", optional: false },
    { name_key: "recipes.items.overnight-oats.ingredients.3", optional: false },
    { name_key: "recipes.items.overnight-oats.ingredients.4", optional: false },
    { name_key: "recipes.items.overnight-oats.ingredients.5", optional: true },
  ],
};

const mockRecipeWithProducts: RecipeDetail = {
  ...mockRecipe,
  ingredients: [
    {
      name_key: "recipes.items.overnight-oats.ingredients.1",
      optional: false,
      id: "ing-1",
      ingredient_ref_id: 42,
      linked_products: [
        {
          product_id: 101,
          product_name: "Bio Oat Flakes",
          brand: "EcoFarm",
          unhealthiness_score: 12,
          image_url: null,
          is_primary: true,
        },
        {
          product_id: 102,
          product_name: "Quick Oats",
          brand: null,
          unhealthiness_score: 25,
          image_url: null,
          is_primary: false,
        },
      ],
    },
    {
      name_key: "recipes.items.overnight-oats.ingredients.2",
      optional: false,
      linked_products: [],
    },
  ],
};

beforeEach(() => {
  vi.clearAllMocks();
  mockGetRecipeDetail.mockResolvedValue({ ok: true, data: mockRecipe });
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("RecipeDetailPage", () => {
  it("shows skeleton while loading", () => {
    mockGetRecipeDetail.mockReturnValue(new Promise(() => {}));
    render(<RecipeDetailPage />, { wrapper: createWrapper() });
    expect(screen.getByTestId("skeleton")).toBeInTheDocument();
  });

  it("renders recipe title after loading", async () => {
    render(<RecipeDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByRole("heading", {
          name: "Overnight Oats with Yogurt & Berries",
        }),
      ).toBeInTheDocument();
    });
  });

  it("renders recipe description", async () => {
    render(<RecipeDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByText(
          "Creamy overnight oats topped with fresh berries and a drizzle of honey.",
        ),
      ).toBeInTheDocument();
    });
  });

  it("renders all ingredients", async () => {
    render(<RecipeDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("½ cup rolled oats")).toBeInTheDocument();
    });
    expect(screen.getByText("½ cup plain yogurt")).toBeInTheDocument();
    expect(screen.getByText("¼ cup milk")).toBeInTheDocument();
    expect(screen.getByText("Handful of mixed berries")).toBeInTheDocument();
  });

  it("shows optional label for optional ingredients", async () => {
    render(<RecipeDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("(optional)")).toBeInTheDocument();
    });
  });

  it("renders all steps", async () => {
    render(<RecipeDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByText(
          "Combine oats, yogurt, and milk in a jar. Stir well.",
        ),
      ).toBeInTheDocument();
    });
    expect(
      screen.getByText(
        "Cover and refrigerate overnight (or at least 4 hours).",
      ),
    ).toBeInTheDocument();
    expect(
      screen.getByText(
        "Top with fresh berries and a drizzle of honey before serving.",
      ),
    ).toBeInTheDocument();
  });

  it("renders step numbers", async () => {
    render(<RecipeDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("1")).toBeInTheDocument();
    });
    expect(screen.getByText("2")).toBeInTheDocument();
    expect(screen.getByText("3")).toBeInTheDocument();
  });

  it("shows difficulty badge", async () => {
    render(<RecipeDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Easy")).toBeInTheDocument();
    });
  });

  it("shows servings count", async () => {
    render(<RecipeDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText(/1 servings/)).toBeInTheDocument();
    });
  });

  it("renders tags as chips", async () => {
    render(<RecipeDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("quick")).toBeInTheDocument();
    });
    expect(screen.getByText("healthy")).toBeInTheDocument();
  });

  it("shows error state on API failure", async () => {
    mockGetRecipeDetail.mockResolvedValue({
      ok: false,
      error: { message: "Not found" },
    });

    render(<RecipeDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByText("Could not load recipes. Please try again."),
      ).toBeInTheDocument();
    });
  });

  it("shows retry button on error", async () => {
    mockGetRecipeDetail.mockResolvedValue({
      ok: false,
      error: { message: "Not found" },
    });

    render(<RecipeDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByRole("button", { name: "Retry" }),
      ).toBeInTheDocument();
    });
  });

  it("retries on retry button click", async () => {
    mockGetRecipeDetail
      .mockResolvedValueOnce({
        ok: false,
        error: { message: "Not found" },
      })
      .mockResolvedValueOnce({ ok: true, data: mockRecipe });

    render(<RecipeDetailPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(
        screen.getByRole("button", { name: "Retry" }),
      ).toBeInTheDocument();
    });

    await user.click(screen.getByRole("button", { name: "Retry" }));

    await waitFor(() => {
      expect(
        screen.getByRole("heading", {
          name: "Overnight Oats with Yogurt & Berries",
        }),
      ).toBeInTheDocument();
    });
  });

  it("renders breadcrumbs with recipes link", async () => {
    render(<RecipeDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Recipes")).toBeInTheDocument();
    });

    const recipesLink = screen.getByText("Recipes").closest("a");
    expect(recipesLink).toHaveAttribute("href", "/app/recipes");
  });

  it("renders ingredients section heading", async () => {
    render(<RecipeDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByRole("heading", { name: "Ingredients" }),
      ).toBeInTheDocument();
    });
  });

  it("renders steps section heading", async () => {
    render(<RecipeDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByRole("heading", { name: "Steps" }),
      ).toBeInTheDocument();
    });
  });

  it("renders prep and cook time", async () => {
    render(<RecipeDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText(/Prep: 5 min/)).toBeInTheDocument();
    });
    expect(screen.getByText(/Cook: 0 min/)).toBeInTheDocument();
  });

  it("renders IngredientProductList when ingredients have linked products", async () => {
    mockGetRecipeDetail.mockResolvedValue({
      ok: true,
      data: mockRecipeWithProducts,
    });

    render(<RecipeDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("ingredient-product-list")).toBeInTheDocument();
    });
    expect(screen.getByText("2 products")).toBeInTheDocument();
  });

  it("does not render IngredientProductList when linked products is empty", async () => {
    render(<RecipeDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByRole("heading", { name: "Ingredients" }),
      ).toBeInTheDocument();
    });
    expect(screen.queryAllByTestId("ingredient-product-list")).toHaveLength(0);
  });

  it("renders only one IngredientProductList for recipe with one linked ingredient", async () => {
    mockGetRecipeDetail.mockResolvedValue({
      ok: true,
      data: mockRecipeWithProducts,
    });

    render(<RecipeDetailPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getAllByTestId("ingredient-product-list")).toHaveLength(1);
    });
  });
});
