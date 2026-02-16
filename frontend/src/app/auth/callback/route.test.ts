import { describe, expect, it, vi, beforeEach } from "vitest";

const { mockExchangeCode } = vi.hoisted(() => ({
  mockExchangeCode: vi.fn(),
}));

vi.mock("@/lib/supabase/server", () => ({
  createServerSupabaseClient: vi.fn().mockResolvedValue({
    auth: { exchangeCodeForSession: mockExchangeCode },
  }),
}));

// We must import AFTER the mock is set up
import { GET } from "./route";
import { NextRequest } from "next/server";
import { createServerSupabaseClient } from "@/lib/supabase/server";

function makeRequest(url: string) {
  return new NextRequest(new URL(url, "http://localhost:3000"));
}

describe("Auth callback GET route", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("exchanges the code for a session when code param is present", async () => {
    const res = await GET(makeRequest("/auth/callback?code=abc123"));

    expect(createServerSupabaseClient).toHaveBeenCalled();
    expect(mockExchangeCode).toHaveBeenCalledWith("abc123");
    expect(res.status).toBe(307);
    expect(new URL(res.headers.get("location")!).pathname).toBe("/app/search");
  });

  it("redirects without exchanging when no code param", async () => {
    const res = await GET(makeRequest("/auth/callback"));

    expect(createServerSupabaseClient).not.toHaveBeenCalled();
    expect(mockExchangeCode).not.toHaveBeenCalled();
    expect(res.status).toBe(307);
    expect(new URL(res.headers.get("location")!).pathname).toBe("/app/search");
  });
});
