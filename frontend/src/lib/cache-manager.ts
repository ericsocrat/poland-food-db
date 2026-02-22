// ─── IndexedDB-backed LRU product cache ─────────────────────────────────────
// Stores recently viewed product profiles for offline access.
// Uses the Cache API pattern but backed by IndexedDB for structured data.
//
// - Max 50 products (LRU eviction)
// - Max 5 cached search results
// - Each entry stores a timestamp for "Last updated" display.

const DB_NAME = "fooddb-offline";
const DB_VERSION = 1;
const PRODUCT_STORE = "products";
const SEARCH_STORE = "searches";
const MAX_PRODUCTS = 50;
const MAX_SEARCHES = 5;

export interface CachedProduct<T = unknown> {
  productId: number;
  data: T;
  cachedAt: number; // epoch ms
  accessedAt: number; // epoch ms — for LRU ordering
}

export interface CachedSearch<T = unknown> {
  queryKey: string;
  data: T;
  cachedAt: number;
  accessedAt: number;
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
    request.onupgradeneeded = () => {
      const db = request.result;
      if (!db.objectStoreNames.contains(PRODUCT_STORE)) {
        const store = db.createObjectStore(PRODUCT_STORE, {
          keyPath: "productId",
        });
        store.createIndex("accessedAt", "accessedAt", { unique: false });
      }
      if (!db.objectStoreNames.contains(SEARCH_STORE)) {
        const store = db.createObjectStore(SEARCH_STORE, {
          keyPath: "queryKey",
        });
        store.createIndex("accessedAt", "accessedAt", { unique: false });
      }
    };
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error);
  });
}

// ─── Product cache operations ───────────────────────────────────────────────

/**
 * Cache a product profile. If the cache exceeds MAX_PRODUCTS, the
 * least-recently-accessed entry is evicted.
 * Silently fails when IndexedDB is unavailable.
 */
export async function cacheProduct<T>(
  productId: number,
  data: T,
): Promise<void> {
  if (!isIndexedDBAvailable()) return;
  const db = await openDB();
  const now = Date.now();
  const tx = db.transaction(PRODUCT_STORE, "readwrite");
  const store = tx.objectStore(PRODUCT_STORE);

  const entry: CachedProduct<T> = {
    productId,
    data,
    cachedAt: now,
    accessedAt: now,
  };
  store.put(entry);

  // LRU eviction — count entries > MAX_PRODUCTS and remove oldest
  const countReq = store.count();
  countReq.onsuccess = () => {
    const count = countReq.result;
    if (count > MAX_PRODUCTS) {
      const excess = count - MAX_PRODUCTS;
      const idx = store.index("accessedAt");
      const cursor = idx.openCursor(); // ascending = oldest first
      let deleted = 0;
      cursor.onsuccess = () => {
        const c = cursor.result;
        if (c && deleted < excess) {
          c.delete();
          deleted++;
          c.continue();
        }
      };
    }
  };

  return new Promise((resolve, reject) => {
    tx.oncomplete = () => {
      db.close();
      resolve();
    };
    tx.onerror = () => {
      db.close();
      reject(tx.error);
    };
  });
}

/**
 * Retrieve a cached product and bump its accessedAt for LRU freshness.
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
        // Bump accessedAt
        entry.accessedAt = Date.now();
        store.put(entry);
        resolve(entry);
      } else {
        resolve(null);
      }
    };
    getReq.onerror = () => reject(getReq.error);
    tx.oncomplete = () => db.close();
    tx.onerror = () => {
      db.close();
      reject(tx.error);
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
      reject(req.error);
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
      reject(req.error);
    };
  });
}

// ─── Search cache operations ────────────────────────────────────────────────

/**
 * Cache a search result. Evicts oldest when exceeding MAX_SEARCHES.
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

  const entry: CachedSearch<T> = {
    queryKey,
    data,
    cachedAt: now,
    accessedAt: now,
  };
  store.put(entry);

  const countReq = store.count();
  countReq.onsuccess = () => {
    const count = countReq.result;
    if (count > MAX_SEARCHES) {
      const excess = count - MAX_SEARCHES;
      const idx = store.index("accessedAt");
      const cursor = idx.openCursor();
      let deleted = 0;
      cursor.onsuccess = () => {
        const c = cursor.result;
        if (c && deleted < excess) {
          c.delete();
          deleted++;
          c.continue();
        }
      };
    }
  };

  return new Promise((resolve, reject) => {
    tx.oncomplete = () => {
      db.close();
      resolve();
    };
    tx.onerror = () => {
      db.close();
      reject(tx.error);
    };
  });
}

/**
 * Retrieve cached search results.
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
        store.put(entry);
        resolve(entry);
      } else {
        resolve(null);
      }
    };
    getReq.onerror = () => reject(getReq.error);
    tx.oncomplete = () => db.close();
    tx.onerror = () => {
      db.close();
      reject(tx.error);
    };
  });
}

// ─── Clear all caches ───────────────────────────────────────────────────────

/**
 * Clear all cached products and searches.
 * Silently fails when IndexedDB is unavailable.
 */
export async function clearAllCaches(): Promise<void> {
  if (!isIndexedDBAvailable()) return;
  const db = await openDB();
  const tx = db.transaction([PRODUCT_STORE, SEARCH_STORE], "readwrite");
  tx.objectStore(PRODUCT_STORE).clear();
  tx.objectStore(SEARCH_STORE).clear();

  return new Promise((resolve, reject) => {
    tx.oncomplete = () => {
      db.close();
      resolve();
    };
    tx.onerror = () => {
      db.close();
      reject(tx.error);
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
