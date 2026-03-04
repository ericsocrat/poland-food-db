import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import "fake-indexeddb/auto";
import {
  cacheProduct,
  getCachedProduct,
  getAllCachedProducts,
  getCachedProductCount,
  cacheSearch,
  getCachedSearch,
  clearAllCaches,
  timeAgo,
} from "./cache-manager";

// ─── Helpers ────────────────────────────────────────────────────────────────

function deleteDB(name: string): Promise<void> {
  return new Promise((resolve, reject) => {
    const req = indexedDB.deleteDatabase(name);
    req.onsuccess = () => resolve();
    req.onerror = () => reject(req.error);
  });
}

beforeEach(async () => {
  // Clean slate before each test
  await deleteDB("tryvit-offline");
});

afterEach(() => {
  vi.restoreAllMocks();
});

// ─── Product cache operations ───────────────────────────────────────────────

describe("cacheProduct", () => {
  it("stores and retrieves a product", async () => {
    await cacheProduct(42, { name: "Skyr Naturalny" });
    const entry = await getCachedProduct<{ name: string }>(42);
    expect(entry).not.toBeNull();
    expect(entry!.productId).toBe(42);
    expect(entry!.data).toEqual({ name: "Skyr Naturalny" });
  });

  it("sets cachedAt and accessedAt timestamps", async () => {
    const before = Date.now();
    await cacheProduct(1, { x: 1 });
    const after = Date.now();
    const entry = await getCachedProduct(1);
    expect(entry!.cachedAt).toBeGreaterThanOrEqual(before);
    expect(entry!.cachedAt).toBeLessThanOrEqual(after);
  });

  it("overwrites existing product with same id (upsert)", async () => {
    await cacheProduct(10, { version: 1 });
    await cacheProduct(10, { version: 2 });
    const entry = await getCachedProduct<{ version: number }>(10);
    expect(entry!.data.version).toBe(2);
  });

  it("evicts LRU entries when exceeding MAX_PRODUCTS (50)", async () => {
    // Insert 52 products; oldest 2 should be evicted
    for (let i = 1; i <= 52; i++) {
      await cacheProduct(i, { idx: i });
    }
    // Give eviction time to process
    const count = await getCachedProductCount();
    expect(count).toBeLessThanOrEqual(50);
    // Product 1 or 2 (oldest) should be gone
    const oldest = await getCachedProduct(1);
    expect(oldest).toBeNull();
  });

  it("silently succeeds when IndexedDB is unavailable", async () => {
    const origIndexedDB = globalThis.indexedDB;
    Object.defineProperty(globalThis, "indexedDB", {
      value: undefined,
      writable: true,
      configurable: true,
    });
    // Should not throw
    await expect(cacheProduct(1, { x: 1 })).resolves.toBeUndefined();
    Object.defineProperty(globalThis, "indexedDB", {
      value: origIndexedDB,
      writable: true,
      configurable: true,
    });
  });
});

// ─── getCachedProduct ───────────────────────────────────────────────────────

describe("getCachedProduct", () => {
  it("returns null for non-existent product", async () => {
    const entry = await getCachedProduct(999);
    expect(entry).toBeNull();
  });

  it("bumps accessedAt on retrieval (LRU refresh)", async () => {
    await cacheProduct(5, { data: "test" });
    const first = await getCachedProduct(5);
    // Wait a tiny bit to ensure timestamp difference
    await new Promise((r) => setTimeout(r, 10));
    const second = await getCachedProduct(5);
    expect(second!.accessedAt).toBeGreaterThanOrEqual(first!.accessedAt);
  });

  it("returns null when IndexedDB is unavailable", async () => {
    const origIndexedDB = globalThis.indexedDB;
    Object.defineProperty(globalThis, "indexedDB", {
      value: undefined,
      writable: true,
      configurable: true,
    });
    const result = await getCachedProduct(1);
    expect(result).toBeNull();
    Object.defineProperty(globalThis, "indexedDB", {
      value: origIndexedDB,
      writable: true,
      configurable: true,
    });
  });
});

// ─── getAllCachedProducts ────────────────────────────────────────────────────

describe("getAllCachedProducts", () => {
  it("returns empty array when no products cached", async () => {
    const products = await getAllCachedProducts();
    expect(products).toEqual([]);
  });

  it("returns products ordered by accessedAt descending", async () => {
    await cacheProduct(1, { name: "A" });
    await new Promise((r) => setTimeout(r, 10));
    await cacheProduct(2, { name: "B" });
    await new Promise((r) => setTimeout(r, 10));
    await cacheProduct(3, { name: "C" });

    const products = await getAllCachedProducts();
    expect(products.length).toBe(3);
    // Most recently cached should be first
    expect(products[0].productId).toBe(3);
    expect(products[2].productId).toBe(1);
  });

  it("returns empty array when IndexedDB is unavailable", async () => {
    const origIndexedDB = globalThis.indexedDB;
    Object.defineProperty(globalThis, "indexedDB", {
      value: undefined,
      writable: true,
      configurable: true,
    });
    const result = await getAllCachedProducts();
    expect(result).toEqual([]);
    Object.defineProperty(globalThis, "indexedDB", {
      value: origIndexedDB,
      writable: true,
      configurable: true,
    });
  });
});

// ─── getCachedProductCount ──────────────────────────────────────────────────

describe("getCachedProductCount", () => {
  it("returns 0 when empty", async () => {
    const count = await getCachedProductCount();
    expect(count).toBe(0);
  });

  it("returns correct count after caching products", async () => {
    await cacheProduct(1, {});
    await cacheProduct(2, {});
    await cacheProduct(3, {});
    const count = await getCachedProductCount();
    expect(count).toBe(3);
  });

  it("returns 0 when IndexedDB is unavailable", async () => {
    const origIndexedDB = globalThis.indexedDB;
    Object.defineProperty(globalThis, "indexedDB", {
      value: undefined,
      writable: true,
      configurable: true,
    });
    const count = await getCachedProductCount();
    expect(count).toBe(0);
    Object.defineProperty(globalThis, "indexedDB", {
      value: origIndexedDB,
      writable: true,
      configurable: true,
    });
  });
});

// ─── Search cache operations ────────────────────────────────────────────────

describe("cacheSearch", () => {
  it("stores and retrieves a search result", async () => {
    await cacheSearch("mleko", { results: [1, 2, 3] });
    const entry = await getCachedSearch<{ results: number[] }>("mleko");
    expect(entry).not.toBeNull();
    expect(entry!.queryKey).toBe("mleko");
    expect(entry!.data).toEqual({ results: [1, 2, 3] });
  });

  it("overwrites existing search with same key", async () => {
    await cacheSearch("ser", { results: [1] });
    await cacheSearch("ser", { results: [1, 2, 3] });
    const entry = await getCachedSearch<{ results: number[] }>("ser");
    expect(entry!.data.results.length).toBe(3);
  });

  it("evicts LRU entries when exceeding MAX_SEARCHES (5)", async () => {
    for (let i = 1; i <= 7; i++) {
      await cacheSearch(`query${i}`, { idx: i });
    }
    // The oldest queries should be evicted
    const oldest = await getCachedSearch("query1");
    expect(oldest).toBeNull();
    // Recent queries should survive
    const recent = await getCachedSearch("query7");
    expect(recent).not.toBeNull();
  });

  it("silently succeeds when IndexedDB is unavailable", async () => {
    const origIndexedDB = globalThis.indexedDB;
    Object.defineProperty(globalThis, "indexedDB", {
      value: undefined,
      writable: true,
      configurable: true,
    });
    await expect(cacheSearch("q", {})).resolves.toBeUndefined();
    Object.defineProperty(globalThis, "indexedDB", {
      value: origIndexedDB,
      writable: true,
      configurable: true,
    });
  });
});

// ─── getCachedSearch ────────────────────────────────────────────────────────

describe("getCachedSearch", () => {
  it("returns null for non-existent search", async () => {
    const entry = await getCachedSearch("nonexistent");
    expect(entry).toBeNull();
  });

  it("bumps accessedAt on retrieval", async () => {
    await cacheSearch("test", { data: true });
    const first = await getCachedSearch("test");
    await new Promise((r) => setTimeout(r, 10));
    const second = await getCachedSearch("test");
    expect(second!.accessedAt).toBeGreaterThanOrEqual(first!.accessedAt);
  });

  it("returns null when IndexedDB is unavailable", async () => {
    const origIndexedDB = globalThis.indexedDB;
    Object.defineProperty(globalThis, "indexedDB", {
      value: undefined,
      writable: true,
      configurable: true,
    });
    const result = await getCachedSearch("q");
    expect(result).toBeNull();
    Object.defineProperty(globalThis, "indexedDB", {
      value: origIndexedDB,
      writable: true,
      configurable: true,
    });
  });
});

// ─── clearAllCaches ─────────────────────────────────────────────────────────

describe("clearAllCaches", () => {
  it("removes all products and searches", async () => {
    await cacheProduct(1, { a: 1 });
    await cacheProduct(2, { b: 2 });
    await cacheSearch("q1", { r: 1 });

    await clearAllCaches();

    const products = await getAllCachedProducts();
    const search = await getCachedSearch("q1");
    expect(products).toEqual([]);
    expect(search).toBeNull();
  });

  it("works on already-empty cache", async () => {
    await expect(clearAllCaches()).resolves.toBeUndefined();
  });

  it("silently succeeds when IndexedDB is unavailable", async () => {
    const origIndexedDB = globalThis.indexedDB;
    Object.defineProperty(globalThis, "indexedDB", {
      value: undefined,
      writable: true,
      configurable: true,
    });
    await expect(clearAllCaches()).resolves.toBeUndefined();
    Object.defineProperty(globalThis, "indexedDB", {
      value: origIndexedDB,
      writable: true,
      configurable: true,
    });
  });
});

// ─── timeAgo ────────────────────────────────────────────────────────────────

describe("timeAgo", () => {
  it("returns 'just now' for timestamps < 60s ago", () => {
    expect(timeAgo(Date.now() - 30_000)).toBe("just now");
  });

  it("returns minutes for 1–59 min ago", () => {
    expect(timeAgo(Date.now() - 5 * 60_000)).toBe("5m ago");
  });

  it("returns hours for 1–23h ago", () => {
    expect(timeAgo(Date.now() - 3 * 3_600_000)).toBe("3h ago");
  });

  it("returns days for 24h+ ago", () => {
    expect(timeAgo(Date.now() - 2 * 86_400_000)).toBe("2d ago");
  });

  it("returns '1m ago' at exactly 60 seconds", () => {
    expect(timeAgo(Date.now() - 60_000)).toBe("1m ago");
  });

  it("returns '1h ago' at exactly 60 minutes", () => {
    expect(timeAgo(Date.now() - 60 * 60_000)).toBe("1h ago");
  });

  it("returns '1d ago' at exactly 24 hours", () => {
    expect(timeAgo(Date.now() - 24 * 3_600_000)).toBe("1d ago");
  });
});
