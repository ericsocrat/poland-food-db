import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { HealthProfileSection } from "./HealthProfileSection";
import type {
  HealthProfile,
  RpcResult,
  HealthProfileListResponse,
  HealthProfileMutationResponse,
} from "@/lib/types";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockListHealthProfiles = vi.fn();
const mockCreateHealthProfile = vi.fn();
const mockUpdateHealthProfile = vi.fn();
const mockDeleteHealthProfile = vi.fn();

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

vi.mock("@/lib/api", () => ({
  listHealthProfiles: (...args: unknown[]) => mockListHealthProfiles(...args),
  createHealthProfile: (...args: unknown[]) => mockCreateHealthProfile(...args),
  updateHealthProfile: (...args: unknown[]) => mockUpdateHealthProfile(...args),
  deleteHealthProfile: (...args: unknown[]) => mockDeleteHealthProfile(...args),
}));

vi.mock("sonner", () => ({
  toast: {
    success: vi.fn(),
    error: vi.fn(),
  },
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

function makeProfile(overrides: Partial<HealthProfile> = {}): HealthProfile {
  return {
    profile_id: "p-1",
    profile_name: "Test Profile",
    is_active: false,
    health_conditions: [],
    max_sugar_g: null,
    max_salt_g: null,
    max_saturated_fat_g: null,
    max_calories_kcal: null,
    notes: null,
    created_at: "2026-01-01T00:00:00Z",
    updated_at: "2026-01-01T00:00:00Z",
    ...overrides,
  };
}

function okResult<T>(data: T): RpcResult<T> {
  return { ok: true, data };
}

function errResult(message: string): RpcResult<never> {
  return { ok: false, error: { code: "ERR", message } };
}

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false, staleTime: 0 },
    },
  });
  return function Wrapper({ children }: { children: React.ReactNode }) {
    return (
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    );
  };
}

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("HealthProfileSection", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  // ─── Loading state ──────────────────────────────────────────────────

  it("shows loading state initially", () => {
    mockListHealthProfiles.mockReturnValue(new Promise(() => {})); // never resolves
    render(<HealthProfileSection />, { wrapper: createWrapper() });
    expect(screen.getByText("Loading…")).toBeInTheDocument();
  });

  // ─── Empty state ────────────────────────────────────────────────────

  it("shows empty state when no profiles exist", async () => {
    mockListHealthProfiles.mockResolvedValue(
      okResult<HealthProfileListResponse>({
        api_version: "1",
        profiles: [],
      }),
    );

    render(<HealthProfileSection />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText(/No health profiles yet/)).toBeInTheDocument();
    });

    expect(screen.getByText("+ New Profile")).toBeInTheDocument();
  });

  // ─── Profile list ───────────────────────────────────────────────────

  it("renders profiles with names and conditions", async () => {
    const profiles = [
      makeProfile({
        profile_id: "p-1",
        profile_name: "Diabetes Plan",
        is_active: true,
        health_conditions: ["diabetes", "hypertension"],
      }),
      makeProfile({
        profile_id: "p-2",
        profile_name: "Heart Care",
        is_active: false,
        health_conditions: ["heart_disease"],
      }),
    ];

    mockListHealthProfiles.mockResolvedValue(
      okResult<HealthProfileListResponse>({
        api_version: "1",
        profiles,
      }),
    );

    render(<HealthProfileSection />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Diabetes Plan")).toBeInTheDocument();
    });

    expect(screen.getByText("Heart Care")).toBeInTheDocument();
    expect(screen.getByText("Active")).toBeInTheDocument();
    expect(screen.getByText("Diabetes, Hypertension")).toBeInTheDocument();
    expect(screen.getByText("Heart Disease")).toBeInTheDocument();
  });

  // ─── Max profiles ──────────────────────────────────────────────────

  it("hides new profile button at 5 profiles", async () => {
    const profiles = Array.from({ length: 5 }, (_, i) =>
      makeProfile({ profile_id: `p-${i}`, profile_name: `P${i}` }),
    );

    mockListHealthProfiles.mockResolvedValue(
      okResult<HealthProfileListResponse>({
        api_version: "1",
        profiles,
      }),
    );

    render(<HealthProfileSection />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("P0")).toBeInTheDocument();
    });

    expect(screen.queryByText("+ New Profile")).not.toBeInTheDocument();
  });

  // ─── Create form ────────────────────────────────────────────────────

  it("opens create form when + New Profile clicked", async () => {
    mockListHealthProfiles.mockResolvedValue(
      okResult<HealthProfileListResponse>({
        api_version: "1",
        profiles: [],
      }),
    );

    render(<HealthProfileSection />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("+ New Profile")).toBeInTheDocument();
    });

    await userEvent.click(screen.getByText("+ New Profile"));

    expect(screen.getByLabelText("Profile name")).toBeInTheDocument();
    expect(screen.getByText("Health conditions")).toBeInTheDocument();
    expect(
      screen.getByText("Nutrient limits (per 100g, optional)"),
    ).toBeInTheDocument();
    expect(screen.getByLabelText("Notes (optional)")).toBeInTheDocument();
    expect(screen.getByText("Set as active profile")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Create" })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Cancel" })).toBeInTheDocument();
  });

  // ─── Cancel form ────────────────────────────────────────────────────

  it("closes form on cancel", async () => {
    mockListHealthProfiles.mockResolvedValue(
      okResult<HealthProfileListResponse>({
        api_version: "1",
        profiles: [],
      }),
    );

    render(<HealthProfileSection />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("+ New Profile")).toBeInTheDocument();
    });

    await userEvent.click(screen.getByText("+ New Profile"));
    expect(screen.getByLabelText("Profile name")).toBeInTheDocument();

    await userEvent.click(screen.getByRole("button", { name: "Cancel" }));

    await waitFor(() => {
      expect(screen.queryByLabelText("Profile name")).not.toBeInTheDocument();
    });
  });

  // ─── Submit create ──────────────────────────────────────────────────

  it("submits create form and calls API", async () => {
    mockListHealthProfiles.mockResolvedValue(
      okResult<HealthProfileListResponse>({
        api_version: "1",
        profiles: [],
      }),
    );
    mockCreateHealthProfile.mockResolvedValue(
      okResult<HealthProfileMutationResponse>({
        api_version: "1",
        profile_id: "new-id",
        created: true,
      }),
    );

    render(<HealthProfileSection />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("+ New Profile")).toBeInTheDocument();
    });

    await userEvent.click(screen.getByText("+ New Profile"));

    const nameInput = screen.getByLabelText("Profile name");
    await userEvent.type(nameInput, "My Plan");

    // Toggle a condition
    await userEvent.click(screen.getByText(/Diabetes/));

    // Fill nutrient limits
    const sugarInput = screen.getByLabelText("Max sugar (g)");
    await userEvent.type(sugarInput, "25");

    await userEvent.click(screen.getByRole("button", { name: "Create" }));

    await waitFor(() => {
      expect(mockCreateHealthProfile).toHaveBeenCalledTimes(1);
    });

    const callArgs = mockCreateHealthProfile.mock.calls[0][1];
    expect(callArgs.p_profile_name).toBe("My Plan");
    expect(callArgs.p_health_conditions).toContain("diabetes");
    expect(callArgs.p_max_sugar_g).toBe(25);
  });

  // ─── Submit create with empty name ──────────────────────────────────

  it("shows error toast when name is empty", async () => {
    const { toast } = await import("sonner");

    mockListHealthProfiles.mockResolvedValue(
      okResult<HealthProfileListResponse>({
        api_version: "1",
        profiles: [],
      }),
    );

    render(<HealthProfileSection />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("+ New Profile")).toBeInTheDocument();
    });

    await userEvent.click(screen.getByText("+ New Profile"));
    await userEvent.click(screen.getByRole("button", { name: "Create" }));

    expect(toast.error).toHaveBeenCalledWith("Profile name is required");
    expect(mockCreateHealthProfile).not.toHaveBeenCalled();
  });

  // ─── Create API error ──────────────────────────────────────────────

  it("shows error toast on create failure", async () => {
    const { toast } = await import("sonner");

    mockListHealthProfiles.mockResolvedValue(
      okResult<HealthProfileListResponse>({
        api_version: "1",
        profiles: [],
      }),
    );
    mockCreateHealthProfile.mockResolvedValue(errResult("Limit reached"));

    render(<HealthProfileSection />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("+ New Profile")).toBeInTheDocument();
    });

    await userEvent.click(screen.getByText("+ New Profile"));
    await userEvent.type(screen.getByLabelText("Profile name"), "Plan");
    await userEvent.click(screen.getByRole("button", { name: "Create" }));

    await waitFor(() => {
      expect(toast.error).toHaveBeenCalledWith("Limit reached");
    });
  });

  // ─── Edit form ──────────────────────────────────────────────────────

  it("opens edit form with pre-filled values", async () => {
    const profile = makeProfile({
      profile_name: "Existing Plan",
      health_conditions: ["gout"],
      max_sugar_g: 10,
      notes: "Some notes",
    });

    mockListHealthProfiles.mockResolvedValue(
      okResult<HealthProfileListResponse>({
        api_version: "1",
        profiles: [profile],
      }),
    );

    render(<HealthProfileSection />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Existing Plan")).toBeInTheDocument();
    });

    // Click edit button (✏️)
    await userEvent.click(screen.getByText("✏️"));

    const nameInput = screen.getByLabelText("Profile name");
    expect(nameInput).toHaveValue("Existing Plan");

    const notesInput = screen.getByLabelText("Notes (optional)");
    expect(notesInput).toHaveValue("Some notes");
  });

  // ─── Submit update ─────────────────────────────────────────────────

  it("submits update form and calls API", async () => {
    const profile = makeProfile({
      profile_name: "Plan A",
    });

    mockListHealthProfiles.mockResolvedValue(
      okResult<HealthProfileListResponse>({
        api_version: "1",
        profiles: [profile],
      }),
    );
    mockUpdateHealthProfile.mockResolvedValue(
      okResult<HealthProfileMutationResponse>({
        api_version: "1",
        profile_id: "p-1",
        updated: true,
      }),
    );

    render(<HealthProfileSection />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Plan A")).toBeInTheDocument();
    });

    await userEvent.click(screen.getByText("✏️"));

    // The button should say "Update" for editing
    expect(screen.getByRole("button", { name: "Update" })).toBeInTheDocument();

    await userEvent.click(screen.getByRole("button", { name: "Update" }));

    await waitFor(() => {
      expect(mockUpdateHealthProfile).toHaveBeenCalledTimes(1);
    });
  });

  // ─── Clear thresholds sends clear flags ────────────────────────────

  it("sends clear flags when clearing existing thresholds on update", async () => {
    const profile = makeProfile({
      profile_id: "clr-1",
      profile_name: "Has Thresholds",
      max_sugar_g: 15,
      max_salt_g: 2,
      max_saturated_fat_g: 5,
      max_calories_kcal: 500,
    });

    mockListHealthProfiles.mockResolvedValue(
      okResult<HealthProfileListResponse>({
        api_version: "1",
        profiles: [profile],
      }),
    );
    mockUpdateHealthProfile.mockResolvedValue(
      okResult<HealthProfileMutationResponse>({
        api_version: "1",
        profile_id: "clr-1",
        updated: true,
      }),
    );

    render(<HealthProfileSection />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Has Thresholds")).toBeInTheDocument();
    });

    await userEvent.click(screen.getByText("✏️"));

    // Clear the sugar threshold
    const sugarInput = screen.getByLabelText("Max sugar (g)");
    await userEvent.clear(sugarInput);

    await userEvent.click(screen.getByRole("button", { name: "Update" }));

    await waitFor(() => {
      expect(mockUpdateHealthProfile).toHaveBeenCalledTimes(1);
    });

    const callArgs = mockUpdateHealthProfile.mock.calls[0][1];
    // Sugar was cleared: clear flag should be true
    expect(callArgs.p_clear_max_sugar).toBe(true);
    // Other thresholds still have values: clear flags should be false
    expect(callArgs.p_clear_max_salt).toBe(false);
    expect(callArgs.p_clear_max_sat_fat).toBe(false);
    expect(callArgs.p_clear_max_calories).toBe(false);
  });

  // ─── Delete profile ─────────────────────────────────────────────────

  it("calls delete API when delete button clicked", async () => {
    const profile = makeProfile({
      profile_id: "del-1",
      profile_name: "To Delete",
    });

    mockListHealthProfiles.mockResolvedValue(
      okResult<HealthProfileListResponse>({
        api_version: "1",
        profiles: [profile],
      }),
    );
    mockDeleteHealthProfile.mockResolvedValue(
      okResult<HealthProfileMutationResponse>({
        api_version: "1",
        profile_id: "del-1",
        deleted: true,
      }),
    );

    render(<HealthProfileSection />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("To Delete")).toBeInTheDocument();
    });

    await userEvent.click(screen.getByText("🗑️"));

    await waitFor(() => {
      expect(mockDeleteHealthProfile).toHaveBeenCalledWith(
        expect.anything(),
        "del-1",
      );
    });
  });

  // ─── Delete error ──────────────────────────────────────────────────

  it("shows error toast on delete failure", async () => {
    const { toast } = await import("sonner");
    const profile = makeProfile({ profile_id: "err-1", profile_name: "Fail" });

    mockListHealthProfiles.mockResolvedValue(
      okResult<HealthProfileListResponse>({
        api_version: "1",
        profiles: [profile],
      }),
    );
    mockDeleteHealthProfile.mockResolvedValue(errResult("Cannot delete"));

    render(<HealthProfileSection />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Fail")).toBeInTheDocument();
    });

    await userEvent.click(screen.getByText("🗑️"));

    await waitFor(() => {
      expect(toast.error).toHaveBeenCalledWith("Cannot delete");
    });
  });

  // ─── Toggle active ─────────────────────────────────────────────────

  it("toggles active state on a profile", async () => {
    const profile = makeProfile({
      profile_id: "toggle-1",
      profile_name: "Toggle Me",
      is_active: false,
    });

    mockListHealthProfiles.mockResolvedValue(
      okResult<HealthProfileListResponse>({
        api_version: "1",
        profiles: [profile],
      }),
    );
    mockUpdateHealthProfile.mockResolvedValue(
      okResult<HealthProfileMutationResponse>({
        api_version: "1",
        profile_id: "toggle-1",
        updated: true,
      }),
    );

    render(<HealthProfileSection />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Toggle Me")).toBeInTheDocument();
    });

    // Click the play button (▶) to activate
    await userEvent.click(screen.getByText("▶"));

    await waitFor(() => {
      expect(mockUpdateHealthProfile).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({ p_is_active: true }),
      );
    });
  });

  // ─── Toggle active error ───────────────────────────────────────────

  it("shows error toast on toggle failure", async () => {
    const { toast } = await import("sonner");
    const profile = makeProfile({
      profile_id: "terr-1",
      profile_name: "Toggle Err",
      is_active: true,
    });

    mockListHealthProfiles.mockResolvedValue(
      okResult<HealthProfileListResponse>({
        api_version: "1",
        profiles: [profile],
      }),
    );
    mockUpdateHealthProfile.mockResolvedValue(errResult("Toggle failed"));

    render(<HealthProfileSection />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Toggle Err")).toBeInTheDocument();
    });

    // Click pause button (⏸) since it's active
    await userEvent.click(screen.getByText("⏸"));

    await waitFor(() => {
      expect(toast.error).toHaveBeenCalledWith("Toggle failed");
    });
  });

  // ─── Condition chips ───────────────────────────────────────────────

  it("toggles condition chips on and off", async () => {
    mockListHealthProfiles.mockResolvedValue(
      okResult<HealthProfileListResponse>({
        api_version: "1",
        profiles: [],
      }),
    );

    render(<HealthProfileSection />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("+ New Profile")).toBeInTheDocument();
    });

    await userEvent.click(screen.getByText("+ New Profile"));

    // Click Diabetes chip to enable
    const diabetesBtn = screen.getByText(/Diabetes/);
    await userEvent.click(diabetesBtn);
    // Click again to disable
    await userEvent.click(diabetesBtn);

    // The button should still be there (toggled off)
    expect(screen.getByText(/Diabetes/)).toBeInTheDocument();
  });

  // ─── Form inputs ───────────────────────────────────────────────────

  it("allows filling all nutrient limit fields and notes", async () => {
    mockListHealthProfiles.mockResolvedValue(
      okResult<HealthProfileListResponse>({
        api_version: "1",
        profiles: [],
      }),
    );
    mockCreateHealthProfile.mockResolvedValue(
      okResult<HealthProfileMutationResponse>({
        api_version: "1",
        profile_id: "new-2",
        created: true,
      }),
    );

    render(<HealthProfileSection />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("+ New Profile")).toBeInTheDocument();
    });

    await userEvent.click(screen.getByText("+ New Profile"));

    await userEvent.type(
      screen.getByLabelText("Profile name"),
      "Full Input Test",
    );
    await userEvent.type(screen.getByLabelText("Max sugar (g)"), "15");
    await userEvent.type(screen.getByLabelText("Max salt (g)"), "2.5");
    await userEvent.type(screen.getByLabelText("Max sat. fat (g)"), "8");
    await userEvent.type(screen.getByLabelText("Max calories (kcal)"), "500");
    await userEvent.type(
      screen.getByLabelText("Notes (optional)"),
      "Test note",
    );

    // Toggle active checkbox
    await userEvent.click(screen.getByRole("checkbox"));

    await userEvent.click(screen.getByRole("button", { name: "Create" }));

    await waitFor(() => {
      expect(mockCreateHealthProfile).toHaveBeenCalledTimes(1);
    });

    const callArgs = mockCreateHealthProfile.mock.calls[0][1];
    expect(callArgs.p_profile_name).toBe("Full Input Test");
    expect(callArgs.p_max_sugar_g).toBe(15);
    expect(callArgs.p_max_salt_g).toBe(2.5);
    expect(callArgs.p_max_saturated_fat_g).toBe(8);
    expect(callArgs.p_max_calories_kcal).toBe(500);
    expect(callArgs.p_notes).toBe("Test note");
    expect(callArgs.p_is_active).toBe(true);
  });

  // ─── Active profile badge ─────────────────────────────────────────

  it("shows active badge only on active profiles", async () => {
    const profiles = [
      makeProfile({
        profile_id: "a-1",
        profile_name: "Active One",
        is_active: true,
      }),
      makeProfile({
        profile_id: "a-2",
        profile_name: "Inactive One",
        is_active: false,
      }),
    ];

    mockListHealthProfiles.mockResolvedValue(
      okResult<HealthProfileListResponse>({
        api_version: "1",
        profiles,
      }),
    );

    render(<HealthProfileSection />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Active One")).toBeInTheDocument();
    });

    // Only one "Active" badge
    const badges = screen.getAllByText("Active");
    expect(badges).toHaveLength(1);
  });

  // ─── Query error ───────────────────────────────────────────────────

  it("handles list API error by throwing (React Query error boundary)", async () => {
    mockListHealthProfiles.mockResolvedValue(errResult("Database down"));

    // React Query will catch the throw — the component will show error state
    // We suppress console.error from React Query
    const spy = vi.spyOn(console, "error").mockImplementation(() => {});

    render(<HealthProfileSection />, { wrapper: createWrapper() });

    // After error, loading should stop
    await waitFor(() => {
      expect(screen.queryByText("Loading…")).not.toBeInTheDocument();
    });

    spy.mockRestore();
  });
});
