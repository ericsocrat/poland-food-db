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

  // ─── Fresh (≤30 days) ──────────────────────────────────────────────────

  it("renders fresh status for date 5 days ago", () => {
    render(<FreshnessIndicator lastVerifiedAt={daysAgo(5)} />);
    expect(screen.getByText(/Verified 5d ago/)).toBeTruthy();
  });

  it("renders fresh status for date 30 days ago (boundary)", () => {
    render(<FreshnessIndicator lastVerifiedAt={daysAgo(30)} />);
    expect(screen.getByText(/Verified 30d ago/)).toBeTruthy();
  });

  // ─── Aging (31–90 days) ────────────────────────────────────────────────

  it("renders aging status for date 60 days ago", () => {
    render(<FreshnessIndicator lastVerifiedAt={daysAgo(60)} />);
    expect(screen.getByText(/Data may be outdated \(60d\)/)).toBeTruthy();
  });

  it("renders aging status for date 31 days ago (boundary)", () => {
    render(<FreshnessIndicator lastVerifiedAt={daysAgo(31)} />);
    expect(screen.getByText(/Data may be outdated \(31d\)/)).toBeTruthy();
  });

  // ─── Stale (>90 days) ─────────────────────────────────────────────────

  it("renders stale status for date 120 days ago", () => {
    render(<FreshnessIndicator lastVerifiedAt={daysAgo(120)} />);
    expect(screen.getByText(/Stale — last verified 120d ago/)).toBeTruthy();
  });

  it("renders stale status for date 91 days ago (boundary)", () => {
    render(<FreshnessIndicator lastVerifiedAt={daysAgo(91)} />);
    expect(screen.getByText(/Stale — last verified 91d ago/)).toBeTruthy();
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
  it("returns fresh for 0 days", () => {
    expect(getFreshnessStatus(0)).toBe("fresh");
  });

  it("returns fresh for 30 days", () => {
    expect(getFreshnessStatus(30)).toBe("fresh");
  });

  it("returns aging for 31 days", () => {
    expect(getFreshnessStatus(31)).toBe("aging");
  });

  it("returns aging for 90 days", () => {
    expect(getFreshnessStatus(90)).toBe("aging");
  });

  it("returns stale for 91 days", () => {
    expect(getFreshnessStatus(91)).toBe("stale");
  });
});
