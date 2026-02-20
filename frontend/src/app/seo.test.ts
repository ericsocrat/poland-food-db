import { describe, it, expect, vi, beforeEach } from "vitest";

/* ---------- robots.ts ---------- */

describe("robots()", () => {
  beforeEach(() => {
    vi.unstubAllEnvs();
  });

  it("returns valid robots configuration", async () => {
    const mod = await import("./robots");
    const result = mod.default();

    expect(result.rules).toBeDefined();
    expect(Array.isArray(result.rules)).toBe(true);
  });

  it("allows all user agents on /", async () => {
    const mod = await import("./robots");
    const result = mod.default();
    const rule = Array.isArray(result.rules) ? result.rules[0] : result.rules;

    expect(rule.userAgent).toBe("*");
    expect(rule.allow).toBe("/");
  });

  it("disallows /api/ and /app/settings", async () => {
    const mod = await import("./robots");
    const result = mod.default();
    const rule = Array.isArray(result.rules) ? result.rules[0] : result.rules;

    expect(rule.disallow).toContain("/api/");
    expect(rule.disallow).toContain("/app/settings");
  });

  it("includes a sitemap URL", async () => {
    const mod = await import("./robots");
    const result = mod.default();

    expect(result.sitemap).toContain("/sitemap.xml");
  });
});

/* ---------- sitemap.ts ---------- */

describe("sitemap()", () => {
  it("returns an array of sitemap entries", async () => {
    const mod = await import("./sitemap");
    const result = mod.default();

    expect(Array.isArray(result)).toBe(true);
    expect(result.length).toBeGreaterThanOrEqual(2);
  });

  it("includes root and /app URLs", async () => {
    const mod = await import("./sitemap");
    const result = mod.default();
    const urls = result.map((e) => e.url);

    expect(urls.some((u) => u.endsWith("/app"))).toBe(true);
    // Root URL should be the base URL without path suffix
    expect(urls.some((u) => !u.includes("/app"))).toBe(true);
  });

  it("entries have lastModified and priority", async () => {
    const mod = await import("./sitemap");
    const result = mod.default();

    for (const entry of result) {
      expect(entry.lastModified).toBeDefined();
      expect(typeof entry.priority).toBe("number");
    }
  });
});
