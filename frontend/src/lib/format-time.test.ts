import { describe, expect, it } from "vitest";

import { formatRelativeTime } from "@/lib/format-time";

// ─── formatRelativeTime ─────────────────────────────────

describe("formatRelativeTime", () => {
  const base = new Date("2026-03-20T12:00:00Z");

  it("returns 'just now' for less than 1 minute ago", () => {
    const date = new Date(base.getTime() - 30 * 1000);
    expect(formatRelativeTime(date, base)).toBe("just now");
  });

  it("returns 'just now' for 0 seconds ago", () => {
    expect(formatRelativeTime(base, base)).toBe("just now");
  });

  it("returns minutes ago for 1–59 minutes", () => {
    const date = new Date(base.getTime() - 5 * 60 * 1000);
    expect(formatRelativeTime(date, base)).toBe("5m ago");
  });

  it("returns hours ago for 1–23 hours", () => {
    const date = new Date(base.getTime() - 3 * 3600 * 1000);
    expect(formatRelativeTime(date, base)).toBe("3h ago");
  });

  it("returns days ago for 1–6 days", () => {
    const date = new Date(base.getTime() - 4 * 86400 * 1000);
    expect(formatRelativeTime(date, base)).toBe("4d ago");
  });

  it("returns short locale date for 7+ days ago", () => {
    const date = new Date(base.getTime() - 10 * 86400 * 1000);
    const result = formatRelativeTime(date, base);
    // locale-dependent, but should not be a relative format
    expect(result).not.toContain("ago");
    expect(result).not.toBe("just now");
  });

  it("returns 'just now' for future dates (clamped to 0)", () => {
    const future = new Date(base.getTime() + 60 * 1000);
    expect(formatRelativeTime(future, base)).toBe("just now");
  });

  it("handles boundary: exactly 60 seconds → 1m ago", () => {
    const date = new Date(base.getTime() - 60 * 1000);
    expect(formatRelativeTime(date, base)).toBe("1m ago");
  });

  it("handles boundary: exactly 1 hour → 1h ago", () => {
    const date = new Date(base.getTime() - 3600 * 1000);
    expect(formatRelativeTime(date, base)).toBe("1h ago");
  });

  it("handles boundary: exactly 1 day → 1d ago", () => {
    const date = new Date(base.getTime() - 86400 * 1000);
    expect(formatRelativeTime(date, base)).toBe("1d ago");
  });

  it("handles boundary: exactly 7 days → short date (not 7d ago)", () => {
    const date = new Date(base.getTime() - 7 * 86400 * 1000);
    const result = formatRelativeTime(date, base);
    expect(result).not.toContain("d ago");
  });
});
