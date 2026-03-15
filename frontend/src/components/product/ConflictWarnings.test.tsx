import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string, params?: Record<string, string>) => {
      if (params) {
        let result = key;
        for (const [k, v] of Object.entries(params)) {
          result += ` ${k}=${v}`;
        }
        return result;
      }
      return key;
    },
  }),
}));

import type { ConflictItem } from "@/lib/types";
import { ConflictWarnings } from "./ConflictWarnings";

// ─── Fixtures ───────────────────────────────────────────────────────────────

const HIGH_CONFLICT: ConflictItem = {
  rule: "M1",
  key: "nova_ultra_processed",
  severity: "high",
  message: "NOVA 4 conflicts with score band",
};

const MEDIUM_CONFLICT: ConflictItem = {
  rule: "M3a",
  key: "high_sugar_flag",
  severity: "medium",
  message: "High sugar flag conflicts with good headline",
};

const INFO_CONFLICT: ConflictItem = {
  rule: "M4",
  key: "nutri_score_favorable",
  severity: "info",
  message: "Nutri-Score A/B signals some positives",
};

const NUTRI_POOR_CONFLICT: ConflictItem = {
  rule: "M2",
  key: "nutri_score_poor",
  severity: "high",
  message: "Nutri-Score E conflicts with score band",
};

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ConflictWarnings", () => {
  it("returns null when conflicts array is empty", () => {
    const { container } = render(
      <ConflictWarnings conflicts={[]} />,
    );
    expect(container.firstChild).toBeNull();
  });

  it("renders the section title", () => {
    render(<ConflictWarnings conflicts={[HIGH_CONFLICT]} />);
    expect(screen.getByText("conflicts.title")).toBeInTheDocument();
  });

  it("renders a single high-severity conflict", () => {
    render(<ConflictWarnings conflicts={[HIGH_CONFLICT]} />);
    expect(
      screen.getByText("conflicts.nova_ultra_processed"),
    ).toBeInTheDocument();
    expect(screen.getByTestId("conflict-warnings")).toBeInTheDocument();
  });

  it("renders multiple conflicts", () => {
    render(
      <ConflictWarnings
        conflicts={[HIGH_CONFLICT, MEDIUM_CONFLICT, INFO_CONFLICT]}
      />,
    );
    expect(
      screen.getByText("conflicts.nova_ultra_processed"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("conflicts.high_sugar_flag"),
    ).toBeInTheDocument();
    // nutri_score_favorable gets grade interpolation → appended by mock t
    expect(
      screen.getByText("conflicts.nutri_score_favorable grade=?"),
    ).toBeInTheDocument();
  });

  // ── Severity styling ──────────────────────────────────────────────────────

  it("applies warning styling for high severity", () => {
    render(<ConflictWarnings conflicts={[HIGH_CONFLICT]} />);
    const container = screen
      .getByText("conflicts.nova_ultra_processed")
      .closest("div[class*='border']");
    expect(container?.className).toContain("bg-warning");
  });

  it("applies amber styling for medium severity", () => {
    render(<ConflictWarnings conflicts={[MEDIUM_CONFLICT]} />);
    const container = screen
      .getByText("conflicts.high_sugar_flag")
      .closest("div[class*='border']");
    expect(container?.className).toContain("bg-amber");
  });

  it("applies blue styling for info severity", () => {
    render(<ConflictWarnings conflicts={[INFO_CONFLICT]} />);
    const container = screen
      .getByText("conflicts.nutri_score_favorable grade=?")
      .closest("div[class*='border']");
    expect(container?.className).toContain("bg-blue");
  });

  // ── Grade interpolation ───────────────────────────────────────────────────

  it("interpolates nutri-score grade for nutri_score_poor key", () => {
    render(
      <ConflictWarnings
        conflicts={[NUTRI_POOR_CONFLICT]}
        nutriScoreLabel="E"
      />,
    );
    // t("conflicts.nutri_score_poor", { grade: "E" }) → "conflicts.nutri_score_poor grade=E"
    expect(
      screen.getByText("conflicts.nutri_score_poor grade=E"),
    ).toBeInTheDocument();
  });

  it("interpolates nutri-score grade for nutri_score_favorable key", () => {
    render(
      <ConflictWarnings
        conflicts={[INFO_CONFLICT]}
        nutriScoreLabel="A"
      />,
    );
    expect(
      screen.getByText("conflicts.nutri_score_favorable grade=A"),
    ).toBeInTheDocument();
  });

  it("falls back to '?' when nutriScoreLabel is not provided", () => {
    render(<ConflictWarnings conflicts={[NUTRI_POOR_CONFLICT]} />);
    expect(
      screen.getByText("conflicts.nutri_score_poor grade=?"),
    ).toBeInTheDocument();
  });
});
