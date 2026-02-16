import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import SharedListPage from "./page";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("next/navigation", () => ({
  useParams: () => ({ token: "abc123" }),
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

const mockUseSharedList = vi.fn();
vi.mock("@/hooks/use-lists", () => ({
  useSharedList: (...args: unknown[]) => mockUseSharedList(...args),
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

const mockListData = {
  list_name: "My Favorites",
  description: "Best foods I found",
  total_count: 2,
  items: [
    {
      product_id: 1,
      product_name: "Chips Original",
      brand: "Lay's",
      category: "Chips",
      unhealthiness_score: 72,
      nutri_score_label: "D",
    },
    {
      product_id: 2,
      product_name: "Green Juice",
      brand: "Suja",
      category: "Drinks",
      unhealthiness_score: 15,
      nutri_score_label: "A",
    },
  ],
};

beforeEach(() => {
  vi.clearAllMocks();
});

describe("SharedListPage", () => {
  it("shows loading spinner while loading", () => {
    mockUseSharedList.mockReturnValue({
      data: undefined,
      isLoading: true,
      error: null,
    });

    render(<SharedListPage />, { wrapper: createWrapper() });
    // Should render without error during loading
    expect(document.querySelector(".min-h-screen")).toBeTruthy();
  });

  it("shows not found message on error", () => {
    mockUseSharedList.mockReturnValue({
      data: undefined,
      isLoading: false,
      error: new Error("Not found"),
    });

    render(<SharedListPage />, { wrapper: createWrapper() });
    expect(screen.getByText("List not found")).toBeInTheDocument();
  });

  it("shows not found when data is null", () => {
    mockUseSharedList.mockReturnValue({
      data: null,
      isLoading: false,
      error: null,
    });

    render(<SharedListPage />, { wrapper: createWrapper() });
    expect(screen.getByText("List not found")).toBeInTheDocument();
  });

  it("shows go home link on error", () => {
    mockUseSharedList.mockReturnValue({
      data: undefined,
      isLoading: false,
      error: new Error("Not found"),
    });

    render(<SharedListPage />, { wrapper: createWrapper() });
    expect(screen.getByText("Go home").closest("a")).toHaveAttribute(
      "href",
      "/",
    );
  });

  it("renders list name and description", () => {
    mockUseSharedList.mockReturnValue({
      data: mockListData,
      isLoading: false,
      error: null,
    });

    render(<SharedListPage />, { wrapper: createWrapper() });
    expect(screen.getByText("My Favorites")).toBeInTheDocument();
    expect(screen.getByText("Best foods I found")).toBeInTheDocument();
  });

  it("renders product count", () => {
    mockUseSharedList.mockReturnValue({
      data: mockListData,
      isLoading: false,
      error: null,
    });

    render(<SharedListPage />, { wrapper: createWrapper() });
    expect(screen.getByText("2 product(s)")).toBeInTheDocument();
  });

  it("renders singular product count", () => {
    mockUseSharedList.mockReturnValue({
      data: { ...mockListData, total_count: 1, items: [mockListData.items[0]] },
      isLoading: false,
      error: null,
    });

    render(<SharedListPage />, { wrapper: createWrapper() });
    expect(screen.getByText("1 product(s)")).toBeInTheDocument();
  });

  it("renders product names and brands", () => {
    mockUseSharedList.mockReturnValue({
      data: mockListData,
      isLoading: false,
      error: null,
    });

    render(<SharedListPage />, { wrapper: createWrapper() });
    expect(screen.getByText("Chips Original")).toBeInTheDocument();
    expect(screen.getByText("Green Juice")).toBeInTheDocument();
  });

  it("renders empty list message", () => {
    mockUseSharedList.mockReturnValue({
      data: { ...mockListData, items: [] },
      isLoading: false,
      error: null,
    });

    render(<SharedListPage />, { wrapper: createWrapper() });
    expect(screen.getByText("This list is empty.")).toBeInTheDocument();
  });

  it("renders shared list badge", () => {
    mockUseSharedList.mockReturnValue({
      data: mockListData,
      isLoading: false,
      error: null,
    });

    render(<SharedListPage />, { wrapper: createWrapper() });
    expect(screen.getByText("Shared list")).toBeInTheDocument();
  });

  it("passes token to useSharedList", () => {
    mockUseSharedList.mockReturnValue({
      data: undefined,
      isLoading: true,
      error: null,
    });

    render(<SharedListPage />, { wrapper: createWrapper() });
    expect(mockUseSharedList).toHaveBeenCalledWith("abc123");
  });
});
