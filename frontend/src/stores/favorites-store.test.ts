import { describe, it, expect, beforeEach } from "vitest";
import { useFavoritesStore } from "@/stores/favorites-store";

// ─── Helpers ────────────────────────────────────────────────────────────────

const store = () => useFavoritesStore.getState();

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("useFavoritesStore", () => {
  beforeEach(() => {
    useFavoritesStore.setState({
      favoriteIds: new Set<number>(),
      loaded: false,
    });
  });

  // ─── initial state ─────────────────────────────────────────────────

  it("starts empty and not loaded", () => {
    expect(store().favoriteIds.size).toBe(0);
    expect(store().loaded).toBe(false);
  });

  // ─── setFavoriteIds ────────────────────────────────────────────────

  it("setFavoriteIds replaces entire set and marks loaded", () => {
    store().setFavoriteIds([10, 20, 30]);
    expect(store().favoriteIds).toEqual(new Set([10, 20, 30]));
    expect(store().loaded).toBe(true);
  });

  it("setFavoriteIds deduplicates input", () => {
    store().setFavoriteIds([5, 5, 5]);
    expect(store().favoriteIds.size).toBe(1);
    expect(store().isFavorite(5)).toBe(true);
  });

  it("setFavoriteIds overwrites previous set", () => {
    store().setFavoriteIds([1, 2]);
    store().setFavoriteIds([3, 4]);
    expect(store().isFavorite(1)).toBe(false);
    expect(store().isFavorite(3)).toBe(true);
  });

  // ─── addFavorite ───────────────────────────────────────────────────

  it("addFavorite adds a single ID", () => {
    store().addFavorite(42);
    expect(store().isFavorite(42)).toBe(true);
  });

  it("addFavorite is idempotent", () => {
    store().addFavorite(42);
    store().addFavorite(42);
    expect(store().favoriteIds.size).toBe(1);
  });

  it("addFavorite preserves existing favorites", () => {
    store().setFavoriteIds([1, 2]);
    store().addFavorite(3);
    expect(store().isFavorite(1)).toBe(true);
    expect(store().isFavorite(3)).toBe(true);
  });

  // ─── removeFavorite ────────────────────────────────────────────────

  it("removeFavorite removes a single ID", () => {
    store().setFavoriteIds([1, 2, 3]);
    store().removeFavorite(2);
    expect(store().isFavorite(2)).toBe(false);
    expect(store().favoriteIds.size).toBe(2);
  });

  it("removeFavorite is no-op for missing ID", () => {
    store().setFavoriteIds([1]);
    store().removeFavorite(999);
    expect(store().favoriteIds.size).toBe(1);
  });

  // ─── isFavorite ────────────────────────────────────────────────────

  it("isFavorite returns true for present IDs", () => {
    store().setFavoriteIds([7, 8, 9]);
    expect(store().isFavorite(8)).toBe(true);
  });

  it("isFavorite returns false for absent IDs", () => {
    store().setFavoriteIds([7, 8, 9]);
    expect(store().isFavorite(100)).toBe(false);
  });

  // ─── reset ─────────────────────────────────────────────────────────

  it("reset clears favorites and loaded flag", () => {
    store().setFavoriteIds([1, 2, 3]);
    expect(store().loaded).toBe(true);
    store().reset();
    expect(store().favoriteIds.size).toBe(0);
    expect(store().loaded).toBe(false);
  });
});
