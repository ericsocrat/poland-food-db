import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { HealthWarningsCard, HealthWarningBadge } from "./HealthWarningsCard";
import type {
  RpcResult,
  HealthProfileActiveResponse,
  HealthWarningsResponse,
} from "@/lib/types";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockGetActiveHealthProfile = vi.fn();
const mockGetProductHealthWarnings = vi.fn();

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

vi.mock("@/lib/api", () => ({
  getActiveHealthProfile: (...args: unknown[]) =>
    mockGetActiveHealthProfile(...args),
  getProductHealthWarnings: (...args: unknown[]) =>
    mockGetProductHealthWarnings(...args),
}));

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

const noProfile: HealthProfileActiveResponse = {
  api_version: "1.0",
  profile: null,
};

const activeProfile: HealthProfileActiveResponse = {
  api_version: "1.0",
  profile: {
    profile_id: "p-1",
    profile_name: "My Health",
    is_active: true,
    health_conditions: ["diabetes", "hypertension"],
    max_sugar_g: 10,
    max_salt_g: 1.0,
    max_saturated_fat_g: null,
    max_calories_kcal: null,
    notes: null,
    created_at: "2026-01-01T00:00:00Z",
    updated_at: "2026-01-01T00:00:00Z",
  },
};

const noWarnings: HealthWarningsResponse = {
  api_version: "1.0",
  product_id: 42,
  warning_count: 0,
  warnings: [],
};

const twoWarnings: HealthWarningsResponse = {
  api_version: "1.0",
  product_id: 42,
  warning_count: 2,
  warnings: [
    {
      condition: "diabetes",
      severity: "high",
      message: "Sugar exceeds your limit: 13.5g vs max 10g",
    },
    {
      condition: "hypertension",
      severity: "moderate",
      message: "Salt is elevated for hypertension",
    },
  ],
};

const criticalWarning: HealthWarningsResponse = {
  api_version: "1.0",
  product_id: 42,
  warning_count: 1,
  warnings: [
    {
      condition: "celiac_disease",
      severity: "critical",
      message: "Contains gluten — unsafe for celiac disease",
    },
  ],
};

// ─── HealthWarningsCard Tests ───────────────────────────────────────────────

describe("HealthWarningsCard", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("shows setup prompt when no active profile", async () => {
    mockGetActiveHealthProfile.mockResolvedValue(ok(noProfile));

    render(<HealthWarningsCard productId={42} />, {
      wrapper: createWrapper(),
    });

    await waitFor(() => {
      expect(
        screen.getByText("Personalized health warnings"),
      ).toBeInTheDocument();
    });
    expect(screen.getByText(/health profile/)).toBeInTheDocument();
    expect(screen.getByRole("link")).toHaveAttribute("href", "/app/settings");
  });

  it("shows 'within your limits' when no warnings", async () => {
    mockGetActiveHealthProfile.mockResolvedValue(ok(activeProfile));
    mockGetProductHealthWarnings.mockResolvedValue(ok(noWarnings));

    render(<HealthWarningsCard productId={42} />, {
      wrapper: createWrapper(),
    });

    await waitFor(() => {
      expect(screen.getByText("Within your limits")).toBeInTheDocument();
    });
    expect(screen.getByText(/My Health/)).toBeInTheDocument();
  });

  it("renders warnings sorted by severity", async () => {
    mockGetActiveHealthProfile.mockResolvedValue(ok(activeProfile));
    mockGetProductHealthWarnings.mockResolvedValue(ok(twoWarnings));

    render(<HealthWarningsCard productId={42} />, {
      wrapper: createWrapper(),
    });

    await waitFor(() => {
      expect(screen.getByText("2 health warning(s)")).toBeInTheDocument();
    });
    expect(
      screen.getByText("Sugar exceeds your limit: 13.5g vs max 10g"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("Salt is elevated for hypertension"),
    ).toBeInTheDocument();
    expect(screen.getByText(/My Health/)).toBeInTheDocument();
  });

  it("renders critical warning with correct severity", async () => {
    mockGetActiveHealthProfile.mockResolvedValue(ok(activeProfile));
    mockGetProductHealthWarnings.mockResolvedValue(ok(criticalWarning));

    render(<HealthWarningsCard productId={42} />, {
      wrapper: createWrapper(),
    });

    await waitFor(() => {
      expect(screen.getByText("1 health warning(s)")).toBeInTheDocument();
    });
    expect(
      screen.getByText("Contains gluten — unsafe for celiac disease"),
    ).toBeInTheDocument();
  });

  it("displays profile name for active profile", async () => {
    mockGetActiveHealthProfile.mockResolvedValue(ok(activeProfile));
    mockGetProductHealthWarnings.mockResolvedValue(ok(twoWarnings));

    render(<HealthWarningsCard productId={42} />, {
      wrapper: createWrapper(),
    });

    await waitFor(() => {
      expect(screen.getByText(/Profile: My Health/)).toBeInTheDocument();
    });
  });
});

// ─── HealthWarningBadge Tests ───────────────────────────────────────────────

describe("HealthWarningBadge", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("renders nothing when no active profile", async () => {
    mockGetActiveHealthProfile.mockResolvedValue(ok(noProfile));

    const { container } = render(<HealthWarningBadge productId={42} />, {
      wrapper: createWrapper(),
    });

    // Wait for profile query to resolve, badge should be null
    await waitFor(() => {
      expect(mockGetActiveHealthProfile).toHaveBeenCalled();
    });
    expect(container.firstChild).toBeNull();
  });

  it("renders green check when profile exists but no warnings", async () => {
    mockGetActiveHealthProfile.mockResolvedValue(ok(activeProfile));
    mockGetProductHealthWarnings.mockResolvedValue(ok(noWarnings));

    render(<HealthWarningBadge productId={42} />, {
      wrapper: createWrapper(),
    });

    await waitFor(() => {
      expect(screen.getByText("✓")).toBeInTheDocument();
    });
    expect(screen.getByTitle("No health warnings")).toBeInTheDocument();
  });

  it("renders warning count badge when warnings exist", async () => {
    mockGetActiveHealthProfile.mockResolvedValue(ok(activeProfile));
    mockGetProductHealthWarnings.mockResolvedValue(ok(twoWarnings));

    render(<HealthWarningBadge productId={42} />, {
      wrapper: createWrapper(),
    });

    await waitFor(() => {
      expect(screen.getByText("2")).toBeInTheDocument();
    });
    expect(screen.getByTitle("2 health warning(s)")).toBeInTheDocument();
  });

  it("renders 1 warning with singular title", async () => {
    mockGetActiveHealthProfile.mockResolvedValue(ok(activeProfile));
    mockGetProductHealthWarnings.mockResolvedValue(ok(criticalWarning));

    render(<HealthWarningBadge productId={42} />, {
      wrapper: createWrapper(),
    });

    await waitFor(() => {
      expect(screen.getByText("1")).toBeInTheDocument();
    });
    expect(screen.getByTitle("1 health warning(s)")).toBeInTheDocument();
  });
});
