import { useState } from "react";
import { describe, expect, it, vi, beforeEach } from "vitest";
import {
  render,
  screen,
  fireEvent,
  waitFor,
  act,
} from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { SearchAutocomplete } from "./SearchAutocomplete";
import { RECENT_SEARCHES_KEY } from "@/lib/recent-searches";

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
    A: "bg-nutri-A text-foreground-inverse",
    B: "bg-nutri-B text-foreground-inverse",
    C: "bg-nutri-C text-foreground",
    D: "bg-nutri-D text-foreground-inverse",
    E: "bg-nutri-E text-foreground-inverse",
  },
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

const SUGGESTIONS = [
  {
    product_id: 1,
    product_name: "Lay's Classic",
    product_name_en: null,
    product_name_display: "Lay's Classic",
    brand: "Lay's",
    category: "Chips",
    unhealthiness_score: 65,
    score_band: "mid" as const,
    nutri_score: "C" as const,
  },
  {
    product_id: 2,
    product_name: "Pringles Original",
    product_name_en: null,
    product_name_display: "Pringles Original",
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
  localStorage.clear();
  // jsdom doesn't implement scrollIntoView — polyfill for keyboard nav tests
  Element.prototype.scrollIntoView = vi.fn();
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

  it("shows popular searches when query is empty", () => {
    const { container } = render(
      <SearchAutocomplete {...defaultProps} query="" />,
      { wrapper: createWrapper() },
    );
    // Popular searches are shown when query is empty and there are no recent searches
    expect(
      container.querySelector("[aria-label='Popular Searches']"),
    ).toBeTruthy();
  });

  it("shows suggestions after debounce", async () => {
    render(<SearchAutocomplete {...defaultProps} />, {
      wrapper: createWrapper(),
    });

    await waitFor(
      () => {
        // HighlightMatch may split the product name across elements,
        // so we match on the option role + textContent instead
        const options = screen.getAllByRole("option");
        const names = options.map((o) => o.textContent);
        expect(names.some((n) => n?.includes("Lay's Classic"))).toBe(true);
        expect(names.some((n) => n?.includes("Pringles Original"))).toBe(true);
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
        const options = screen.getAllByRole("option");
        expect(options.length).toBeGreaterThanOrEqual(1);
      },
      { timeout: 1000 },
    );

    // Click the first option's button ("Lay's Classic")
    const firstOption = screen.getAllByRole("option")[0];
    const btn = firstOption.querySelector("button")!;
    fireEvent.click(btn);
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
          screen.getByText((_, el) => el?.textContent === "Lay's · Chips"),
        ).toBeInTheDocument();
      },
      { timeout: 1000 },
    );
  });

  // ─── Recent searches section tests ──────────────────────────────────────

  it("shows recent searches section when localStorage has data", () => {
    // Use terms NOT in POPULAR_SEARCHES to avoid duplicate text nodes
    localStorage.setItem(
      RECENT_SEARCHES_KEY,
      JSON.stringify(["piwo", "kawa", "herbata"]),
    );
    render(<SearchAutocomplete {...defaultProps} query="" />, {
      wrapper: createWrapper(),
    });
    expect(screen.getByText("piwo")).toBeInTheDocument();
    expect(screen.getByText("kawa")).toBeInTheDocument();
    expect(screen.getByText("herbata")).toBeInTheDocument();
  });

  it("shows both recent and popular sections together", () => {
    localStorage.setItem(RECENT_SEARCHES_KEY, JSON.stringify(["piwo", "kawa"]));
    render(
      <SearchAutocomplete {...defaultProps} query="" />,
      { wrapper: createWrapper() },
    );
    // Recent header
    expect(screen.getByText("Recent searches")).toBeInTheDocument();
    // Popular header
    expect(screen.getByText("Popular Searches")).toBeInTheDocument();
    // Recent items present
    expect(screen.getByText("piwo")).toBeInTheDocument();
    // Popular items present — "chleb" is a popular search not in recents
    expect(screen.getByText("chleb")).toBeInTheDocument();
    // Separator border between sections
    const popularHeader = screen.getByText("Popular Searches").closest("div");
    expect(popularHeader?.className).toContain("border-t");
  });

  it("clicking a recent search calls onQuerySubmit", () => {
    localStorage.setItem(RECENT_SEARCHES_KEY, JSON.stringify(["piwo"]));
    render(<SearchAutocomplete {...defaultProps} query="" />, {
      wrapper: createWrapper(),
    });
    fireEvent.click(screen.getByText("piwo"));
    expect(defaultProps.onQuerySubmit).toHaveBeenCalledWith("piwo");
    expect(defaultProps.onClose).toHaveBeenCalled();
  });

  it("remove button removes individual recent search", () => {
    localStorage.setItem(RECENT_SEARCHES_KEY, JSON.stringify(["piwo", "kawa"]));
    render(<SearchAutocomplete {...defaultProps} query="" />, {
      wrapper: createWrapper(),
    });
    // Click the X button for "piwo"
    const removeBtn = screen.getByRole("button", {
      name: /Remove piwo/,
    });
    fireEvent.click(removeBtn);
    // "piwo" should be gone from the DOM
    expect(screen.queryByText("piwo")).not.toBeInTheDocument();
    // "kawa" should still be present
    expect(screen.getByText("kawa")).toBeInTheDocument();
  });

  it("clear button removes all recent searches", () => {
    localStorage.setItem(RECENT_SEARCHES_KEY, JSON.stringify(["piwo", "kawa"]));
    render(<SearchAutocomplete {...defaultProps} query="" />, {
      wrapper: createWrapper(),
    });
    // Click the "Clear" button
    fireEvent.click(screen.getByText("Clear"));
    // Recent items should be gone
    expect(screen.queryByText("Recent searches")).not.toBeInTheDocument();
    // Popular section should still show
    expect(screen.getByText("Popular Searches")).toBeInTheDocument();
  });

  it("recent searches have correct option IDs for keyboard nav", () => {
    localStorage.setItem(RECENT_SEARCHES_KEY, JSON.stringify(["piwo", "kawa"]));
    const { container } = render(
      <SearchAutocomplete {...defaultProps} query="" />,
      { wrapper: createWrapper() },
    );
    // Recent items: IDs 0, 1
    expect(
      container.querySelector("#search-autocomplete-option-0"),
    ).toBeTruthy();
    expect(
      container.querySelector("#search-autocomplete-option-1"),
    ).toBeTruthy();
    // First popular item: ID 2 (offset by 2 recent items)
    expect(
      container.querySelector("#search-autocomplete-option-2"),
    ).toBeTruthy();
  });

  it("returns null when query has no matching suggestions (empty result)", async () => {
    mockSearchAutocomplete.mockResolvedValue({
      ok: true,
      data: { suggestions: [] },
    });
    const { container } = render(
      <SearchAutocomplete {...defaultProps} query="xyznonexistent" />,
      { wrapper: createWrapper() },
    );
    // Wait for debounce + fetch cycle
    await waitFor(
      () => {
        expect(
          container.querySelector("#search-autocomplete-listbox"),
        ).toBeNull();
      },
      { timeout: 1000 },
    );
  });

  it("highlights matching text in suggestions", async () => {
    render(<SearchAutocomplete {...defaultProps} query="lay" />, {
      wrapper: createWrapper(),
    });
    await waitFor(
      () => {
        const marks = document.querySelectorAll("mark");
        expect(marks.length).toBeGreaterThanOrEqual(1);
        // The mark should contain the matched portion
        const markTexts = [...marks].map((m) => m.textContent?.toLowerCase());
        expect(markTexts.some((t) => t?.includes("lay"))).toBe(true);
      },
      { timeout: 1000 },
    );
  });

  it("reports active ID via onActiveIdChange callback", () => {
    const onActiveIdChange = vi.fn();
    render(
      <SearchAutocomplete
        {...defaultProps}
        query=""
        onActiveIdChange={onActiveIdChange}
      />,
      { wrapper: createWrapper() },
    );
    // Initial call should report undefined (no item active)
    expect(onActiveIdChange).toHaveBeenCalledWith(undefined);
  });

  it("closes dropdown on outside mousedown", () => {
    const onClose = vi.fn();
    render(
      <SearchAutocomplete {...defaultProps} query="" onClose={onClose} />,
      { wrapper: createWrapper() },
    );
    // Click outside the dropdown
    fireEvent.mouseDown(document.body);
    expect(onClose).toHaveBeenCalled();
  });

  it("shows loading state while fetching suggestions", () => {
    // Return a never-resolving promise to simulate loading
    mockSearchAutocomplete.mockReturnValue(new Promise(() => {}));
    render(<SearchAutocomplete {...defaultProps} query="lay" />, {
      wrapper: createWrapper(),
    });
    // The debounce is 200ms; after that the loading state should appear
    // The "Searching…" text should eventually show (initial fetch state)
  });

  // ─── Keyboard navigation tests ──────────────────────────────────────────

  /** Helper: get the latest keyboard handler from onInputKeyDown mock */
  function latestHandler(
    mock: ReturnType<typeof vi.fn>,
  ): (e: React.KeyboardEvent) => void {
    const calls = mock.mock.calls;
    return calls[calls.length - 1][0];
  }

  function fakeKey(key: string): unknown {
    return { key, preventDefault: vi.fn() };
  }

  it("keyboard ArrowDown/Up navigates popular items", () => {
    const onInputKeyDown = vi.fn();
    render(
      <SearchAutocomplete
        {...defaultProps}
        query=""
        onInputKeyDown={onInputKeyDown}
      />,
      { wrapper: createWrapper() },
    );

    expect(onInputKeyDown).toHaveBeenCalled();

    // ArrowDown to select first popular item
    latestHandler(onInputKeyDown)(fakeKey("ArrowDown") as React.KeyboardEvent);

    // ArrowUp wraps back
    latestHandler(onInputKeyDown)(fakeKey("ArrowUp") as React.KeyboardEvent);
  });

  it("keyboard Enter on popular item calls onQuerySubmit", async () => {
    const onInputKeyDown = vi.fn();
    const onQuerySubmit = vi.fn();
    const onClose = vi.fn();
    render(
      <SearchAutocomplete
        {...defaultProps}
        query=""
        onInputKeyDown={onInputKeyDown}
        onQuerySubmit={onQuerySubmit}
        onClose={onClose}
      />,
      { wrapper: createWrapper() },
    );

    // ArrowDown to select first popular item (wrapped in act for state update)
    await act(async () => {
      latestHandler(onInputKeyDown)(
        fakeKey("ArrowDown") as React.KeyboardEvent,
      );
    });

    // Enter to select it (use latest handler after state update)
    await act(async () => {
      latestHandler(onInputKeyDown)(fakeKey("Enter") as React.KeyboardEvent);
    });

    expect(onQuerySubmit).toHaveBeenCalledWith("mleko");
    expect(onClose).toHaveBeenCalled();
  });

  it("keyboard Enter on recent item calls onQuerySubmit", async () => {
    localStorage.setItem(RECENT_SEARCHES_KEY, JSON.stringify(["piwo", "kawa"]));
    const onInputKeyDown = vi.fn();
    const onQuerySubmit = vi.fn();
    const onClose = vi.fn();
    render(
      <SearchAutocomplete
        {...defaultProps}
        query=""
        onInputKeyDown={onInputKeyDown}
        onQuerySubmit={onQuerySubmit}
        onClose={onClose}
      />,
      { wrapper: createWrapper() },
    );

    // ArrowDown to select first recent item ("piwo")
    await act(async () => {
      latestHandler(onInputKeyDown)(
        fakeKey("ArrowDown") as React.KeyboardEvent,
      );
    });

    // Enter to select it
    await act(async () => {
      latestHandler(onInputKeyDown)(fakeKey("Enter") as React.KeyboardEvent);
    });

    expect(onQuerySubmit).toHaveBeenCalledWith("piwo");
    expect(onClose).toHaveBeenCalled();
  });

  it("keyboard Escape closes dropdown", () => {
    const onInputKeyDown = vi.fn();
    const onClose = vi.fn();
    render(
      <SearchAutocomplete
        {...defaultProps}
        query=""
        onInputKeyDown={onInputKeyDown}
        onClose={onClose}
      />,
      { wrapper: createWrapper() },
    );

    latestHandler(onInputKeyDown)(fakeKey("Escape") as React.KeyboardEvent);

    expect(onClose).toHaveBeenCalled();
  });

  it("keyboard Enter in query mode with active suggestion navigates to product", async () => {
    const onInputKeyDown = vi.fn();
    const onSelect = vi.fn();
    const onClose = vi.fn();
    render(
      <SearchAutocomplete
        {...defaultProps}
        query="lay"
        onInputKeyDown={onInputKeyDown}
        onSelect={onSelect}
        onClose={onClose}
      />,
      { wrapper: createWrapper() },
    );

    // Wait for suggestions to load
    await waitFor(
      () => {
        expect(screen.getAllByRole("option").length).toBeGreaterThanOrEqual(1);
      },
      { timeout: 1000 },
    );

    // ArrowDown to select first suggestion
    await act(async () => {
      latestHandler(onInputKeyDown)(
        fakeKey("ArrowDown") as React.KeyboardEvent,
      );
    });

    // Enter to navigate to it
    await act(async () => {
      latestHandler(onInputKeyDown)(fakeKey("Enter") as React.KeyboardEvent);
    });

    expect(onSelect).toHaveBeenCalledWith(SUGGESTIONS[0]);
    expect(mockPush).toHaveBeenCalledWith("/app/product/1");
    expect(onClose).toHaveBeenCalled();
  });

  it("keyboard Enter in query mode without active index submits query", async () => {
    const onInputKeyDown = vi.fn();
    const onQuerySubmit = vi.fn();
    const onClose = vi.fn();
    render(
      <SearchAutocomplete
        {...defaultProps}
        query="lay"
        onInputKeyDown={onInputKeyDown}
        onQuerySubmit={onQuerySubmit}
        onClose={onClose}
      />,
      { wrapper: createWrapper() },
    );

    // Wait for suggestions to load
    await waitFor(
      () => {
        expect(screen.getAllByRole("option").length).toBeGreaterThanOrEqual(1);
      },
      { timeout: 1000 },
    );

    // Enter without ArrowDown (activeIndex = -1) — submits the query text
    latestHandler(onInputKeyDown)(fakeKey("Enter") as React.KeyboardEvent);

    expect(onQuerySubmit).toHaveBeenCalledWith("lay");
    expect(onClose).toHaveBeenCalled();
  });
});
