import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import HomePage, { metadata } from "./page";

// ─── i18n translations map ──────────────────────────────────────────────────

const tMap: Record<string, string> = {
  "landing.tagline": "healthier choices, made simple",
  "landing.description":
    "Search, scan, and compare food products in Poland and Germany. Get instant health scores, allergen warnings, and better alternatives.",
  "landing.getStarted": "Get started",
  "landing.signIn": "Sign in",
  "landing.featuresHeading": "Everything you need to eat healthier",
  "landing.featureSearch": "Search",
  "landing.featureSearchDesc":
    "Find products by name, brand, or category",
  "landing.featureScan": "Scan",
  "landing.featureScanDesc": "Scan barcodes for instant product info",
  "landing.featureCompare": "Compare",
  "landing.featureCompareDesc":
    "See health scores and find better alternatives",
  "landing.howItWorksHeading": "How it works",
  "landing.step1Title": "Search or scan",
  "landing.step1Desc":
    "Find any product by name, brand, or barcode scan.",
  "landing.step2Title": "Get your score",
  "landing.step2Desc":
    "See a clear 1–100 health score based on 9 nutrition factors.",
  "landing.step3Title": "Find better",
  "landing.step3Desc":
    "Discover healthier alternatives in the same category.",
  "landing.statsHeading": "Trusted data you can rely on",
  "landing.statProducts": "Products analyzed",
  "landing.statCategories": "Food categories",
  "landing.statFactors": "Scoring factors",
  "landing.statCountries": "Countries covered",
  "landing.ctaHeading": "Ready to eat healthier?",
  "landing.ctaDescription":
    "Join TryVit and make informed food choices backed by real nutrition data.",
  "landing.statProductsValue": "2,400+",
  "landing.statCategoriesValue": "25",
  "landing.statFactorsValue": "9",
  "landing.statCountriesValue": "2",
};

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => tMap[key] ?? key,
  }),
}));

vi.mock("next/link", () => ({
  default: ({
    href,
    children,
    ...rest
  }: {
    href: string;
    children: React.ReactNode;
    className?: string;
  }) => (
    <a href={href} {...rest}>
      {children}
    </a>
  ),
}));

vi.mock("@/components/common/Logo", () => ({
  Logo: (props: { variant?: string; size?: number }) => (
    <span data-testid="logo" data-variant={props.variant} />
  ),
}));

vi.mock("@/components/common/SkipLink", () => ({
  SkipLink: () => null,
}));

vi.mock("@/components/layout/Header", () => ({
  Header: () => <header data-testid="header">Header</header>,
}));

vi.mock("@/components/layout/Footer", () => ({
  Footer: () => <footer data-testid="footer">Footer</footer>,
}));

// ─── Hero section ───────────────────────────────────────────────────────────

describe("HomePage — Hero section", () => {
  it("renders the main heading with tagline", () => {
    render(<HomePage />);
    const heading = screen.getByRole("heading", { level: 1 });
    expect(heading).toHaveTextContent(/healthier/);
    expect(heading).toHaveTextContent(/made simple/);
  });

  it("renders the description", () => {
    render(<HomePage />);
    expect(
      screen.getByText(/Search, scan, and compare food products/),
    ).toBeInTheDocument();
  });

  it("renders Logo icon in the hero", () => {
    render(<HomePage />);
    const logo = screen.getByTestId("logo");
    expect(logo).toHaveAttribute("data-variant", "icon");
  });

  it("renders Get started CTA linking to signup", () => {
    render(<HomePage />);
    const ctas = screen.getAllByText("Get started");
    expect(ctas[0].closest("a")).toHaveAttribute("href", "/auth/signup");
  });

  it("renders Sign in link to login", () => {
    render(<HomePage />);
    const link = screen.getByText("Sign in");
    expect(link.closest("a")).toHaveAttribute("href", "/auth/login");
  });
});

// ─── Features section ───────────────────────────────────────────────────────

describe("HomePage — Features section", () => {
  it("renders feature section heading", () => {
    render(<HomePage />);
    expect(
      screen.getByText("Everything you need to eat healthier"),
    ).toBeInTheDocument();
  });

  it("renders three feature highlights", () => {
    render(<HomePage />);
    expect(screen.getByText("Search")).toBeInTheDocument();
    expect(screen.getByText("Scan")).toBeInTheDocument();
    expect(screen.getByText("Compare")).toBeInTheDocument();
  });

  it("renders feature descriptions", () => {
    render(<HomePage />);
    expect(
      screen.getByText("Find products by name, brand, or category"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("Scan barcodes for instant product info"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("See health scores and find better alternatives"),
    ).toBeInTheDocument();
  });

  it("renders feature icons as SVGs", () => {
    const { container } = render(<HomePage />);
    const svgs = container.querySelectorAll("svg");
    expect(svgs.length).toBeGreaterThanOrEqual(3);
  });
});

// ─── How It Works section ───────────────────────────────────────────────────

describe("HomePage — How It Works section", () => {
  it("renders How It Works heading", () => {
    render(<HomePage />);
    expect(screen.getByText("How it works")).toBeInTheDocument();
  });

  it("renders three numbered steps", () => {
    render(<HomePage />);
    expect(screen.getByText("Search or scan")).toBeInTheDocument();
    expect(screen.getByText("Get your score")).toBeInTheDocument();
    expect(screen.getByText("Find better")).toBeInTheDocument();
  });

  it("renders step descriptions", () => {
    render(<HomePage />);
    expect(
      screen.getByText(/Find any product by name, brand, or barcode/),
    ).toBeInTheDocument();
    expect(
      screen.getByText(/clear 1–100 health score/),
    ).toBeInTheDocument();
    expect(
      screen.getByText(/healthier alternatives in the same category/),
    ).toBeInTheDocument();
  });

  it("renders step numbers 1, 2, 3", () => {
    render(<HomePage />);
    expect(screen.getByText("1")).toBeInTheDocument();
    // "2" appears both as step number and stat value — verify at least 2 instances
    expect(screen.getAllByText("2").length).toBeGreaterThanOrEqual(2);
    expect(screen.getByText("3")).toBeInTheDocument();
  });
});

// ─── Data Stats section ─────────────────────────────────────────────────────

describe("HomePage — Data Stats section", () => {
  it("renders stats heading", () => {
    render(<HomePage />);
    expect(
      screen.getByText("Trusted data you can rely on"),
    ).toBeInTheDocument();
  });

  it("renders four stat values", () => {
    render(<HomePage />);
    expect(screen.getByText("2,400+")).toBeInTheDocument();
    expect(screen.getByText("25")).toBeInTheDocument();
    expect(screen.getByText("9")).toBeInTheDocument();
  });

  it("renders stat labels", () => {
    render(<HomePage />);
    expect(screen.getByText("Products analyzed")).toBeInTheDocument();
    expect(screen.getByText("Food categories")).toBeInTheDocument();
    expect(screen.getByText("Scoring factors")).toBeInTheDocument();
    expect(screen.getByText("Countries covered")).toBeInTheDocument();
  });
});

// ─── CTA Repeat section ─────────────────────────────────────────────────────

describe("HomePage — CTA Repeat section", () => {
  it("renders CTA heading", () => {
    render(<HomePage />);
    expect(
      screen.getByText("Ready to eat healthier?"),
    ).toBeInTheDocument();
  });

  it("renders CTA description", () => {
    render(<HomePage />);
    expect(
      screen.getByText(/informed food choices backed by real nutrition/),
    ).toBeInTheDocument();
  });

  it("renders second Get started CTA linking to signup", () => {
    render(<HomePage />);
    const ctas = screen.getAllByText("Get started");
    expect(ctas.length).toBeGreaterThanOrEqual(2);
    expect(ctas[1].closest("a")).toHaveAttribute("href", "/auth/signup");
  });
});

// ─── Layout composition ─────────────────────────────────────────────────────

describe("HomePage — Layout", () => {
  it("includes Header component", () => {
    render(<HomePage />);
    expect(screen.getByTestId("header")).toBeInTheDocument();
  });

  it("includes Footer component", () => {
    render(<HomePage />);
    expect(screen.getByTestId("footer")).toBeInTheDocument();
  });

  it("has a main content landmark", () => {
    render(<HomePage />);
    expect(screen.getByRole("main")).toBeInTheDocument();
  });

  it("renders accessible section headings", () => {
    render(<HomePage />);
    const h2s = screen.getAllByRole("heading", { level: 2 });
    // Features, How It Works, Stats, CTA = 4 h2 headings
    expect(h2s.length).toBe(4);
  });
});

// ─── SEO metadata export ────────────────────────────────────────────────────

describe("HomePage — SEO metadata", () => {
  it("exports page-level metadata with title", () => {
    expect(metadata).toBeDefined();
    expect(metadata.title).toBe("TryVit — Know What You Eat");
  });

  it("exports metadata description mentioning products and countries", () => {
    expect(metadata.description).toContain("2,400+");
    expect(metadata.description).toContain("Poland and Germany");
  });

  it("exports openGraph metadata with type website", () => {
    const og = metadata.openGraph as Record<string, unknown>;
    expect(og).toBeDefined();
    expect(og.type).toBe("website");
    expect(og.title).toBe("TryVit — Know What You Eat");
  });

  it("exports twitter card metadata", () => {
    const tw = metadata.twitter as Record<string, unknown>;
    expect(tw).toBeDefined();
    expect(tw.card).toBe("summary_large_image");
  });
});

// ─── JSON-LD structured data ────────────────────────────────────────────────

describe("HomePage — JSON-LD", () => {
  it("renders a WebSite JSON-LD script tag", () => {
    const { container } = render(<HomePage />);
    const script = container.querySelector('script[type="application/ld+json"]');
    expect(script).not.toBeNull();
    const jsonLd = JSON.parse(script!.textContent!);
    expect(jsonLd["@type"]).toBe("WebSite");
    expect(jsonLd.name).toBe("TryVit");
  });

  it("includes SearchAction in JSON-LD", () => {
    const { container } = render(<HomePage />);
    const script = container.querySelector('script[type="application/ld+json"]');
    const jsonLd = JSON.parse(script!.textContent!);
    expect(jsonLd.potentialAction["@type"]).toBe("SearchAction");
    expect(jsonLd.potentialAction.target.urlTemplate).toContain("/app/search");
  });
});
