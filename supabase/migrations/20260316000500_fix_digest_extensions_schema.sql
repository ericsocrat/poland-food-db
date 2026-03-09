-- Migration: Fix digest() calls to use extensions.digest() for CI compatibility
-- Issue: #773 — QA CI broken on main because bare postgres:17 containers don't
--         have 'extensions' in search_path, so unqualified digest() fails.
-- Rollback: No-op — this only re-upserts formula_source_hashes with the same values.
-- Idempotency: ON CONFLICT DO UPDATE — safe to run 1× or 100×.

-- Re-insert formula source hashes using extensions.digest() so this migration
-- works in CI environments where pgcrypto lives in the extensions schema.
INSERT INTO public.formula_source_hashes (function_name, expected_hash)
VALUES
    ('compute_unhealthiness_v33', encode(extensions.digest(
        (SELECT prosrc FROM pg_proc WHERE proname = 'compute_unhealthiness_v33' LIMIT 1),
        'sha256'
    ), 'hex')),
    ('explain_score_v33', encode(extensions.digest(
        (SELECT prosrc FROM pg_proc WHERE proname = 'explain_score_v33' LIMIT 1),
        'sha256'
    ), 'hex'))
ON CONFLICT (function_name) DO UPDATE SET
    expected_hash = EXCLUDED.expected_hash,
    updated_at = now();
