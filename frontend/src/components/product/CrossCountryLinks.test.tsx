import type { CrossCountryLink, RpcResult } from "@/lib/types";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { render, screen } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockGetCrossCountryLinks = vi.fn();

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

vi.mock("@/lib/api", () => ({
  getCrossCountryLinks: (...args: unknown[]) =>
    mockGetCrossCountryLinks(...args),
}));

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => key,
  }),
}));

vi.mock("next/link", () => ({
  default: ({
    children,
    href,
    ...rest
  }: {
    children: React.ReactNode;
    href: string;
    [key: string]: unknown;
  }) => (
    <a href={href} {...rest}>
      {children}
    </a>
  ),
}));

import { CrossCountryLinks } from "./CrossCountryLinks";

// ─── Helpers ────────────────────────────────────────────────────────────────

function ok<T>(data: T): RpcResult<T> {
  return { ok: true, data };
}

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false, staleTime: 0 },
    },
  });
  return function Wrapper({ children }: { children: React.ReactNode }) {
    return (
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    );
  };
}

// ─── Fixtures ───────────────────────────────────────────────────────────────

const pepsiLink: CrossCountryLink = {
  link_id: 5,
  link_type: "identical",
  confidence: "brand_match",
  notes: 'Auto-linked: brand "Pepsi" + name similarity 1.00',
  created_at: "2026-03-04T20:38:40.28373+00:00",
  product: {
    product_id: 783,
    product_name: "Pepsi",
    brand: "Pepsi",
    country: "DE",
    category: "Drinks",
    unhealthiness_score: 7,
    nutri_score_label: "D",
  },
};

const fantaLink: CrossCountryLink = {
  link_id: 8,
  link_type: "equivalent",
  confidence: "brand_match",
  notes: 'Auto-linked: brand "Fanta" + name similarity 0.65',
  created_at: "2026-03-04T20:38:40.28373+00:00",
  product: {
    product_id: 801,
    product_name: "Fanta Orange",
    brand: "Fanta",
    country: "DE",
    category: "Drinks",
    unhealthiness_score: 35,
    nutri_score_label: "E",
  },
};

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("CrossCountryLinks", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("renders nothing when there are no links", async () => {
    mockGetCrossCountryLinks.mockResolvedValue(ok([]));

    const { container } = render(<CrossCountryLinks productId={42} />, {
      wrapper: createWrapper(),
    });

    // Wait for query to settle, then assert nothing rendered
    await vi.waitFor(() => {
      expect(mockGetCrossCountryLinks).toHaveBeenCalledTimes(1);
    });

    expect(
      container.querySelector('[data-testid="cross-country-links-section"]'),
    ).toBeNull();
  });

  it("renders section with links when data is available", async () => {
    mockGetCrossCountryLinks.mockResolvedValue(ok([pepsiLink, fantaLink]));

    render(<CrossCountryLinks productId={42} />, {
      wrapper: createWrapper(),
    });

    // Wait for section to appear
    const section = await screen.findByTestId("cross-country-links-section");
    expect(section).toBeInTheDocument();

    // Heading present with count badge
    expect(
      screen.getByText("crossCountryLinks.title"),
    ).toBeInTheDocument();
    expect(screen.getByText("2")).toBeInTheDocument();

    // Both link cards rendered
    const cards = screen.getAllByTestId("cross-country-link-card");
    expect(cards).toHaveLength(2);
  });

  it("renders product name, brand, and category for each link", async () => {
    mockGetCrossCountryLinks.mockResolvedValue(ok([pepsiLink]));

    render(<CrossCountryLinks productId={42} />, {
      wrapper: createWrapper(),
    });

    await screen.findByTestId("cross-country-links-section");

    expect(screen.getByText("Pepsi")).toBeInTheDocument();
    expect(screen.getByText(/Pepsi · Drinks/)).toBeInTheDocument();
  });

  it("renders unhealthiness score badge", async () => {
    mockGetCrossCountryLinks.mockResolvedValue(ok([pepsiLink]));

    render(<CrossCountryLinks productId={42} />, {
      wrapper: createWrapper(),
    });

    await screen.findByTestId("cross-country-links-section");

    // Score value rendered
    expect(screen.getByText("7")).toBeInTheDocument();
  });

  it("shows link type badge with correct translation key", async () => {
    mockGetCrossCountryLinks.mockResolvedValue(ok([pepsiLink]));

    render(<CrossCountryLinks productId={42} />, {
      wrapper: createWrapper(),
    });

    await screen.findByTestId("cross-country-links-section");

    // Link type label uses translation key
    expect(
      screen.getByText("crossCountryLinks.typeIdentical"),
    ).toBeInTheDocument();
  });

  it("links each card to the product detail page", async () => {
    mockGetCrossCountryLinks.mockResolvedValue(ok([pepsiLink]));

    render(<CrossCountryLinks productId={42} />, {
      wrapper: createWrapper(),
    });

    const card = await screen.findByTestId("cross-country-link-card");
    expect(card).toHaveAttribute("href", "/app/product/783");
  });

  it("renders multiple link types correctly", async () => {
    mockGetCrossCountryLinks.mockResolvedValue(ok([pepsiLink, fantaLink]));

    render(<CrossCountryLinks productId={42} />, {
      wrapper: createWrapper(),
    });

    await screen.findByTestId("cross-country-links-section");

    expect(
      screen.getByText("crossCountryLinks.typeIdentical"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("crossCountryLinks.typeEquivalent"),
    ).toBeInTheDocument();
  });

  it("does not render when query is loading", () => {
    // Never resolve — stays loading
    mockGetCrossCountryLinks.mockReturnValue(new Promise(() => {}));

    const { container } = render(<CrossCountryLinks productId={42} />, {
      wrapper: createWrapper(),
    });

    expect(
      container.querySelector('[data-testid="cross-country-links-section"]'),
    ).toBeNull();
  });
});
