import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import SearchPage from "./page";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
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
  }) => (
    <a href={href} {...rest}>
      {children}
    </a>
  ),
}));

const mockSearchProducts = vi.fn();
vi.mock("@/lib/api", () => ({
  searchProducts: (...args: unknown[]) => mockSearchProducts(...args),
}));

vi.mock("@/components/search/SearchAutocomplete", () => ({
  SearchAutocomplete: () => <div data-testid="autocomplete" />,
}));

vi.mock("@/components/search/FilterPanel", () => ({
  FilterPanel: ({
    onChange,
  }: {
    filters: unknown;
    onChange: (f: Record<string, unknown>) => void;
    show: boolean;
    onClose: () => void;
  }) => (
    <div data-testid="filter-panel">
      <button
        data-testid="mock-set-category-filter"
        onClick={() => onChange({ category: ["chips"] })}
      />
      <button data-testid="mock-clear-filters" onClick={() => onChange({})} />
    </div>
  ),
}));

vi.mock("@/components/search/ActiveFilterChips", () => ({
  ActiveFilterChips: () => <div data-testid="active-filter-chips" />,
}));

vi.mock("@/components/search/SaveSearchDialog", () => ({
  SaveSearchDialog: () => <div data-testid="save-search-dialog" />,
}));

vi.mock("@/components/product/HealthWarningsCard", () => ({
  HealthWarningBadge: () => <span data-testid="health-warning-badge" />,
}));

vi.mock("@/components/product/AvoidBadge", () => ({
  AvoidBadge: () => <span data-testid="avoid-badge" />,
}));

vi.mock("@/components/product/AddToListMenu", () => ({
  AddToListMenu: () => <span data-testid="add-to-list" />,
}));

vi.mock("@/components/compare/CompareCheckbox", () => ({
  CompareCheckbox: () => <span data-testid="compare-checkbox" />,
}));

vi.mock("@/components/common/LoadingSpinner", () => ({
  LoadingSpinner: ({ size }: { size?: string }) => (
    <div data-testid="loading-spinner" data-size={size} />
  ),
}));

vi.mock("@/components/common/skeletons", () => ({
  SearchResultsSkeleton: () => (
    <div data-testid="skeleton" role="status" aria-busy="true" />
  ),
}));

vi.mock("@/components/common/NutriScoreBadge", () => ({
  NutriScoreBadge: ({ grade }: { grade: string | null }) => (
    <span data-testid="nutri-score-badge">{grade ?? "?"}</span>
  ),
}));

vi.mock("@/components/common/NovaBadge", () => ({
  NovaBadge: ({ group }: { group: number }) => (
    <span data-testid="nova-badge">{group}</span>
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

function makeSearchResult(overrides: Record<string, unknown> = {}) {
  return {
    product_id: 1,
    product_name: "Test Chips",
    product_name_en: null,
    brand: "TestBrand",
    category: "chips",
    category_display: "Chips",
    category_icon: "🍟",
    unhealthiness_score: 65,
    score_band: "high",
    nutri_score: "D",
    nova_group: "4",
    calories: 530,
    high_salt: true,
    high_sugar: false,
    high_sat_fat: false,
    high_additive_load: false,
    is_avoided: false,
    relevance: 1.0,
    ...overrides,
  };
}

function makeSearchResponse(overrides: Record<string, unknown> = {}) {
  return {
    ok: true,
    data: {
      api_version: "v1",
      query: "chips",
      country: "PL",
      total: 2,
      page: 1,
      pages: 1,
      page_size: 20,
      filters_applied: {},
      results: [
        makeSearchResult(),
        makeSearchResult({
          product_id: 2,
          product_name: "Healthy Water",
          brand: "AquaBrand",
          category: "drinks",
          category_display: "Drinks",
          category_icon: "🥤",
          unhealthiness_score: 5,
          score_band: "low",
          nutri_score: "A",
          calories: 0,
        }),
      ],
      ...overrides,
    },
  };
}

// ─── Tests ──────────────────────────────────────────────────────────────────

beforeEach(() => {
  vi.clearAllMocks();
  localStorage.clear();
});

describe("SearchPage", () => {
  it("renders search input with placeholder", () => {
    render(<SearchPage />, { wrapper: createWrapper() });
    expect(screen.getByPlaceholderText("Search products…")).toBeInTheDocument();
  });

  it("renders search button", () => {
    render(<SearchPage />, { wrapper: createWrapper() });
    expect(screen.getByRole("button", { name: "Search" })).toBeInTheDocument();
  });

  it("renders empty state when no search is active", () => {
    render(<SearchPage />, { wrapper: createWrapper() });
    expect(
      screen.getByText("Search by name, brand, or browse with filters"),
    ).toBeInTheDocument();
  });

  it("submits search on form submit and shows results", async () => {
    mockSearchProducts.mockResolvedValue(makeSearchResponse());
    const user = userEvent.setup();

    render(<SearchPage />, { wrapper: createWrapper() });

    const input = screen.getByPlaceholderText("Search products…");
    await user.type(input, "chips");
    await user.click(screen.getByRole("button", { name: "Search" }));

    await waitFor(() => {
      expect(screen.getByText("Test Chips")).toBeInTheDocument();
    });
    expect(screen.getByText("Healthy Water")).toBeInTheDocument();
    expect(screen.getByText(/2 result\(s\)/)).toBeInTheDocument();
  });

  it("shows error state when search fails", async () => {
    mockSearchProducts.mockRejectedValue(new Error("Network error"));
    const user = userEvent.setup();

    render(<SearchPage />, { wrapper: createWrapper() });

    await user.type(screen.getByPlaceholderText("Search products…"), "chips");
    await user.click(screen.getByRole("button", { name: "Search" }));

    await waitFor(() => {
      expect(
        screen.getByText("Search failed. Please try again."),
      ).toBeInTheDocument();
    });
  });

  it("disables search button when input is empty", () => {
    render(<SearchPage />, { wrapper: createWrapper() });
    expect(screen.getByRole("button", { name: "Search" })).toBeDisabled();
  });

  it("clears search when clear button is clicked", async () => {
    mockSearchProducts.mockResolvedValue(makeSearchResponse());
    const user = userEvent.setup();

    render(<SearchPage />, { wrapper: createWrapper() });

    const input = screen.getByPlaceholderText("Search products…");
    await user.type(input, "chips");

    const clearBtn = screen.getByRole("button", { name: "Clear search" });
    await user.click(clearBtn);

    expect(input).toHaveValue("");
  });

  it("shows recent searches from localStorage", () => {
    localStorage.setItem(
      "fooddb:recent-searches",
      JSON.stringify(["chips", "water"]),
    );

    render(<SearchPage />, { wrapper: createWrapper() });

    expect(screen.getByText("chips")).toBeInTheDocument();
    expect(screen.getByText("water")).toBeInTheDocument();
  });

  it("clicking a recent search populates and submits query", async () => {
    mockSearchProducts.mockResolvedValue(makeSearchResponse());
    localStorage.setItem("fooddb:recent-searches", JSON.stringify(["chips"]));
    const user = userEvent.setup();

    render(<SearchPage />, { wrapper: createWrapper() });
    await user.click(screen.getByText("chips"));

    await waitFor(() => {
      expect(mockSearchProducts).toHaveBeenCalled();
    });
  });

  it("renders product cards with score and nutri badges", async () => {
    mockSearchProducts.mockResolvedValue(makeSearchResponse());
    const user = userEvent.setup();

    render(<SearchPage />, { wrapper: createWrapper() });
    await user.type(screen.getByPlaceholderText("Search products…"), "chips");
    await user.click(screen.getByRole("button", { name: "Search" }));

    await waitFor(() => {
      expect(screen.getByText("Test Chips")).toBeInTheDocument();
    });

    // Score badge
    expect(screen.getByText("65")).toBeInTheDocument();
    // Brand and category info
    expect(screen.getByText(/TestBrand/)).toBeInTheDocument();
  });

  it("renders pagination when multiple pages", async () => {
    mockSearchProducts.mockResolvedValue(
      makeSearchResponse({ total: 60, pages: 3, page: 1 }),
    );
    const user = userEvent.setup();

    render(<SearchPage />, { wrapper: createWrapper() });
    await user.type(screen.getByPlaceholderText("Search products…"), "test");
    await user.click(screen.getByRole("button", { name: "Search" }));

    await waitFor(() => {
      expect(screen.getByText("Page 1 of 3")).toBeInTheDocument();
    });

    expect(screen.getByRole("button", { name: "Next →" })).toBeEnabled();
    expect(screen.getByRole("button", { name: "← Prev" })).toBeDisabled();
  });

  it("navigates to next page", async () => {
    mockSearchProducts.mockResolvedValue(
      makeSearchResponse({ total: 60, pages: 3, page: 1 }),
    );
    const user = userEvent.setup();

    render(<SearchPage />, { wrapper: createWrapper() });
    await user.type(screen.getByPlaceholderText("Search products…"), "test");
    await user.click(screen.getByRole("button", { name: "Search" }));

    await waitFor(() => {
      expect(screen.getByText("Page 1 of 3")).toBeInTheDocument();
    });

    mockSearchProducts.mockResolvedValue(
      makeSearchResponse({ total: 60, pages: 3, page: 2 }),
    );

    await user.click(screen.getByRole("button", { name: "Next →" }));

    await waitFor(() => {
      expect(mockSearchProducts).toHaveBeenCalledTimes(2);
    });
  });

  it("shows empty results message", async () => {
    mockSearchProducts.mockResolvedValue(
      makeSearchResponse({ total: 0, results: [], query: "nonexistent" }),
    );
    const user = userEvent.setup();

    render(<SearchPage />, { wrapper: createWrapper() });
    await user.type(
      screen.getByPlaceholderText("Search products…"),
      "nonexistent",
    );
    await user.click(screen.getByRole("button", { name: "Search" }));

    await waitFor(() => {
      expect(
        screen.getByText(/No products match your search/),
      ).toBeInTheDocument();
    });
  });

  it("renders show avoided toggle", () => {
    render(<SearchPage />, { wrapper: createWrapper() });
    expect(screen.getByText("Show avoided")).toBeInTheDocument();
  });

  it("toggles show avoided and persists to localStorage", async () => {
    const user = userEvent.setup();
    render(<SearchPage />, { wrapper: createWrapper() });

    await user.click(screen.getByText("Show avoided"));
    expect(localStorage.getItem("fooddb:show-avoided")).toBe("true");

    await user.click(screen.getByText("Show avoided"));
    expect(localStorage.getItem("fooddb:show-avoided")).toBe("false");
  });

  it("renders saved searches link", () => {
    render(<SearchPage />, { wrapper: createWrapper() });
    expect(screen.getByText("Saved")).toBeInTheDocument();
  });

  it("renders filter panel component", () => {
    render(<SearchPage />, { wrapper: createWrapper() });
    expect(screen.getByTestId("filter-panel")).toBeInTheDocument();
  });

  it("renders active filter chips component", () => {
    render(<SearchPage />, { wrapper: createWrapper() });
    expect(screen.getByTestId("active-filter-chips")).toBeInTheDocument();
  });

  it("product links navigate to product detail", async () => {
    mockSearchProducts.mockResolvedValue(makeSearchResponse());
    const user = userEvent.setup();

    render(<SearchPage />, { wrapper: createWrapper() });
    await user.type(screen.getByPlaceholderText("Search products…"), "chips");
    await user.click(screen.getByRole("button", { name: "Search" }));

    await waitFor(() => {
      expect(screen.getByText("Test Chips")).toBeInTheDocument();
    });

    const productLink = screen.getByText("Test Chips").closest("a");
    expect(productLink).toHaveAttribute("href", "/app/product/1");
  });

  it("renders avoided product with reduced opacity", async () => {
    mockSearchProducts.mockResolvedValue({
      ok: true,
      data: {
        api_version: "v1",
        query: "chips",
        country: "PL",
        total: 1,
        page: 1,
        pages: 1,
        page_size: 20,
        filters_applied: {},
        results: [makeSearchResult({ is_avoided: true })],
      },
    });
    const user = userEvent.setup();

    render(<SearchPage />, { wrapper: createWrapper() });
    await user.type(screen.getByPlaceholderText("Search products…"), "chips");
    await user.click(screen.getByRole("button", { name: "Search" }));

    await waitFor(() => {
      expect(screen.getByText("Test Chips")).toBeInTheDocument();
    });

    const li = screen.getByText("Test Chips").closest("li");
    expect(li?.className).toContain("opacity-50");
  });

  it("saves recent search to localStorage on successful search", async () => {
    mockSearchProducts.mockResolvedValue(makeSearchResponse());
    const user = userEvent.setup();

    render(<SearchPage />, { wrapper: createWrapper() });
    await user.type(screen.getByPlaceholderText("Search products…"), "chips");
    await user.click(screen.getByRole("button", { name: "Search" }));

    await waitFor(() => {
      expect(screen.getByText("Test Chips")).toBeInTheDocument();
    });

    const recent = JSON.parse(
      localStorage.getItem("fooddb:recent-searches") ?? "[]",
    );
    expect(recent).toContain("chips");
  });

  it("shows result count with singular form", async () => {
    mockSearchProducts.mockResolvedValue(
      makeSearchResponse({
        total: 1,
        results: [makeSearchResult()],
      }),
    );
    const user = userEvent.setup();

    render(<SearchPage />, { wrapper: createWrapper() });
    await user.type(screen.getByPlaceholderText("Search products…"), "chips");
    await user.click(screen.getByRole("button", { name: "Search" }));

    await waitFor(() => {
      expect(screen.getByText(/\b1 result\b/)).toBeInTheDocument();
    });
  });

  it("shows calorie info in product row", async () => {
    mockSearchProducts.mockResolvedValue(makeSearchResponse());
    const user = userEvent.setup();

    render(<SearchPage />, { wrapper: createWrapper() });
    await user.type(screen.getByPlaceholderText("Search products…"), "chips");
    await user.click(screen.getByRole("button", { name: "Search" }));

    await waitFor(() => {
      expect(screen.getByText(/530 kcal/)).toBeInTheDocument();
    });
  });

  it("renders page number buttons for many pages", async () => {
    mockSearchProducts.mockResolvedValue(
      makeSearchResponse({ total: 200, pages: 10, page: 5 }),
    );
    const user = userEvent.setup();

    render(<SearchPage />, { wrapper: createWrapper() });
    await user.type(screen.getByPlaceholderText("Search products…"), "test");
    await user.click(screen.getByRole("button", { name: "Search" }));

    await waitFor(() => {
      expect(screen.getByText("Page 5 of 10")).toBeInTheDocument();
    });

    // Should show ellipsis for large page sets
    const ellipses = screen.getAllByText("…");
    expect(ellipses.length).toBeGreaterThan(0);

    // Should show page 1 and page 10
    expect(screen.getByRole("button", { name: "1" })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "10" })).toBeInTheDocument();
  });

  it("clicking a page number button fetches that page", async () => {
    mockSearchProducts.mockResolvedValue(
      makeSearchResponse({ total: 60, pages: 3, page: 1 }),
    );
    const user = userEvent.setup();

    render(<SearchPage />, { wrapper: createWrapper() });
    await user.type(screen.getByPlaceholderText("Search products…"), "test");
    await user.click(screen.getByRole("button", { name: "Search" }));

    await waitFor(() => {
      expect(screen.getByText("Page 1 of 3")).toBeInTheDocument();
    });

    mockSearchProducts.mockResolvedValue(
      makeSearchResponse({ total: 60, pages: 3, page: 2 }),
    );

    await user.click(screen.getByRole("button", { name: "2" }));

    await waitFor(() => {
      expect(mockSearchProducts).toHaveBeenCalledTimes(2);
    });
  });

  it("Prev button navigates back a page", async () => {
    // Start at page 1
    mockSearchProducts.mockResolvedValue(
      makeSearchResponse({ total: 60, pages: 3, page: 1 }),
    );
    const user = userEvent.setup();

    render(<SearchPage />, { wrapper: createWrapper() });
    await user.type(screen.getByPlaceholderText("Search products…"), "test");
    await user.click(screen.getByRole("button", { name: "Search" }));

    await waitFor(() => {
      expect(screen.getByText("Page 1 of 3")).toBeInTheDocument();
    });

    // Navigate to page 2 via page button
    mockSearchProducts.mockResolvedValue(
      makeSearchResponse({ total: 60, pages: 3, page: 2 }),
    );
    await user.click(screen.getByRole("button", { name: "2" }));

    await waitFor(() => {
      expect(screen.getByText("Page 2 of 3")).toBeInTheDocument();
    });

    // Now click Prev
    mockSearchProducts.mockResolvedValue(
      makeSearchResponse({ total: 60, pages: 3, page: 1 }),
    );
    await user.click(screen.getByRole("button", { name: "← Prev" }));

    await waitFor(() => {
      expect(screen.getByText("Page 1 of 3")).toBeInTheDocument();
    });
  });

  it("shows empty results with clear-all-filters button when filters active", async () => {
    mockSearchProducts.mockResolvedValue(
      makeSearchResponse({ total: 0, results: [] }),
    );
    const user = userEvent.setup();

    render(<SearchPage />, { wrapper: createWrapper() });

    // Set category filter first
    await user.click(screen.getByTestId("mock-set-category-filter"));

    await waitFor(() => {
      expect(screen.getByText(/No products match your/)).toBeInTheDocument();
    });

    expect(screen.getByText("Clear all filters")).toBeInTheDocument();
  });

  it("browse mode triggers search with empty query when filters set", async () => {
    mockSearchProducts.mockResolvedValue(makeSearchResponse());
    const user = userEvent.setup();

    render(<SearchPage />, { wrapper: createWrapper() });

    // Set filter — should trigger browse mode
    await user.click(screen.getByTestId("mock-set-category-filter"));

    await waitFor(() => {
      expect(mockSearchProducts).toHaveBeenCalled();
    });
  });

  it("renders product with null calories without crashing", async () => {
    mockSearchProducts.mockResolvedValue({
      ok: true,
      data: {
        api_version: "v1",
        query: "test",
        country: "PL",
        total: 1,
        page: 1,
        pages: 1,
        page_size: 20,
        filters_applied: {},
        results: [makeSearchResult({ calories: null })],
      },
    });
    const user = userEvent.setup();

    render(<SearchPage />, { wrapper: createWrapper() });
    await user.type(screen.getByPlaceholderText("Search products…"), "test");
    await user.click(screen.getByRole("button", { name: "Search" }));

    await waitFor(() => {
      expect(screen.getByText("Test Chips")).toBeInTheDocument();
    });
  });

  it("shows save search button when search is active", async () => {
    mockSearchProducts.mockResolvedValue(makeSearchResponse());
    const user = userEvent.setup();

    render(<SearchPage />, { wrapper: createWrapper() });
    await user.type(screen.getByPlaceholderText("Search products…"), "chips");
    await user.click(screen.getByRole("button", { name: "Search" }));

    await waitFor(() => {
      expect(screen.getByText("Test Chips")).toBeInTheDocument();
    });

    expect(screen.getByText(/Save search/)).toBeInTheDocument();
  });

  it("handles API error with message", async () => {
    mockSearchProducts.mockResolvedValue({
      ok: false,
      error: { message: "Rate limited" },
    });
    const user = userEvent.setup();

    render(<SearchPage />, { wrapper: createWrapper() });
    await user.type(screen.getByPlaceholderText("Search products…"), "chips");
    await user.click(screen.getByRole("button", { name: "Search" }));

    await waitFor(() => {
      expect(
        screen.getByText("Search failed. Please try again."),
      ).toBeInTheDocument();
    });
  });

  // ── View mode toggle ──────────────────────────────────────────────────

  it("renders compact view toggle button", () => {
    render(<SearchPage />, { wrapper: createWrapper() });
    expect(screen.getByLabelText("Toggle view mode")).toBeInTheDocument();
  });

  it("toggles between compact and detailed labels", async () => {
    render(<SearchPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    // Initially shows "Compact" (offers to switch to compact)
    expect(screen.getByText("Compact")).toBeInTheDocument();

    await user.click(screen.getByLabelText("Toggle view mode"));

    // After click shows "Detailed" (offers to switch back)
    expect(screen.getByText("Detailed")).toBeInTheDocument();
  });

  it("persists view mode in localStorage", async () => {
    render(<SearchPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await user.click(screen.getByLabelText("Toggle view mode"));

    expect(localStorage.getItem("fooddb:search-view")).toBe("compact");
  });

  it("renders compact product rows when in compact mode", async () => {
    mockSearchProducts.mockResolvedValue(makeSearchResponse());
    const user = userEvent.setup();
    render(<SearchPage />, { wrapper: createWrapper() });

    // Switch to compact mode
    await user.click(screen.getByLabelText("Toggle view mode"));

    // Perform search
    await user.type(screen.getByPlaceholderText("Search products…"), "chips");
    await user.click(screen.getByRole("button", { name: "Search" }));

    await waitFor(() => {
      expect(screen.getByText("Test Chips")).toBeInTheDocument();
    });

    // In compact mode, NOVA badges should not be rendered
    expect(screen.queryByTestId("nova-badge")).not.toBeInTheDocument();
  });

  // ─── Score tooltips ───────────────────────────────────────────────────

  it("renders score tooltip trigger on detailed product rows", async () => {
    mockSearchProducts.mockResolvedValue(makeSearchResponse());
    const user = userEvent.setup();
    render(<SearchPage />, { wrapper: createWrapper() });

    await user.type(screen.getByPlaceholderText("Search products…"), "chips");
    await user.click(screen.getByRole("button", { name: "Search" }));

    await waitFor(() => {
      expect(screen.getByText("Test Chips")).toBeInTheDocument();
    });

    const triggers = screen.getAllByTestId("score-tooltip-trigger");
    expect(triggers.length).toBeGreaterThanOrEqual(1);
  });

  it("shows tooltip content with health flags when trigger is clicked", async () => {
    // "Test Chips" has high_salt: true
    mockSearchProducts.mockResolvedValue(makeSearchResponse());
    const user = userEvent.setup();
    render(<SearchPage />, { wrapper: createWrapper() });

    await user.type(screen.getByPlaceholderText("Search products…"), "chips");
    await user.click(screen.getByRole("button", { name: "Search" }));

    await waitFor(() => {
      expect(screen.getByText("Test Chips")).toBeInTheDocument();
    });

    const triggers = screen.getAllByTestId("score-tooltip-trigger");
    await user.click(triggers[0]);

    await waitFor(() => {
      expect(screen.getByTestId("score-tooltip-content")).toBeInTheDocument();
    });

    // Should show "High salt" since the first product has high_salt: true
    expect(screen.getByText("High salt")).toBeInTheDocument();
  });

  it("shows 'no major flags' when product has no health flags", async () => {
    mockSearchProducts.mockResolvedValue(
      makeSearchResponse({
        results: [
          makeSearchResult({
            high_salt: false,
            high_sugar: false,
            high_sat_fat: false,
            high_additive_load: false,
            unhealthiness_score: 5,
            score_band: "low",
          }),
        ],
      }),
    );
    const user = userEvent.setup();
    render(<SearchPage />, { wrapper: createWrapper() });

    await user.type(screen.getByPlaceholderText("Search products…"), "test");
    await user.click(screen.getByRole("button", { name: "Search" }));

    await waitFor(() => {
      expect(screen.getByText("Test Chips")).toBeInTheDocument();
    });

    const trigger = screen.getByTestId("score-tooltip-trigger");
    await user.click(trigger);

    await waitFor(() => {
      expect(
        screen.getByText("No major health flags detected."),
      ).toBeInTheDocument();
    });
  });
});
