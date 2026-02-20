import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { AchievementGrid } from "./AchievementGrid";
import type { AchievementDef } from "@/lib/types";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => key,
  }),
}));

// ─── Fixtures ───────────────────────────────────────────────────────────────

const mockAchievements: AchievementDef[] = [
  {
    id: "a1",
    slug: "first_scan",
    category: "exploration",
    title_key: "achievement.first_scan.title",
    desc_key: "achievement.first_scan.desc",
    icon: "🔍",
    threshold: 1,
    country: null,
    sort_order: 10,
    progress: 1,
    unlocked_at: "2026-02-20T12:00:00Z",
  },
  {
    id: "a2",
    slug: "scan_10",
    category: "exploration",
    title_key: "achievement.scan_10.title",
    desc_key: "achievement.scan_10.desc",
    icon: "📱",
    threshold: 10,
    country: null,
    sort_order: 20,
    progress: 5,
    unlocked_at: null,
  },
  {
    id: "a3",
    slug: "first_low_score",
    category: "health",
    title_key: "achievement.first_low_score.title",
    desc_key: "achievement.first_low_score.desc",
    icon: "💚",
    threshold: 1,
    country: null,
    sort_order: 10,
    progress: 1,
    unlocked_at: "2026-02-21T10:00:00Z",
  },
  {
    id: "a4",
    slug: "first_list",
    category: "engagement",
    title_key: "achievement.first_list.title",
    desc_key: "achievement.first_list.desc",
    icon: "📋",
    threshold: 1,
    country: null,
    sort_order: 10,
    progress: 0,
    unlocked_at: null,
  },
  {
    id: "a5",
    slug: "read_learn_page",
    category: "mastery",
    title_key: "achievement.read_learn_page.title",
    desc_key: "achievement.read_learn_page.desc",
    icon: "📖",
    threshold: 1,
    country: null,
    sort_order: 10,
    progress: 0,
    unlocked_at: null,
  },
];

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("AchievementGrid", () => {
  it("renders the grid container", () => {
    render(<AchievementGrid achievements={mockAchievements} />);

    expect(screen.getByTestId("achievement-grid")).toBeInTheDocument();
  });

  it("renders category headings for all 4 categories", () => {
    render(<AchievementGrid achievements={mockAchievements} />);

    expect(
      screen.getByText("achievements.category.exploration"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("achievements.category.health"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("achievements.category.engagement"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("achievements.category.mastery"),
    ).toBeInTheDocument();
  });

  it("renders all achievement cards", () => {
    render(<AchievementGrid achievements={mockAchievements} />);

    expect(
      screen.getByTestId("achievement-card-first_scan"),
    ).toBeInTheDocument();
    expect(
      screen.getByTestId("achievement-card-scan_10"),
    ).toBeInTheDocument();
    expect(
      screen.getByTestId("achievement-card-first_low_score"),
    ).toBeInTheDocument();
    expect(
      screen.getByTestId("achievement-card-first_list"),
    ).toBeInTheDocument();
    expect(
      screen.getByTestId("achievement-card-read_learn_page"),
    ).toBeInTheDocument();
  });

  it("groups exploration achievements together", () => {
    render(<AchievementGrid achievements={mockAchievements} />);

    const explorationSection = screen
      .getByText("achievements.category.exploration")
      .closest("section");
    expect(explorationSection).toBeInTheDocument();
    expect(
      explorationSection?.querySelector(
        '[data-testid="achievement-card-first_scan"]',
      ),
    ).toBeInTheDocument();
    expect(
      explorationSection?.querySelector(
        '[data-testid="achievement-card-scan_10"]',
      ),
    ).toBeInTheDocument();
  });

  it("does not render empty categories", () => {
    const explorationOnly = mockAchievements.filter(
      (a) => a.category === "exploration",
    );
    render(<AchievementGrid achievements={explorationOnly} />);

    expect(
      screen.getByText("achievements.category.exploration"),
    ).toBeInTheDocument();
    expect(
      screen.queryByText("achievements.category.health"),
    ).not.toBeInTheDocument();
    expect(
      screen.queryByText("achievements.category.engagement"),
    ).not.toBeInTheDocument();
    expect(
      screen.queryByText("achievements.category.mastery"),
    ).not.toBeInTheDocument();
  });

  it("renders empty when no achievements provided", () => {
    render(<AchievementGrid achievements={[]} />);

    const grid = screen.getByTestId("achievement-grid");
    expect(grid).toBeInTheDocument();
    // No category headings
    expect(
      screen.queryByText("achievements.category.exploration"),
    ).not.toBeInTheDocument();
  });

  it("renders category icons", () => {
    render(<AchievementGrid achievements={mockAchievements} />);

    // Category icons are rendered as role="img" with aria-hidden
    const explorationHeading = screen.getByText(
      "achievements.category.exploration",
    );
    const parent = explorationHeading.parentElement;
    expect(parent?.textContent).toContain("🧭");
  });
});
