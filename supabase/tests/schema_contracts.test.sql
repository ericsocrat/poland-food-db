-- ─── pgTAP: Column existence & type contracts ──────────────────────────────
-- Ensures the columns that RPC functions reference actually exist.
-- This test would have directly caught the nutri_score vs nutri_score_label bug.
-- Run via: supabase test db
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;
SELECT plan(20);

-- ─── products table — columns used by api_record_scan ───────────────────────

SELECT has_column('public', 'products', 'product_id',
  'products has product_id');

SELECT has_column('public', 'products', 'product_name',
  'products has product_name');

SELECT has_column('public', 'products', 'brand',
  'products has brand');

SELECT has_column('public', 'products', 'category',
  'products has category');

SELECT has_column('public', 'products', 'ean',
  'products has ean');

SELECT has_column('public', 'products', 'unhealthiness_score',
  'products has unhealthiness_score');

SELECT has_column('public', 'products', 'nutri_score_label',
  'products has nutri_score_label (NOT nutri_score)');

SELECT has_column('public', 'products', 'nova_classification',
  'products has nova_classification');

SELECT has_column('public', 'products', 'country',
  'products has country');

-- ─── Negative check: columns that should NOT exist ──────────────────────────
-- If someone tries to add a bare "nutri_score" column, alarm bell.

SELECT hasnt_column('public', 'products', 'nutri_score',
  'products must NOT have a bare nutri_score column (use nutri_score_label)');

-- ─── scan_history table ─────────────────────────────────────────────────────

SELECT has_table('public', 'scan_history',
  'scan_history table exists');

SELECT has_column('public', 'scan_history', 'user_id',
  'scan_history has user_id');

SELECT has_column('public', 'scan_history', 'ean',
  'scan_history has ean');

SELECT has_column('public', 'scan_history', 'product_id',
  'scan_history has product_id');

SELECT has_column('public', 'scan_history', 'found',
  'scan_history has found');

-- ─── product_submissions table ──────────────────────────────────────────────

SELECT has_table('public', 'product_submissions',
  'product_submissions table exists');

SELECT has_column('public', 'product_submissions', 'ean',
  'product_submissions has ean');

SELECT has_column('public', 'product_submissions', 'status',
  'product_submissions has status');

-- ─── category_ref table ────────────────────────────────────────────────────

SELECT has_column('public', 'category_ref', 'slug',
  'category_ref has slug column');

SELECT has_column('public', 'category_ref', 'display_name',
  'category_ref has display_name column');

SELECT * FROM finish();
ROLLBACK;
