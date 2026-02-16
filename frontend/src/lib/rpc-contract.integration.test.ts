// ─── RPC Contract Tests ─────────────────────────────────────────────────────
// These tests call REAL Supabase RPC functions and validate the response shape
// matches the TypeScript interfaces the frontend expects.
//
// They are SKIPPED when Supabase env vars are not set (normal `npm test`).
// Run with: INTEGRATION=1 npm test -- --testPathPattern=rpc-contract
//
// These tests would have caught the nutri_score column mismatch bug because
// the actual SQL function would have thrown a "column does not exist" error.
// ─────────────────────────────────────────────────────────────────────────────

import { describe, it, expect, beforeAll } from "vitest";
import { createClient, type SupabaseClient } from "@supabase/supabase-js";

const INTEGRATION = process.env.INTEGRATION === "1";
const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL ?? "";
const SUPABASE_KEY = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ?? "";

// ─── Skip guard ─────────────────────────────────────────────────────────────

const describeIntegration = INTEGRATION ? describe : describe.skip;

// ─── Setup ──────────────────────────────────────────────────────────────────

let supabase: SupabaseClient;

beforeAll(() => {
  if (!INTEGRATION) return;
  supabase = createClient(SUPABASE_URL, SUPABASE_KEY, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
});

// ─── Type guard helpers ─────────────────────────────────────────────────────

function expectJsonbKeys(obj: Record<string, unknown>, keys: string[]) {
  for (const k of keys) {
    expect(obj).toHaveProperty(k);
  }
}

// ─── Tests ──────────────────────────────────────────────────────────────────

describeIntegration("RPC Contract: api_record_scan", () => {
  it("returns correct shape for a known EAN", async () => {
    const { data, error } = await supabase.rpc("api_record_scan", {
      p_ean: "5900320001303",
    });

    expect(error).toBeNull();
    expect(data).toBeTruthy();

    // Should not be an error response
    expect(data).not.toHaveProperty("error");

    // Must have all keys the frontend's RecordScanFoundResponse expects
    expectJsonbKeys(data, [
      "api_version",
      "found",
      "product_id",
      "product_name",
      "brand",
      "category",
      "unhealthiness_score",
      "nutri_score",
    ]);

    expect(data.found).toBe(true);
    expect(typeof data.product_id).toBe("number");
    expect(typeof data.product_name).toBe("string");
  });

  it("returns found=false for unknown EAN", async () => {
    const { data, error } = await supabase.rpc("api_record_scan", {
      p_ean: "0000000000000",
    });

    expect(error).toBeNull();
    expect(data).toBeTruthy();
    expectJsonbKeys(data, ["api_version", "found", "ean", "has_pending_submission"]);
    expect(data.found).toBe(false);
  });

  it("returns error for invalid EAN", async () => {
    const { data, error } = await supabase.rpc("api_record_scan", {
      p_ean: "123",
    });

    expect(error).toBeNull();
    expect(data).toBeTruthy();
    expect(data).toHaveProperty("error");
  });
});

describeIntegration("RPC Contract: api_category_overview", () => {
  it("returns categories with slug field", async () => {
    const { data, error } = await supabase.rpc("api_category_overview", {
      p_country: "PL",
    });

    expect(error).toBeNull();
    expect(data).toBeTruthy();
    expectJsonbKeys(data, ["api_version", "categories"]);

    expect(Array.isArray(data.categories)).toBe(true);
    expect(data.categories.length).toBeGreaterThan(0);

    // Each category should have slug (post-migration)
    const first = data.categories[0];
    expectJsonbKeys(first, [
      "category",
      "slug",
      "display_name",
      "product_count",
    ]);
    expect(typeof first.slug).toBe("string");
    expect(first.slug.length).toBeGreaterThan(0);
  });
});

describeIntegration("RPC Contract: api_category_listing", () => {
  it("resolves slug to category and returns products", async () => {
    // First get a valid slug
    const { data: overview } = await supabase.rpc("api_category_overview", {
      p_country: "PL",
    });
    const slug = overview?.categories?.[0]?.slug;
    expect(slug).toBeTruthy();

    const { data, error } = await supabase.rpc("api_category_listing", {
      p_category: slug,
    });

    expect(error).toBeNull();
    expect(data).toBeTruthy();
    expectJsonbKeys(data, ["api_version", "products", "total"]);
    expect(Array.isArray(data.products)).toBe(true);
  });
});

describeIntegration("RPC Contract: api_search_products", () => {
  it("returns correct shape for text search", async () => {
    const { data, error } = await supabase.rpc("api_search_products", {
      p_query: "milk",
    });

    expect(error).toBeNull();
    expect(data).toBeTruthy();
    expectJsonbKeys(data, ["api_version", "products", "total", "page", "pages"]);
    expect(Array.isArray(data.products)).toBe(true);
  });
});

describeIntegration("RPC Contract: api_search_autocomplete", () => {
  it("returns suggestions array", async () => {
    const { data, error } = await supabase.rpc("api_search_autocomplete", {
      p_query: "chi",
    });

    expect(error).toBeNull();
    expect(data).toBeTruthy();
    expectJsonbKeys(data, ["api_version", "suggestions"]);
    expect(Array.isArray(data.suggestions)).toBe(true);
  });
});

describeIntegration("RPC Contract: api_get_filter_options", () => {
  it("returns filter options", async () => {
    const { data, error } = await supabase.rpc("api_get_filter_options", {
      p_country: "PL",
    });

    expect(error).toBeNull();
    expect(data).toBeTruthy();
    expect(data).toHaveProperty("api_version");
  });
});

describeIntegration("RPC Contract: api_better_alternatives", () => {
  it("returns alternatives array", async () => {
    // Get a real product_id first
    const { data: scanData } = await supabase.rpc("api_record_scan", {
      p_ean: "5900320001303",
    });
    const productId = scanData?.product_id;
    expect(productId).toBeTruthy();

    const { data, error } = await supabase.rpc("api_better_alternatives", {
      p_product_id: productId,
    });

    expect(error).toBeNull();
    expect(data).toBeTruthy();
    expectJsonbKeys(data, ["api_version", "alternatives"]);
    expect(Array.isArray(data.alternatives)).toBe(true);
  });
});

describeIntegration("RPC Contract: api_product_detail_by_ean", () => {
  it("returns full product detail", async () => {
    const { data, error } = await supabase.rpc("api_product_detail_by_ean", {
      p_ean: "5900320001303",
    });

    expect(error).toBeNull();
    expect(data).toBeTruthy();
    expectJsonbKeys(data, ["api_version", "product"]);

    const product = data.product;
    expect(product).toBeTruthy();
    expectJsonbKeys(product, [
      "product_id",
      "product_name",
      "unhealthiness_score",
    ]);
  });
});
