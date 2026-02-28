import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import {
  FreshnessIndicator,
  getDaysSince,
  getFreshnessStatus,
} from "./FreshnessIndicator";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string, params?: Record<string, string | number>) => {
      const map: Record<string, string> = {
        "trust.freshness.fresh": `Verified ${params?.days ?? 0}d ago`,
        "trust.freshness.aging": `Data may be outdated (${params?.days ?? 0}d)`,
        "trust.freshness.stale": `Stale — last verified ${params?.days ?? 0}d ago`,
        "trust.freshness.tooltipDate": `Last verified: ${params?.date ?? ""}`,
        "trust.freshness.ariaLabel": `Data freshness: ${params?.status ?? ""}`,
      };
      return map[key] ?? key;
    },
  }),
}));

// ─── Helper: create ISO date N days ago ─────────────────────────────────────

function daysAgo(n: number): string {
  const d = new Date();
  d.setDate(d.getDate() - n);
  return d.toISOString();
}

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("FreshnessIndicator", () => {
  beforeEach(() => vi.clearAllMocks());

  // ─── Null/undefined handling ────────────────────────────────────────────

  it("renders nothing when lastVerifiedAt is null", () => {
    const { container } = render(<FreshnessIndicator lastVerifiedAt={null} />);
    expect(container.innerHTML).toBe("");
  });

  it("renders nothing when lastVerifiedAt is undefined", () => {
    const { container } = render(
      <FreshnessIndicator lastVerifiedAt={undefined} />,
    );
    expect(container.innerHTML).toBe("");
  });

  it("renders nothing when lastVerifiedAt is empty string", () => {
    const { container } = render(<FreshnessIndicator lastVerifiedAt="" />);
    expect(container.innerHTML).toBe("");
  });

  // ─── Fresh (≤7 days by default) ────────────────────────────────────────

  it("renders fresh status for date 3 days ago", () => {
    render(<FreshnessIndicator lastVerifiedAt={daysAgo(3)} />);
    expect(screen.getByText(/Verified 3d ago/)).toBeTruthy();
  });

  it("renders fresh status for date 7 days ago (boundary)", () => {
    render(<FreshnessIndicator lastVerifiedAt={daysAgo(7)} />);
    expect(screen.getByText(/Verified 7d ago/)).toBeTruthy();
  });

  // ─── Aging (8–30 days by default) ──────────────────────────────────────

  it("renders aging status for date 15 days ago", () => {
    render(<FreshnessIndicator lastVerifiedAt={daysAgo(15)} />);
    expect(screen.getByText(/Data may be outdated \(15d\)/)).toBeTruthy();
  });

  it("renders aging status for date 8 days ago (boundary)", () => {
    render(<FreshnessIndicator lastVerifiedAt={daysAgo(8)} />);
    expect(screen.getByText(/Data may be outdated \(8d\)/)).toBeTruthy();
  });

  it("renders aging status for date 30 days ago (boundary)", () => {
    render(<FreshnessIndicator lastVerifiedAt={daysAgo(30)} />);
    expect(screen.getByText(/Data may be outdated \(30d\)/)).toBeTruthy();
  });

  // ─── Stale (>30 days by default) ───────────────────────────────────────

  it("renders stale status for date 60 days ago", () => {
    render(<FreshnessIndicator lastVerifiedAt={daysAgo(60)} />);
    expect(screen.getByText(/Stale — last verified 60d ago/)).toBeTruthy();
  });

  it("renders stale status for date 31 days ago (boundary)", () => {
    render(<FreshnessIndicator lastVerifiedAt={daysAgo(31)} />);
    expect(screen.getByText(/Stale — last verified 31d ago/)).toBeTruthy();
  });

  // ─── Custom thresholds ─────────────────────────────────────────────────

  it("respects custom freshDays threshold", () => {
    // 15 days ago with freshDays=20 → still fresh
    render(<FreshnessIndicator lastVerifiedAt={daysAgo(15)} freshDays={20} />);
    expect(screen.getByText(/Verified 15d ago/)).toBeTruthy();
  });

  it("respects custom agingDays threshold", () => {
    // 50 days ago with agingDays=60 → aging (not stale)
    render(<FreshnessIndicator lastVerifiedAt={daysAgo(50)} agingDays={60} />);
    expect(screen.getByText(/Data may be outdated \(50d\)/)).toBeTruthy();
  });

  it("applies both custom thresholds together", () => {
    // 5 days ago with freshDays=3, agingDays=10 → aging
    render(
      <FreshnessIndicator
        lastVerifiedAt={daysAgo(5)}
        freshDays={3}
        agingDays={10}
      />,
    );
    expect(screen.getByText(/Data may be outdated \(5d\)/)).toBeTruthy();
  });

  // ─── Freshness ring ───────────────────────────────────────────────────

  it("renders freshness ring SVG", () => {
    render(<FreshnessIndicator lastVerifiedAt={daysAgo(3)} />);
    expect(screen.getByTestId("freshness-ring")).toBeTruthy();
  });

  it("ring has two circle elements (track + progress)", () => {
    const { container } = render(
      <FreshnessIndicator lastVerifiedAt={daysAgo(3)} />,
    );
    const ring = screen.getByTestId("freshness-ring");
    const circles = ring.querySelectorAll("circle");
    expect(circles.length).toBe(2);
  });

  // ─── Accessibility ──────────────────────────────────────────────────────

  it("has role=status", () => {
    render(<FreshnessIndicator lastVerifiedAt={daysAgo(5)} />);
    expect(screen.getByRole("status")).toBeTruthy();
  });

  it("has aria-label with freshness status", () => {
    render(<FreshnessIndicator lastVerifiedAt={daysAgo(5)} />);
    const el = screen.getByRole("status");
    expect(el.getAttribute("aria-label")).toContain("Data freshness:");
  });

  it("has tooltip with date via title attribute", () => {
    render(<FreshnessIndicator lastVerifiedAt={daysAgo(10)} />);
    const el = screen.getByRole("status");
    expect(el.getAttribute("title")).toContain("Last verified:");
  });

  it("ring SVG is aria-hidden", () => {
    render(<FreshnessIndicator lastVerifiedAt={daysAgo(3)} />);
    const ring = screen.getByTestId("freshness-ring");
    expect(ring.getAttribute("aria-hidden")).toBe("true");
  });

  // ─── Mode variants ────────────────────────────────────────────────────

  it("uses compact text size by default", () => {
    render(<FreshnessIndicator lastVerifiedAt={daysAgo(5)} />);
    expect(screen.getByRole("status").className).toContain("text-xs");
  });

  it("uses full text size for mode=full", () => {
    render(<FreshnessIndicator lastVerifiedAt={daysAgo(5)} mode="full" />);
    expect(screen.getByRole("status").className).toContain("text-sm");
  });
});

// ─── Helper function unit tests ─────────────────────────────────────────────

describe("getDaysSince", () => {
  it("returns 0 for today", () => {
    expect(getDaysSince(new Date().toISOString())).toBe(0);
  });

  it("returns positive number for past dates", () => {
    const d = new Date();
    d.setDate(d.getDate() - 10);
    expect(getDaysSince(d.toISOString())).toBe(10);
  });
});

describe("getFreshnessStatus", () => {
  // Default thresholds (7/30)
  it("returns fresh for 0 days", () => {
    expect(getFreshnessStatus(0, 7, 30)).toBe("fresh");
  });

  it("returns fresh for 7 days (default boundary)", () => {
    expect(getFreshnessStatus(7, 7, 30)).toBe("fresh");
  });

  it("returns aging for 8 days (default boundary)", () => {
    expect(getFreshnessStatus(8, 7, 30)).toBe("aging");
  });

  it("returns aging for 30 days (default boundary)", () => {
    expect(getFreshnessStatus(30, 7, 30)).toBe("aging");
  });

  it("returns stale for 31 days (default boundary)", () => {
    expect(getFreshnessStatus(31, 7, 30)).toBe("stale");
  });

  // Custom thresholds
  it("respects custom thresholds", () => {
    expect(getFreshnessStatus(5, 3, 10)).toBe("aging");
    expect(getFreshnessStatus(2, 3, 10)).toBe("fresh");
    expect(getFreshnessStatus(15, 3, 10)).toBe("stale");
  });
});
