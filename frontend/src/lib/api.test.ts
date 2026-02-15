import { describe, it, expect, vi, beforeEach } from "vitest";
import {
  listHealthProfiles,
  getActiveHealthProfile,
  createHealthProfile,
  updateHealthProfile,
  deleteHealthProfile,
  getProductHealthWarnings,
} from "@/lib/api";

// ─── Mock the RPC layer ─────────────────────────────────────────────────────

const mockCallRpc = vi.fn();

vi.mock("@/lib/rpc", () => ({
  callRpc: (...args: unknown[]) => mockCallRpc(...args),
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const fakeSupabase = {} as any;

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("Health Profile API functions", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  // ─── listHealthProfiles ───────────────────────────────────────────

  it("listHealthProfiles calls api_list_health_profiles with no params", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { profiles: [] } });
    await listHealthProfiles(fakeSupabase);
    expect(mockCallRpc).toHaveBeenCalledWith(
      fakeSupabase,
      "api_list_health_profiles",
    );
  });

  // ─── getActiveHealthProfile ───────────────────────────────────────

  it("getActiveHealthProfile calls api_get_active_health_profile", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { profile: null } });
    await getActiveHealthProfile(fakeSupabase);
    expect(mockCallRpc).toHaveBeenCalledWith(
      fakeSupabase,
      "api_get_active_health_profile",
    );
  });

  // ─── createHealthProfile ──────────────────────────────────────────

  it("createHealthProfile passes params to api_create_health_profile", async () => {
    const params = {
      p_profile_name: "Test",
      p_health_conditions: ["diabetes"],
      p_is_active: true,
      p_max_sugar_g: 25,
    };
    mockCallRpc.mockResolvedValue({
      ok: true,
      data: { profile_id: "abc", created: true },
    });
    await createHealthProfile(fakeSupabase, params);
    expect(mockCallRpc).toHaveBeenCalledWith(
      fakeSupabase,
      "api_create_health_profile",
      params,
    );
  });

  // ─── updateHealthProfile ──────────────────────────────────────────

  it("updateHealthProfile passes params to api_update_health_profile", async () => {
    const params = { p_profile_id: "p-1", p_profile_name: "Updated" };
    mockCallRpc.mockResolvedValue({
      ok: true,
      data: { profile_id: "p-1", updated: true },
    });
    await updateHealthProfile(fakeSupabase, params);
    expect(mockCallRpc).toHaveBeenCalledWith(
      fakeSupabase,
      "api_update_health_profile",
      params,
    );
  });

  it("updateHealthProfile passes clear flags to api_update_health_profile", async () => {
    const params = {
      p_profile_id: "p-2",
      p_clear_max_sugar: true,
      p_clear_max_salt: false,
      p_clear_max_sat_fat: true,
      p_clear_max_calories: false,
    };
    mockCallRpc.mockResolvedValue({
      ok: true,
      data: { profile_id: "p-2", updated: true },
    });
    await updateHealthProfile(fakeSupabase, params);
    expect(mockCallRpc).toHaveBeenCalledWith(
      fakeSupabase,
      "api_update_health_profile",
      params,
    );
  });

  // ─── deleteHealthProfile ──────────────────────────────────────────

  it("deleteHealthProfile passes profile_id to api_delete_health_profile", async () => {
    mockCallRpc.mockResolvedValue({
      ok: true,
      data: { profile_id: "d-1", deleted: true },
    });
    await deleteHealthProfile(fakeSupabase, "d-1");
    expect(mockCallRpc).toHaveBeenCalledWith(
      fakeSupabase,
      "api_delete_health_profile",
      { p_profile_id: "d-1" },
    );
  });

  // ─── getProductHealthWarnings ─────────────────────────────────────

  it("getProductHealthWarnings calls api_product_health_warnings with product_id", async () => {
    mockCallRpc.mockResolvedValue({
      ok: true,
      data: { product_id: 42, warning_count: 0, warnings: [] },
    });
    await getProductHealthWarnings(fakeSupabase, 42);
    expect(mockCallRpc).toHaveBeenCalledWith(
      fakeSupabase,
      "api_product_health_warnings",
      { p_product_id: 42 },
    );
  });

  it("getProductHealthWarnings includes profile_id when provided", async () => {
    mockCallRpc.mockResolvedValue({
      ok: true,
      data: { product_id: 42, warning_count: 1, warnings: [] },
    });
    await getProductHealthWarnings(fakeSupabase, 42, "prof-1");
    expect(mockCallRpc).toHaveBeenCalledWith(
      fakeSupabase,
      "api_product_health_warnings",
      { p_product_id: 42, p_profile_id: "prof-1" },
    );
  });
});
