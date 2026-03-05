import {
    cacheProduct,
    cacheSearch,
    checkStorageQuota,
    clearAllCaches,
    getAllCachedProducts,
    getCacheStats,
    getCachedProduct,
    getCachedProductCount,
    getCachedSearch,
    getProductWithSWR,
    isStale,
    resetCacheStats,
    timeAgo,
} from "@/lib/cache-manager";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

// ─── fake-indexeddb ─────────────────────────────────────────────────────────
// Vitest runs in Node, which has no IndexedDB. We use fake-indexeddb shim.
import "fake-indexeddb/auto";

describe("cache-manager", () => {
  beforeEach(async () => {
    // Clear DB between tests
    await clearAllCaches().catch(() => {});
    // Delete the DB entirely to avoid version conflicts
    const req = indexedDB.deleteDatabase("tryvit-offline");
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

    it("evicts entries when exceeding 100 products", async () => {
      // Cache 102 products (IDs 1-102)
      for (let i = 1; i <= 102; i++) {
        await cacheProduct(i, { name: `Product ${i}` });
      }
      // Allow async eviction to complete
      await new Promise((r) => setTimeout(r, 50));
      const count = await getCachedProductCount();
      expect(count).toBe(100);
      // The newest should still be there
      const newest = await getCachedProduct(102);
      expect(newest).not.toBeNull();
    });

    it("accepts optional category in options", async () => {
      await cacheProduct(1, { name: "Milk" }, { category: "Dairy" });
      const result = await getCachedProduct(1);
      expect(result).not.toBeNull();
      expect(result!.category).toBe("Dairy");
    });

    it("preserves category on data update", async () => {
      await cacheProduct(1, { name: "V1" }, { category: "Dairy" });
      await cacheProduct(1, { name: "V2" }); // no category override
      const result = await getCachedProduct(1);
      expect(result!.data).toEqual({ name: "V2" });
      expect(result!.category).toBe("Dairy");
    });
  });

  // ─── LFU-LRU hybrid eviction ──────────────────────────────────────────

  describe("LFU-LRU hybrid eviction", () => {
    it("retains frequently accessed products over rarely accessed ones", async () => {
      // Cache products 1-100
      for (let i = 1; i <= 100; i++) {
        await cacheProduct(i, { name: `Product ${i}` });
      }

      // Access product 1 many times to boost its frequency score
      for (let j = 0; j < 10; j++) {
        await getCachedProduct(1);
      }

      // Now add 5 more products (IDs 101-105) to trigger eviction
      for (let i = 101; i <= 105; i++) {
        await cacheProduct(i, { name: `Product ${i}` });
      }
      await new Promise((r) => setTimeout(r, 50));

      const count = await getCachedProductCount();
      expect(count).toBe(100);

      // Product 1 should survive eviction due to high access count
      const frequentProduct = await getCachedProduct(1);
      expect(frequentProduct).not.toBeNull();

      // New products should also survive
      const newestProduct = await getCachedProduct(105);
      expect(newestProduct).not.toBeNull();
    });

    it("increments accessCount on each retrieval", async () => {
      await cacheProduct(1, { name: "Test" });

      // AccessCount starts at 1 (from caching), +1 from each retrieval
      const first = await getCachedProduct(1);
      expect(first!.accessCount).toBe(2);

      const second = await getCachedProduct(1);
      expect(second!.accessCount).toBe(3);

      const third = await getCachedProduct(1);
      expect(third!.accessCount).toBe(4);
    });

    it("preserves accessCount when re-caching product data", async () => {
      await cacheProduct(1, { name: "V1" });
      // Access a few times to build up count
      await getCachedProduct(1);
      await getCachedProduct(1);
      // Re-cache with updated data — accessCount should be preserved + incremented
      await cacheProduct(1, { name: "V2" });
      const result = await getCachedProduct(1);
      // Initial 1 + 2 gets + re-cache bump + final get = 5
      expect(result!.accessCount).toBeGreaterThanOrEqual(4);
      expect(result!.data).toEqual({ name: "V2" });
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

    it("evicts entries when exceeding 10 searches", async () => {
      for (let i = 1; i <= 12; i++) {
        await cacheSearch(`query-${i}`, { results: i });
      }
      await new Promise((r) => setTimeout(r, 50));
      // Newest should remain
      const newest = await getCachedSearch("query-12");
      expect(newest).not.toBeNull();
    });

    it("increments accessCount on search retrieval", async () => {
      await cacheSearch("query", { results: 1 });
      const first = await getCachedSearch("query");
      expect(first!.accessCount).toBe(2); // 1 from cache + 1 from get

      const second = await getCachedSearch("query");
      expect(second!.accessCount).toBe(3);
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
      expect(timeAgo(Date.now() - 2 * 3_600_000)).toBe("2h ago");
      expect(timeAgo(Date.now() - 23 * 3_600_000)).toBe("23h ago");
    });

    it("returns days for >= 24 hours", () => {
      expect(timeAgo(Date.now() - 48 * 3_600_000)).toBe("2d ago");
      expect(timeAgo(Date.now() - 7 * 24 * 3_600_000)).toBe("7d ago");
    });
  });

  // ─── isStale ──────────────────────────────────────────────────────────

  describe("isStale", () => {
    it("returns false for fresh entries", () => {
      const entry = { cachedAt: Date.now() };
      expect(isStale(entry)).toBe(false);
    });

    it("returns true for entries older than default threshold (24h)", () => {
      const entry = { cachedAt: Date.now() - 25 * 60 * 60 * 1000 };
      expect(isStale(entry)).toBe(true);
    });

    it("respects custom maxAgeMs threshold", () => {
      const entry = { cachedAt: Date.now() - 5 * 60 * 1000 }; // 5 minutes old
      expect(isStale(entry, 10 * 60 * 1000)).toBe(false); // 10 min threshold
      expect(isStale(entry, 3 * 60 * 1000)).toBe(true); // 3 min threshold
    });

    it("returns true for entries past threshold boundary", () => {
      const threshold = 1000;
      const entry = { cachedAt: Date.now() - threshold - 1 };
      expect(isStale(entry, threshold)).toBe(true);
    });
  });

  // ─── SWR (Stale-While-Revalidate) ─────────────────────────────────────

  describe("getProductWithSWR", () => {
    it("returns cached data when fresh", async () => {
      await cacheProduct(1, { name: "Cached" });
      const fetcher = vi.fn();

      const result = await getProductWithSWR(1, fetcher);

      expect(result).not.toBeNull();
      expect(result!.data).toEqual({ name: "Cached" });
      expect(result!.source).toBe("cache");
      expect(result!.stale).toBe(false);
      expect(fetcher).not.toHaveBeenCalled();
    });

    it("fetches from network on cache miss", async () => {
      const fetcher = vi.fn().mockResolvedValue({ name: "Fetched" });

      const result = await getProductWithSWR(1, fetcher);

      expect(result).not.toBeNull();
      expect(result!.data).toEqual({ name: "Fetched" });
      expect(result!.source).toBe("network");
      expect(result!.stale).toBe(false);
      expect(fetcher).toHaveBeenCalledWith(1);
    });

    it("caches network-fetched data for subsequent calls", async () => {
      const fetcher = vi.fn().mockResolvedValue({ name: "Fetched" });

      await getProductWithSWR(1, fetcher);
      const cached = await getCachedProduct(1);

      expect(cached).not.toBeNull();
      expect(cached!.data).toEqual({ name: "Fetched" });
    });

    it("returns null when both cache and fetcher fail", async () => {
      const fetcher = vi.fn().mockRejectedValue(new Error("Network error"));

      const result = await getProductWithSWR(999, fetcher);

      expect(result).toBeNull();
    });

    it("returns stale data and triggers revalidation", async () => {
      await cacheProduct(1, { name: "Old Data" });

      const fetcher = vi.fn().mockResolvedValue({ name: "Fresh Data" });

      // maxAgeMs=0 makes everything stale immediately
      const result = await getProductWithSWR(1, fetcher, {
        maxAgeMs: 0,
      });

      expect(result).not.toBeNull();
      expect(result!.data).toEqual({ name: "Old Data" });
      expect(result!.source).toBe("cache");
      expect(result!.stale).toBe(true);

      // Wait for background revalidation
      await new Promise((r) => setTimeout(r, 150));
      expect(fetcher).toHaveBeenCalledWith(1);

      // Verify cache was updated with fresh data
      const updated = await getCachedProduct(1);
      expect(updated!.data).toEqual({ name: "Fresh Data" });
    });

    it("swallows revalidation errors silently", async () => {
      await cacheProduct(1, { name: "Stale Data" });
      const fetcher = vi.fn().mockRejectedValue(new Error("Fail"));

      const result = await getProductWithSWR(1, fetcher, { maxAgeMs: 0 });

      expect(result).not.toBeNull();
      expect(result!.data).toEqual({ name: "Stale Data" });

      // Wait for bg revalidation attempt
      await new Promise((r) => setTimeout(r, 150));

      // Cache should still have old data
      const stillCached = await getCachedProduct(1);
      expect(stillCached!.data).toEqual({ name: "Stale Data" });
    });

    it("passes category option through to cacheProduct", async () => {
      const fetcher = vi.fn().mockResolvedValue({ name: "Milk" });

      await getProductWithSWR(1, fetcher, { category: "Dairy" });

      const cached = await getCachedProduct(1);
      expect(cached!.category).toBe("Dairy");
    });
  });

  // ─── Cache analytics ──────────────────────────────────────────────────

  describe("getCacheStats", () => {
    it("returns zero stats for empty cache", async () => {
      const stats = await getCacheStats();
      expect(stats.productCount).toBe(0);
      expect(stats.searchCount).toBe(0);
      expect(stats.hitRate).toBe(0);
      expect(stats.avgProductAgeMs).toBe(0);
      expect(stats.oldestProductMs).toBe(0);
    });

    it("reports correct product and search counts", async () => {
      await cacheProduct(1, { name: "A" });
      await cacheProduct(2, { name: "B" });
      await cacheSearch("q1", { r: 1 });

      const stats = await getCacheStats();
      expect(stats.productCount).toBe(2);
      expect(stats.searchCount).toBe(1);
    });

    it("tracks cache hits from getCachedProduct", async () => {
      await cacheProduct(1, { name: "Test" });

      // 1 hit
      await getCachedProduct(1);

      const stats = await getCacheStats();
      expect(stats.hitCount).toBeGreaterThanOrEqual(1);
    });

    it("tracks cache misses from getCachedProduct", async () => {
      // 1 miss
      await getCachedProduct(999);

      const stats = await getCacheStats();
      expect(stats.missCount).toBeGreaterThanOrEqual(1);
    });

    it("computes product age metrics", async () => {
      await cacheProduct(1, { name: "Test" });
      await new Promise((r) => setTimeout(r, 20));

      const stats = await getCacheStats();
      expect(stats.avgProductAgeMs).toBeGreaterThan(0);
      expect(stats.oldestProductMs).toBeGreaterThan(0);
    });
  });

  describe("resetCacheStats", () => {
    it("resets hit/miss counters to zero", async () => {
      await cacheProduct(1, { name: "Test" });
      await getCachedProduct(1); // hit
      await getCachedProduct(999); // miss

      await resetCacheStats();

      const stats = await getCacheStats();
      expect(stats.hitCount).toBe(0);
      expect(stats.missCount).toBe(0);
      expect(stats.hitRate).toBe(0);
    });
  });

  // ─── Quota management ─────────────────────────────────────────────────

  describe("checkStorageQuota", () => {
    it("returns null when Storage API is unavailable", async () => {
      // fake-indexeddb doesn't provide navigator.storage
      const result = await checkStorageQuota();
      expect(result).toBeNull();
    });

    it("returns usage stats when Storage API exists", async () => {
      const originalNavigator = globalThis.navigator;
      Object.defineProperty(globalThis, "navigator", {
        value: {
          ...originalNavigator,
          storage: {
            estimate: vi
              .fn()
              .mockResolvedValue({ usage: 500_000, quota: 1_000_000 }),
          },
        },
        writable: true,
        configurable: true,
      });

      const result = await checkStorageQuota();
      expect(result).not.toBeNull();
      expect(result!.usage).toBe(500_000);
      expect(result!.quota).toBe(1_000_000);
      expect(result!.usagePct).toBe(50);
      expect(result!.cleanupTriggered).toBe(false);

      Object.defineProperty(globalThis, "navigator", {
        value: originalNavigator,
        writable: true,
        configurable: true,
      });
    });

    it("triggers cleanup when usage exceeds 80%", async () => {
      // Pre-populate cache
      for (let i = 1; i <= 20; i++) {
        await cacheProduct(i, { name: `Product ${i}` });
      }
      await cacheSearch("q1", { results: 1 });

      const originalNavigator = globalThis.navigator;
      Object.defineProperty(globalThis, "navigator", {
        value: {
          ...originalNavigator,
          storage: {
            estimate: vi
              .fn()
              .mockResolvedValue({ usage: 900_000, quota: 1_000_000 }),
          },
        },
        writable: true,
        configurable: true,
      });

      const result = await checkStorageQuota();
      expect(result).not.toBeNull();
      expect(result!.usagePct).toBe(90);
      expect(result!.cleanupTriggered).toBe(true);

      // Searches should be cleared after aggressive cleanup
      const search = await getCachedSearch("q1");
      expect(search).toBeNull();

      // Some products should be evicted (keeps top half)
      const productCount = await getCachedProductCount();
      expect(productCount).toBeLessThanOrEqual(10);

      Object.defineProperty(globalThis, "navigator", {
        value: originalNavigator,
        writable: true,
        configurable: true,
      });
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

    it("getProductWithSWR falls back to network", async () => {
      Object.defineProperty(globalThis, "indexedDB", {
        value: undefined,
        writable: true,
        configurable: true,
      });
      const fetcher = vi.fn().mockResolvedValue({ name: "Network Only" });
      // Without IndexedDB, getCachedProduct returns null → fetcher called
      const result = await getProductWithSWR(1, fetcher);
      expect(fetcher).toHaveBeenCalledWith(1);
      // cacheProduct is a no-op → still returns network result
      if (result) {
        expect(result.source).toBe("network");
      }
    });

    it("getCacheStats returns defaults without IndexedDB", async () => {
      Object.defineProperty(globalThis, "indexedDB", {
        value: undefined,
        writable: true,
        configurable: true,
      });
      const stats = await getCacheStats();
      expect(stats.productCount).toBe(0);
      expect(stats.searchCount).toBe(0);
      expect(stats.hitRate).toBe(0);
    });

    it("resetCacheStats is a no-op without IndexedDB", async () => {
      Object.defineProperty(globalThis, "indexedDB", {
        value: undefined,
        writable: true,
        configurable: true,
      });
      await expect(resetCacheStats()).resolves.toBeUndefined();
    });

    it("checkStorageQuota returns null without navigator.storage", async () => {
      const result = await checkStorageQuota();
      expect(result).toBeNull();
    });

    it("isStale works without IndexedDB (pure function)", () => {
      expect(isStale({ cachedAt: 0 })).toBe(true);
      expect(isStale({ cachedAt: Date.now() })).toBe(false);
    });
  });
});
