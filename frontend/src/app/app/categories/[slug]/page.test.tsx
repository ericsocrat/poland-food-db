import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import CategoryListingPage from "./page";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

vi.mock("next/navigation", () => ({
  useParams: () => ({ slug: "chips" }),
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

const mockGetCategoryListing = vi.fn();
vi.mock("@/lib/api", () => ({
  getCategoryListing: (...args: unknown[]) => mockGetCategoryListing(...args),
}));

vi.mock("@/components/common/LoadingSpinner", () => ({
  LoadingSpinner: () => <div data-testid="spinner">Loading…</div>,
}));

// Stub child components
vi.mock("@/components/product/HealthWarningsCard", () => ({
  HealthWarningBadge: () => <span data-testid="health-badge" />,
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

const mockProducts = [
  {
    product_id: 1,
    ean: "1234567890123",
    product_name: "Lay's Classic",
    brand: "Lay's",
    unhealthiness_score: 72,
    score_band: "high" as const,
    nutri_score: "D" as const,
    nova_group: "4",
    processing_risk: "high",
    calories: 536,
    total_fat_g: 33,
    protein_g: 6,
    sugars_g: 1,
    salt_g: 1.3,
    high_salt_flag: true,
    high_sugar_flag: false,
    high_sat_fat_flag: true,
    confidence: "high",
    data_completeness_pct: 95,
  },
  {
    product_id: 2,
    ean: "2345678901234",
    product_name: "Pringles Original",
    brand: "Pringles",
    unhealthiness_score: 65,
    score_band: "moderate" as const,
    nutri_score: "C" as const,
    nova_group: "4",
    processing_risk: "high",
    calories: 520,
    total_fat_g: 32,
    protein_g: 4,
    sugars_g: 2,
    salt_g: 1.8,
    high_salt_flag: true,
    high_sugar_flag: false,
    high_sat_fat_flag: false,
    confidence: "high",
    data_completeness_pct: 90,
  },
];

beforeEach(() => {
  vi.clearAllMocks();
  mockGetCategoryListing.mockResolvedValue({
    ok: true,
    data: {
      total_count: 2,
      products: mockProducts,
    },
  });
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("CategoryListingPage", () => {
  it("renders category title from slug", async () => {
    render(<CategoryListingPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("chips")).toBeInTheDocument();
    });
  });

  it("shows total product count", async () => {
    render(<CategoryListingPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("2 product(s)")).toBeInTheDocument();
    });
  });

  it("links back to categories page", async () => {
    render(<CategoryListingPage />, { wrapper: createWrapper() });
    expect(screen.getByText("Categories").closest("a")).toHaveAttribute(
      "href",
      "/app/categories",
    );
  });

  it("shows loading spinner while fetching", () => {
    mockGetCategoryListing.mockReturnValue(new Promise(() => {}));
    render(<CategoryListingPage />, { wrapper: createWrapper() });
    expect(screen.getByTestId("spinner")).toBeInTheDocument();
  });

  it("shows error state on API failure", async () => {
    mockGetCategoryListing.mockResolvedValue({
      ok: false,
      error: { message: "Server err" },
    });
    render(<CategoryListingPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Failed to load categories.")).toBeInTheDocument();
    });
  });

  it("shows retry button on error", async () => {
    mockGetCategoryListing.mockResolvedValue({
      ok: false,
      error: { message: "Server err" },
    });
    render(<CategoryListingPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Retry")).toBeInTheDocument();
    });
  });

  it("shows empty state when no products", async () => {
    mockGetCategoryListing.mockResolvedValue({
      ok: true,
      data: { total_count: 0, products: [] },
    });
    render(<CategoryListingPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(
        screen.getByText("No products in this category."),
      ).toBeInTheDocument();
    });
  });

  it("renders product rows with names and brands", async () => {
    render(<CategoryListingPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Lay's Classic")).toBeInTheDocument();
    });
    expect(screen.getByText("Pringles Original")).toBeInTheDocument();
  });

  it("shows health warning flags", async () => {
    render(<CategoryListingPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      // Both products have high_salt_flag so multiple elements
      expect(screen.getAllByText("High salt")).toHaveLength(2);
    });
    expect(screen.getByText("High sat. fat")).toBeInTheDocument();
  });

  it("renders sort controls", async () => {
    render(<CategoryListingPage />, { wrapper: createWrapper() });
    const select = screen.getByRole("combobox");
    expect(select).toBeInTheDocument();
    // Default sort
    expect(screen.getByText("↑ Asc")).toBeInTheDocument();
  });

  it("toggles sort direction", async () => {
    render(<CategoryListingPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await user.click(screen.getByText("↑ Asc"));
    expect(screen.getByText("↓ Desc")).toBeInTheDocument();
  });

  it("links product rows to detail pages", async () => {
    render(<CategoryListingPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Lay's Classic")).toBeInTheDocument();
    });
    const link = screen.getByText("Lay's Classic").closest("a");
    expect(link).toHaveAttribute("href", "/app/product/1");
  });

  it("does not show pagination for single page", async () => {
    render(<CategoryListingPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Lay's Classic")).toBeInTheDocument();
    });
    expect(screen.queryByText("Previous")).not.toBeInTheDocument();
    expect(screen.queryByText("Next")).not.toBeInTheDocument();
  });

  it("shows pagination when multiple pages", async () => {
    mockGetCategoryListing.mockResolvedValue({
      ok: true,
      data: {
        total_count: 45,
        products: mockProducts,
      },
    });
    render(<CategoryListingPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Previous")).toBeInTheDocument();
    });
    expect(screen.getByText("Next →")).toBeInTheDocument();
    expect(screen.getByText("Page 1 of 3")).toBeInTheDocument();
  });

  it("renders product score badges", async () => {
    render(<CategoryListingPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("72")).toBeInTheDocument();
    });
    expect(screen.getByText("65")).toBeInTheDocument();
  });

  it("renders nutri-score badges", async () => {
    render(<CategoryListingPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("D")).toBeInTheDocument();
    });
    expect(screen.getByText("C")).toBeInTheDocument();
  });

  it("uses singular 'product' for count of 1", async () => {
    mockGetCategoryListing.mockResolvedValue({
      ok: true,
      data: {
        total_count: 1,
        products: [mockProducts[0]],
      },
    });
    render(<CategoryListingPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("1 product(s)")).toBeInTheDocument();
    });
  });

  it("renders child component badges per row", async () => {
    render(<CategoryListingPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Lay's Classic")).toBeInTheDocument();
    });
    expect(screen.getAllByTestId("health-badge")).toHaveLength(2);
    expect(screen.getAllByTestId("avoid-badge")).toHaveLength(2);
    expect(screen.getAllByTestId("compare-checkbox")).toHaveLength(2);
  });
});
