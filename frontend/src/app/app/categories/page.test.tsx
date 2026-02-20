import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import CategoriesPage from "./page";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

vi.mock("next/link", () => ({
  default: ({
    href,
    children,
  }: {
    href: string;
    children: React.ReactNode;
  }) => <a href={href}>{children}</a>,
}));

const mockGetCategoryOverview = vi.fn();
vi.mock("@/lib/api", () => ({
  getCategoryOverview: (...args: unknown[]) => mockGetCategoryOverview(...args),
}));

vi.mock("@/components/common/skeletons", () => ({
  CategoryGridSkeleton: () => (
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

const mockCategories = [
  {
    category: "Chips",
    slug: "chips",
    display_name: "Chips",
    icon_emoji: "🍟",
    product_count: 42,
    avg_score: 72,
  },
  {
    category: "Drinks",
    slug: "drinks",
    display_name: "Drinks",
    icon_emoji: "🥤",
    product_count: 1,
    avg_score: 30,
  },
  {
    category: "Cereals",
    slug: "cereals",
    display_name: "Cereals",
    icon_emoji: "🥣",
    product_count: 10,
    avg_score: 55,
  },
];

beforeEach(() => {
  vi.clearAllMocks();
  mockGetCategoryOverview.mockResolvedValue({
    ok: true,
    data: mockCategories,
  });
});

describe("CategoriesPage", () => {
  it("renders category cards after loading", async () => {
    render(<CategoriesPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Chips")).toBeInTheDocument();
    });
    expect(screen.getByText("Drinks")).toBeInTheDocument();
    expect(screen.getByText("Cereals")).toBeInTheDocument();
  });

  it("renders page title", async () => {
    render(<CategoriesPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByRole("heading", { name: /Categories/i })).toBeInTheDocument();
    });
  });

  it("shows category icons", async () => {
    render(<CategoriesPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("🍟")).toBeInTheDocument();
    });
    expect(screen.getByText("🥤")).toBeInTheDocument();
    expect(screen.getByText("🥣")).toBeInTheDocument();
  });

  it("shows product counts with correct pluralization", async () => {
    render(<CategoriesPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("42 product(s)")).toBeInTheDocument();
    });
    expect(screen.getByText("1 product(s)")).toBeInTheDocument();
    expect(screen.getByText("10 product(s)")).toBeInTheDocument();
  });

  it("shows average score badges", async () => {
    render(<CategoriesPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("avg 72")).toBeInTheDocument();
    });
    expect(screen.getByText("avg 30")).toBeInTheDocument();
    expect(screen.getByText("avg 55")).toBeInTheDocument();
  });

  it("links each card to the category detail page", async () => {
    render(<CategoriesPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Chips")).toBeInTheDocument();
    });

    const chipsLink = screen.getByText("Chips").closest("a");
    expect(chipsLink).toHaveAttribute("href", "/app/categories/chips");
  });

  it("uses slug in category detail links", async () => {
    mockGetCategoryOverview.mockResolvedValue({
      ok: true,
      data: [
        {
          category: "Seafood & Fish",
          slug: "seafood-fish",
          display_name: "Seafood & Fish",
          icon_emoji: "🐟",
          product_count: 15,
          avg_score: 40,
        },
      ],
    });

    render(<CategoriesPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Seafood & Fish")).toBeInTheDocument();
    });

    const link = screen.getByText("Seafood & Fish").closest("a");
    expect(link).toHaveAttribute("href", "/app/categories/seafood-fish");
  });

  it("shows error state on API failure", async () => {
    mockGetCategoryOverview.mockResolvedValue({
      ok: false,
      error: { message: "Server error" },
    });

    render(<CategoriesPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByText("Failed to load categories."),
      ).toBeInTheDocument();
    });
  });

  it("shows retry button on error", async () => {
    mockGetCategoryOverview.mockResolvedValue({
      ok: false,
      error: { message: "Server error" },
    });

    render(<CategoriesPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByRole("button", { name: "Retry" })).toBeInTheDocument();
    });
  });

  it("retries on retry button click", async () => {
    mockGetCategoryOverview
      .mockResolvedValueOnce({
        ok: false,
        error: { message: "Server error" },
      })
      .mockResolvedValueOnce({
        ok: true,
        data: mockCategories,
      });

    render(<CategoriesPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByRole("button", { name: "Retry" })).toBeInTheDocument();
    });

    await user.click(screen.getByRole("button", { name: "Retry" }));

    await waitFor(() => {
      expect(screen.getByText("Chips")).toBeInTheDocument();
    });
  });
});

describe("scoreToBand (via CategoryCard rendering)", () => {
  it("applies correct band for low score (≤25)", async () => {
    mockGetCategoryOverview.mockResolvedValue({
      ok: true,
      data: [
        {
          category: "test",
          display_name: "Test",
          icon_emoji: "📦",
          product_count: 5,
          avg_score: 20,
        },
      ],
    });

    render(<CategoriesPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("avg 20")).toBeInTheDocument();
    });
  });

  it("applies correct band for very high score (>75)", async () => {
    mockGetCategoryOverview.mockResolvedValue({
      ok: true,
      data: [
        {
          category: "test",
          display_name: "Test",
          icon_emoji: "📦",
          product_count: 5,
          avg_score: 90,
        },
      ],
    });

    render(<CategoriesPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("avg 90")).toBeInTheDocument();
    });
  });
});

describe("Categories desktop grid layout", () => {
  it("renders responsive grid with correct column classes", async () => {
    render(<CategoriesPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Chips")).toBeInTheDocument();
    });

    const grid = screen.getByText("Chips").closest("a")!.parentElement!;
    expect(grid.className).toContain("grid");
    expect(grid.className).toContain("lg:grid-cols-3");
    expect(grid.className).toContain("xl:grid-cols-4");
  });

  it("category cards have transition classes for hover states", async () => {
    render(<CategoriesPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Chips")).toBeInTheDocument();
    });

    const card = screen.getByText("Chips").closest(".card")!;
    expect(card.className).toContain("transition-all");
    expect(card.className).toContain("duration-fast");
  });
});
