import { useState } from "react";
import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { DidYouMean } from "./DidYouMean";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockSearchDidYouMean = vi.fn();
vi.mock("@/lib/api", () => ({
  searchDidYouMean: (...args: unknown[]) => mockSearchDidYouMean(...args),
}));

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => "mock-supabase",
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

const SUGGESTIONS = [
  {
    product_id: 101,
    product_name: "Mleko UHT 3.2%",
    brand: "Mlekovita",
    category: "Dairy",
    unhealthiness_score: 25,
    sim: 0.45,
  },
  {
    product_id: 102,
    product_name: "Mleko Wiejskie",
    brand: "Piątnica",
    category: "Dairy",
    unhealthiness_score: 22,
    sim: 0.35,
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

beforeEach(() => {
  vi.clearAllMocks();
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("DidYouMean", () => {
  it("renders suggestions when API returns matches", async () => {
    mockSearchDidYouMean.mockResolvedValue({
      ok: true,
      data: { query: "mlkeo", suggestions: SUGGESTIONS },
    });

    render(<DidYouMean query="mlkeo" onSuggestionClick={vi.fn()} />, {
      wrapper: createWrapper(),
    });

    await waitFor(() => {
      expect(screen.getByTestId("did-you-mean")).toBeInTheDocument();
    });

    expect(screen.getByText(/Did you mean/)).toBeInTheDocument();
    expect(screen.getByText(/Mleko UHT 3\.2%/)).toBeInTheDocument();
    expect(screen.getByText(/Mleko Wiejskie/)).toBeInTheDocument();
  });

  it("calls onSuggestionClick when a suggestion is clicked", async () => {
    mockSearchDidYouMean.mockResolvedValue({
      ok: true,
      data: { query: "mlkeo", suggestions: SUGGESTIONS },
    });

    const handleClick = vi.fn();
    render(<DidYouMean query="mlkeo" onSuggestionClick={handleClick} />, {
      wrapper: createWrapper(),
    });

    await waitFor(() => {
      expect(screen.getByTestId("did-you-mean-link-0")).toBeInTheDocument();
    });

    fireEvent.click(screen.getByTestId("did-you-mean-link-0"));
    expect(handleClick).toHaveBeenCalledWith("Mleko UHT 3.2%");
  });

  it("renders nothing when API returns no suggestions", async () => {
    mockSearchDidYouMean.mockResolvedValue({
      ok: true,
      data: { query: "xyzabc", suggestions: [] },
    });

    const { container } = render(
      <DidYouMean query="xyzabc" onSuggestionClick={vi.fn()} />,
      { wrapper: createWrapper() },
    );

    // Wait for query to settle — component should not render
    await waitFor(() => {
      expect(mockSearchDidYouMean).toHaveBeenCalled();
    });

    expect(container.querySelector("[data-testid='did-you-mean']")).toBeNull();
  });

  it("renders nothing when query is too short", () => {
    const { container } = render(
      <DidYouMean query="x" onSuggestionClick={vi.fn()} />,
      { wrapper: createWrapper() },
    );

    expect(container.querySelector("[data-testid='did-you-mean']")).toBeNull();
  });

  it("handles API errors gracefully", async () => {
    mockSearchDidYouMean.mockResolvedValue({
      ok: false,
      error: { code: "500", message: "Internal error" },
    });

    const { container } = render(
      <DidYouMean query="mlkeo" onSuggestionClick={vi.fn()} />,
      { wrapper: createWrapper() },
    );

    await waitFor(() => {
      expect(mockSearchDidYouMean).toHaveBeenCalled();
    });

    expect(container.querySelector("[data-testid='did-you-mean']")).toBeNull();
  });

  it("deduplicates suggestions with the same product name", async () => {
    const dupes = [
      { ...SUGGESTIONS[0] },
      { ...SUGGESTIONS[0], product_id: 999 }, // same name, different ID
    ];
    mockSearchDidYouMean.mockResolvedValue({
      ok: true,
      data: { query: "mlkeo", suggestions: dupes },
    });

    render(<DidYouMean query="mlkeo" onSuggestionClick={vi.fn()} />, {
      wrapper: createWrapper(),
    });

    await waitFor(() => {
      expect(screen.getByTestId("did-you-mean")).toBeInTheDocument();
    });

    // Should only show one suggestion button, not two
    const links = screen.getAllByTestId(/did-you-mean-link/);
    expect(links).toHaveLength(1);
  });
});
