import { describe, it, expect, vi, afterEach } from "vitest";
import { render, screen } from "@testing-library/react";
import {
  DashboardGreeting,
  getTimeOfDay,
  getSeasonKey,
} from "./DashboardGreeting";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string, params?: Record<string, string>) => {
      if (params?.name) return `${key}:${params.name}`;
      return key;
    },
  }),
}));

// ─── getTimeOfDay ───────────────────────────────────────────────────────────

describe("getTimeOfDay", () => {
  afterEach(() => {
    vi.useRealTimers();
  });

  it("returns morning for 5:00–11:59", () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date("2026-03-01T08:00:00"));
    expect(getTimeOfDay()).toBe("morning");
  });

  it("returns afternoon for 12:00–16:59", () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date("2026-03-01T14:00:00"));
    expect(getTimeOfDay()).toBe("afternoon");
  });

  it("returns evening for 17:00–21:59", () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date("2026-03-01T19:00:00"));
    expect(getTimeOfDay()).toBe("evening");
  });

  it("returns night for 22:00–4:59", () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date("2026-03-01T23:00:00"));
    expect(getTimeOfDay()).toBe("night");
  });

  it("returns night at 0:00", () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date("2026-03-01T00:00:00"));
    expect(getTimeOfDay()).toBe("night");
  });

  it("returns morning at exactly 5:00", () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date("2026-03-01T05:00:00"));
    expect(getTimeOfDay()).toBe("morning");
  });
});

// ─── getSeasonKey ───────────────────────────────────────────────────────────

describe("getSeasonKey", () => {
  afterEach(() => {
    vi.useRealTimers();
  });

  it("returns spring for March–May", () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date("2026-04-15T12:00:00"));
    expect(getSeasonKey()).toBe("spring");
  });

  it("returns summer for June–August", () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date("2026-07-01T12:00:00"));
    expect(getSeasonKey()).toBe("summer");
  });

  it("returns autumn for September–November", () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date("2026-10-01T12:00:00"));
    expect(getSeasonKey()).toBe("autumn");
  });

  it("returns winter for December–February", () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date("2026-01-15T12:00:00"));
    expect(getSeasonKey()).toBe("winter");
  });

  it("returns winter for December", () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date("2026-12-25T12:00:00"));
    expect(getSeasonKey()).toBe("winter");
  });
});

// ─── DashboardGreeting component ────────────────────────────────────────────

describe("DashboardGreeting", () => {
  afterEach(() => {
    vi.useRealTimers();
  });

  it("renders the greeting heading", () => {
    render(<DashboardGreeting />);
    const heading = screen.getByRole("heading", { level: 1 });
    expect(heading).toBeInTheDocument();
  });

  it("shows the subtitle", () => {
    render(<DashboardGreeting />);
    expect(screen.getByText("dashboard.subtitle")).toBeInTheDocument();
  });

  it("shows seasonal nudge", () => {
    render(<DashboardGreeting />);
    expect(screen.getByTestId("seasonal-nudge")).toBeInTheDocument();
  });

  it("includes display name when provided", () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date("2026-03-01T08:00:00"));
    render(<DashboardGreeting displayName="Jan" />);
    const heading = screen.getByRole("heading", { level: 1 });
    expect(heading.textContent).toContain("Jan");
  });

  it("renders without display name", () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date("2026-03-01T08:00:00"));
    render(<DashboardGreeting />);
    const heading = screen.getByRole("heading", { level: 1 });
    expect(heading.textContent).toContain("dashboard.greeting.morning");
  });
});
