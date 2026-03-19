import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";
import {
  ScanErrorView,
  ScanFoundView,
  ScanLookingUpView,
  ScanNotFoundView,
} from "./ScanResultView";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/hooks/use-reduced-motion", () => ({
  useReducedMotion: () => true,
}));

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string, params?: Record<string, string>) => {
      if (params) return `${key}:${JSON.stringify(params)}`;
      return key;
    },
  }),
}));

vi.mock("@/components/common/Button", () => ({
  Button: ({
    children,
    onClick,
  }: {
    children: React.ReactNode;
    onClick?: () => void;
    variant?: string;
    className?: string;
    icon?: React.ReactNode;
  }) => <button onClick={onClick}>{children}</button>,
  ButtonLink: ({
    children,
    href,
  }: {
    children: React.ReactNode;
    href: string;
    variant?: string;
    className?: string;
    icon?: React.ReactNode;
  }) => <a href={href}>{children}</a>,
}));

vi.mock("@/components/common/LoadingSpinner", () => ({
  LoadingSpinner: () => <div data-testid="loading-spinner" />,
}));

vi.mock("@/components/scan/ScanMissSubmitCTA", () => ({
  ScanMissSubmitCTA: ({
    ean,
    hasPendingSubmission,
    country,
  }: {
    ean: string;
    hasPendingSubmission?: boolean;
    country?: string;
  }) => (
    <div data-testid="scan-miss-submit-cta" data-ean={ean} data-pending={String(!!hasPendingSubmission)} data-country={country ?? ""} />
  ),
}));

vi.mock("@/lib/score-utils", () => ({
  toTryVitScore: (u: number) => 100 - u,
  getScoreBand: (u: number) => {
    if (u >= 1 && u <= 20)
      return { band: "green", labelKey: "scoreBand.excellent", bgColor: "#dcfce7", textColor: "#166534" };
    if (u >= 21 && u <= 40)
      return { band: "yellow", labelKey: "scoreBand.good", bgColor: "#fef9c3", textColor: "#854d0e" };
    if (u >= 41 && u <= 60)
      return { band: "orange", labelKey: "scoreBand.moderate", bgColor: "#fff7ed", textColor: "#9a3412" };
    if (u >= 61 && u <= 80)
      return { band: "red", labelKey: "scoreBand.poor", bgColor: "#fef2f2", textColor: "#991b1b" };
    if (u >= 81 && u <= 100)
      return { band: "darkred", labelKey: "scoreBand.bad", bgColor: "#fef2f2", textColor: "#7f1d1d" };
    return null;
  },
}));

vi.mock("@/lib/gs1", () => ({
  gs1CountryHint: (ean: string) => {
    if (ean.startsWith("590")) return { code: "PL", name: "Poland" };
    if (ean.startsWith("400")) return { code: "DE", name: "Germany" };
    return null;
  },
}));

vi.mock("@/lib/constants", () => ({
  NUTRI_COLORS: {
    A: "bg-green-600",
    B: "bg-lime-500",
    C: "bg-yellow-500",
    D: "bg-orange-500",
    E: "bg-red-600",
  },
  getCountryFlag: (code: string) => {
    const flags: Record<string, string> = { PL: "🇵🇱", DE: "🇩🇪" };
    return flags[code] ?? "🌐";
  },
  getCountryName: (code: string) => {
    const names: Record<string, string> = { PL: "Poland", DE: "Germany" };
    return names[code] ?? code;
  },
}));

// ─── Fixtures ───────────────────────────────────────────────────────────────

const mockFoundProduct = {
  api_version: "v1" as const,
  found: true as const,
  product_id: 42,
  product_name: "Test Chips",
  product_name_en: "Test Chips",
  product_name_display: "Test Chips Display",
  brand: "TestBrand",
  category: "chips",
  category_display: "Chips",
  category_icon: "🍟",
  unhealthiness_score: 35,
  nutri_score: "C" as const,
  product_country: "PL",
  is_cross_country: false,
};

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ScanErrorView", () => {
  const onRetry = vi.fn();
  const onReset = vi.fn();

  beforeEach(() => vi.clearAllMocks());

  it("renders error heading", () => {
    render(<ScanErrorView ean="5901234123457" onRetry={onRetry} onReset={onReset} />);
    expect(screen.getByText("scan.lookupFailed")).toBeInTheDocument();
  });

  it("renders ean in error message", () => {
    render(<ScanErrorView ean="5901234123457" onRetry={onRetry} onReset={onReset} />);
    expect(screen.getByText(/5901234123457/)).toBeInTheDocument();
  });

  it("renders retry and scan-another buttons", () => {
    render(<ScanErrorView ean="5901234123457" onRetry={onRetry} onReset={onReset} />);
    expect(screen.getByText("common.retry")).toBeInTheDocument();
    expect(screen.getByText("scan.scanAnother")).toBeInTheDocument();
  });

  it("calls onRetry when retry clicked", async () => {
    const user = userEvent.setup();
    render(<ScanErrorView ean="5901234123457" onRetry={onRetry} onReset={onReset} />);
    await user.click(screen.getByText("common.retry"));
    expect(onRetry).toHaveBeenCalledOnce();
  });

  it("calls onReset when scan-another clicked", async () => {
    const user = userEvent.setup();
    render(<ScanErrorView ean="5901234123457" onRetry={onRetry} onReset={onReset} />);
    await user.click(screen.getByText("scan.scanAnother"));
    expect(onReset).toHaveBeenCalledOnce();
  });
});

// ─── ScanNotFoundView ───────────────────────────────────────────────────────

describe("ScanNotFoundView", () => {
  const onReset = vi.fn();

  beforeEach(() => vi.clearAllMocks());

  it("renders not-found heading", () => {
    render(
      <ScanNotFoundView
        ean="5901234123457"
        scanResult={{ api_version: "v1", found: false, ean: "5901234123457", has_pending_submission: false }}
        onReset={onReset}
      />,
    );
    expect(screen.getByText("scan.notFound")).toBeInTheDocument();
  });

  it("renders ean in monospace code element", () => {
    render(
      <ScanNotFoundView
        ean="5901234123457"
        scanResult={{ api_version: "v1", found: false, ean: "5901234123457", has_pending_submission: false }}
        onReset={onReset}
      />,
    );
    const codeEl = screen.getByText("5901234123457");
    expect(codeEl.tagName).toBe("CODE");
  });

  it("renders ScanMissSubmitCTA with correct props", () => {
    render(
      <ScanNotFoundView
        ean="5901234123457"
        scanResult={{ api_version: "v1", found: false, ean: "5901234123457", has_pending_submission: true }}
        onReset={onReset}
      />,
    );
    const cta = screen.getByTestId("scan-miss-submit-cta");
    expect(cta).toHaveAttribute("data-ean", "5901234123457");
    expect(cta).toHaveAttribute("data-pending", "true");
  });

  it("passes country prop to ScanMissSubmitCTA", () => {
    render(
      <ScanNotFoundView
        ean="5901234123457"
        scanResult={{ api_version: "v1", found: false, ean: "5901234123457", has_pending_submission: false }}
        onReset={onReset}
        country="DE"
      />,
    );
    const cta = screen.getByTestId("scan-miss-submit-cta");
    expect(cta).toHaveAttribute("data-country", "DE");
  });

  it("renders scan-another and history links", () => {
    render(
      <ScanNotFoundView
        ean="5901234123457"
        scanResult={{ api_version: "v1", found: false, ean: "5901234123457", has_pending_submission: false }}
        onReset={onReset}
      />,
    );
    expect(screen.getByText("scan.scanAnother")).toBeInTheDocument();
    expect(screen.getByText("scan.history")).toBeInTheDocument();
  });

  it("renders scan-another button before history link (R5 button order)", () => {
    render(
      <ScanNotFoundView
        ean="5901234123457"
        scanResult={{ api_version: "v1", found: false, ean: "5901234123457", has_pending_submission: false }}
        onReset={onReset}
      />,
    );
    const scanAnother = screen.getByText("scan.scanAnother");
    const history = screen.getByText("scan.history");
    // scanAnother should appear before history in DOM order
    expect(
      scanAnother.compareDocumentPosition(history) & Node.DOCUMENT_POSITION_FOLLOWING,
    ).toBeTruthy();
  });

  it("history link points to /app/scan/history", () => {
    render(
      <ScanNotFoundView
        ean="5901234123457"
        scanResult={{ api_version: "v1", found: false, ean: "5901234123457", has_pending_submission: false }}
        onReset={onReset}
      />,
    );
    expect(screen.getByText("scan.history").closest("a")).toHaveAttribute(
      "href",
      "/app/scan/history",
    );
  });

  it("shows GS1 country hint when EAN has recognised prefix", () => {
    render(
      <ScanNotFoundView
        ean="5901234123457"
        scanResult={{ api_version: "v1", found: false, ean: "5901234123457", has_pending_submission: false }}
        onReset={onReset}
      />,
    );
    expect(screen.getByText("🇵🇱")).toBeInTheDocument();
    expect(screen.getByText(/scan\.gs1Hint/)).toBeInTheDocument();
  });

  it("shows GS1 coverage note alongside hint", () => {
    render(
      <ScanNotFoundView
        ean="5901234123457"
        scanResult={{ api_version: "v1", found: false, ean: "5901234123457", has_pending_submission: false }}
        onReset={onReset}
      />,
    );
    expect(screen.getByText(/scan\.gs1CoverageNote/)).toBeInTheDocument();
  });

  it("does not show GS1 coverage note when prefix is unrecognised", () => {
    render(
      <ScanNotFoundView
        ean="9999999999999"
        scanResult={{ api_version: "v1", found: false, ean: "9999999999999", has_pending_submission: false }}
        onReset={onReset}
      />,
    );
    expect(screen.queryByText(/scan\.gs1CoverageNote/)).toBeNull();
  });

  it("does not show GS1 country hint when prefix is unrecognised", () => {
    render(
      <ScanNotFoundView
        ean="9999999999999"
        scanResult={{ api_version: "v1", found: false, ean: "9999999999999", has_pending_submission: false }}
        onReset={onReset}
      />,
    );
    expect(screen.queryByText(/scan\.gs1Hint/)).toBeNull();
  });
});

// ─── ScanLookingUpView ──────────────────────────────────────────────────────

describe("ScanLookingUpView", () => {
  it("renders loading spinner", () => {
    render(<ScanLookingUpView ean="5901234123457" />);
    expect(screen.getByTestId("loading-spinner")).toBeInTheDocument();
  });

  it("renders ean in looking-up message", () => {
    render(<ScanLookingUpView ean="5901234123457" />);
    expect(screen.getByText(/5901234123457/)).toBeInTheDocument();
  });
});

// ─── ScanFoundView ──────────────────────────────────────────────────────────

describe("ScanFoundView", () => {
  const onViewDetails = vi.fn();
  const onReset = vi.fn();

  beforeEach(() => vi.clearAllMocks());

  it("renders product-found heading", () => {
    render(
      <ScanFoundView product={mockFoundProduct} onViewDetails={onViewDetails} onReset={onReset} />,
    );
    expect(screen.getByText("scan.productFound")).toBeInTheDocument();
  });

  it("renders product display name", () => {
    render(
      <ScanFoundView product={mockFoundProduct} onViewDetails={onViewDetails} onReset={onReset} />,
    );
    expect(screen.getByText("Test Chips Display")).toBeInTheDocument();
  });

  it("falls back to product_name when product_name_display is null", () => {
    const product = { ...mockFoundProduct, product_name_display: null };
    render(
      <ScanFoundView product={product} onViewDetails={onViewDetails} onReset={onReset} />,
    );
    expect(screen.getByText("Test Chips")).toBeInTheDocument();
  });

  it("renders brand when present", () => {
    render(
      <ScanFoundView product={mockFoundProduct} onViewDetails={onViewDetails} onReset={onReset} />,
    );
    expect(screen.getByText("TestBrand")).toBeInTheDocument();
  });

  it("does not render brand when null", () => {
    const product = { ...mockFoundProduct, brand: null };
    render(
      <ScanFoundView product={product} onViewDetails={onViewDetails} onReset={onReset} />,
    );
    expect(screen.queryByText("TestBrand")).toBeNull();
  });

  it("renders TryVit score badge", async () => {
    render(
      <ScanFoundView product={mockFoundProduct} onViewDetails={onViewDetails} onReset={onReset} />,
    );
    // toTryVitScore(35) = 65 — score animates via count-up, so wait for it
    await waitFor(() => expect(screen.getByText("65")).toBeInTheDocument());
  });

  it("renders score band label", () => {
    render(
      <ScanFoundView product={mockFoundProduct} onViewDetails={onViewDetails} onReset={onReset} />,
    );
    expect(screen.getByText("scoreBand.good")).toBeInTheDocument();
  });

  it("renders Nutri-Score badge when present", () => {
    render(
      <ScanFoundView product={mockFoundProduct} onViewDetails={onViewDetails} onReset={onReset} />,
    );
    expect(screen.getByText("C")).toBeInTheDocument();
    expect(screen.getByText("Nutri-Score")).toBeInTheDocument();
  });

  it("does not render Nutri-Score when null", () => {
    const product = { ...mockFoundProduct, nutri_score: null };
    render(
      <ScanFoundView product={product} onViewDetails={onViewDetails} onReset={onReset} />,
    );
    expect(screen.queryByText("Nutri-Score")).toBeNull();
  });

  it("calls onViewDetails when view-details clicked", async () => {
    const user = userEvent.setup();
    render(
      <ScanFoundView product={mockFoundProduct} onViewDetails={onViewDetails} onReset={onReset} />,
    );
    await user.click(screen.getByText("scan.viewDetails"));
    expect(onViewDetails).toHaveBeenCalledOnce();
  });

  it("calls onReset when scan-next clicked", async () => {
    const user = userEvent.setup();
    render(
      <ScanFoundView product={mockFoundProduct} onViewDetails={onViewDetails} onReset={onReset} />,
    );
    await user.click(screen.getByText("scan.scanNext"));
    expect(onReset).toHaveBeenCalledOnce();
  });

  // ─── Cross-country badge ────────────────────────────────────────────

  it("does not render cross-country badge when is_cross_country is false", () => {
    render(
      <ScanFoundView product={mockFoundProduct} onViewDetails={onViewDetails} onReset={onReset} />,
    );
    expect(screen.queryByText(/scan\.crossCountryBadge/)).toBeNull();
  });

  it("renders cross-country badge when is_cross_country is true", () => {
    const crossCountryProduct = { ...mockFoundProduct, is_cross_country: true, product_country: "DE" };
    render(
      <ScanFoundView product={crossCountryProduct} onViewDetails={onViewDetails} onReset={onReset} />,
    );
    expect(screen.getByText(/scan\.crossCountryBadge/)).toBeInTheDocument();
  });

  it("shows correct country name in cross-country badge", () => {
    const crossCountryProduct = { ...mockFoundProduct, is_cross_country: true, product_country: "DE" };
    render(
      <ScanFoundView product={crossCountryProduct} onViewDetails={onViewDetails} onReset={onReset} />,
    );
    expect(screen.getByText(/Germany/)).toBeInTheDocument();
  });

  it("shows country flag emoji in cross-country badge", () => {
    const crossCountryProduct = { ...mockFoundProduct, is_cross_country: true, product_country: "PL" };
    render(
      <ScanFoundView product={crossCountryProduct} onViewDetails={onViewDetails} onReset={onReset} />,
    );
    expect(screen.getByText("🇵🇱")).toBeInTheDocument();
  });
});
