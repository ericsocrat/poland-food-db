import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { useState } from "react";
import type { AchievementsResponse } from "@/lib/types";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockGetAchievements = vi.fn();

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

vi.mock("@/lib/api", () => ({
  getAchievements: (...args: unknown[]) => mockGetAchievements(...args),
}));

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => {
      const msgs: Record<string, string> = {
        "achievements.title": "Achievements",
        "achievements.subtitle": "Track your food discovery progress",
        "achievements.overallProgress": "Overall Progress",
        "achievements.earned": "Earned",
        "achievements.errorTitle": "Something went wrong",
        "achievements.errorDescription": "Could not load achievements.",
        "achievements.emptyTitle": "No achievements yet",
        "achievements.emptyDescription": "Start scanning!",
        "achievements.category.exploration": "Exploration",
        "achievements.category.health": "Health",
        "nav.home": "Home",
      };
      return msgs[key] ?? key;
    },
  }),
}));

vi.mock("next/navigation", () => ({
  usePathname: () => "/app/achievements",
  useRouter: () => ({ push: vi.fn(), back: vi.fn() }),
}));

import AchievementsPage from "./page";

// ─── Wrapper ────────────────────────────────────────────────────────────────

function Wrapper({ children }: Readonly<{ children: React.ReactNode }>) {
  const [client] = useState(
    () =>
      new QueryClient({
        defaultOptions: { queries: { retry: false, staleTime: 0 } },
      }),
  );
  return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
}

// ─── Fixtures ───────────────────────────────────────────────────────────────

const mockData: AchievementsResponse = {
  achievements: [
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
  ],
  total: 18,
  unlocked: 2,
};

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("AchievementsPage", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("renders page title and subtitle", async () => {
    mockGetAchievements.mockResolvedValue({ ok: true, data: mockData });

    render(
      <Wrapper>
        <AchievementsPage />
      </Wrapper>,
    );

    expect(screen.getByRole("heading", { name: "Achievements", level: 1 })).toBeInTheDocument();
    expect(
      screen.getByText("Track your food discovery progress"),
    ).toBeInTheDocument();
  });

  it("shows loading skeletons initially", () => {
    mockGetAchievements.mockReturnValue(new Promise(() => {})); // Never resolves

    render(
      <Wrapper>
        <AchievementsPage />
      </Wrapper>,
    );

    expect(screen.getByTestId("achievements-loading")).toBeInTheDocument();
  });

  it("renders overall progress after loading", async () => {
    mockGetAchievements.mockResolvedValue({ ok: true, data: mockData });

    render(
      <Wrapper>
        <AchievementsPage />
      </Wrapper>,
    );

    const summary = await screen.findByTestId("achievements-summary");
    expect(summary).toHaveTextContent("2 / 18");
    expect(summary).toHaveTextContent("11%");
  });

  it("renders achievement grid after loading", async () => {
    mockGetAchievements.mockResolvedValue({ ok: true, data: mockData });

    render(
      <Wrapper>
        <AchievementsPage />
      </Wrapper>,
    );

    // Wait for grid to appear
    const grid = await screen.findByTestId("achievement-grid");
    expect(grid).toBeInTheDocument();

    // Check that achievements are rendered
    expect(
      screen.getByTestId("achievement-card-first_scan"),
    ).toBeInTheDocument();
    expect(
      screen.getByTestId("achievement-card-scan_10"),
    ).toBeInTheDocument();
  });

  it("shows error state on API failure", async () => {
    mockGetAchievements.mockResolvedValue({
      ok: false,
      error: { message: "Server error" },
    });

    render(
      <Wrapper>
        <AchievementsPage />
      </Wrapper>,
    );

    const errorTitle = await screen.findByText("Something went wrong");
    expect(errorTitle).toBeInTheDocument();
  });

  it("shows empty state when no achievements exist", async () => {
    mockGetAchievements.mockResolvedValue({
      ok: true,
      data: { achievements: [], total: 0, unlocked: 0 },
    });

    render(
      <Wrapper>
        <AchievementsPage />
      </Wrapper>,
    );

    const emptyTitle = await screen.findByText("No achievements yet");
    expect(emptyTitle).toBeInTheDocument();
  });

  it("renders breadcrumbs with home link", async () => {
    mockGetAchievements.mockResolvedValue({ ok: true, data: mockData });

    render(
      <Wrapper>
        <AchievementsPage />
      </Wrapper>,
    );

    // Breadcrumbs should have home link
    expect(screen.getByText("Home")).toBeInTheDocument();
  });

  it("shows category sections for achievements", async () => {
    mockGetAchievements.mockResolvedValue({ ok: true, data: mockData });

    render(
      <Wrapper>
        <AchievementsPage />
      </Wrapper>,
    );

    await screen.findByTestId("achievement-grid");

    expect(screen.getByText("Exploration")).toBeInTheDocument();
    expect(screen.getByText("Health")).toBeInTheDocument();
  });
});
