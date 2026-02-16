import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { ActiveFilterChips } from "./ActiveFilterChips";
import type { SearchFilters } from "@/lib/types";

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ActiveFilterChips", () => {
  const onChange = vi.fn() as unknown as (filters: SearchFilters) => void;

  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("renders nothing when no filters are active", () => {
    const { container } = render(
      <ActiveFilterChips filters={{}} onChange={onChange} />,
    );
    expect(container.innerHTML).toBe("");
  });

  // ─── Category chips ─────────────────────────────────────────────────

  it("renders category chips", () => {
    render(
      <ActiveFilterChips
        filters={{ category: ["Chips", "Cereals"] }}
        onChange={onChange}
      />,
    );
    expect(screen.getByText("Chips")).toBeTruthy();
    expect(screen.getByText("Cereals")).toBeTruthy();
  });

  it("removes a category chip on click", () => {
    render(
      <ActiveFilterChips
        filters={{ category: ["Chips", "Cereals"] }}
        onChange={onChange}
      />,
    );
    fireEvent.click(screen.getByLabelText("Remove Chips filter"));
    expect(onChange).toHaveBeenCalledWith({
      category: ["Cereals"],
    });
  });

  it("clears category array when last chip removed", () => {
    render(
      <ActiveFilterChips
        filters={{ category: ["Chips"] }}
        onChange={onChange}
      />,
    );
    fireEvent.click(screen.getByLabelText("Remove Chips filter"));
    expect(onChange).toHaveBeenCalledWith({
      category: undefined,
    });
  });

  // ─── Nutri-Score chips ──────────────────────────────────────────────

  it("renders nutri score chips with label prefix", () => {
    render(
      <ActiveFilterChips
        filters={{ nutri_score: ["A", "B"] }}
        onChange={onChange}
      />,
    );
    expect(screen.getByText("Nutri A")).toBeTruthy();
    expect(screen.getByText("Nutri B")).toBeTruthy();
  });

  it("removes a nutri score chip on click", () => {
    render(
      <ActiveFilterChips
        filters={{ nutri_score: ["A", "B"] }}
        onChange={onChange}
      />,
    );
    fireEvent.click(screen.getByLabelText("Remove Nutri A filter"));
    expect(onChange).toHaveBeenCalledWith({
      nutri_score: ["B"],
    });
  });

  // ─── Allergen-free chips ────────────────────────────────────────────

  it("renders allergen-free chips with label lookup", () => {
    render(
      <ActiveFilterChips
        filters={{ allergen_free: ["en:gluten"] }}
        onChange={onChange}
      />,
    );
    // Should find the ALLERGEN_TAGS entry and render "{label}-free"
    const chip = screen.getByText(/gluten-free/i);
    expect(chip).toBeTruthy();
  });

  it("renders fallback label for unknown allergen tag", () => {
    render(
      <ActiveFilterChips
        filters={{ allergen_free: ["en:mystery"] }}
        onChange={onChange}
      />,
    );
    expect(screen.getByText("mystery-free")).toBeTruthy();
  });

  // ─── Max unhealthiness chip ─────────────────────────────────────────

  it("renders max unhealthiness chip", () => {
    render(
      <ActiveFilterChips
        filters={{ max_unhealthiness: 50 }}
        onChange={onChange}
      />,
    );
    expect(screen.getByText("Score ≤ 50")).toBeTruthy();
  });

  it("removes max unhealthiness chip on click", () => {
    render(
      <ActiveFilterChips
        filters={{ max_unhealthiness: 50 }}
        onChange={onChange}
      />,
    );
    fireEvent.click(screen.getByLabelText("Remove Score ≤ 50 filter"));
    expect(onChange).toHaveBeenCalledWith({
      max_unhealthiness: undefined,
    });
  });

  // ─── Sort chip ──────────────────────────────────────────────────────

  it("renders sort chip for non-default sort", () => {
    render(
      <ActiveFilterChips
        filters={{ sort_by: "calories", sort_order: "desc" }}
        onChange={onChange}
      />,
    );
    expect(screen.getByText("Sort: Calories ↓")).toBeTruthy();
  });

  it("renders sort chip with ascending arrow", () => {
    render(
      <ActiveFilterChips
        filters={{ sort_by: "name", sort_order: "asc" }}
        onChange={onChange}
      />,
    );
    expect(screen.getByText("Sort: Name ↑")).toBeTruthy();
  });

  it("does not render sort chip for relevance", () => {
    render(
      <ActiveFilterChips
        filters={{ sort_by: "relevance" }}
        onChange={onChange}
      />,
    );
    expect(screen.queryByText(/Sort:/)).toBeNull();
  });

  it("removes sort chip on click", () => {
    render(
      <ActiveFilterChips
        filters={{ sort_by: "name", sort_order: "asc" }}
        onChange={onChange}
      />,
    );
    fireEvent.click(screen.getByLabelText("Remove Sort: Name ↑ filter"));
    expect(onChange).toHaveBeenCalledWith({
      sort_by: undefined,
      sort_order: undefined,
    });
  });

  // ─── Clear all ──────────────────────────────────────────────────────

  it("shows Clear all button when 2+ chips visible", () => {
    render(
      <ActiveFilterChips
        filters={{ category: ["Chips"], max_unhealthiness: 50 }}
        onChange={onChange}
      />,
    );
    expect(screen.getByText("Clear all")).toBeTruthy();
  });

  it("does not show Clear all button for single chip", () => {
    render(
      <ActiveFilterChips
        filters={{ category: ["Chips"] }}
        onChange={onChange}
      />,
    );
    expect(screen.queryByText("Clear all")).toBeNull();
  });

  it("clears all filters on Clear all click", () => {
    render(
      <ActiveFilterChips
        filters={
          { category: ["Chips"], max_unhealthiness: 50 } as SearchFilters
        }
        onChange={onChange}
      />,
    );
    fireEvent.click(screen.getByText("Clear all"));
    expect(onChange).toHaveBeenCalledWith({});
  });
});
