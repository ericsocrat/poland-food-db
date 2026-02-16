import { describe, expect, it, vi } from "vitest";
import { render } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ListsHydrator } from "./ListsHydrator";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockUseAvoidProductIds = vi.fn();
const mockUseFavoriteProductIds = vi.fn();

vi.mock("@/hooks/use-lists", () => ({
  useAvoidProductIds: () => mockUseAvoidProductIds(),
  useFavoriteProductIds: () => mockUseFavoriteProductIds(),
}));

function createWrapper() {
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={client}>{children}</QueryClientProvider>
  );
}

describe("ListsHydrator", () => {
  it("calls both hooks on mount", () => {
    render(<ListsHydrator />, { wrapper: createWrapper() });
    expect(mockUseAvoidProductIds).toHaveBeenCalled();
    expect(mockUseFavoriteProductIds).toHaveBeenCalled();
  });

  it("renders nothing visible", () => {
    const { container } = render(<ListsHydrator />, {
      wrapper: createWrapper(),
    });
    expect(container.innerHTML).toBe("");
  });
});
