import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import RecipesBrowsePage from "./page";
import type { RecipeSummary } from "@/lib/types";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
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

const mockBrowseRecipes = vi.fn();
vi.mock("@/lib/api", () => ({
  browseRecipes: (...args: unknown[]) => mockBrowseRecipes(...args),
}));

vi.mock("@/components/common/skeletons", () => ({
  RecipeGridSkeleton: () => (
    <div data-testid="skeleton" role="status" aria-busy="true" />
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

const mockRecipes: RecipeSummary[] = [
  {
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
    total_time: 5,
  },
  {
    id: "r2",
    slug: "zupa-pomidorowa",
    title_key: "recipes.items.zupa-pomidorowa.title",
    description_key: "recipes.items.zupa-pomidorowa.description",
    category: "soup",
    difficulty: "medium",
    prep_time_min: 10,
    cook_time_min: 20,
    servings: 4,
    image_url: null,
    country: "PL",
    tags: ["traditional", "polish"],
    total_time: 30,
  },
];

beforeEach(() => {
  vi.clearAllMocks();
  mockBrowseRecipes.mockResolvedValue({ ok: true, data: mockRecipes });
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("RecipesBrowsePage", () => {
  it("shows skeleton while loading", () => {
    mockBrowseRecipes.mockReturnValue(new Promise(() => {}));
    render(<RecipesBrowsePage />, { wrapper: createWrapper() });
    expect(screen.getByTestId("skeleton")).toBeInTheDocument();
  });

  it("renders recipe cards after loading", async () => {
    render(<RecipesBrowsePage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByText("Overnight Oats with Yogurt & Berries"),
      ).toBeInTheDocument();
    });
    expect(screen.getByText("Tomato Soup (Zupa Pomidorowa)")).toBeInTheDocument();
  });

  it("renders page title", async () => {
    render(<RecipesBrowsePage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByRole("heading", { name: /Recipes/i }),
      ).toBeInTheDocument();
    });
  });

  it("links each card to the recipe detail page", async () => {
    render(<RecipesBrowsePage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByText("Overnight Oats with Yogurt & Berries"),
      ).toBeInTheDocument();
    });

    const link = screen
      .getByText("Overnight Oats with Yogurt & Berries")
      .closest("a");
    expect(link).toHaveAttribute("href", "/app/recipes/overnight-oats");
  });

  it("shows error state on API failure", async () => {
    mockBrowseRecipes.mockResolvedValue({
      ok: false,
      error: { message: "Server error" },
    });

    render(<RecipesBrowsePage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByText("Could not load recipes. Please try again."),
      ).toBeInTheDocument();
    });
  });

  it("shows retry button on error", async () => {
    mockBrowseRecipes.mockResolvedValue({
      ok: false,
      error: { message: "Server error" },
    });

    render(<RecipesBrowsePage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByRole("button", { name: "Retry" }),
      ).toBeInTheDocument();
    });
  });

  it("retries on retry button click", async () => {
    mockBrowseRecipes
      .mockResolvedValueOnce({
        ok: false,
        error: { message: "Server error" },
      })
      .mockResolvedValueOnce({ ok: true, data: mockRecipes });

    render(<RecipesBrowsePage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(
        screen.getByRole("button", { name: "Retry" }),
      ).toBeInTheDocument();
    });

    await user.click(screen.getByRole("button", { name: "Retry" }));

    await waitFor(() => {
      expect(
        screen.getByText("Overnight Oats with Yogurt & Berries"),
      ).toBeInTheDocument();
    });
  });

  it("shows empty state when no recipes match", async () => {
    mockBrowseRecipes.mockResolvedValue({ ok: true, data: [] });

    render(<RecipesBrowsePage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("No recipes found")).toBeInTheDocument();
    });
  });

  it("renders category filter dropdown", async () => {
    render(<RecipesBrowsePage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByRole("combobox", { name: /Filter by category/i }),
      ).toBeInTheDocument();
    });
  });

  it("renders difficulty filter dropdown", async () => {
    render(<RecipesBrowsePage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByRole("combobox", { name: /Filter by difficulty/i }),
      ).toBeInTheDocument();
    });
  });

  it("passes category filter to API when selected", async () => {
    render(<RecipesBrowsePage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(
        screen.getByRole("combobox", { name: /Filter by category/i }),
      ).toBeInTheDocument();
    });

    const categorySelect = screen.getByRole("combobox", {
      name: /Filter by category/i,
    });
    await user.selectOptions(categorySelect, "breakfast");

    await waitFor(() => {
      const lastCall =
        mockBrowseRecipes.mock.calls[mockBrowseRecipes.mock.calls.length - 1];
      expect(lastCall[1]).toEqual(
        expect.objectContaining({ category: "breakfast" }),
      );
    });
  });

  it("passes difficulty filter to API when selected", async () => {
    render(<RecipesBrowsePage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(
        screen.getByRole("combobox", { name: /Filter by difficulty/i }),
      ).toBeInTheDocument();
    });

    const difficultySelect = screen.getByRole("combobox", {
      name: /Filter by difficulty/i,
    });
    await user.selectOptions(difficultySelect, "easy");

    await waitFor(() => {
      const lastCall =
        mockBrowseRecipes.mock.calls[mockBrowseRecipes.mock.calls.length - 1];
      expect(lastCall[1]).toEqual(
        expect.objectContaining({ difficulty: "easy" }),
      );
    });
  });

  it("renders responsive grid with correct column classes", async () => {
    render(<RecipesBrowsePage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByText("Overnight Oats with Yogurt & Berries"),
      ).toBeInTheDocument();
    });

    const grid = screen
      .getByText("Overnight Oats with Yogurt & Berries")
      .closest("a")!.parentElement!;
    expect(grid.className).toContain("grid");
    expect(grid.className).toContain("lg:grid-cols-3");
  });

  it("renders breadcrumbs with home link", async () => {
    render(<RecipesBrowsePage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Home")).toBeInTheDocument();
    });

    const homeLink = screen.getByText("Home").closest("a");
    expect(homeLink).toHaveAttribute("href", "/app");
  });
});
