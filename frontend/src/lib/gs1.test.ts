import { gs1CountryHint } from "@/lib/gs1";
import { describe, expect, it } from "vitest";

// ─── gs1CountryHint ─────────────────────────────────────────────────────────

describe("gs1CountryHint", () => {
  it("returns Poland for 590 prefix", () => {
    expect(gs1CountryHint("5901234123457")).toEqual({
      code: "PL",
      name: "Poland",
    });
  });

  it("returns Germany for 400–440 prefix range", () => {
    expect(gs1CountryHint("4000000000000")).toEqual({
      code: "DE",
      name: "Germany",
    });
    expect(gs1CountryHint("4400000000000")).toEqual({
      code: "DE",
      name: "Germany",
    });
    expect(gs1CountryHint("4200000000000")).toEqual({
      code: "DE",
      name: "Germany",
    });
  });

  it("returns France for 300–379 prefix", () => {
    expect(gs1CountryHint("3000000000000")).toEqual({
      code: "FR",
      name: "France",
    });
    expect(gs1CountryHint("3790000000000")).toEqual({
      code: "FR",
      name: "France",
    });
  });

  it("returns United Kingdom for 500–509 prefix", () => {
    expect(gs1CountryHint("5000000000000")).toEqual({
      code: "GB",
      name: "United Kingdom",
    });
  });

  it("returns Italy for 800–839 prefix", () => {
    expect(gs1CountryHint("8000000000000")).toEqual({
      code: "IT",
      name: "Italy",
    });
    expect(gs1CountryHint("8390000000000")).toEqual({
      code: "IT",
      name: "Italy",
    });
  });

  it("returns Spain for 840–849 prefix", () => {
    expect(gs1CountryHint("8400000000000")).toEqual({
      code: "ES",
      name: "Spain",
    });
  });

  it("returns United States for 000–139 prefixes", () => {
    expect(gs1CountryHint("0000000000000")).toEqual({
      code: "US",
      name: "United States",
    });
    expect(gs1CountryHint("0600000000000")).toEqual({
      code: "US",
      name: "United States",
    });
    expect(gs1CountryHint("1390000000000")).toEqual({
      code: "US",
      name: "United States",
    });
  });

  it("works with 12-digit UPC-A codes", () => {
    expect(gs1CountryHint("012345678901")).toEqual({
      code: "US",
      name: "United States",
    });
  });

  it("returns null for EAN-8 codes", () => {
    expect(gs1CountryHint("12345678")).toBeNull();
  });

  it("returns null for unrecognised prefixes", () => {
    expect(gs1CountryHint("9990000000000")).toBeNull();
  });

  it("returns null for empty string", () => {
    expect(gs1CountryHint("")).toBeNull();
  });

  it("returns null for short strings", () => {
    expect(gs1CountryHint("123")).toBeNull();
  });
});
