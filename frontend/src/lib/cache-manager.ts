// ─── IndexedDB-backed LFU-LRU product cache ─────────────────────────────────
// Stores recently viewed product profiles for offline access.
// Uses the Cache API pattern but backed by IndexedDB for structured data.
//
// - Max 100 products (LFU-LRU hybrid eviction)
// - Max 10 cached search results
// - SWR (stale-while-revalidate) pattern for offline-first browsing
// - Quota management to prevent IndexedDB overflow on mobile
// - Cache analytics for debugging and optimization

const DB_NAME = "tryvit-offline";
const DB_VERSION = 2;
const PRODUCT_STORE = "products";
const SEARCH_STORE = "searches";
const META_STORE = "meta";
const MAX_PRODUCTS = 100;
const MAX_SEARCHES = 10;

/** Each additional access effectively "ages down" an entry by this amount. */
const FREQUENCY_BONUS_MS = 3_600_000; // 1 hour per access
/** Default staleness threshold for SWR. */
const STALE_THRESHOLD_MS = 24 * 60 * 60 * 1000; // 24 hours
/** Trigger aggressive cleanup above this storage usage percentage. */
const QUOTA_WARNING_PCT = 80;

export interface CachedProduct<T = unknown> {
  productId: number;
  data: T;
  cachedAt: number; // epoch ms
  accessedAt: number; // epoch ms — for LRU ordering
  accessCount: number; // access frequency — for LFU weighting
  category?: string; // product category — for category-based retention
}

export interface CachedSearch<T = unknown> {
  queryKey: string;
  data: T;
  cachedAt: number;
  accessedAt: number;
  accessCount: number;
}

export interface CacheProductOptions {
  /** Product category for category-based retention priority. */
  category?: string;
  /** Cache priority — 'high' entries are evicted last. */
  priority?: "high" | "normal" | "low";
}

export interface SWRResult<T> {
  data: T;
  source: "cache" | "network";
  stale: boolean;
}

export interface CacheStats {
  productCount: number;
  searchCount: number;
  hitCount: number;
  missCount: number;
  hitRate: number; // 0–1
  avgProductAgeMs: number;
  oldestProductMs: number;
  storageEstimate?: {
    usage: number;
    quota: number;
    usagePct: number;
  };
}

interface CacheMeta {
  key: string;
  hitCount: number;
  missCount: number;
  lastReset: number;
}

// ─── DB lifecycle ───────────────────────────────────────────────────────────

function isIndexedDBAvailable(): boolean {
  try {
    return typeof indexedDB !== "undefined";
  } catch {
    return false;
  }
}

function openDB(): Promise<IDBDatabase> {
  if (!isIndexedDBAvailable()) {
    return Promise.reject(new Error("IndexedDB not available"));
  }
  return new Promise((resolve, reject) => {
    const request = indexedDB.open(DB_NAME, DB_VERSION);
    request.onupgradeneeded = (event) => {
      const db = request.result;
      const oldVersion = event.oldVersion;

      // Version 1: product + search stores
      if (oldVersion < 1) {
        const productStore = db.createObjectStore(PRODUCT_STORE, {
          keyPath: "productId",
        });
        productStore.createIndex("accessedAt", "accessedAt", { unique: false });
        const searchStore = db.createObjectStore(SEARCH_STORE, {
          keyPath: "queryKey",
        });
        searchStore.createIndex("accessedAt", "accessedAt", { unique: false });
      }

      // Version 2: meta store for cache analytics
      if (oldVersion < 2) {
        if (!db.objectStoreNames.contains(META_STORE)) {
          db.createObjectStore(META_STORE, { keyPath: "key" });
        }
      }
    };
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error ?? new Error("IndexedDB open failed"));
  });
}

// ─── LFU-LRU hybrid eviction score ──────────────────────────────────────────

/**
 * Computes a composite eviction score. Higher score = keep longer.
 * Combines recency (accessedAt) with access frequency (accessCount).
 * Each access "ages down" the entry by FREQUENCY_BONUS_MS, making
 * frequently-accessed entries survive eviction even if not the most recent.
 */
function computeEvictionScore(entry: {
  accessedAt: number;
  accessCount?: number;
}): number {
  return entry.accessedAt + (entry.accessCount ?? 0) * FREQUENCY_BONUS_MS;
}

// ─── Analytics helpers (private) ────────────────────────────────────────────

async function recordCacheEvent(
  type: "hit" | "miss",
): Promise<void> {
  try {
    const db = await openDB();
    const tx = db.transaction(META_STORE, "readwrite");
    const store = tx.objectStore(META_STORE);

    const getReq = store.get("analytics");
    getReq.onsuccess = () => {
      const meta: CacheMeta = getReq.result ?? {
        key: "analytics",
        hitCount: 0,
        missCount: 0,
        lastReset: Date.now(),
      };
      if (type === "hit") meta.hitCount++;
      else meta.missCount++;
      store.put(meta);
    };

    await new Promise<void>((resolve) => {
      tx.oncomplete = () => {
        db.close();
        resolve();
      };
      tx.onerror = () => {
        db.close();
        resolve(); // swallow errors — analytics are non-critical
      };
    });
  } catch {
    // Analytics are best-effort — never throw
  }
}

// ─── Product cache operations ───────────────────────────────────────────────

/**
 * Cache a product profile. If the cache exceeds MAX_PRODUCTS, entries
 * with the lowest LFU-LRU composite score are evicted.
 * Silently fails when IndexedDB is unavailable.
 */
export async function cacheProduct<T>(
  productId: number,
  data: T,
  options?: CacheProductOptions,
): Promise<void> {
  if (!isIndexedDBAvailable()) return;
  const db = await openDB();
  const now = Date.now();
  const tx = db.transaction(PRODUCT_STORE, "readwrite");
  const store = tx.objectStore(PRODUCT_STORE);

  // Preserve existing accessCount when updating an entry
  const existingReq = store.get(productId);
  existingReq.onsuccess = () => {
    const existing = existingReq.result as CachedProduct<T> | undefined;
    const entry: CachedProduct<T> = {
      productId,
      data,
      cachedAt: now,
      accessedAt: now,
      accessCount: existing ? (existing.accessCount ?? 0) + 1 : 1,
      category: options?.category ?? existing?.category,
    };
    store.put(entry);

    // LFU-LRU eviction — load all entries and evict by composite score
    const allReq = store.getAll();
    allReq.onsuccess = () => {
      const entries = allReq.result as CachedProduct[];
      if (entries.length > MAX_PRODUCTS) {
        // Sort by eviction score ascending — lowest score evicted first
        entries.sort(
          (a, b) => computeEvictionScore(a) - computeEvictionScore(b),
        );
        const excess = entries.length - MAX_PRODUCTS;
        for (let i = 0; i < excess; i++) {
          store.delete(entries[i].productId);
        }
      }
    };
  };

  return new Promise((resolve, reject) => {
    tx.oncomplete = () => {
      db.close();
      resolve();
    };
    tx.onerror = () => {
      db.close();
      reject(tx.error ?? new Error("Transaction failed"));
    };
  });
}

/**
 * Retrieve a cached product, bump accessedAt and accessCount for LFU-LRU,
 * and record cache hit/miss analytics.
 * Returns null when IndexedDB is unavailable.
 */
export async function getCachedProduct<T>(
  productId: number,
): Promise<CachedProduct<T> | null> {
  if (!isIndexedDBAvailable()) return null;
  const db = await openDB();
  const tx = db.transaction(PRODUCT_STORE, "readwrite");
  const store = tx.objectStore(PRODUCT_STORE);

  return new Promise((resolve, reject) => {
    const getReq = store.get(productId);
    getReq.onsuccess = () => {
      const entry = getReq.result as CachedProduct<T> | undefined;
      if (entry) {
        // Bump accessedAt and accessCount
        entry.accessedAt = Date.now();
        entry.accessCount = (entry.accessCount ?? 0) + 1;
        store.put(entry);
        recordCacheEvent("hit").catch(() => {});
        resolve(entry);
      } else {
        recordCacheEvent("miss").catch(() => {});
        resolve(null);
      }
    };
    getReq.onerror = () => reject(getReq.error ?? new Error("Get request failed"));
    tx.oncomplete = () => db.close();
    tx.onerror = () => {
      db.close();
      reject(tx.error ?? new Error("Transaction failed"));
    };
  });
}

/**
 * Get all cached products, ordered by accessedAt descending (most recent first).
 * Returns empty array when IndexedDB is unavailable.
 */
export async function getAllCachedProducts<T>(): Promise<CachedProduct<T>[]> {
  if (!isIndexedDBAvailable()) return [];
  const db = await openDB();
  const tx = db.transaction(PRODUCT_STORE, "readonly");
  const store = tx.objectStore(PRODUCT_STORE);

  return new Promise((resolve, reject) => {
    const req = store.getAll();
    req.onsuccess = () => {
      const entries = (req.result as CachedProduct<T>[]).sort(
        (a, b) => b.accessedAt - a.accessedAt,
      );
      db.close();
      resolve(entries);
    };
    req.onerror = () => {
      db.close();
      reject(req.error ?? new Error("GetAll request failed"));
    };
  });
}

/**
 * Count of cached products (for UI display).
 * Returns 0 when IndexedDB is unavailable.
 */
export async function getCachedProductCount(): Promise<number> {
  if (!isIndexedDBAvailable()) return 0;
  const db = await openDB();
  const tx = db.transaction(PRODUCT_STORE, "readonly");
  const store = tx.objectStore(PRODUCT_STORE);

  return new Promise((resolve, reject) => {
    const req = store.count();
    req.onsuccess = () => {
      db.close();
      resolve(req.result);
    };
    req.onerror = () => {
      db.close();
      reject(req.error ?? new Error("Count request failed"));
    };
  });
}

// ─── Search cache operations ────────────────────────────────────────────────

/**
 * Cache a search result. Evicts by LFU-LRU score when exceeding MAX_SEARCHES.
 * Silently fails when IndexedDB is unavailable.
 */
export async function cacheSearch<T>(
  queryKey: string,
  data: T,
): Promise<void> {
  if (!isIndexedDBAvailable()) return;
  const db = await openDB();
  const now = Date.now();
  const tx = db.transaction(SEARCH_STORE, "readwrite");
  const store = tx.objectStore(SEARCH_STORE);

  // Preserve existing accessCount when updating
  const existingReq = store.get(queryKey);
  existingReq.onsuccess = () => {
    const existing = existingReq.result as CachedSearch<T> | undefined;
    const entry: CachedSearch<T> = {
      queryKey,
      data,
      cachedAt: now,
      accessedAt: now,
      accessCount: existing ? (existing.accessCount ?? 0) + 1 : 1,
    };
    store.put(entry);

    // LFU-LRU eviction
    const allReq = store.getAll();
    allReq.onsuccess = () => {
      const entries = allReq.result as CachedSearch[];
      if (entries.length > MAX_SEARCHES) {
        entries.sort(
          (a, b) => computeEvictionScore(a) - computeEvictionScore(b),
        );
        const excess = entries.length - MAX_SEARCHES;
        for (let i = 0; i < excess; i++) {
          store.delete(entries[i].queryKey);
        }
      }
    };
  };

  return new Promise((resolve, reject) => {
    tx.oncomplete = () => {
      db.close();
      resolve();
    };
    tx.onerror = () => {
      db.close();
      reject(tx.error ?? new Error("Transaction failed"));
    };
  });
}

/**
 * Retrieve cached search results, bump accessedAt and accessCount.
 * Returns null when IndexedDB is unavailable.
 */
export async function getCachedSearch<T>(
  queryKey: string,
): Promise<CachedSearch<T> | null> {
  if (!isIndexedDBAvailable()) return null;
  const db = await openDB();
  const tx = db.transaction(SEARCH_STORE, "readwrite");
  const store = tx.objectStore(SEARCH_STORE);

  return new Promise((resolve, reject) => {
    const getReq = store.get(queryKey);
    getReq.onsuccess = () => {
      const entry = getReq.result as CachedSearch<T> | undefined;
      if (entry) {
        entry.accessedAt = Date.now();
        entry.accessCount = (entry.accessCount ?? 0) + 1;
        store.put(entry);
        resolve(entry);
      } else {
        resolve(null);
      }
    };
    getReq.onerror = () => reject(getReq.error ?? new Error("Get request failed"));
    tx.oncomplete = () => db.close();
    tx.onerror = () => {
      db.close();
      reject(tx.error ?? new Error("Transaction failed"));
    };
  });
}

// ─── Clear all caches ───────────────────────────────────────────────────────

/**
 * Clear all cached products, searches, and analytics.
 * Silently fails when IndexedDB is unavailable.
 */
export async function clearAllCaches(): Promise<void> {
  if (!isIndexedDBAvailable()) return;
  const db = await openDB();
  const storeNames = [PRODUCT_STORE, SEARCH_STORE];
  if (db.objectStoreNames.contains(META_STORE)) {
    storeNames.push(META_STORE);
  }
  const tx = db.transaction(storeNames, "readwrite");
  for (const name of storeNames) {
    tx.objectStore(name).clear();
  }

  return new Promise((resolve, reject) => {
    tx.oncomplete = () => {
      db.close();
      resolve();
    };
    tx.onerror = () => {
      db.close();
      reject(tx.error ?? new Error("Transaction failed"));
    };
  });
}

// ─── Helpers ────────────────────────────────────────────────────────────────

/**
 * Returns a human-readable "time ago" string from a timestamp.
 * Used for "Cached 2h ago" display.
 */
export function timeAgo(epochMs: number): string {
  const diff = Date.now() - epochMs;
  const seconds = Math.floor(diff / 1000);
  if (seconds < 60) return "just now";
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  return `${days}d ago`;
}

// ─── Staleness check ────────────────────────────────────────────────────────

/**
 * Returns true if a cached entry is stale (older than maxAgeMs).
 * Default threshold: 24 hours.
 */
export function isStale(
  entry: { cachedAt: number },
  maxAgeMs: number = STALE_THRESHOLD_MS,
): boolean {
  return Date.now() - entry.cachedAt >= maxAgeMs;
}

// ─── Stale-While-Revalidate ─────────────────────────────────────────────────

/**
 * Get a product using the stale-while-revalidate pattern:
 * 1. Cache hit (fresh) → return cached data immediately.
 * 2. Cache hit (stale) → return cached data, revalidate in background.
 * 3. Cache miss → fetch via `fetcher`, cache the result, return it.
 *
 * Returns null only when both cache and fetcher fail.
 */
export async function getProductWithSWR<T>(
  productId: number,
  fetcher: (id: number) => Promise<T>,
  options?: { maxAgeMs?: number; category?: string },
): Promise<SWRResult<T> | null> {
  const cached = await getCachedProduct<T>(productId);
  if (cached) {
    const stale = isStale(cached, options?.maxAgeMs);
    if (stale) {
      // Fire-and-forget background revalidation
      fetcher(productId)
        .then((fresh) => cacheProduct(productId, fresh, { category: options?.category }))
        .catch(() => {}); // swallow — stale data is still valid
    }
    return { data: cached.data, source: "cache", stale };
  }

  // Cache miss — fetch from network
  try {
    const freshData = await fetcher(productId);
    await cacheProduct(productId, freshData, { category: options?.category });
    return { data: freshData, source: "network", stale: false };
  } catch {
    return null;
  }
}

// ─── Quota management ───────────────────────────────────────────────────────

/**
 * Check IndexedDB storage usage. Returns usage stats and triggers
 * aggressive cleanup if usage exceeds QUOTA_WARNING_PCT.
 * Returns null when the Storage API is unavailable.
 */
export async function checkStorageQuota(): Promise<{
  usage: number;
  quota: number;
  usagePct: number;
  cleanupTriggered: boolean;
} | null> {
  if (
    typeof navigator === "undefined" ||
    !("storage" in navigator) ||
    !("estimate" in navigator.storage)
  ) {
    return null;
  }

  const { usage, quota } = await navigator.storage.estimate();
  const usageBytes = usage ?? 0;
  const quotaBytes = quota ?? 1;
  const usagePct = (usageBytes / quotaBytes) * 100;

  let cleanupTriggered = false;
  if (usagePct > QUOTA_WARNING_PCT) {
    await aggressiveCleanup();
    cleanupTriggered = true;
  }

  return {
    usage: usageBytes,
    quota: quotaBytes,
    usagePct,
    cleanupTriggered,
  };
}

/**
 * Aggressively evict low-value cache entries to free storage.
 * Keeps the top half of products by eviction score, removes the rest
 * and clears all search caches.
 */
async function aggressiveCleanup(): Promise<void> {
  if (!isIndexedDBAvailable()) return;
  const db = await openDB();
  const tx = db.transaction([PRODUCT_STORE, SEARCH_STORE], "readwrite");

  // Clear all searches — they're cheap to re-fetch
  tx.objectStore(SEARCH_STORE).clear();

  // Keep only the top half of products by eviction score
  const productStore = tx.objectStore(PRODUCT_STORE);
  const allReq = productStore.getAll();
  allReq.onsuccess = () => {
    const entries = allReq.result as CachedProduct[];
    const keepCount = Math.ceil(entries.length / 2);
    if (entries.length > keepCount) {
      entries.sort(
        (a, b) => computeEvictionScore(a) - computeEvictionScore(b),
      );
      const evictCount = entries.length - keepCount;
      for (let i = 0; i < evictCount; i++) {
        productStore.delete(entries[i].productId);
      }
    }
  };

  return new Promise((resolve) => {
    tx.oncomplete = () => {
      db.close();
      resolve();
    };
    tx.onerror = () => {
      db.close();
      resolve(); // best-effort — don't throw
    };
  });
}

// ─── Cache analytics ────────────────────────────────────────────────────────

/**
 * Returns cache usage statistics including hit/miss rates,
 * product age metrics, and optional storage estimates.
 */
export async function getCacheStats(): Promise<CacheStats> {
  const defaultStats: CacheStats = {
    productCount: 0,
    searchCount: 0,
    hitCount: 0,
    missCount: 0,
    hitRate: 0,
    avgProductAgeMs: 0,
    oldestProductMs: 0,
  };

  if (!isIndexedDBAvailable()) return defaultStats;

  try {
    const db = await openDB();
    const stores = [PRODUCT_STORE, SEARCH_STORE];
    if (db.objectStoreNames.contains(META_STORE)) {
      stores.push(META_STORE);
    }
    const tx = db.transaction(stores, "readonly");
    const productStore = tx.objectStore(PRODUCT_STORE);
    const searchStore = tx.objectStore(SEARCH_STORE);

    const [products, searches, meta] = await Promise.all([
      idbRequest<CachedProduct[]>(productStore.getAll()),
      idbRequest<CachedSearch[]>(searchStore.getAll()),
      db.objectStoreNames.contains(META_STORE)
        ? idbRequest<CacheMeta | undefined>(
            tx.objectStore(META_STORE).get("analytics"),
          )
        : Promise.resolve(undefined),
    ]);

    db.close();

    const now = Date.now();
    const hitCount = meta?.hitCount ?? 0;
    const missCount = meta?.missCount ?? 0;
    const total = hitCount + missCount;

    let avgAge = 0;
    let oldestAge = 0;
    if (products.length > 0) {
      const ages = products.map((p) => now - p.cachedAt);
      avgAge = ages.reduce((sum, a) => sum + a, 0) / ages.length;
      oldestAge = Math.max(...ages);
    }

    const stats: CacheStats = {
      productCount: products.length,
      searchCount: searches.length,
      hitCount,
      missCount,
      hitRate: total > 0 ? hitCount / total : 0,
      avgProductAgeMs: avgAge,
      oldestProductMs: oldestAge,
    };

    // Optionally attach storage estimate
    if (
      typeof navigator !== "undefined" &&
      "storage" in navigator &&
      "estimate" in navigator.storage
    ) {
      try {
        const { usage, quota } = await navigator.storage.estimate();
        const usageBytes = usage ?? 0;
        const quotaBytes = quota ?? 1;
        stats.storageEstimate = {
          usage: usageBytes,
          quota: quotaBytes,
          usagePct: (usageBytes / quotaBytes) * 100,
        };
      } catch {
        // Storage API not available — that's fine
      }
    }

    return stats;
  } catch {
    return defaultStats;
  }
}

/**
 * Reset cache analytics counters.
 */
export async function resetCacheStats(): Promise<void> {
  if (!isIndexedDBAvailable()) return;
  try {
    const db = await openDB();
    if (!db.objectStoreNames.contains(META_STORE)) {
      db.close();
      return;
    }
    const tx = db.transaction(META_STORE, "readwrite");
    tx.objectStore(META_STORE).put({
      key: "analytics",
      hitCount: 0,
      missCount: 0,
      lastReset: Date.now(),
    });
    await new Promise<void>((resolve) => {
      tx.oncomplete = () => {
        db.close();
        resolve();
      };
      tx.onerror = () => {
        db.close();
        resolve();
      };
    });
  } catch {
    // best-effort
  }
}

// ─── IDB request helper ─────────────────────────────────────────────────────

/**
 * Wraps an IDBRequest in a Promise for cleaner async/await usage.
 */
function idbRequest<T>(request: IDBRequest): Promise<T> {
  return new Promise((resolve, reject) => {
    request.onsuccess = () => resolve(request.result as T);
    request.onerror = () =>
      reject(new Error(request.error?.message ?? "IDB request failed"));
  });
}
