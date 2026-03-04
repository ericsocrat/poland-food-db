import type { CategoryOverviewItem } from "@/lib/types";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { render, screen } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { CategoriesBrowse } from "./CategoriesBrowse";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

const mockGetCategoryOverview = vi.fn();
vi.mock("@/lib/api", () => ({
  getCategoryOverview: (...args: unknown[]) =>
    mockGetCategoryOverview(...args),
}));

vi.mock("next/link", () => ({
  default: ({
    href,
    children,
    ...rest
  }: {
    href: string;
    children: React.ReactNode;
    className?: string;
    style?: React.CSSProperties;
  }) => (
    <a href={href} {...rest}>
      {children}
    </a>
  ),
}));

vi.mock("@/components/common/CategoryIcon", () => ({
  CategoryIcon: ({ slug }: { slug: string }) => (
    <span data-testid={`cat-icon-${slug}`} />
  ),
}));

vi.mock("@/components/common/Skeleton", () => ({
  Skeleton: (props: { className?: string }) => (
    <div data-testid="skeleton" className={props.className} />
  ),
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

function createWrapper() {
  const qc = new QueryClient({
    defaultOptions: { queries: { retry: false, staleTime: 0 } },
  });
  return function Wrapper({ children }: { children: React.ReactNode }) {
    return (
      <QueryClientProvider client={qc}>{children}</QueryClientProvider>
    );
  };
}

const MOCK_CATEGORIES: CategoryOverviewItem[] = [
  {
    country_code: "PL",
    category: "Dairy",
    slug: "dairy",
    display_name: "Dairy",
    category_description: null,
    icon_emoji: "🧀",
    sort_order: 1,
    product_count: 50,
    avg_score: 25,
    min_score: 5,
    max_score: 60,
    median_score: 22,
    pct_nutri_a_b: 40,
    pct_nova_4: 10,
  },
  {
    country_code: "PL",
    category: "Chips",
    slug: "chips",
    display_name: "Chips",
    category_description: null,
    icon_emoji: "🍟",
    sort_order: 2,
    product_count: 45,
    avg_score: 55,
    min_score: 30,
    max_score: 80,
    median_score: 53,
    pct_nutri_a_b: 5,
    pct_nova_4: 80,
  },
];

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("CategoriesBrowse", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("shows skeletons while loading", () => {
    mockGetCategoryOverview.mockReturnValue(new Promise(() => {}));
    render(<CategoriesBrowse />, { wrapper: createWrapper() });
    expect(screen.getAllByTestId("skeleton").length).toBeGreaterThanOrEqual(1);
  });

  it("renders category chips when data loads", async () => {
    mockGetCategoryOverview.mockResolvedValue({
      ok: true,
      data: MOCK_CATEGORIES,
    });
    render(<CategoriesBrowse />, { wrapper: createWrapper() });
    await vi.waitFor(() => {
      expect(screen.getByText("Dairy")).toBeInTheDocument();
      expect(screen.getByText("Chips")).toBeInTheDocument();
    });
  });

  it("links each chip to its category page", async () => {
    mockGetCategoryOverview.mockResolvedValue({
      ok: true,
      data: MOCK_CATEGORIES,
    });
    render(<CategoriesBrowse />, { wrapper: createWrapper() });
    await vi.waitFor(() => {
      const links = screen.getAllByRole("link");
      const hrefs = links.map((l) => l.getAttribute("href"));
      expect(hrefs).toContain("/app/categories/dairy");
      expect(hrefs).toContain("/app/categories/chips");
    });
  });

  it("renders a View All link", async () => {
    mockGetCategoryOverview.mockResolvedValue({
      ok: true,
      data: MOCK_CATEGORIES,
    });
    render(<CategoriesBrowse />, { wrapper: createWrapper() });
    await vi.waitFor(() => {
      const viewAll = screen.getAllByRole("link").find(
        (l) => l.getAttribute("href") === "/app/categories",
      );
      expect(viewAll).toBeInTheDocument();
    });
  });

  it("renders category icons for each chip", async () => {
    mockGetCategoryOverview.mockResolvedValue({
      ok: true,
      data: MOCK_CATEGORIES,
    });
    render(<CategoriesBrowse />, { wrapper: createWrapper() });
    await vi.waitFor(() => {
      expect(screen.getByTestId("cat-icon-dairy")).toBeInTheDocument();
      expect(screen.getByTestId("cat-icon-chips")).toBeInTheDocument();
    });
  });
});
