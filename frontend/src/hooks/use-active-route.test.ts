import { describe, expect, it, vi } from "vitest";
import { renderHook } from "@testing-library/react";
import { useActiveRoute } from "./use-active-route";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockPathname = vi.fn<() => string>().mockReturnValue("/app");
vi.mock("next/navigation", () => ({ usePathname: () => mockPathname() }));

describe("useActiveRoute", () => {
  it("returns 'home' for /app", () => {
    mockPathname.mockReturnValue("/app");
    const { result } = renderHook(() => useActiveRoute());
    expect(result.current).toBe("home");
  });

  it("returns 'search' for /app/search", () => {
    mockPathname.mockReturnValue("/app/search");
    const { result } = renderHook(() => useActiveRoute());
    expect(result.current).toBe("search");
  });

  it("returns 'search' for /app/search/results", () => {
    mockPathname.mockReturnValue("/app/search/results");
    const { result } = renderHook(() => useActiveRoute());
    expect(result.current).toBe("search");
  });

  it("returns 'scan' for /app/scan", () => {
    mockPathname.mockReturnValue("/app/scan");
    const { result } = renderHook(() => useActiveRoute());
    expect(result.current).toBe("scan");
  });

  it("returns 'scan' for /app/scan/result/42", () => {
    mockPathname.mockReturnValue("/app/scan/result/42");
    const { result } = renderHook(() => useActiveRoute());
    expect(result.current).toBe("scan");
  });

  it("returns 'lists' for /app/lists", () => {
    mockPathname.mockReturnValue("/app/lists");
    const { result } = renderHook(() => useActiveRoute());
    expect(result.current).toBe("lists");
  });

  it("returns 'lists' for /app/lists/abc-123", () => {
    mockPathname.mockReturnValue("/app/lists/abc-123");
    const { result } = renderHook(() => useActiveRoute());
    expect(result.current).toBe("lists");
  });

  it("returns 'settings' for /app/settings", () => {
    mockPathname.mockReturnValue("/app/settings");
    const { result } = renderHook(() => useActiveRoute());
    expect(result.current).toBe("settings");
  });

  it("returns 'compare' for /app/compare", () => {
    mockPathname.mockReturnValue("/app/compare");
    const { result } = renderHook(() => useActiveRoute());
    expect(result.current).toBe("compare");
  });

  it("returns 'compare' for /app/compare/saved", () => {
    mockPathname.mockReturnValue("/app/compare/saved");
    const { result } = renderHook(() => useActiveRoute());
    expect(result.current).toBe("compare");
  });

  it("returns 'categories' for /app/categories", () => {
    mockPathname.mockReturnValue("/app/categories");
    const { result } = renderHook(() => useActiveRoute());
    expect(result.current).toBe("categories");
  });

  it("returns null for /app/product/42", () => {
    mockPathname.mockReturnValue("/app/product/42");
    const { result } = renderHook(() => useActiveRoute());
    expect(result.current).toBeNull();
  });

  it("returns null for /app/ingredient/7", () => {
    mockPathname.mockReturnValue("/app/ingredient/7");
    const { result } = renderHook(() => useActiveRoute());
    expect(result.current).toBeNull();
  });

  it("returns null for unrelated paths", () => {
    mockPathname.mockReturnValue("/onboarding");
    const { result } = renderHook(() => useActiveRoute());
    expect(result.current).toBeNull();
  });
});
