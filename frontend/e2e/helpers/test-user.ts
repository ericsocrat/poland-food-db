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

/**
 * Find the test user by email using paginated search.
 * Stops early when found instead of loading all users.
 */
async function findTestUserById(
  supabase: SupabaseClient,
): Promise<string | null> {
  const PAGE_SIZE = 50;
  let page = 1;

  // eslint-disable-next-line no-constant-condition
  while (true) {
    const {
      data: { users },
    } = await supabase.auth.admin.listUsers({ page, perPage: PAGE_SIZE });

    const match = users.find((u) => u.email === TEST_EMAIL);
    if (match) return match.id;

    // No more pages
    if (users.length < PAGE_SIZE) return null;
    page++;
  }
}

/** Delete any existing test user, then create a fresh auto-confirmed one. */
export async function ensureTestUser(): Promise<string> {
  const supabase = getAdminClient();

  // Remove stale test user if present (idempotent) — paginated search
  const existingId = await findTestUserById(supabase);
  if (existingId) {
    await supabase.auth.admin.deleteUser(existingId);
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

  const userId = await findTestUserById(supabase);
  if (userId) {
    await supabase.auth.admin.deleteUser(userId);
  }
}
