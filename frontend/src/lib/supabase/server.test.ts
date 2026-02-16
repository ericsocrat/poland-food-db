import { describe, it, expect, vi, beforeEach } from "vitest";

const { mockGetAll, mockSet, mockCreateServerClient } = vi.hoisted(() => ({
  mockGetAll: vi.fn().mockReturnValue([]),
  mockSet: vi.fn(),
  mockCreateServerClient: vi.fn().mockReturnValue({ auth: {} }),
}));

vi.mock("next/headers", () => ({
  cookies: vi.fn().mockResolvedValue({
    getAll: mockGetAll,
    set: mockSet,
  }),
}));

vi.mock("@supabase/ssr", () => ({
  createServerClient: mockCreateServerClient,
}));

import { createServerSupabaseClient } from "./server";

describe("createServerSupabaseClient", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("awaits cookies() and creates a server client", async () => {
    await createServerSupabaseClient();
    expect(mockCreateServerClient).toHaveBeenCalledWith(
      expect.any(String),
      expect.any(String),
      expect.objectContaining({
        cookies: expect.objectContaining({
          getAll: expect.any(Function),
          setAll: expect.any(Function),
        }),
      }),
    );
  });

  it("returns the supabase client", async () => {
    const client = await createServerSupabaseClient();
    expect(client).toEqual({ auth: {} });
  });

  it("cookies.getAll delegates to cookie store", async () => {
    await createServerSupabaseClient();
    const cookieConfig = mockCreateServerClient.mock.calls[0][2].cookies;
    cookieConfig.getAll();
    expect(mockGetAll).toHaveBeenCalled();
  });

  it("cookies.setAll delegates to cookie store", async () => {
    await createServerSupabaseClient();
    const cookieConfig = mockCreateServerClient.mock.calls[0][2].cookies;
    cookieConfig.setAll([{ name: "a", value: "b", options: {} }]);
    expect(mockSet).toHaveBeenCalledWith("a", "b", {});
  });

  it("cookies.setAll swallows errors in read-only context", async () => {
    mockSet.mockImplementation(() => {
      throw new Error("Read-only cookies");
    });
    await createServerSupabaseClient();
    const cookieConfig = mockCreateServerClient.mock.calls[0][2].cookies;
    // Should not throw
    expect(() =>
      cookieConfig.setAll([{ name: "a", value: "b", options: {} }]),
    ).not.toThrow();
  });
});
