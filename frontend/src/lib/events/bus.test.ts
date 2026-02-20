// ─── EventBus unit tests ─────────────────────────────────────────────────────
// Issue #52: Telemetry Mapping for Achievements

import { describe, it, expect, vi, beforeEach } from "vitest";
import { eventBus } from "@/lib/events/bus";
import type { AppEvent } from "@/lib/events/types";

const scanEvent: AppEvent = {
  type: "product.scanned",
  payload: { ean: "5901234123457" },
};

describe("AppEventBus", () => {
  beforeEach(() => {
    eventBus.clear();
  });

  it("emits events to all subscribers", async () => {
    const handler1 = vi.fn();
    const handler2 = vi.fn();
    eventBus.subscribe(handler1);
    eventBus.subscribe(handler2);

    await eventBus.emit(scanEvent);

    expect(handler1).toHaveBeenCalledWith(scanEvent);
    expect(handler2).toHaveBeenCalledWith(scanEvent);
  });

  it("returns an unsubscribe function that removes the handler", async () => {
    const handler = vi.fn();
    const unsubscribe = eventBus.subscribe(handler);

    unsubscribe();
    await eventBus.emit(scanEvent);

    expect(handler).not.toHaveBeenCalled();
  });

  it("does not throw when emitting with no subscribers", async () => {
    await expect(eventBus.emit(scanEvent)).resolves.toBeUndefined();
  });

  it("isolates handler failures — one failing handler does not affect others", async () => {
    const failing = vi.fn().mockRejectedValue(new Error("boom"));
    const passing = vi.fn();
    eventBus.subscribe(failing);
    eventBus.subscribe(passing);

    await eventBus.emit(scanEvent);

    expect(failing).toHaveBeenCalledWith(scanEvent);
    expect(passing).toHaveBeenCalledWith(scanEvent);
  });

  it("handles synchronous exceptions in handlers", async () => {
    const throwing = vi.fn(() => {
      throw new Error("sync boom");
    });
    const passing = vi.fn();
    eventBus.subscribe(throwing);
    eventBus.subscribe(passing);

    await eventBus.emit(scanEvent);

    expect(passing).toHaveBeenCalledWith(scanEvent);
  });

  it("tracks subscriber count via .size", () => {
    expect(eventBus.size).toBe(0);
    const unsub1 = eventBus.subscribe(vi.fn());
    expect(eventBus.size).toBe(1);
    eventBus.subscribe(vi.fn());
    expect(eventBus.size).toBe(2);
    unsub1();
    expect(eventBus.size).toBe(1);
  });

  it("clears all subscribers", () => {
    eventBus.subscribe(vi.fn());
    eventBus.subscribe(vi.fn());
    expect(eventBus.size).toBe(2);

    eventBus.clear();
    expect(eventBus.size).toBe(0);
  });

  it("handles the same handler subscribed twice", async () => {
    const handler = vi.fn();
    eventBus.subscribe(handler);
    eventBus.subscribe(handler);

    // Set uses reference equality, so same fn added twice = 1 entry
    expect(eventBus.size).toBe(1);
    await eventBus.emit(scanEvent);
    expect(handler).toHaveBeenCalledTimes(1);
  });
});
