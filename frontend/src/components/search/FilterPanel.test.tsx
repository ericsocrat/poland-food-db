import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { FilterPanel } from "./FilterPanel";
import type { SearchFilters } from "@/lib/types";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

const mockFilterOptions = {
  api_version: "1",
  country: "PL",
  categories: [
    {
      category: "chips",
      display_name: "Chips",
      icon_emoji: "🍟",
      count: 42,
    },
    {
      category: "drinks",
      display_name: "Drinks",
      icon_emoji: "🥤",
      count: 18,
    },
  ],
  nutri_scores: [
    { label: "A", count: 5 },
    { label: "B", count: 10 },
    { label: "C", count: 8 },
    { label: "NOT-APPLICABLE", count: 3 },
  ],
  nova_groups: [
    { group: "1", count: 12 },
    { group: "4", count: 25 },
  ],
  allergens: [
    { tag: "gluten", count: 30 },
    { tag: "milk", count: 15 },
  ],
};

const mockGetFilterOptions = vi.fn();
vi.mock("@/lib/api", () => ({
  getFilterOptions: (...args: unknown[]) => mockGetFilterOptions(...args),
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

interface RenderProps {
  filters?: SearchFilters;
  onChange?: (f: SearchFilters) => void;
  show?: boolean;
  onClose?: () => void;
}

function renderPanel(props: RenderProps = {}) {
  const defaultOnChange = vi.fn();
  const defaultOnClose = vi.fn();
  const mergedProps = {
    filters: props.filters ?? {},
    onChange: props.onChange ?? defaultOnChange,
    show: props.show ?? true,
    onClose: props.onClose ?? defaultOnClose,
  };

  const result = render(<FilterPanel {...mergedProps} />, {
    wrapper: createWrapper(),
  });

  return { ...result, ...mergedProps };
}

beforeEach(() => {
  vi.clearAllMocks();
  mockGetFilterOptions.mockResolvedValue({
    ok: true,
    data: mockFilterOptions,
  });
});

// Both desktop sidebar and mobile bottom sheet render the same filterContent,
// so we use getAllBy* and target the first match throughout.

describe("FilterPanel", () => {
  it("shows loading state initially", () => {
    mockGetFilterOptions.mockReturnValue(new Promise(() => {}));
    renderPanel();
    // The loading spinner uses <output aria-label="Loading">
    const spinners = screen.getAllByLabelText("Loading…");
    expect(spinners.length).toBeGreaterThanOrEqual(1);
  });

  it("renders sort options after loading", async () => {
    renderPanel();
    await waitFor(() => {
      expect(screen.getAllByText("Relevance").length).toBeGreaterThanOrEqual(1);
    });
    expect(screen.getAllByText("Name").length).toBeGreaterThanOrEqual(1);
    expect(screen.getAllByText("Health Score").length).toBeGreaterThanOrEqual(
      1,
    );
    expect(screen.getAllByText("Calories").length).toBeGreaterThanOrEqual(1);
  });

  it("renders category checkboxes from API data", async () => {
    renderPanel();
    await waitFor(() => {
      expect(screen.getAllByText(/Chips/).length).toBeGreaterThanOrEqual(1);
    });
    expect(screen.getAllByText(/Drinks/).length).toBeGreaterThanOrEqual(1);
  });

  it("shows category counts", async () => {
    renderPanel();
    await waitFor(() => {
      expect(screen.getAllByText("42").length).toBeGreaterThanOrEqual(1);
    });
    expect(screen.getAllByText("18").length).toBeGreaterThanOrEqual(1);
  });

  it("renders nutri-score filter buttons", async () => {
    renderPanel();
    await waitFor(() => {
      expect(screen.getAllByText("A").length).toBeGreaterThanOrEqual(1);
    });
    expect(screen.getAllByText("B").length).toBeGreaterThanOrEqual(1);
    expect(screen.getAllByText("C").length).toBeGreaterThanOrEqual(1);
  });

  it('renders "Not Rated" instead of "NOT-APPLICABLE"', async () => {
    renderPanel();
    await waitFor(() => {
      expect(screen.getAllByText("Not Rated").length).toBeGreaterThanOrEqual(1);
    });
    // Raw DB value must NOT appear
    expect(screen.queryAllByText(/NOT.APPLICABLE/i)).toHaveLength(0);
  });

  it("renders allergen-free filter checkboxes", async () => {
    renderPanel();
    await waitFor(() => {
      expect(screen.getAllByText("Gluten-free").length).toBeGreaterThanOrEqual(
        1,
      );
    });
    expect(
      screen.getAllByText("Milk / Dairy-free").length,
    ).toBeGreaterThanOrEqual(1);
  });

  it("calls onChange when selecting a category", async () => {
    const onChange = vi.fn();
    renderPanel({ onChange });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getAllByText(/Chips/).length).toBeGreaterThanOrEqual(1);
    });

    // Target the first category checkbox
    const checkboxes = screen.getAllByRole("checkbox");
    const chipsCheckbox = checkboxes[0];
    await user.click(chipsCheckbox);

    expect(onChange).toHaveBeenCalledWith(
      expect.objectContaining({ category: ["chips"] }),
    );
  });

  it("calls onChange when selecting a nutri-score", async () => {
    const onChange = vi.fn();
    renderPanel({ onChange });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getAllByText("A").length).toBeGreaterThanOrEqual(1);
    });

    // Click the first "A" button
    await user.click(screen.getAllByText("A")[0]);

    expect(onChange).toHaveBeenCalledWith(
      expect.objectContaining({ nutri_score: ["A"] }),
    );
  });

  it("calls onChange when selecting a sort option", async () => {
    const onChange = vi.fn();
    renderPanel({ onChange });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getAllByText("Name").length).toBeGreaterThanOrEqual(1);
    });

    await user.click(screen.getAllByText("Name")[0]);

    expect(onChange).toHaveBeenCalledWith(
      expect.objectContaining({ sort_by: "name" }),
    );
  });

  it("shows sort order buttons when non-relevance sort selected", async () => {
    renderPanel({ filters: { sort_by: "name" } });
    await waitFor(() => {
      expect(screen.getAllByText("↑ Asc").length).toBeGreaterThanOrEqual(1);
    });
    expect(screen.getAllByText("↓ Desc").length).toBeGreaterThanOrEqual(1);
  });

  it("does not show sort order buttons for relevance sort", async () => {
    renderPanel({ filters: { sort_by: "relevance" } });
    await waitFor(() => {
      expect(screen.getAllByText("Relevance").length).toBeGreaterThanOrEqual(1);
    });
    expect(screen.queryAllByText("↑ Asc")).toHaveLength(0);
  });

  it("shows direction arrow on active sort button", async () => {
    renderPanel({ filters: { sort_by: "name", sort_order: "asc" } });
    await waitFor(() => {
      const nameButtons = screen.getAllByText(/^Name/);
      expect(nameButtons.length).toBeGreaterThanOrEqual(1);
      expect(nameButtons[0].textContent).toContain("↑");
    });
  });

  it("shows descending arrow on active sort button", async () => {
    renderPanel({ filters: { sort_by: "calories", sort_order: "desc" } });
    await waitFor(() => {
      const calButtons = screen.getAllByText(/^Calories/);
      expect(calButtons.length).toBeGreaterThanOrEqual(1);
      expect(calButtons[0].textContent).toContain("↓");
    });
  });

  it("does not show direction arrow on relevance sort button", async () => {
    renderPanel({ filters: { sort_by: "relevance" } });
    await waitFor(() => {
      const relButtons = screen.getAllByText("Relevance");
      expect(relButtons.length).toBeGreaterThanOrEqual(1);
      expect(relButtons[0].textContent).not.toContain("↑");
      expect(relButtons[0].textContent).not.toContain("↓");
    });
  });

  it("applies ring styling to active sort button", async () => {
    renderPanel({ filters: { sort_by: "name" } });
    await waitFor(() => {
      const nameButtons = screen.getAllByText(/^Name/);
      expect(nameButtons.length).toBeGreaterThanOrEqual(1);
      expect(nameButtons[0].className).toContain("ring-2");
    });
  });

  it("calls onChange with sort order", async () => {
    const onChange = vi.fn();
    renderPanel({ filters: { sort_by: "name" }, onChange });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getAllByText("↓ Desc").length).toBeGreaterThanOrEqual(1);
    });

    await user.click(screen.getAllByText("↓ Desc")[0]);

    expect(onChange).toHaveBeenCalledWith(
      expect.objectContaining({ sort_order: "desc" }),
    );
  });

  it("shows clear all button when filters are active", async () => {
    renderPanel({ filters: { category: ["chips"] } });
    await waitFor(() => {
      expect(screen.getAllByText("Clear all").length).toBeGreaterThanOrEqual(1);
    });
  });

  it("does not show clear all button when no filters", async () => {
    renderPanel();
    await waitFor(() => {
      expect(screen.getAllByText("Relevance").length).toBeGreaterThanOrEqual(1);
    });
    expect(screen.queryAllByText("Clear all")).toHaveLength(0);
  });

  it("calls onChange with empty object on clear all", async () => {
    const onChange = vi.fn();
    renderPanel({ filters: { category: ["chips"] }, onChange });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getAllByText("Clear all").length).toBeGreaterThanOrEqual(1);
    });

    await user.click(screen.getAllByText("Clear all")[0]);

    expect(onChange).toHaveBeenCalledWith({});
  });

  it("renders max health score slider", async () => {
    renderPanel();
    await waitFor(() => {
      expect(
        screen.getAllByText("Max Health Score").length,
      ).toBeGreaterThanOrEqual(1);
    });
    expect(screen.getAllByText("Any").length).toBeGreaterThanOrEqual(1);
  });

  it("shows current max score value when set", async () => {
    renderPanel({ filters: { max_unhealthiness: 50 } });
    await waitFor(() => {
      expect(screen.getAllByText("≤ 50").length).toBeGreaterThanOrEqual(1);
    });
  });

  it("renders mobile close button when shown", async () => {
    renderPanel({ show: true });
    await waitFor(() => {
      expect(screen.getByText("Show Results")).toBeInTheDocument();
    });
  });

  it("calls onClose when mobile close button clicked", async () => {
    const onClose = vi.fn();
    renderPanel({ show: true, onClose });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getByText("Show Results")).toBeInTheDocument();
    });

    await user.click(screen.getByText("Show Results"));

    expect(onClose).toHaveBeenCalled();
  });

  it("calls onClose when backdrop clicked", async () => {
    const onClose = vi.fn();
    renderPanel({ show: true, onClose });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(
        screen.getByRole("button", { name: "Close filters" }),
      ).toBeInTheDocument();
    });

    await user.click(screen.getByRole("button", { name: "Close filters" }));

    expect(onClose).toHaveBeenCalled();
  });

  it("does not render mobile sheet when show is false", () => {
    mockGetFilterOptions.mockReturnValue(new Promise(() => {}));
    renderPanel({ show: false });
    expect(screen.queryByText("Show Results")).not.toBeInTheDocument();
    expect(
      screen.queryByRole("button", { name: "Close filters" }),
    ).not.toBeInTheDocument();
  });

  it("deselects a category when toggling off", async () => {
    const onChange = vi.fn();
    renderPanel({ filters: { category: ["chips"] }, onChange });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getAllByText(/Chips/).length).toBeGreaterThanOrEqual(1);
    });

    // First checked checkbox is the chips one
    const checkboxes = screen.getAllByRole("checkbox");
    const chipsCheckbox = checkboxes[0];
    await user.click(chipsCheckbox);

    expect(onChange).toHaveBeenCalledWith(
      expect.objectContaining({ category: undefined }),
    );
  });

  // ─── NOVA Group Filter ──────────────────────────────────────────────────

  it("renders NOVA group filter buttons with counts", async () => {
    renderPanel();
    await waitFor(() => {
      expect(screen.getAllByText(/Unprocessed/).length).toBeGreaterThanOrEqual(
        1,
      );
    });
    expect(
      screen.getAllByText(/Ultra-processed/).length,
    ).toBeGreaterThanOrEqual(1);
    expect(screen.getAllByText("(12)").length).toBeGreaterThanOrEqual(1);
    expect(screen.getAllByText("(25)").length).toBeGreaterThanOrEqual(1);
  });

  it("renders NOVA Group section heading", async () => {
    renderPanel();
    await waitFor(() => {
      expect(screen.getAllByText("NOVA Group").length).toBeGreaterThanOrEqual(
        1,
      );
    });
  });

  it("calls onChange when selecting a NOVA group", async () => {
    const onChange = vi.fn();
    renderPanel({ onChange });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getAllByText(/Unprocessed/).length).toBeGreaterThanOrEqual(
        1,
      );
    });

    // Click the first NOVA "1 — Unprocessed" button
    await user.click(screen.getAllByText(/Unprocessed/)[0]);

    expect(onChange).toHaveBeenCalledWith(
      expect.objectContaining({ nova_group: ["1"] }),
    );
  });

  it("deselects a NOVA group when toggling off", async () => {
    const onChange = vi.fn();
    renderPanel({ filters: { nova_group: ["1"] }, onChange });
    const user = userEvent.setup();

    await waitFor(() => {
      expect(screen.getAllByText(/Unprocessed/).length).toBeGreaterThanOrEqual(
        1,
      );
    });

    await user.click(screen.getAllByText(/Unprocessed/)[0]);

    expect(onChange).toHaveBeenCalledWith(
      expect.objectContaining({ nova_group: undefined }),
    );
  });

  it("shows clear all when NOVA group filter is active", async () => {
    renderPanel({ filters: { nova_group: ["4"] } });
    await waitFor(() => {
      expect(screen.getAllByText("Clear all").length).toBeGreaterThanOrEqual(1);
    });
  });
});
