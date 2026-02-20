import { describe, it, expect, vi, beforeEach } from "vitest";
import React from "react";

// Make React available globally for JSX in the tested module
vi.stubGlobal("React", React);

// Mock next/og — ImageResponse is used with `new`
vi.mock("next/og", () => {
  const ImageResponseMock = vi.fn().mockImplementation(function (this: Response) {
    return new Response();
  });
  return { ImageResponse: ImageResponseMock };
});

describe("opengraph-image root", () => {
  beforeEach(() => {
    vi.resetModules();
    // Mock global fetch for the font loader
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        arrayBuffer: () => Promise.resolve(new ArrayBuffer(8)),
      }),
    );
  });

  it("exports correct size (1200×630)", async () => {
    const mod = await import("./opengraph-image");
    expect(mod.size).toEqual({ width: 1200, height: 630 });
  });

  it("exports png content type", async () => {
    const mod = await import("./opengraph-image");
    expect(mod.contentType).toBe("image/png");
  });

  it("exports alt text with brand name", async () => {
    const mod = await import("./opengraph-image");
    expect(mod.alt).toContain("Poland Food DB");
  });

  it("exports a revalidate value", async () => {
    const mod = await import("./opengraph-image");
    expect(mod.revalidate).toBeGreaterThan(0);
  });

  it("default export is a function", async () => {
    const mod = await import("./opengraph-image");
    expect(typeof mod.default).toBe("function");
  });

  it("calls ImageResponse when invoked", async () => {
    const { ImageResponse } = await import("next/og");
    const mod = await import("./opengraph-image");
    await mod.default();
    expect(ImageResponse).toHaveBeenCalled();
  });
});
