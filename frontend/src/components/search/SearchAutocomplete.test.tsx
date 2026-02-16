import { useState } from "react";
import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { SearchAutocomplete } from "./SearchAutocomplete";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockPush = vi.fn();
vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: mockPush }),
}));

const mockSearchAutocomplete = vi.fn();
vi.mock("@/lib/api", () => ({
  searchAutocomplete: (...args: unknown[]) => mockSearchAutocomplete(...args),
}));

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => "mock-supabase",
}));

vi.mock("@/lib/constants", () => ({
  SCORE_BANDS: {
    good: { bg: "bg-green-100", color: "text-green-800" },
    mid: { bg: "bg-yellow-100", color: "text-yellow-800" },
    bad: { bg: "bg-red-100", color: "text-red-800" },
  },
  NUTRI_COLORS: {
    A: "bg-green-500 text-white",
    B: "bg-lime-400 text-gray-900",
    C: "bg-yellow-400 text-gray-900",
    D: "bg-orange-400 text-white",
    E: "bg-red-500 text-white",
  },
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

const SUGGESTIONS = [
  {
    product_id: 1,
    product_name: "Lay's Classic",
    brand: "Lay's",
    category: "Chips",
    unhealthiness_score: 65,
    score_band: "mid" as const,
    nutri_score: "C" as const,
  },
  {
    product_id: 2,
    product_name: "Pringles Original",
    brand: "Pringles",
    category: "Chips",
    unhealthiness_score: 72,
    score_band: "bad" as const,
    nutri_score: "D" as const,
  },
];

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

const defaultProps = {
  query: "lay",
  onSelect: vi.fn(),
  onQuerySubmit: vi.fn(),
  onQueryChange: vi.fn(),
  show: true,
  onClose: vi.fn(),
};

beforeEach(() => {
  vi.clearAllMocks();
  mockSearchAutocomplete.mockResolvedValue({
    ok: true,
    data: { suggestions: SUGGESTIONS },
  });
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("SearchAutocomplete", () => {
  it("returns null when show=false", () => {
    const { container } = render(
      <SearchAutocomplete {...defaultProps} show={false} />,
      { wrapper: createWrapper() },
    );
    expect(container.innerHTML).toBe("");
  });

  it("returns null when query is empty", () => {
    const { container } = render(
      <SearchAutocomplete {...defaultProps} query="" />,
      { wrapper: createWrapper() },
    );
    expect(container.innerHTML).toBe("");
  });

  it("shows suggestions after debounce", async () => {
    render(<SearchAutocomplete {...defaultProps} />, {
      wrapper: createWrapper(),
    });

    await waitFor(
      () => {
        expect(screen.getByText("Lay's Classic")).toBeInTheDocument();
        expect(screen.getByText("Pringles Original")).toBeInTheDocument();
      },
      { timeout: 1000 },
    );
  });

  it("renders 'Search for' footer", async () => {
    render(<SearchAutocomplete {...defaultProps} />, {
      wrapper: createWrapper(),
    });

    await waitFor(
      () => {
        expect(screen.getByText(/Search for/)).toBeInTheDocument();
      },
      { timeout: 1000 },
    );
  });

  it("calls onSelect and routes on suggestion click", async () => {
    render(<SearchAutocomplete {...defaultProps} />, {
      wrapper: createWrapper(),
    });

    await waitFor(
      () => {
        expect(screen.getByText("Lay's Classic")).toBeInTheDocument();
      },
      { timeout: 1000 },
    );

    fireEvent.click(screen.getByText("Lay's Classic"));
    expect(defaultProps.onSelect).toHaveBeenCalledWith(SUGGESTIONS[0]);
    expect(mockPush).toHaveBeenCalledWith("/app/product/1");
    expect(defaultProps.onClose).toHaveBeenCalled();
  });

  it("renders score badges", async () => {
    render(<SearchAutocomplete {...defaultProps} />, {
      wrapper: createWrapper(),
    });

    await waitFor(
      () => {
        expect(screen.getByText("65")).toBeInTheDocument();
        expect(screen.getByText("72")).toBeInTheDocument();
      },
      { timeout: 1000 },
    );
  });

  it("renders nutri-score badges", async () => {
    render(<SearchAutocomplete {...defaultProps} />, {
      wrapper: createWrapper(),
    });

    await waitFor(
      () => {
        expect(screen.getByText("C")).toBeInTheDocument();
        expect(screen.getByText("D")).toBeInTheDocument();
      },
      { timeout: 1000 },
    );
  });

  it("calls onQuerySubmit from footer button", async () => {
    render(<SearchAutocomplete {...defaultProps} />, {
      wrapper: createWrapper(),
    });

    await waitFor(
      () => {
        expect(screen.getByText(/Search for/)).toBeInTheDocument();
      },
      { timeout: 1000 },
    );

    fireEvent.click(screen.getByText(/Search for/));
    expect(defaultProps.onQuerySubmit).toHaveBeenCalledWith("lay");
    expect(defaultProps.onClose).toHaveBeenCalled();
  });

  it("renders brand and category in suggestion", async () => {
    render(<SearchAutocomplete {...defaultProps} />, {
      wrapper: createWrapper(),
    });

    await waitFor(
      () => {
        expect(
          screen.getByText((_, el) =>
            el?.textContent === "Lay's · Chips" ? true : false,
          ),
        ).toBeInTheDocument();
      },
      { timeout: 1000 },
    );
  });
});
