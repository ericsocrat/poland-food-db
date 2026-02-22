import { describe, it, expect, beforeEach } from "vitest";
import {
  getRecentSearches,
  addRecentSearch,
  removeRecentSearch,
  clearRecentSearches,
  RECENT_SEARCHES_KEY,
  RECENT_SEARCHES_MAX,
} from "@/lib/recent-searches";

// ─── recent-searches utility tests ──────────────────────────────────────────

describe("recent-searches", () => {
  beforeEach(() => {
    localStorage.clear();
  });

  describe("getRecentSearches", () => {
    it("returns empty array when nothing stored", () => {
      expect(getRecentSearches()).toEqual([]);
    });

    it("returns stored searches", () => {
      localStorage.setItem(
        RECENT_SEARCHES_KEY,
        JSON.stringify(["mleko", "ser"]),
      );
      expect(getRecentSearches()).toEqual(["mleko", "ser"]);
    });

    it("returns empty array on corrupt JSON", () => {
      localStorage.setItem(RECENT_SEARCHES_KEY, "not-json{");
      expect(getRecentSearches()).toEqual([]);
    });

    it("returns empty array when stored value is not an array", () => {
      localStorage.setItem(RECENT_SEARCHES_KEY, JSON.stringify(42));
      expect(getRecentSearches()).toEqual([]);
    });

    it("filters out non-string values from stored array", () => {
      localStorage.setItem(
        RECENT_SEARCHES_KEY,
        JSON.stringify(["mleko", 42, null, "ser", true]),
      );
      expect(getRecentSearches()).toEqual(["mleko", "ser"]);
    });

    it("handles localStorage unavailable gracefully", () => {
      const origGetItem = Storage.prototype.getItem;
      Storage.prototype.getItem = () => {
        throw new Error("SecurityError");
      };
      expect(getRecentSearches()).toEqual([]);
      Storage.prototype.getItem = origGetItem;
    });
  });

  describe("addRecentSearch", () => {
    it("adds a search term", () => {
      addRecentSearch("mleko");
      expect(getRecentSearches()).toEqual(["mleko"]);
    });

    it("prepends new searches (most recent first)", () => {
      addRecentSearch("mleko");
      addRecentSearch("ser");
      expect(getRecentSearches()).toEqual(["ser", "mleko"]);
    });

    it("deduplicates — moves existing term to front", () => {
      addRecentSearch("mleko");
      addRecentSearch("ser");
      addRecentSearch("mleko");
      expect(getRecentSearches()).toEqual(["mleko", "ser"]);
    });

    it("trims whitespace from query", () => {
      addRecentSearch("  mleko  ");
      expect(getRecentSearches()).toEqual(["mleko"]);
    });

    it("ignores empty queries", () => {
      addRecentSearch("");
      addRecentSearch("   ");
      expect(getRecentSearches()).toEqual([]);
    });

    it("caps at RECENT_SEARCHES_MAX entries (FIFO)", () => {
      for (let i = 0; i < RECENT_SEARCHES_MAX + 5; i++) {
        addRecentSearch(`search-${i}`);
      }
      const result = getRecentSearches();
      expect(result.length).toBe(RECENT_SEARCHES_MAX);
      // Most recent should be first
      expect(result[0]).toBe(`search-${RECENT_SEARCHES_MAX + 4}`);
    });
  });

  describe("removeRecentSearch", () => {
    it("removes a specific search term", () => {
      addRecentSearch("mleko");
      addRecentSearch("ser");
      removeRecentSearch("mleko");
      expect(getRecentSearches()).toEqual(["ser"]);
    });

    it("no-ops if term not found", () => {
      addRecentSearch("mleko");
      removeRecentSearch("jogurt");
      expect(getRecentSearches()).toEqual(["mleko"]);
    });
  });

  describe("clearRecentSearches", () => {
    it("removes all recent searches", () => {
      addRecentSearch("mleko");
      addRecentSearch("ser");
      clearRecentSearches();
      expect(getRecentSearches()).toEqual([]);
    });

    it("removes the localStorage key entirely", () => {
      addRecentSearch("mleko");
      clearRecentSearches();
      expect(localStorage.getItem(RECENT_SEARCHES_KEY)).toBeNull();
    });
  });
});
