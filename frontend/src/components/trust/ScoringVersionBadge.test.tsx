import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import { ScoringVersionBadge } from "./ScoringVersionBadge";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string, params?: Record<string, string | number>) => {
      const map: Record<string, string> = {
        "trust.scoringVersion.label": `Score v${params?.version ?? ""}`,
        "trust.scoringVersion.tooltip": `This product was scored using formula v${params?.version ?? ""} (${params?.factors ?? 9}-factor model).`,
        "trust.scoringVersion.ariaLabel": `Scoring formula version ${params?.version ?? ""}`,
      };
      return map[key] ?? key;
    },
  }),
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ScoringVersionBadge", () => {
  beforeEach(() => vi.clearAllMocks());

  // ─── Null/undefined handling ────────────────────────────────────────────

  it("renders nothing when version is null", () => {
    const { container } = render(<ScoringVersionBadge version={null} />);
    expect(container.innerHTML).toBe("");
  });

  it("renders nothing when version is undefined", () => {
    const { container } = render(<ScoringVersionBadge version={undefined} />);
    expect(container.innerHTML).toBe("");
  });

  it("renders nothing when version is empty string", () => {
    const { container } = render(<ScoringVersionBadge version="" />);
    expect(container.innerHTML).toBe("");
  });

  // ─── Normal rendering ─────────────────────────────────────────────────

  it("renders version label for v3.2", () => {
    render(<ScoringVersionBadge version="3.2" />);
    expect(screen.getByText("Score v3.2")).toBeTruthy();
  });

  it("renders version label for v4.0", () => {
    render(<ScoringVersionBadge version="4.0" />);
    expect(screen.getByText("Score v4.0")).toBeTruthy();
  });

  // ─── Tooltip ──────────────────────────────────────────────────────────

  it("has tooltip with version and factor count", () => {
    render(<ScoringVersionBadge version="3.2" />);
    expect(
      screen.getByTitle(
        "This product was scored using formula v3.2 (9-factor model).",
      ),
    ).toBeTruthy();
  });

  it("uses custom factor count in tooltip", () => {
    render(<ScoringVersionBadge version="4.0" factors={12} />);
    expect(
      screen.getByTitle(
        "This product was scored using formula v4.0 (12-factor model).",
      ),
    ).toBeTruthy();
  });

  // ─── Accessibility ──────────────────────────────────────────────────────

  it("has role=note", () => {
    render(<ScoringVersionBadge version="3.2" />);
    expect(screen.getByRole("note")).toBeTruthy();
  });

  it("has correct aria-label", () => {
    render(<ScoringVersionBadge version="3.2" />);
    expect(screen.getByRole("note").getAttribute("aria-label")).toBe(
      "Scoring formula version 3.2",
    );
  });
});
