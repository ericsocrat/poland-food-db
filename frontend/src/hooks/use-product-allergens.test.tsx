import { useProductAllergenWarnings } from "@/hooks/use-product-allergens";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { renderHook, waitFor } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockGetProductAllergens = vi.fn();

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

vi.mock("@/lib/api", () => ({
  getProductAllergens: (...args: unknown[]) =>
    mockGetProductAllergens(...args),
}));

const mockUsePreferences = vi.fn();

vi.mock("@/components/common/RouteGuard", () => ({
  usePreferences: () => mockUsePreferences(),
}));

const mockMatchProductAllergens = vi.fn();

vi.mock("@/lib/allergen-matching", async (importOriginal) => {
  // eslint-disable-next-line @typescript-eslint/consistent-type-imports
  const original = await importOriginal<typeof import("@/lib/allergen-matching")>();
  return {
    ...original,
    matchProductAllergens: (...args: unknown[]) =>
      mockMatchProductAllergens(...args),
  };
});

// ─── Helpers ────────────────────────────────────────────────────────────────

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, staleTime: 0 } },
  });
  return function Wrapper({ children }: { children: React.ReactNode }) {
    return (
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    );
  };
}

const milkWarning = {
  tag: "milk",
  label: "Milk / Dairy",
  icon: "🥛",
  type: "contains" as const,
};

const glutenWarning = {
  tag: "gluten",
  label: "Gluten",
  icon: "🌾",
  type: "traces" as const,
};

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("useProductAllergenWarnings", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockUsePreferences.mockReturnValue({
      avoid_allergens: ["milk", "gluten"],
      treat_may_contain_as_unsafe: false,
    });
  });

  it("returns allergen warnings for matching products", async () => {
    const allergenData = {
      "42": { contains: ["milk"], traces: [] },
      "99": { contains: ["gluten"], traces: ["milk"] },
    };
    mockGetProductAllergens.mockResolvedValue({ ok: true, data: allergenData });
    mockMatchProductAllergens
      .mockReturnValueOnce([milkWarning])
      .mockReturnValueOnce([glutenWarning]);

    const { result } = renderHook(
      () => useProductAllergenWarnings([42, 99]),
      { wrapper: createWrapper() },
    );

    await waitFor(() => expect(result.current).toEqual({
      42: [milkWarning],
      99: [glutenWarning],
    }));

    expect(mockGetProductAllergens).toHaveBeenCalledWith(
      expect.anything(),
      [42, 99],
    );
  });

  it("returns empty map when no allergen preferences", () => {
    mockUsePreferences.mockReturnValue({
      avoid_allergens: [],
      treat_may_contain_as_unsafe: false,
    });

    const { result } = renderHook(
      () => useProductAllergenWarnings([42]),
      { wrapper: createWrapper() },
    );

    // Query should be disabled (no allergen preferences)
    expect(result.current).toEqual({});
    expect(mockGetProductAllergens).not.toHaveBeenCalled();
  });

  it("returns empty map when preferences are undefined", () => {
    mockUsePreferences.mockReturnValue(undefined);

    const { result } = renderHook(
      () => useProductAllergenWarnings([42]),
      { wrapper: createWrapper() },
    );

    expect(result.current).toEqual({});
    expect(mockGetProductAllergens).not.toHaveBeenCalled();
  });

  it("returns empty map when productIds is empty", () => {
    const { result } = renderHook(
      () => useProductAllergenWarnings([]),
      { wrapper: createWrapper() },
    );

    expect(result.current).toEqual({});
    expect(mockGetProductAllergens).not.toHaveBeenCalled();
  });

  it("excludes products with no matching warnings", async () => {
    const allergenData = {
      "42": { contains: ["milk"], traces: [] },
      "55": { contains: ["soybeans"], traces: [] },
    };
    mockGetProductAllergens.mockResolvedValue({ ok: true, data: allergenData });
    mockMatchProductAllergens
      .mockReturnValueOnce([milkWarning])
      .mockReturnValueOnce([]); // No match for product 55

    const { result } = renderHook(
      () => useProductAllergenWarnings([42, 55]),
      { wrapper: createWrapper() },
    );

    await waitFor(() => expect(result.current).toEqual({
      42: [milkWarning],
    }));

    // Product 55 should NOT be in the result (empty warnings)
    expect(result.current[55]).toBeUndefined();
  });

  it("passes avoidAllergens and treatMayContainAsUnsafe to matcher", async () => {
    mockUsePreferences.mockReturnValue({
      avoid_allergens: ["peanuts"],
      treat_may_contain_as_unsafe: true,
    });

    const allergenData = {
      "42": { contains: [], traces: ["peanuts"] },
    };
    mockGetProductAllergens.mockResolvedValue({ ok: true, data: allergenData });
    mockMatchProductAllergens.mockReturnValue([]);

    renderHook(
      () => useProductAllergenWarnings([42]),
      { wrapper: createWrapper() },
    );

    await waitFor(() =>
      expect(mockMatchProductAllergens).toHaveBeenCalledWith(
        { contains: [], traces: ["peanuts"] },
        ["peanuts"],
        true,
      ),
    );
  });

  it("handles API error gracefully", async () => {
    mockGetProductAllergens.mockResolvedValue({
      ok: false,
      error: { code: "ERR", message: "server error" },
    });

    const { result } = renderHook(
      () => useProductAllergenWarnings([42]),
      { wrapper: createWrapper() },
    );

    // The hook returns {} as default, even when query errors
    // (the useMemo returns {} when rawAllergenMap is undefined)
    await waitFor(() => expect(mockGetProductAllergens).toHaveBeenCalled());
    expect(result.current).toEqual({});
  });

  it("returns warnings for multiple products", async () => {
    const allergenData = {
      "1": { contains: ["milk"], traces: [] },
      "2": { contains: ["gluten"], traces: ["milk"] },
      "3": { contains: ["milk", "gluten"], traces: [] },
    };
    mockGetProductAllergens.mockResolvedValue({ ok: true, data: allergenData });
    mockMatchProductAllergens
      .mockReturnValueOnce([milkWarning])
      .mockReturnValueOnce([glutenWarning])
      .mockReturnValueOnce([milkWarning, glutenWarning]);

    const { result } = renderHook(
      () => useProductAllergenWarnings([1, 2, 3]),
      { wrapper: createWrapper() },
    );

    await waitFor(() => expect(Object.keys(result.current)).toHaveLength(3));
    expect(result.current[1]).toEqual([milkWarning]);
    expect(result.current[2]).toEqual([glutenWarning]);
    expect(result.current[3]).toEqual([milkWarning, glutenWarning]);
  });

  it("returns empty map when all products have no warnings", async () => {
    const allergenData = {
      "42": { contains: ["soybeans"], traces: [] },
    };
    mockGetProductAllergens.mockResolvedValue({ ok: true, data: allergenData });
    mockMatchProductAllergens.mockReturnValue([]);

    const { result } = renderHook(
      () => useProductAllergenWarnings([42]),
      { wrapper: createWrapper() },
    );

    await waitFor(() => expect(mockMatchProductAllergens).toHaveBeenCalled());
    expect(result.current).toEqual({});
  });
});
