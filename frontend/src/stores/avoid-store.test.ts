import { describe, it, expect, beforeEach } from "vitest";
import { useAvoidStore } from "@/stores/avoid-store";

// ─── Helpers ────────────────────────────────────────────────────────────────

const store = () => useAvoidStore.getState();

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("useAvoidStore", () => {
  beforeEach(() => {
    useAvoidStore.setState({
      avoidedIds: new Set<number>(),
      loaded: false,
    });
  });

  // ─── initial state ─────────────────────────────────────────────────

  it("starts empty and not loaded", () => {
    expect(store().avoidedIds.size).toBe(0);
    expect(store().loaded).toBe(false);
  });

  // ─── setAvoidedIds ─────────────────────────────────────────────────

  it("setAvoidedIds replaces entire set and marks loaded", () => {
    store().setAvoidedIds([10, 20, 30]);
    expect(store().avoidedIds).toEqual(new Set([10, 20, 30]));
    expect(store().loaded).toBe(true);
  });

  it("setAvoidedIds deduplicates input", () => {
    store().setAvoidedIds([5, 5, 5]);
    expect(store().avoidedIds.size).toBe(1);
  });

  it("setAvoidedIds overwrites previous set", () => {
    store().setAvoidedIds([1, 2]);
    store().setAvoidedIds([3, 4]);
    expect(store().isAvoided(1)).toBe(false);
    expect(store().isAvoided(3)).toBe(true);
  });

  // ─── addAvoided ────────────────────────────────────────────────────

  it("addAvoided adds a single ID", () => {
    store().addAvoided(42);
    expect(store().isAvoided(42)).toBe(true);
  });

  it("addAvoided is idempotent", () => {
    store().addAvoided(42);
    store().addAvoided(42);
    expect(store().avoidedIds.size).toBe(1);
  });

  it("addAvoided preserves existing avoided IDs", () => {
    store().setAvoidedIds([1, 2]);
    store().addAvoided(3);
    expect(store().isAvoided(1)).toBe(true);
    expect(store().isAvoided(3)).toBe(true);
  });

  // ─── removeAvoided ─────────────────────────────────────────────────

  it("removeAvoided removes a single ID", () => {
    store().setAvoidedIds([1, 2, 3]);
    store().removeAvoided(2);
    expect(store().isAvoided(2)).toBe(false);
    expect(store().avoidedIds.size).toBe(2);
  });

  it("removeAvoided is no-op for missing ID", () => {
    store().setAvoidedIds([1]);
    store().removeAvoided(999);
    expect(store().avoidedIds.size).toBe(1);
  });

  // ─── isAvoided ─────────────────────────────────────────────────────

  it("isAvoided returns true for present IDs", () => {
    store().setAvoidedIds([7, 8, 9]);
    expect(store().isAvoided(8)).toBe(true);
  });

  it("isAvoided returns false for absent IDs", () => {
    store().setAvoidedIds([7, 8, 9]);
    expect(store().isAvoided(100)).toBe(false);
  });

  // ─── reset ─────────────────────────────────────────────────────────

  it("reset clears avoided IDs and loaded flag", () => {
    store().setAvoidedIds([1, 2, 3]);
    expect(store().loaded).toBe(true);
    store().reset();
    expect(store().avoidedIds.size).toBe(0);
    expect(store().loaded).toBe(false);
  });
});
