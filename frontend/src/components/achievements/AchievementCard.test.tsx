import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { AchievementCard } from "./AchievementCard";
import type { AchievementDef } from "@/lib/types";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => key,
  }),
}));

// ─── Fixtures ───────────────────────────────────────────────────────────────

const unlockedAchievement: AchievementDef = {
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
};

const lockedAchievement: AchievementDef = {
  id: "a2",
  slug: "scan_50",
  category: "exploration",
  title_key: "achievement.scan_50.title",
  desc_key: "achievement.scan_50.desc",
  icon: "🏅",
  threshold: 50,
  country: null,
  sort_order: 30,
  progress: 25,
  unlocked_at: null,
};

const zeroProgressAchievement: AchievementDef = {
  id: "a3",
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
};

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("AchievementCard", () => {
  it("renders unlocked achievement with earned badge", () => {
    render(<AchievementCard achievement={unlockedAchievement} />);

    expect(screen.getByText("🔍")).toBeInTheDocument();
    expect(
      screen.getByText("achievement.first_scan.title"),
    ).toBeInTheDocument();
    expect(screen.getByText("achievement.first_scan.desc")).toBeInTheDocument();
    expect(screen.getByText("achievements.earned")).toBeInTheDocument();
  });

  it("does not show progress bar for unlocked achievement", () => {
    render(<AchievementCard achievement={unlockedAchievement} />);

    expect(
      screen.queryByTestId("achievement-progress"),
    ).not.toBeInTheDocument();
  });

  it("renders locked achievement with progress bar", () => {
    render(<AchievementCard achievement={lockedAchievement} />);

    expect(screen.getByText("🏅")).toBeInTheDocument();
    expect(screen.getByText("achievement.scan_50.title")).toBeInTheDocument();
    expect(screen.getByTestId("achievement-progress")).toHaveTextContent(
      "25 / 50",
    );
  });

  it("shows 50% progress for 25/50", () => {
    render(<AchievementCard achievement={lockedAchievement} />);

    const progressBar = screen.getByRole("progressbar");
    expect(progressBar).toHaveAttribute("value", "50");
  });

  it("shows 0% progress for zero-progress achievement", () => {
    render(<AchievementCard achievement={zeroProgressAchievement} />);

    const progressBar = screen.getByRole("progressbar");
    expect(progressBar).toHaveAttribute("value", "0");
    expect(screen.getByTestId("achievement-progress")).toHaveTextContent(
      "0 / 1",
    );
  });

  it("applies grayscale styling to locked achievements", () => {
    const { container } = render(
      <AchievementCard achievement={lockedAchievement} />,
    );

    const card = container.firstElementChild;
    expect(card?.className).toContain("grayscale");
  });

  it("applies brand styling to unlocked achievements", () => {
    const { container } = render(
      <AchievementCard achievement={unlockedAchievement} />,
    );

    const card = container.firstElementChild;
    expect(card?.className).toContain("border-brand/30");
  });

  it("has proper test ID based on slug", () => {
    render(<AchievementCard achievement={unlockedAchievement} />);

    expect(
      screen.getByTestId("achievement-card-first_scan"),
    ).toBeInTheDocument();
  });

  it("renders decorative icon as hidden from accessibility tree", () => {
    render(<AchievementCard achievement={unlockedAchievement} />);

    const icon = screen.getByText("🔍");
    expect(icon).toHaveAttribute("aria-hidden", "true");
    expect(icon).toBeInTheDocument();
  });

  it("caps progress percentage at 100%", () => {
    const overAchievement: AchievementDef = {
      ...lockedAchievement,
      progress: 100,
      threshold: 50,
    };
    render(<AchievementCard achievement={overAchievement} />);

    const progressBar = screen.getByRole("progressbar");
    expect(progressBar).toHaveAttribute("value", "100");
  });
});
