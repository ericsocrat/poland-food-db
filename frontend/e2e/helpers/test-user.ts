// ─── E2E test user lifecycle ─────────────────────────────────────────────────
// Creates and tears down a Supabase Auth user for authenticated Playwright tests.
// Requires SUPABASE_SERVICE_ROLE_KEY to access the Admin API.

import { createClient, type SupabaseClient } from "@supabase/supabase-js";

export const TEST_EMAIL = "e2e-playwright@test.fooddb.local";
export const TEST_PASSWORD = "PlaywrightTest123!";

function getAdminClient(): SupabaseClient {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!url || !key) {
    throw new Error(
      "Missing NEXT_PUBLIC_SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY",
    );
  }

  return createClient(url, key, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
}

/** Delete any existing test user, then create a fresh auto-confirmed one. */
export async function ensureTestUser(): Promise<string> {
  const supabase = getAdminClient();

  // Remove stale test user if present (idempotent)
  const {
    data: { users },
  } = await supabase.auth.admin.listUsers();
  const existing = users.find((u) => u.email === TEST_EMAIL);
  if (existing) {
    await supabase.auth.admin.deleteUser(existing.id);
  }

  // Create fresh, pre-confirmed user
  const { data, error } = await supabase.auth.admin.createUser({
    email: TEST_EMAIL,
    password: TEST_PASSWORD,
    email_confirm: true,
  });

  if (error) {
    throw new Error(`Failed to create test user: ${error.message}`);
  }

  return data.user.id;
}

/** Delete the test user (best-effort cleanup). */
export async function deleteTestUser(): Promise<void> {
  const supabase = getAdminClient();

  const {
    data: { users },
  } = await supabase.auth.admin.listUsers();
  const user = users.find((u) => u.email === TEST_EMAIL);
  if (user) {
    await supabase.auth.admin.deleteUser(user.id);
  }
}
