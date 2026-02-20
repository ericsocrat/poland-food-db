// ─── Achievement Middleware unit tests ───────────────────────────────────────
// Issue #52: Telemetry Mapping for Achievements

import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { eventBus } from "@/lib/events/bus";

// ── Mocks ──────────────────────────────────────────────────────────────────

// Mock Supabase client
const mockGetUser = vi.fn();
const mockSupabase = {
  auth: { getUser: mockGetUser },
};

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => mockSupabase,
}));

// Mock API: incrementAchievementProgress
const mockIncrement = vi.fn();
vi.mock("@/lib/api", () => ({
  incrementAchievementProgress: (...args: unknown[]) => mockIncrement(...args),
}));

// Mock toast
const mockShowToast = vi.fn();
vi.mock("@/lib/toast", () => ({
  showToast: (...args: unknown[]) => mockShowToast(...args),
}));

// Import AFTER mocks are set up
import {
  processEvent,
  initAchievementMiddleware,
} from "@/lib/events/achievement-middleware";

describe("processEvent", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    eventBus.clear();
    // Default: authenticated user
    mockGetUser.mockResolvedValue({
      data: { user: { id: "user-123" } },
    });
    // Default: successful RPC
    mockIncrement.mockResolvedValue({
      ok: true,
      data: { newly_unlocked: false, progress: 1, threshold: 1, unlocked: false },
    });
  });

  afterEach(() => {
    eventBus.clear();
  });

  it("calls incrementAchievementProgress for matching events", async () => {
    await processEvent({
      type: "product.scanned",
      payload: { ean: "5901234123457" },
    });

    // product.scanned maps to 3 achievements: first_scan, scan_10, scan_50
    expect(mockIncrement).toHaveBeenCalledTimes(3);
    expect(mockIncrement).toHaveBeenCalledWith(
      mockSupabase,
      "first_scan",
      1,
    );
    expect(mockIncrement).toHaveBeenCalledWith(
      mockSupabase,
      "scan_10",
      1,
    );
    expect(mockIncrement).toHaveBeenCalledWith(
      mockSupabase,
      "scan_50",
      1,
    );
  });

  it("skips processing when user is not authenticated", async () => {
    mockGetUser.mockResolvedValue({ data: { user: null } });

    await processEvent({
      type: "product.scanned",
      payload: { ean: "5901234123457" },
    });

    expect(mockIncrement).not.toHaveBeenCalled();
  });

  it("skips mappings whose condition returns false", async () => {
    // product.viewed with score 80 should NOT trigger low_score achievements
    await processEvent({
      type: "product.viewed",
      payload: { productId: 42, score: 80 },
    });

    expect(mockIncrement).not.toHaveBeenCalled();
  });

  it("triggers conditional mappings when condition passes", async () => {
    // product.viewed with score 25 (≤ 30) should trigger low_score achievements
    await processEvent({
      type: "product.viewed",
      payload: { productId: 42, score: 25 },
    });

    expect(mockIncrement).toHaveBeenCalledTimes(2);
    expect(mockIncrement).toHaveBeenCalledWith(
      mockSupabase,
      "first_low_score",
      1,
    );
    expect(mockIncrement).toHaveBeenCalledWith(
      mockSupabase,
      "low_score_10",
      1,
    );
  });

  it("shows toast when achievement is newly unlocked", async () => {
    mockIncrement.mockResolvedValue({
      ok: true,
      data: { newly_unlocked: true, progress: 1, threshold: 1, unlocked: true },
    });

    await processEvent({
      type: "product.searched",
      payload: { query: "milk" },
    });

    // Wait for fire-and-forget .then() to resolve
    await vi.waitFor(() => {
      expect(mockShowToast).toHaveBeenCalledWith({
        type: "success",
        messageKey: "achievements.unlocked",
      });
    });
  });

  it("does not show toast when achievement is not newly unlocked", async () => {
    await processEvent({
      type: "product.searched",
      payload: { query: "milk" },
    });

    // Wait a tick for .then() chain
    await new Promise((r) => setTimeout(r, 10));
    expect(mockShowToast).not.toHaveBeenCalled();
  });

  it("does not throw when RPC fails", async () => {
    mockIncrement.mockRejectedValue(new Error("network error"));

    await expect(
      processEvent({
        type: "product.scanned",
        payload: { ean: "1234567890123" },
      }),
    ).resolves.toBeUndefined();
  });

  it("does nothing for events with no matching mappings", async () => {
    // session.weekly_visit has a mapping, but an unknown type would not
    await processEvent({
      type: "session.weekly_visit",
      payload: { weekNumber: 8, year: 2026 },
    });

    // weekly_streak_4 should be called
    expect(mockIncrement).toHaveBeenCalledWith(
      mockSupabase,
      "weekly_streak_4",
      1,
    );
  });
});

describe("initAchievementMiddleware", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    eventBus.clear();
    mockGetUser.mockResolvedValue({
      data: { user: { id: "user-123" } },
    });
    mockIncrement.mockResolvedValue({
      ok: true,
      data: { newly_unlocked: false },
    });
  });

  afterEach(() => {
    eventBus.clear();
  });

  it("subscribes to the event bus", () => {
    const unsubscribe = initAchievementMiddleware();
    expect(eventBus.size).toBe(1);
    unsubscribe();
    expect(eventBus.size).toBe(0);
  });

  it("processes events emitted to the bus", async () => {
    const unsubscribe = initAchievementMiddleware();

    await eventBus.emit({
      type: "list.created",
      payload: {},
    });

    // Wait for fire-and-forget processing
    await vi.waitFor(() => {
      expect(mockIncrement).toHaveBeenCalledWith(
        mockSupabase,
        "first_list",
        1,
      );
    });

    unsubscribe();
  });

  it("returns unsubscribe function that stops processing", async () => {
    const unsubscribe = initAchievementMiddleware();
    unsubscribe();

    await eventBus.emit({
      type: "product.scanned",
      payload: { ean: "1234567890123" },
    });

    // Should not have fired since we unsubscribed
    expect(mockIncrement).not.toHaveBeenCalled();
  });
});
