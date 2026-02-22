import { describe, it, expect, beforeEach } from "vitest";
import {
  cacheProduct,
  getCachedProduct,
  getAllCachedProducts,
  getCachedProductCount,
  cacheSearch,
  getCachedSearch,
  clearAllCaches,
  timeAgo,
} from "../cache-manager";

// ─── fake-indexeddb ─────────────────────────────────────────────────────────
// Vitest runs in Node, which has no IndexedDB. We use fake-indexeddb shim.
import "fake-indexeddb/auto";

describe("cache-manager", () => {
  beforeEach(async () => {
    // Clear DB between tests
    await clearAllCaches().catch(() => {});
    // Delete the DB entirely to avoid version conflicts
    const req = indexedDB.deleteDatabase("fooddb-offline");
    await new Promise<void>((resolve) => {
      req.onsuccess = () => resolve();
      req.onerror = () => resolve();
    });
  });

  // ─── Product caching ───────────────────────────────────────────────────

  describe("product caching", () => {
    it("caches and retrieves a product", async () => {
      await cacheProduct(1, { name: "Test Product" });
      const result = await getCachedProduct(1);
      expect(result).not.toBeNull();
      expect(result!.productId).toBe(1);
      expect(result!.data).toEqual({ name: "Test Product" });
      expect(result!.cachedAt).toBeGreaterThan(0);
    });

    it("returns null for uncached product", async () => {
      const result = await getCachedProduct(999);
      expect(result).toBeNull();
    });

    it("updates existing cached product", async () => {
      await cacheProduct(1, { name: "V1" });
      await cacheProduct(1, { name: "V2" });
      const result = await getCachedProduct(1);
      expect(result!.data).toEqual({ name: "V2" });
      const count = await getCachedProductCount();
      expect(count).toBe(1);
    });

    it("bumps accessedAt on retrieval", async () => {
      await cacheProduct(1, { name: "Test" });
      const first = await getCachedProduct(1);
      // Small delay
      await new Promise((r) => setTimeout(r, 10));
      const second = await getCachedProduct(1);
      expect(second!.accessedAt).toBeGreaterThanOrEqual(first!.accessedAt);
    });

    it("returns all cached products sorted by access time", async () => {
      await cacheProduct(1, { name: "First" });
      await new Promise((r) => setTimeout(r, 5));
      await cacheProduct(2, { name: "Second" });
      await new Promise((r) => setTimeout(r, 5));
      await cacheProduct(3, { name: "Third" });

      const all = await getAllCachedProducts();
      expect(all).toHaveLength(3);
      // Most recently accessed first
      expect(all[0].productId).toBe(3);
      expect(all[2].productId).toBe(1);
    });

    it("reports correct count", async () => {
      expect(await getCachedProductCount()).toBe(0);
      await cacheProduct(1, { name: "A" });
      expect(await getCachedProductCount()).toBe(1);
      await cacheProduct(2, { name: "B" });
      expect(await getCachedProductCount()).toBe(2);
    });

    it("evicts oldest when exceeding 50 products", async () => {
      // Cache 52 products (IDs 1-52)
      for (let i = 1; i <= 52; i++) {
        await cacheProduct(i, { name: `Product ${i}` });
      }
      // Allow async eviction to complete
      await new Promise((r) => setTimeout(r, 50));
      const count = await getCachedProductCount();
      expect(count).toBe(50);
      // The oldest (1, 2) should have been evicted
      const oldest = await getCachedProduct(1);
      expect(oldest).toBeNull();
      const second = await getCachedProduct(2);
      expect(second).toBeNull();
      // The newest should still be there
      const newest = await getCachedProduct(52);
      expect(newest).not.toBeNull();
    });
  });

  // ─── Search caching ────────────────────────────────────────────────────

  describe("search caching", () => {
    it("caches and retrieves search results", async () => {
      await cacheSearch("milk", [{ id: 1 }, { id: 2 }]);
      const result = await getCachedSearch("milk");
      expect(result).not.toBeNull();
      expect(result!.queryKey).toBe("milk");
      expect(result!.data).toEqual([{ id: 1 }, { id: 2 }]);
    });

    it("returns null for uncached search", async () => {
      const result = await getCachedSearch("nonexistent");
      expect(result).toBeNull();
    });

    it("evicts oldest when exceeding 5 searches", async () => {
      for (let i = 1; i <= 7; i++) {
        await cacheSearch(`query-${i}`, { results: i });
      }
      await new Promise((r) => setTimeout(r, 50));
      // Oldest two should be evicted
      const oldest = await getCachedSearch("query-1");
      expect(oldest).toBeNull();
      const secondOldest = await getCachedSearch("query-2");
      expect(secondOldest).toBeNull();
      // Newest should remain
      const newest = await getCachedSearch("query-7");
      expect(newest).not.toBeNull();
    });
  });

  // ─── Clear all ─────────────────────────────────────────────────────────

  describe("clearAllCaches", () => {
    it("clears both products and searches", async () => {
      await cacheProduct(1, { name: "Test" });
      await cacheSearch("q", { r: 1 });
      await clearAllCaches();
      expect(await getCachedProductCount()).toBe(0);
      expect(await getCachedSearch("q")).toBeNull();
    });
  });

  // ─── timeAgo ──────────────────────────────────────────────────────────

  describe("timeAgo", () => {
    it('returns "just now" for recent timestamps', () => {
      expect(timeAgo(Date.now())).toBe("just now");
      expect(timeAgo(Date.now() - 30_000)).toBe("just now");
    });

    it("returns minutes for < 1 hour", () => {
      expect(timeAgo(Date.now() - 5 * 60_000)).toBe("5m ago");
      expect(timeAgo(Date.now() - 45 * 60_000)).toBe("45m ago");
    });

    it("returns hours for < 24 hours", () => {
      expect(timeAgo(Date.now() - 2 * 3600_000)).toBe("2h ago");
      expect(timeAgo(Date.now() - 23 * 3600_000)).toBe("23h ago");
    });

    it("returns days for >= 24 hours", () => {
      expect(timeAgo(Date.now() - 48 * 3600_000)).toBe("2d ago");
      expect(timeAgo(Date.now() - 7 * 24 * 3600_000)).toBe("7d ago");
    });
  });

  // ─── Graceful degradation without IndexedDB ────────────────────────────

  describe("graceful degradation", () => {
    let originalIndexedDB: IDBFactory;

    beforeEach(() => {
      originalIndexedDB = globalThis.indexedDB;
    });

    afterEach(() => {
      Object.defineProperty(globalThis, "indexedDB", {
        value: originalIndexedDB,
        writable: true,
        configurable: true,
      });
    });

    it("cacheProduct is a no-op without IndexedDB", async () => {
      Object.defineProperty(globalThis, "indexedDB", {
        value: undefined,
        writable: true,
        configurable: true,
      });
      // Should not throw — resolves to undefined
      await expect(cacheProduct(1, { name: "Test" })).resolves.toBeUndefined();
    });

    it("getCachedProduct returns null without IndexedDB", async () => {
      Object.defineProperty(globalThis, "indexedDB", {
        value: undefined,
        writable: true,
        configurable: true,
      });
      const result = await getCachedProduct(1);
      expect(result).toBeNull();
    });

    it("getAllCachedProducts returns empty without IndexedDB", async () => {
      Object.defineProperty(globalThis, "indexedDB", {
        value: undefined,
        writable: true,
        configurable: true,
      });
      const result = await getAllCachedProducts();
      expect(result).toEqual([]);
    });

    it("getCachedProductCount returns 0 without IndexedDB", async () => {
      Object.defineProperty(globalThis, "indexedDB", {
        value: undefined,
        writable: true,
        configurable: true,
      });
      const count = await getCachedProductCount();
      expect(count).toBe(0);
    });

    it("cacheSearch is a no-op without IndexedDB", async () => {
      Object.defineProperty(globalThis, "indexedDB", {
        value: undefined,
        writable: true,
        configurable: true,
      });
      await expect(cacheSearch("q", { r: 1 })).resolves.toBeUndefined();
    });

    it("getCachedSearch returns null without IndexedDB", async () => {
      Object.defineProperty(globalThis, "indexedDB", {
        value: undefined,
        writable: true,
        configurable: true,
      });
      const result = await getCachedSearch("q");
      expect(result).toBeNull();
    });

    it("clearAllCaches is a no-op without IndexedDB", async () => {
      Object.defineProperty(globalThis, "indexedDB", {
        value: undefined,
        writable: true,
        configurable: true,
      });
      await expect(clearAllCaches()).resolves.toBeUndefined();
    });
  });
});
