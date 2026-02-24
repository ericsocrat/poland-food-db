import { describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { Providers, shouldRetry } from "./Providers";

// Mock sonner Toaster — lightweight stub
vi.mock("sonner", () => ({
  Toaster: () => <div data-testid="toaster" />,
}));

// Mock Supabase client used by FlagProvider
vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({
    channel: () => ({
      on: () => ({ subscribe: () => ({ unsubscribe: vi.fn() }) }),
    }),
    removeChannel: vi.fn(),
  }),
}));

describe("Providers", () => {
  it("renders children", () => {
    render(
      <Providers>
        <p>Hello</p>
      </Providers>,
    );
    expect(screen.getByText("Hello")).toBeInTheDocument();
  });

  it("renders Toaster", () => {
    render(
      <Providers>
        <span />
      </Providers>,
    );
    expect(screen.getByTestId("toaster")).toBeInTheDocument();
  });

  it("renders multiple children", () => {
    render(
      <Providers>
        <p>A</p>
        <p>B</p>
      </Providers>,
    );
    expect(screen.getByText("A")).toBeInTheDocument();
    expect(screen.getByText("B")).toBeInTheDocument();
  });
});

// ─── shouldRetry unit tests ─────────────────────────────────────────────────

describe("shouldRetry", () => {
  it("returns false for 401 auth error", () => {
    const err = Object.assign(new Error("Unauthorized"), { code: "401" });
    expect(shouldRetry(0, err)).toBe(false);
  });

  it("returns false for 403 forbidden error", () => {
    const err = Object.assign(new Error("Forbidden"), { code: "403" });
    expect(shouldRetry(0, err)).toBe(false);
  });

  it("returns false for PGRST301 PostgREST error", () => {
    const err = Object.assign(new Error("JWT expired"), { code: "PGRST301" });
    expect(shouldRetry(0, err)).toBe(false);
  });

  it("returns true on first failure for generic errors", () => {
    expect(shouldRetry(0, new Error("Network error"))).toBe(true);
  });

  it("returns true on second failure for generic errors", () => {
    expect(shouldRetry(1, new Error("Network error"))).toBe(true);
  });

  it("returns false after 2 failures for generic errors", () => {
    expect(shouldRetry(2, new Error("Network error"))).toBe(false);
  });

  it("returns false for numeric code as number", () => {
    const err = Object.assign(new Error("Unauthorized"), { code: 401 });
    expect(shouldRetry(0, err)).toBe(false);
  });
});
