import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { LandingSections } from "./LandingSections";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/components/common/Button", () => ({
  ButtonLink: ({
    children,
    href,
  }: {
    children: React.ReactNode;
    href: string;
  }) => <a href={href}>{children}</a>,
}));

vi.mock("@/components/common/Logo", () => ({
  Logo: () => <div data-testid="logo" />,
}));

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => key,
  }),
}));

vi.mock("lucide-react", () => ({
  BarChart3: () => <span data-testid="icon-barchart" />,
  Camera: () => <span data-testid="icon-camera" />,
  ChevronRight: () => <span data-testid="icon-chevron" />,
  Database: () => <span data-testid="icon-database" />,
  Layers: () => <span data-testid="icon-layers" />,
  Search: () => <span data-testid="icon-search" />,
  Shield: () => <span data-testid="icon-shield" />,
  ShoppingBasket: () => <span data-testid="icon-basket" />,
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("LandingSections", () => {
  it("renders the hero tagline", () => {
    render(<LandingSections />);
    expect(screen.getByText("landing.tagline")).toBeInTheDocument();
  });

  it("renders the hero description", () => {
    render(<LandingSections />);
    expect(screen.getByText("landing.description")).toBeInTheDocument();
  });

  it("renders sign-up and sign-in links", () => {
    render(<LandingSections />);
    const signupLinks = screen.getAllByText("landing.getStarted");
    expect(signupLinks.length).toBeGreaterThanOrEqual(1);
    expect(signupLinks[0].closest("a")).toHaveAttribute(
      "href",
      "/auth/signup",
    );

    const signInLink = screen.getByText("landing.signIn");
    expect(signInLink.closest("a")).toHaveAttribute("href", "/auth/login");
  });

  it("renders features heading and 3 feature cards", () => {
    render(<LandingSections />);
    expect(
      screen.getByText("landing.featuresHeading"),
    ).toBeInTheDocument();
    expect(screen.getByText("landing.featureSearch")).toBeInTheDocument();
    expect(screen.getByText("landing.featureScan")).toBeInTheDocument();
    expect(screen.getByText("landing.featureCompare")).toBeInTheDocument();
  });

  it("renders how-it-works heading and 3 steps", () => {
    render(<LandingSections />);
    expect(
      screen.getByText("landing.howItWorksHeading"),
    ).toBeInTheDocument();
    expect(screen.getByText("landing.step1Title")).toBeInTheDocument();
    expect(screen.getByText("landing.step2Title")).toBeInTheDocument();
    expect(screen.getByText("landing.step3Title")).toBeInTheDocument();
  });

  it("renders stats heading and 4 stat values", () => {
    render(<LandingSections />);
    expect(screen.getByText("landing.statsHeading")).toBeInTheDocument();
    expect(screen.getByText("landing.statProductsValue")).toBeInTheDocument();
    expect(screen.getByText("landing.statCategoriesValue")).toBeInTheDocument();
    expect(screen.getByText("landing.statFactorsValue")).toBeInTheDocument();
    expect(screen.getByText("landing.statCountriesValue")).toBeInTheDocument();
  });

  it("renders CTA repeat section", () => {
    render(<LandingSections />);
    expect(screen.getByText("landing.ctaHeading")).toBeInTheDocument();
    expect(
      screen.getByText("landing.ctaDescription"),
    ).toBeInTheDocument();
  });

  it("renders the logo in hero section", () => {
    render(<LandingSections />);
    expect(screen.getByTestId("logo")).toBeInTheDocument();
  });

  it("renders all heading elements", () => {
    render(<LandingSections />);
    const headings = screen.getAllByRole("heading");
    // h1 (tagline) + h2 (features, howItWorks, stats, cta) + h3 (3 features + 3 steps) = 11
    expect(headings.length).toBeGreaterThanOrEqual(5);
  });
});
