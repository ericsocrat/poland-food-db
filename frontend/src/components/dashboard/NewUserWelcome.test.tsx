import { render, screen } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { NewUserWelcome } from "./NewUserWelcome";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => {
      const map: Record<string, string> = {
        "dashboard.newUserTitle": "Welcome to TryVit",
        "dashboard.newUserSubtitle": "Start exploring healthier food choices.",
        "dashboard.newUserScanTitle": "Scan a product",
        "dashboard.newUserScanDesc": "Use your camera to scan a barcode.",
        "dashboard.newUserBrowseTitle": "Browse categories",
        "dashboard.newUserBrowseDesc": "Explore products by category.",
        "dashboard.newUserFunFact": "Fun Fact",
        "dashboard.tip.0": "Reading labels can save lives!",
      };
      return map[key] ?? key;
    },
  }),
}));

vi.mock("./NutritionTip", () => ({
  tipIndexForToday: () => 0,
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("NewUserWelcome", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("renders welcome title and subtitle", () => {
    render(<NewUserWelcome />);
    expect(screen.getByText("Welcome to TryVit")).toBeInTheDocument();
    expect(
      screen.getByText("Start exploring healthier food choices."),
    ).toBeInTheDocument();
  });

  it("renders scan CTA linking to /app/scan", () => {
    render(<NewUserWelcome />);
    const scanLink = screen.getByTestId("new-user-scan-cta");
    expect(scanLink).toHaveAttribute("href", "/app/scan");
    expect(screen.getByText("Scan a product")).toBeInTheDocument();
  });

  it("renders browse CTA linking to /app/categories", () => {
    render(<NewUserWelcome />);
    const browseLink = screen.getByTestId("new-user-browse-cta");
    expect(browseLink).toHaveAttribute("href", "/app/categories");
    expect(screen.getByText("Browse categories")).toBeInTheDocument();
  });

  it("renders fun fact section with tip text", () => {
    render(<NewUserWelcome />);
    const funFact = screen.getByTestId("new-user-fun-fact");
    expect(funFact).toBeInTheDocument();
    expect(screen.getByText("Fun Fact")).toBeInTheDocument();
    expect(
      screen.getByText("Reading labels can save lives!"),
    ).toBeInTheDocument();
  });

  it("has section aria-label", () => {
    render(<NewUserWelcome />);
    expect(screen.getByLabelText("Welcome to TryVit")).toBeInTheDocument();
  });

  it("has data-testid on container", () => {
    render(<NewUserWelcome />);
    expect(screen.getByTestId("new-user-welcome")).toBeInTheDocument();
  });
});
