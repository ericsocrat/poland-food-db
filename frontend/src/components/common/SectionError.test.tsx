import { fireEvent, render, screen } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { SectionError } from "./SectionError";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string, params?: Record<string, string | number>) => {
      const map: Record<string, string> = {
        "sectionError.network": "Couldn't load — check your connection",
        "sectionError.auth": "Session expired — sign in to continue",
        "sectionError.server": "Couldn't load — server error",
        "sectionError.unknown": "This section couldn't load",
        "sectionError.labeledMessage": `${params?.label ?? ""} couldn't be loaded`,
        "common.tryAgain": "Try again",
      };
      return map[key] ?? key;
    },
  }),
}));

vi.mock("@/lib/error-classifier", () => ({
  classifyError: vi.fn().mockReturnValue("unknown"),
}));

 
const { classifyError } = await import("@/lib/error-classifier");
const mockClassify = vi.mocked(classifyError);

beforeEach(() => {
  vi.clearAllMocks();
  mockClassify.mockReturnValue("unknown");
});

// ─── Rendering ──────────────────────────────────────────────────────────────

describe("SectionError — rendering", () => {
  it("renders with role=alert", () => {
    render(<SectionError error={new Error("fail")} />);
    expect(screen.getByRole("alert")).toBeInTheDocument();
  });

  it("has data-testid='section-error'", () => {
    render(<SectionError error={new Error("fail")} />);
    expect(screen.getByTestId("section-error")).toBeInTheDocument();
  });

  it("shows generic message for unknown errors", () => {
    mockClassify.mockReturnValue("unknown");
    render(<SectionError error={new Error("fail")} />);
    expect(
      screen.getByText("This section couldn't load"),
    ).toBeInTheDocument();
  });
});

// ─── Error Categories ───────────────────────────────────────────────────────

describe("SectionError — categories", () => {
  it("shows network message for network errors", () => {
    mockClassify.mockReturnValue("network");
    render(<SectionError error={new Error("fetch failed")} />);
    expect(
      screen.getByText("Couldn't load — check your connection"),
    ).toBeInTheDocument();
    expect(
      screen.getByTestId("section-error"),
    ).toHaveAttribute("data-error-category", "network");
  });

  it("shows auth message for auth errors", () => {
    mockClassify.mockReturnValue("auth");
    render(<SectionError error={new Error("jwt expired")} />);
    expect(
      screen.getByText("Session expired — sign in to continue"),
    ).toBeInTheDocument();
  });

  it("shows server message for server errors", () => {
    mockClassify.mockReturnValue("server");
    render(<SectionError error={new Error("500")} />);
    expect(
      screen.getByText("Couldn't load — server error"),
    ).toBeInTheDocument();
  });
});

// ─── Label prop ─────────────────────────────────────────────────────────────

describe("SectionError — label", () => {
  it("shows labeled message when label is provided", () => {
    render(
      <SectionError error={new Error("fail")} label="Nutrition data" />,
    );
    expect(
      screen.getByText("Nutrition data couldn't be loaded"),
    ).toBeInTheDocument();
  });
});

// ─── Retry button ───────────────────────────────────────────────────────────

describe("SectionError — retry", () => {
  it("shows retry button when onRetry is provided", () => {
    render(<SectionError error={new Error("fail")} onRetry={() => {}} />);
    expect(
      screen.getByTestId("section-error-retry"),
    ).toBeInTheDocument();
    expect(screen.getByText("Try again")).toBeInTheDocument();
  });

  it("calls onRetry when retry button is clicked", () => {
    const onRetry = vi.fn();
    render(<SectionError error={new Error("fail")} onRetry={onRetry} />);
    fireEvent.click(screen.getByTestId("section-error-retry"));
    expect(onRetry).toHaveBeenCalledOnce();
  });

  it("does not render retry button when onRetry is omitted", () => {
    render(<SectionError error={new Error("fail")} />);
    expect(
      screen.queryByTestId("section-error-retry"),
    ).not.toBeInTheDocument();
  });
});
