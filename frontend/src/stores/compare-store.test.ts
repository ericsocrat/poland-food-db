import { describe, it, expect, beforeEach } from "vitest";
import { useCompareStore } from "@/stores/compare-store";

// ─── Helpers ────────────────────────────────────────────────────────────────

const store = () => useCompareStore.getState();

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("useCompareStore", () => {
  beforeEach(() => {
    // Reset to initial state before each test
    useCompareStore.setState({
      selectedIds: new Set(),
      productNames: new Map(),
    });
  });

  // ─── maxItems ───────────────────────────────────────────────────────

  it("has maxItems = 4", () => {
    expect(store().maxItems).toBe(4);
  });

  // ─── initial state ─────────────────────────────────────────────────

  it("starts empty", () => {
    expect(store().selectedIds.size).toBe(0);
    expect(store().count()).toBe(0);
    expect(store().isFull()).toBe(false);
  });

  // ─── isSelected ────────────────────────────────────────────────────

  it("isSelected returns false for unknown ID", () => {
    expect(store().isSelected(999)).toBe(false);
  });

  it("isSelected returns true after adding", () => {
    store().add(42);
    expect(store().isSelected(42)).toBe(true);
  });

  // ─── add ───────────────────────────────────────────────────────────

  it("add increases count", () => {
    store().add(1);
    expect(store().count()).toBe(1);
  });

  it("add is no-op for duplicate", () => {
    store().add(1);
    store().add(1); // NOSONAR — intentional: testing idempotency
    expect(store().count()).toBe(1);
  });

  it("add is no-op when full", () => {
    store().add(1);
    store().add(2);
    store().add(3);
    store().add(4);
    store().add(5); // should be no-op
    expect(store().count()).toBe(4);
    expect(store().isSelected(5)).toBe(false);
  });

  // ─── remove ────────────────────────────────────────────────────────

  it("remove decreases count", () => {
    store().add(1);
    store().add(2);
    store().remove(1);
    expect(store().count()).toBe(1);
    expect(store().isSelected(1)).toBe(false);
    expect(store().isSelected(2)).toBe(true);
  });

  it("remove is no-op for missing ID", () => {
    store().add(1);
    store().remove(999);
    expect(store().count()).toBe(1);
  });

  // ─── toggle ────────────────────────────────────────────────────────

  it("toggle adds when not selected", () => {
    store().toggle(7);
    expect(store().isSelected(7)).toBe(true);
    expect(store().count()).toBe(1);
  });

  it("toggle removes when already selected", () => {
    store().add(7);
    store().toggle(7);
    expect(store().isSelected(7)).toBe(false);
    expect(store().count()).toBe(0);
  });

  it("toggle is no-op when full and ID not selected", () => {
    store().add(1);
    store().add(2);
    store().add(3);
    store().add(4);
    store().toggle(5);
    expect(store().count()).toBe(4);
    expect(store().isSelected(5)).toBe(false);
  });

  it("toggle removes even when full", () => {
    store().add(1);
    store().add(2);
    store().add(3);
    store().add(4);
    store().toggle(3);
    expect(store().count()).toBe(3);
    expect(store().isSelected(3)).toBe(false);
  });

  // ─── isFull ────────────────────────────────────────────────────────

  it("isFull returns true at capacity", () => {
    store().add(1);
    store().add(2);
    store().add(3);
    store().add(4);
    expect(store().isFull()).toBe(true);
  });

  it("isFull returns false below capacity", () => {
    store().add(1);
    store().add(2);
    store().add(3);
    expect(store().isFull()).toBe(false);
  });

  // ─── clear ─────────────────────────────────────────────────────────

  it("clear empties all selections", () => {
    store().add(1);
    store().add(2);
    store().add(3);
    store().clear();
    expect(store().count()).toBe(0);
    expect(store().isSelected(1)).toBe(false);
  });

  // ─── getIds ────────────────────────────────────────────────────────

  it("getIds returns sorted array", () => {
    store().add(30);
    store().add(10);
    store().add(20);
    expect(store().getIds()).toEqual([10, 20, 30]);
  });

  it("getIds returns empty array when none selected", () => {
    expect(store().getIds()).toEqual([]);
  });

  // ─── productNames ──────────────────────────────────────────────────

  it("stores product name when adding with name", () => {
    store().add(1, "Lays Classic");
    expect(store().getName(1)).toBe("Lays Classic");
  });

  it("stores product name when toggling on with name", () => {
    store().toggle(7, "Doritos Cool Ranch");
    expect(store().getName(7)).toBe("Doritos Cool Ranch");
  });

  it("add without name does not overwrite existing name", () => {
    store().add(1, "Lays Classic");
    // add again without name (no-op since duplicate, but confirm name persists)
    store().add(1);
    expect(store().getName(1)).toBe("Lays Classic");
  });

  // ─── getName ────────────────────────────────────────────────────────

  it("getName returns fallback for unknown product", () => {
    expect(store().getName(999)).toBe("Product #999");
  });

  it("getName returns stored name for known product", () => {
    store().add(42, "Pringles Original");
    expect(store().getName(42)).toBe("Pringles Original");
  });

  // ─── name cleanup on remove ────────────────────────────────────────

  it("remove cleans up product name", () => {
    store().add(1, "Lays Classic");
    store().remove(1);
    expect(store().getName(1)).toBe("Product #1");
  });

  it("toggle off cleans up product name", () => {
    store().toggle(7, "Doritos");
    store().toggle(7);
    expect(store().getName(7)).toBe("Product #7");
  });

  it("clear cleans up all product names", () => {
    store().add(1, "Lays");
    store().add(2, "Doritos");
    store().clear();
    expect(store().getName(1)).toBe("Product #1");
    expect(store().getName(2)).toBe("Product #2");
  });
});
