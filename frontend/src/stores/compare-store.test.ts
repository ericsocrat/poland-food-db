import { describe, it, expect, beforeEach } from "vitest";
import { useCompareStore } from "@/stores/compare-store";

// ─── Helpers ────────────────────────────────────────────────────────────────

const store = () => useCompareStore.getState();

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("useCompareStore", () => {
  beforeEach(() => {
    // Reset to initial state before each test
    useCompareStore.setState({ selectedIds: new Set() });
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
});
