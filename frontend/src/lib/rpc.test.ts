import { describe, it, expect } from "vitest";
import { isAuthError } from "@/lib/rpc";

describe("isAuthError", () => {
  it("recognises PGRST301 code", () => {
    expect(isAuthError({ code: "PGRST301", message: "some error" })).toBe(true);
  });

  it("recognises 401 code", () => {
    expect(isAuthError({ code: "401", message: "Unauthorized" })).toBe(true);
  });

  it("recognises 403 code", () => {
    expect(isAuthError({ code: "403", message: "Forbidden" })).toBe(true);
  });

  it("recognises JWT_EXPIRED code", () => {
    expect(isAuthError({ code: "JWT_EXPIRED", message: "" })).toBe(true);
  });

  it("recognises 'JWT expired' message (case-insensitive)", () => {
    expect(isAuthError({ code: "UNKNOWN", message: "jwt expired" })).toBe(true);
  });

  it("recognises 'not authenticated' message", () => {
    expect(
      isAuthError({ code: "UNKNOWN", message: "User is not authenticated" }),
    ).toBe(true);
  });

  it("recognises 'permission denied' message", () => {
    expect(
      isAuthError({ code: "42501", message: "permission denied for table" }),
    ).toBe(true);
  });

  it("recognises 'Invalid JWT' message", () => {
    expect(
      isAuthError({ code: "UNKNOWN", message: "Invalid JWT provided" }),
    ).toBe(true);
  });

  it("returns false for a non-auth error", () => {
    expect(
      isAuthError({ code: "PGRST116", message: "JSON object requested, multiple rows returned" }),
    ).toBe(false);
  });

  it("returns false for a generic business error", () => {
    expect(
      isAuthError({ code: "BUSINESS_ERROR", message: "Product not found" }),
    ).toBe(false);
  });
});
