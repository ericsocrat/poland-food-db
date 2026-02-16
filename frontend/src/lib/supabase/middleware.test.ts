import { describe, it, expect, vi } from "vitest";
import { NextRequest, NextResponse } from "next/server";

const { mockCreateServerClient } = vi.hoisted(() => ({
  mockCreateServerClient: vi.fn().mockReturnValue({ auth: {} }),
}));

vi.mock("@supabase/ssr", () => ({
  createServerClient: mockCreateServerClient,
}));

import { createMiddlewareClient } from "./middleware";

function makeFixtures() {
  const request = new NextRequest(new URL("http://localhost:3000/app/search"));
  const response = NextResponse.next();
  return { request, response };
}

describe("createMiddlewareClient", () => {
  it("creates a server client with cookie helpers", () => {
    const { request, response } = makeFixtures();
    createMiddlewareClient(request, response);
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

  it("returns the supabase client", () => {
    const { request, response } = makeFixtures();
    const client = createMiddlewareClient(request, response);
    expect(client).toEqual({ auth: {} });
  });

  it("getAll reads from request cookies", () => {
    const { request, response } = makeFixtures();
    const spy = vi.spyOn(request.cookies, "getAll");
    createMiddlewareClient(request, response);
    const cookieConfig = mockCreateServerClient.mock.calls.at(-1)![2].cookies;
    cookieConfig.getAll();
    expect(spy).toHaveBeenCalled();
  });

  it("setAll writes to both request and response cookies", () => {
    const { request, response } = makeFixtures();
    const reqSpy = vi.spyOn(request.cookies, "set");
    const resSpy = vi.spyOn(response.cookies, "set");
    createMiddlewareClient(request, response);
    const cookieConfig = mockCreateServerClient.mock.calls.at(-1)![2].cookies;
    cookieConfig.setAll([{ name: "tok", value: "val", options: { path: "/" } }]);
    expect(reqSpy).toHaveBeenCalledWith("tok", "val");
    expect(resSpy).toHaveBeenCalledWith("tok", "val", { path: "/" });
  });
});
