// ─── AppEventBus — lightweight pub/sub for fire-and-forget events ────────────
// Issue #52: Telemetry Mapping for Achievements

import type { AppEvent } from "./types";

type EventHandler = (event: AppEvent) => void | Promise<void>;

/**
 * Minimal event bus. Handlers run via Promise.allSettled so a single
 * handler failure never blocks the emitter or other handlers.
 */
class AppEventBus {
  private handlers: Set<EventHandler> = new Set();

  /** Subscribe a handler. Returns an unsubscribe function. */
  subscribe(handler: EventHandler): () => void {
    this.handlers.add(handler);
    return () => {
      this.handlers.delete(handler);
    };
  }

  /** Emit an event to all subscribers. Fire-and-forget — never throws. */
  async emit(event: AppEvent): Promise<void> {
    if (this.handlers.size === 0) return;
    await Promise.allSettled(
      [...this.handlers].map((h) => {
        try {
          return h(event);
        } catch {
          return Promise.resolve();
        }
      }),
    );
  }

  /** Number of active subscribers (useful for tests). */
  get size(): number {
    return this.handlers.size;
  }

  /** Remove all subscribers (useful for tests). */
  clear(): void {
    this.handlers.clear();
  }
}

/** Singleton event bus for the entire application. */
export const eventBus = new AppEventBus();
