/// <reference lib="webworker" />
import { defaultCache } from "@serwist/next/worker";
import type { PrecacheEntry, SerwistGlobalConfig } from "serwist";
import { Serwist } from "serwist";

// This declares the service worker's global scope
declare global {
  interface WorkerGlobalScope extends SerwistGlobalConfig {
    __SW_MANIFEST: (PrecacheEntry | string)[] | undefined;
  }
}

declare const self: ServiceWorkerGlobalScope & typeof globalThis;

// ─── Cache version ──────────────────────────────────────────────────────────
// Bump this whenever a new deployment must invalidate all runtime caches
// (e.g. layout / viewport fixes that are invisible to precache hashing).
const CACHE_VERSION = "v2";

const serwist = new Serwist({
  precacheEntries: self.__SW_MANIFEST,
  skipWaiting: true,
  clientsClaim: true,
  navigationPreload: true,
  runtimeCaching: defaultCache,
  fallbacks: {
    entries: [
      {
        url: "/offline",
        matcher({ request }) {
          return request.destination === "document";
        },
      },
    ],
  },
});

serwist.addEventListeners();

// ─── Purge stale runtime caches on activate ─────────────────────────────────
// Serwist's `skipWaiting` activates the new SW immediately, but does NOT clear
// runtime-cached HTML/CSS/JS from the previous version. Without this, PWA users
// who installed before a layout fix (e.g. PR #92/#94) continue seeing stale
// responses from the old cache.
self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((names) =>
      Promise.all(
        names
          .filter((name) => !name.includes(CACHE_VERSION))
          .map((name) => caches.delete(name)),
      ),
    ),
  );
});
