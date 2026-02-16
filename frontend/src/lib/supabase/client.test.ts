import { describe, it, expect, vi } from "vitest";

const { mockCreateBrowserClient } = vi.hoisted(() => ({
  mockCreateBrowserClient: vi.fn().mockReturnValue({ auth: {} }),
}));

vi.mock("@supabase/ssr", () => ({
  createBrowserClient: mockCreateBrowserClient,
}));

import { createClient } from "./client";

describe("createClient (browser)", () => {
  it("calls createBrowserClient with env vars", () => {
    createClient();
    expect(mockCreateBrowserClient).toHaveBeenCalledWith(
      process.env.NEXT_PUBLIC_SUPABASE_URL ?? "",
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ?? "",
    );
  });

  it("returns the client instance", () => {
    const client = createClient();
    expect(client).toEqual({ auth: {} });
  });
});
