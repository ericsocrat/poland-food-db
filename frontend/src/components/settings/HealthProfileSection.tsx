"use client";

// ─── Health profile management section for Settings page ────────────────────

import { useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import { createClient } from "@/lib/supabase/client";
import {
  listHealthProfiles,
  createHealthProfile,
  updateHealthProfile,
  deleteHealthProfile,
} from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { HEALTH_CONDITIONS } from "@/lib/constants";
import type { HealthCondition, HealthProfile } from "@/lib/types";

// ─── Sub-component: Create/Edit form ────────────────────────────────────────

function ProfileForm({
  initial,
  onSave,
  onCancel,
}: Readonly<{
  initial?: HealthProfile;
  onSave: () => void;
  onCancel: () => void;
}>) {
  const supabase = createClient();
  const [name, setName] = useState(initial?.profile_name ?? "");
  const [conditions, setConditions] = useState<HealthCondition[]>(
    initial?.health_conditions ?? [],
  );
  const [isActive, setIsActive] = useState(initial?.is_active ?? false);
  const [maxSugar, setMaxSugar] = useState(
    initial?.max_sugar_g?.toString() ?? "",
  );
  const [maxSalt, setMaxSalt] = useState(initial?.max_salt_g?.toString() ?? "");
  const [maxSatFat, setMaxSatFat] = useState(
    initial?.max_saturated_fat_g?.toString() ?? "",
  );
  const [maxCal, setMaxCal] = useState(
    initial?.max_calories_kcal?.toString() ?? "",
  );
  const [notes, setNotes] = useState(initial?.notes ?? "");
  const [saving, setSaving] = useState(false);

  function toggleCondition(c: HealthCondition) {
    setConditions((prev) =>
      prev.includes(c) ? prev.filter((x) => x !== c) : [...prev, c],
    );
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim()) {
      toast.error("Profile name is required");
      return;
    }
    setSaving(true);

    const params = {
      p_profile_name: name.trim(),
      p_health_conditions: conditions,
      p_is_active: isActive,
      p_max_sugar_g: maxSugar ? Number(maxSugar) : undefined,
      p_max_salt_g: maxSalt ? Number(maxSalt) : undefined,
      p_max_saturated_fat_g: maxSatFat ? Number(maxSatFat) : undefined,
      p_max_calories_kcal: maxCal ? Number(maxCal) : undefined,
      p_notes: notes.trim() || undefined,
    };

    const result = initial
      ? await updateHealthProfile(supabase, {
          p_profile_id: initial.profile_id,
          ...params,
          // Send clear flags when editing: if the field was set before but is
          // now empty, explicitly clear it to NULL in the database.
          p_clear_max_sugar: !maxSugar && initial.max_sugar_g != null,
          p_clear_max_salt: !maxSalt && initial.max_salt_g != null,
          p_clear_max_sat_fat: !maxSatFat && initial.max_saturated_fat_g != null,
          p_clear_max_calories: !maxCal && initial.max_calories_kcal != null,
        })
      : await createHealthProfile(supabase, params);

    setSaving(false);

    if (!result.ok) {
      toast.error(result.error.message);
      return;
    }

    toast.success(initial ? "Profile updated" : "Profile created");
    onSave();
  }

  let submitLabel = "Create";
  if (saving) submitLabel = "Saving…";
  else if (initial) submitLabel = "Update";

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      {/* Name */}
      <div>
        <label
          htmlFor="hp-name"
          className="mb-1 block text-sm font-medium text-gray-700"
        >
          Profile name
        </label>
        <input
          id="hp-name"
          type="text"
          value={name}
          onChange={(e) => setName(e.target.value)}
          placeholder="e.g., My Diabetes Care"
          className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
          maxLength={50}
        />
      </div>

      {/* Conditions */}
      <div>
        <p className="mb-2 block text-sm font-medium text-gray-700">
          Health conditions
        </p>
        <div className="flex flex-wrap gap-2">
          {HEALTH_CONDITIONS.map((c) => (
            <button
              key={c.value}
              type="button"
              onClick={() => toggleCondition(c.value as HealthCondition)}
              className={`rounded-full border px-3 py-1.5 text-sm transition-colors ${
                conditions.includes(c.value as HealthCondition)
                  ? "border-brand-300 bg-brand-50 text-brand-700"
                  : "border-gray-200 text-gray-600 hover:border-gray-300"
              }`}
            >
              {c.icon} {c.label}
            </button>
          ))}
        </div>
      </div>

      {/* Nutrient limits */}
      <div>
        <p className="mb-2 block text-sm font-medium text-gray-700">
          Nutrient limits (per 100g, optional)
        </p>
        <div className="grid grid-cols-2 gap-3">
          <div>
            <label
              htmlFor="hp-max-sugar"
              className="mb-1 block text-xs text-gray-500"
            >
              Max sugar (g)
            </label>
            <input
              id="hp-max-sugar"
              type="number"
              min="0"
              step="0.1"
              value={maxSugar}
              onChange={(e) => setMaxSugar(e.target.value)}
              className="w-full rounded border border-gray-300 px-2 py-1.5 text-sm"
              placeholder="—"
            />
          </div>
          <div>
            <label
              htmlFor="hp-max-salt"
              className="mb-1 block text-xs text-gray-500"
            >
              Max salt (g)
            </label>
            <input
              id="hp-max-salt"
              type="number"
              min="0"
              step="0.01"
              value={maxSalt}
              onChange={(e) => setMaxSalt(e.target.value)}
              className="w-full rounded border border-gray-300 px-2 py-1.5 text-sm"
              placeholder="—"
            />
          </div>
          <div>
            <label
              htmlFor="hp-max-sat-fat"
              className="mb-1 block text-xs text-gray-500"
            >
              Max sat. fat (g)
            </label>
            <input
              id="hp-max-sat-fat"
              type="number"
              min="0"
              step="0.1"
              value={maxSatFat}
              onChange={(e) => setMaxSatFat(e.target.value)}
              className="w-full rounded border border-gray-300 px-2 py-1.5 text-sm"
              placeholder="—"
            />
          </div>
          <div>
            <label
              htmlFor="hp-max-cal"
              className="mb-1 block text-xs text-gray-500"
            >
              Max calories (kcal)
            </label>
            <input
              id="hp-max-cal"
              type="number"
              min="0"
              step="1"
              value={maxCal}
              onChange={(e) => setMaxCal(e.target.value)}
              className="w-full rounded border border-gray-300 px-2 py-1.5 text-sm"
              placeholder="—"
            />
          </div>
        </div>
      </div>

      {/* Notes */}
      <div>
        <label
          htmlFor="hp-notes"
          className="mb-1 block text-sm font-medium text-gray-700"
        >
          Notes (optional)
        </label>
        <textarea
          id="hp-notes"
          value={notes}
          onChange={(e) => setNotes(e.target.value)}
          rows={2}
          maxLength={200}
          className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
          placeholder="Any personal notes…"
        />
      </div>

      {/* Active toggle */}
      <label className="flex cursor-pointer items-center gap-3">
        <input
          type="checkbox"
          checked={isActive}
          onChange={(e) => setIsActive(e.target.checked)}
          className="h-4 w-4 rounded border-gray-300 text-brand-600 focus:ring-brand-500"
        />
        <span className="text-sm text-gray-700">Set as active profile</span>
      </label>

      {/* Actions */}
      <div className="flex gap-2">
        <button type="submit" disabled={saving} className="btn-primary flex-1">
          {submitLabel}
        </button>
        <button
          type="button"
          onClick={onCancel}
          className="flex-1 rounded-lg border border-gray-200 px-4 py-2 text-sm text-gray-600 hover:bg-gray-50"
        >
          Cancel
        </button>
      </div>
    </form>
  );
}

// ─── Main section ───────────────────────────────────────────────────────────

export function HealthProfileSection() {
  const supabase = createClient();
  const queryClient = useQueryClient();
  const [editingProfile, setEditingProfile] = useState<
    HealthProfile | "new" | null
  >(null);

  const { data, isLoading } = useQuery({
    queryKey: queryKeys.healthProfiles,
    queryFn: async () => {
      const result = await listHealthProfiles(supabase);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.healthProfiles,
  });

  const profiles = data?.profiles ?? [];

  async function handleDelete(profileId: string) {
    const result = await deleteHealthProfile(supabase, profileId);
    if (!result.ok) {
      toast.error(result.error.message);
      return;
    }
    toast.success("Profile deleted");
    await queryClient.invalidateQueries({
      queryKey: queryKeys.healthProfiles,
    });
    await queryClient.invalidateQueries({
      queryKey: queryKeys.activeHealthProfile,
    });
  }

  async function handleToggleActive(profile: HealthProfile) {
    const result = await updateHealthProfile(supabase, {
      p_profile_id: profile.profile_id,
      p_is_active: !profile.is_active,
    });
    if (!result.ok) {
      toast.error(result.error.message);
      return;
    }
    toast.success(
      profile.is_active ? "Profile deactivated" : "Profile activated",
    );
    await queryClient.invalidateQueries({
      queryKey: queryKeys.healthProfiles,
    });
    await queryClient.invalidateQueries({
      queryKey: queryKeys.activeHealthProfile,
    });
  }

  function handleSaved() {
    setEditingProfile(null);
    queryClient.invalidateQueries({ queryKey: queryKeys.healthProfiles });
    queryClient.invalidateQueries({
      queryKey: queryKeys.activeHealthProfile,
    });
  }

  if (isLoading) {
    return (
      <section className="card">
        <h2 className="mb-3 text-sm font-semibold text-gray-700">
          Health Profiles
        </h2>
        <p className="text-sm text-gray-400">Loading…</p>
      </section>
    );
  }

  return (
    <section className="card">
      <div className="mb-3 flex items-center justify-between">
        <h2 className="text-sm font-semibold text-gray-700">Health Profiles</h2>
        {!editingProfile && profiles.length < 5 && (
          <button
            onClick={() => setEditingProfile("new")}
            className="rounded-lg border border-brand-200 px-3 py-1 text-xs font-medium text-brand-600 hover:bg-brand-50"
          >
            + New Profile
          </button>
        )}
      </div>

      {/* Empty state */}
      {profiles.length === 0 && !editingProfile && (
        <p className="text-sm text-gray-400">
          No health profiles yet. Create one to get personalised product
          warnings.
        </p>
      )}

      {/* Profile list */}
      {profiles.length > 0 && !editingProfile && (
        <div className="space-y-2">
          {profiles.map((profile) => (
            <div
              key={profile.profile_id}
              className={`rounded-lg border p-3 ${
                profile.is_active
                  ? "border-brand-300 bg-brand-50"
                  : "border-gray-200"
              }`}
            >
              <div className="flex items-start justify-between">
                <div>
                  <div className="flex items-center gap-2">
                    <span className="text-sm font-medium text-gray-900">
                      {profile.profile_name}
                    </span>
                    {profile.is_active && (
                      <span className="rounded-full bg-brand-100 px-2 py-0.5 text-xs font-medium text-brand-700">
                        Active
                      </span>
                    )}
                  </div>
                  {profile.health_conditions.length > 0 && (
                    <p className="mt-1 text-xs text-gray-500">
                      {profile.health_conditions
                        .map(
                          (c) =>
                            HEALTH_CONDITIONS.find((hc) => hc.value === c)
                              ?.label ?? c,
                        )
                        .join(", ")}
                    </p>
                  )}
                </div>
                <div className="flex gap-1">
                  <button
                    onClick={() => handleToggleActive(profile)}
                    className="rounded px-2 py-1 text-xs text-gray-500 hover:bg-gray-100"
                    title={profile.is_active ? "Deactivate" : "Set as active"}
                  >
                    {profile.is_active ? "⏸" : "▶"}
                  </button>
                  <button
                    onClick={() => setEditingProfile(profile)}
                    className="rounded px-2 py-1 text-xs text-gray-500 hover:bg-gray-100"
                  >
                    ✏️
                  </button>
                  <button
                    onClick={() => handleDelete(profile.profile_id)}
                    className="rounded px-2 py-1 text-xs text-red-400 hover:bg-red-50"
                  >
                    🗑️
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Form (create or edit) */}
      {editingProfile && (
        <ProfileForm
          initial={editingProfile === "new" ? undefined : editingProfile}
          onSave={handleSaved}
          onCancel={() => setEditingProfile(null)}
        />
      )}
    </section>
  );
}
