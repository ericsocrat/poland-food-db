# Data Privacy & Compliance Checklist — GDPR/RODO Readiness

> **Last updated:** 2026-02-28
> **Status:** Pre-launch assessment (documentation-only — no automated enforcement yet)
> **Scope:** Poland (PL) primary market + Germany (DE) micro-pilot
> **Regulation:** GDPR (EU 2016/679) / RODO (Polish GDPR implementation — Rozporządzenie o Ochronie Danych Osobowych)
> **Reference:** Issue [#236](https://github.com/ericsocrat/poland-food-db/issues/236)

---

## Table of Contents

1. [Personal Data Inventory](#1-personal-data-inventory)
2. [GDPR/RODO Data Subject Rights](#2-gdprrodo-data-subject-rights)
3. [Health Data Special Category Assessment (Art. 9)](#3-health-data-special-category-assessment-art-9)
4. [Data Retention Policy](#4-data-retention-policy)
5. [Cross-Border Data Transfer Analysis](#5-cross-border-data-transfer-analysis)
6. [Privacy Policy Content Requirements](#6-privacy-policy-content-requirements)
7. [Cookie & Consent Requirements](#7-cookie--consent-requirements)
8. [User Data Export Procedure (Art. 15 / Art. 20)](#8-user-data-export-procedure-art-15--art-20)
9. [User Data Deletion Procedure (Art. 17)](#9-user-data-deletion-procedure-art-17)
10. [Country Expansion Privacy Prerequisites](#10-country-expansion-privacy-prerequisites)
11. [Action Items & Implementation Roadmap](#11-action-items--implementation-roadmap)

---

## 1. Personal Data Inventory

All personal data collected, processed, and stored by the platform, mapped to legal basis and sensitivity classification.

### 1.1 User Data Tables

| Data Category           | Table(s)                                        | Key Fields                                        | Legal Basis (GDPR Art. 6)           | Retention                                   | Sensitivity                                                      |
| ----------------------- | ----------------------------------------------- | ------------------------------------------------- | ----------------------------------- | ------------------------------------------- | ---------------------------------------------------------------- |
| **Account identity**    | `auth.users` (Supabase-managed)                 | email, user_id, created_at                        | Contract (Art. 6(1)(b))             | Until account deletion + 30-day grace       | Standard                                                         |
| **Country preference**  | `user_preferences`                              | country_code, diet_type                           | Consent / Legitimate interest       | Lifetime of account                         | Standard                                                         |
| **Dietary preferences** | `user_preferences`                              | allergen_avoid, allergen_trace, strict_mode       | Consent                             | Lifetime of account                         | Potentially sensitive (allergens may indicate health conditions) |
| **Health conditions**   | `user_health_profiles`                          | health_conditions, sodium/sugar/sat_fat limits    | **Explicit consent (Art. 9(2)(a))** | Lifetime of account (with separate consent) | **Special category (Art. 9)**                                    |
| **Product lists**       | `user_product_lists`, `user_product_list_items` | list names, product selections, notes, sort_order | Consent / Contract                  | Lifetime of account                         | Standard (may reveal dietary patterns)                           |
| **Product comparisons** | `user_comparisons`                              | product_ids, titles, share_tokens                 | Consent / Contract                  | Lifetime of account                         | Standard                                                         |
| **Saved searches**      | `user_saved_searches`                           | query text, filters JSONB, notification prefs     | Consent                             | Lifetime of account                         | Standard (search patterns may reveal health interests)           |
| **Scan history**        | `scan_history`                                  | EAN codes, scanned_at, product_id                 | Legitimate interest / Consent       | **12 months rolling**                       | Standard (reveals purchasing patterns)                           |
| **Product submissions** | `product_submissions`                           | EAN, product_name, brand, photo_url, status       | Consent                             | Until review complete + 90-day archive      | Standard                                                         |
| **Shared content**      | share_tokens on lists/comparisons               | Public URLs with tokens                           | Consent (explicit sharing action)   | Until unshared or account deleted           | Standard                                                         |

### 1.2 Non-Personal Product Data

Product data (products, nutrition_facts, ingredient_ref, product_ingredient, product_allergen_info) is sourced from Open Food Facts (public domain) and does not contain personal data. No GDPR obligations apply to product data.

### 1.3 Data Minimization Assessment

| Principle                   | Status | Notes                                          |
| --------------------------- | ------ | ---------------------------------------------- |
| Only collect what is needed | ✅ Met  | Each user table serves a specific app function |
| No excessive profiling      | ✅ Met  | No behavior tracking beyond scan_history       |
| Health data is optional     | ✅ Met  | App works without health profiles              |
| No location data collected  | ✅ Met  | scan_history does not include geolocation      |

---

## 2. GDPR/RODO Data Subject Rights

Gap analysis of all data subject rights under GDPR, with current implementation status.

### 2.1 Rights Matrix

| Right                         | GDPR Article | Current Status                                                 | Implementation Required                                                                                          |
| ----------------------------- | ------------ | -------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| **Right of access**           | Art. 15      | ⚠️ Partial — `scripts/export_user_data.ps1` exists (admin-only) | Formalize; consider self-service "Download My Data" in Settings                                                  |
| **Right to erasure**          | Art. 17      | ❌ Not implemented                                              | Account deletion flow: cascade delete user_* rows, anonymize scan_history, confirm via email                     |
| **Right to rectification**    | Art. 16      | ✅ Implemented                                                  | Users can edit preferences and profiles in-app; submissions editable if pending                                  |
| **Right to data portability** | Art. 20      | ❌ Not implemented                                              | JSON export of all user_* table data in machine-readable format                                                  |
| **Right to restriction**      | Art. 18      | ❌ Not implemented                                              | Account deactivation flag (soft disable without deletion)                                                        |
| **Right to object**           | Art. 21      | ❌ Not implemented                                              | Opt-out of analytics/telemetry; account deactivation                                                             |
| **Automated decision-making** | Art. 22      | ⚠️ Potentially applicable                                       | Unhealthiness scoring is automated — `api_score_explanation()` provides transparency; document in privacy policy |

### 2.2 Priority Implementation Order

1. **Right to erasure** (Art. 17) — highest regulatory risk; most commonly exercised
2. **Right of access / portability** (Art. 15 / Art. 20) — combine into single "Download My Data" feature
3. **Right to restriction** (Art. 18) — account deactivation flag
4. **Right to object** (Art. 21) — analytics opt-out
5. **Automated decision-making** (Art. 22) — documentation only (score explanation already exists)

---

## 3. Health Data Special Category Assessment (Art. 9)

### 3.1 Data Classification

The `user_health_profiles` table stores:

- **Health conditions**: `health_conditions` array (diabetes, hypertension, celiac_disease, heart_disease, gout, kidney_disease, ibs)
- **Nutrient thresholds**: `max_sodium_mg`, `max_sugar_g`, `max_saturated_fat_g`
- **Profile metadata**: `profile_name`, `is_active`

### 3.2 Assessment

Health conditions are **special category personal data** under GDPR Art. 9(1):

> "Processing of [...] data concerning health [...] shall be prohibited."

**Exception applied:** Art. 9(2)(a) — the data subject has given **explicit consent** to the processing for one or more specified purposes.

### 3.3 Required Consent Properties (Art. 9(2)(a))

Consent for health data must be:

| Requirement      | Description                                                                           | Status                          |
| ---------------- | ------------------------------------------------------------------------------------- | ------------------------------- |
| **Freely given** | Health profile is optional; app works without it                                      | ✅ Met by design                 |
| **Specific**     | Consent is for health profile processing specifically, not bundled with general terms | ❌ Needs separate consent screen |
| **Informed**     | User understands what data is stored and why                                          | ❌ Needs consent text            |
| **Unambiguous**  | Clear affirmative action (not pre-checked boxes)                                      | ❌ Needs explicit opt-in UI      |

### 3.4 Required Implementation

```
1. Separate consent screen before health profile creation
2. Consent text:
   "I consent to [App Name] processing my health condition data
    to provide personalized nutrition warnings and recommendations.
    This data is stored securely and never shared with third parties.
    I can withdraw this consent at any time by deleting my health profile."
3. Consent stored with timestamp: user_health_profiles.consent_given_at
4. Ability to withdraw consent (deletes health profile)
5. Health profile is OPTIONAL — app already works without it
```

### 3.5 Dietary Preferences (Borderline Assessment)

The `user_preferences` table stores allergen arrays (`allergen_avoid`, `allergen_trace`). While allergens are not explicitly listed as special category data, they **may indirectly reveal health conditions** (e.g., gluten avoidance → celiac disease).

**Recommendation:** Treat allergen preferences with elevated care. Include in privacy policy disclosure. Do not require Art. 9 explicit consent (allergens alone are not health data), but mention the possibility in the privacy policy.

---

## 4. Data Retention Policy

### 4.1 Retention Schedule

| Data Type                   | Proposed Retention                           | Justification                                 | Deletion Method                                            |
| --------------------------- | -------------------------------------------- | --------------------------------------------- | ---------------------------------------------------------- |
| Account data (`auth.users`) | Until deletion requested + 30-day grace      | Allow undo of accidental deletion             | Supabase Auth soft delete → hard delete after grace period |
| User preferences            | Lifetime of account                          | Core functionality                            | CASCADE on account deletion                                |
| Health profiles             | Lifetime of account (with separate consent)  | Core functionality (optional)                 | CASCADE on account deletion or consent withdrawal          |
| Product lists               | Lifetime of account                          | User-created content                          | CASCADE on account deletion                                |
| Product comparisons         | Lifetime of account                          | User-created content                          | CASCADE on account deletion                                |
| Saved searches              | Lifetime of account                          | User-created content                          | CASCADE on account deletion                                |
| Scan history                | **12 months rolling**                        | Legitimate interest; older scans lose utility | Automated monthly purge of records > 12 months             |
| Product submissions         | Until reviewed + 90-day archive              | Admin workflow; audit trail                   | Anonymize (set user_id = NULL) after archive period        |
| Shared content tokens       | Until explicitly unshared or account deleted | User-controlled sharing                       | Invalidate tokens on deletion                              |
| Server/application logs     | **30 days**                                  | Debugging and security incident investigation | Automated log rotation                                     |

### 4.2 Automated Retention Enforcement (Future)

Currently no automated retention enforcement exists. Implementation requirements:

1. **scan_history purge** — monthly cron job or Supabase Edge Function:
   ```sql
   DELETE FROM scan_history WHERE scanned_at < NOW() - INTERVAL '12 months';
   ```

2. **product_submissions anonymization** — after review + 90 days:
   ```sql
   UPDATE product_submissions
      SET user_id = NULL
    WHERE status IN ('approved', 'rejected')
      AND updated_at < NOW() - INTERVAL '90 days'
      AND user_id IS NOT NULL;
   ```

3. **Account grace period** — Supabase Auth handles soft delete; hard delete trigger after 30 days.

---

## 5. Cross-Border Data Transfer Analysis

### 5.1 Data Flow Inventory

| Data Flow           | From             | To                            | Mechanism          | GDPR Compliance                                                   |
| ------------------- | ---------------- | ----------------------------- | ------------------ | ----------------------------------------------------------------- |
| User data storage   | User (PL/DE)     | **Supabase (aws-eu-west-1)**  | Direct storage     | ✅ EU region confirmed                                             |
| Product data import | OFF API (France) | Supabase                      | Pipeline import    | ✅ Public data — no personal data involved                         |
| Frontend hosting    | User (PL/DE)     | Vercel (global CDN)           | Edge delivery      | ⚠️ Review Vercel DPA; edge functions may execute in non-EU regions |
| Error monitoring    | User (PL/DE)     | Sentry                        | Error reports      | ⚠️ Review Sentry DPA; ensure EU data residency configured          |
| Auth tokens         | User (PL/DE)     | Supabase Auth (aws-eu-west-1) | Session management | ✅ EU region confirmed                                             |

### 5.2 Supabase Hosting Verification

**Confirmed:** Supabase project `uskvezwftkkudvksmken` is hosted in AWS **eu-west-1** (Ireland).

Evidence: `scripts/export_user_data.ps1` line 48 — `$REMOTE_HOST = "aws-1-eu-west-1.pooler.supabase.com"`.

EU-region hosting satisfies GDPR data residency requirements. No Standard Contractual Clauses (SCCs) needed for Supabase storage.

### 5.3 Action Items — Third-Party Processors

| Processor           | Action                                                               | Status    |
| ------------------- | -------------------------------------------------------------------- | --------- |
| **Supabase**        | Verify DPA (Data Processing Agreement) is signed                     | ⬜ Pending |
| **Vercel**          | Review DPA; check if edge functions process personal data outside EU | ⬜ Pending |
| **Sentry**          | Review DPA; configure EU data residency (sentry.io region setting)   | ⬜ Pending |
| **Open Food Facts** | No DPA needed — public data only, no personal data transferred       | ✅ N/A     |

### 5.4 Sub-Processor Register

GDPR Art. 28(2) requires documentation of all sub-processors:

| Sub-Processor       | Purpose                          | Data Processed                          | Location                | DPA Status              |
| ------------------- | -------------------------------- | --------------------------------------- | ----------------------- | ----------------------- |
| Supabase Inc.       | Database hosting, Auth, Storage  | All user data                           | EU (aws-eu-west-1)      | ⬜ To verify             |
| Vercel Inc.         | Frontend hosting, Edge functions | HTTP requests, session tokens           | Global CDN (EU primary) | ⬜ To verify             |
| Sentry Inc.         | Error monitoring                 | Error traces (may contain user context) | ⬜ To verify             | ⬜ To verify             |
| Amazon Web Services | Infrastructure (via Supabase)    | All Supabase data                       | EU (eu-west-1)          | Covered by Supabase DPA |

---

## 6. Privacy Policy Content Requirements

The privacy policy page (`frontend/src/app/privacy/page.tsx`) must include all items required by GDPR Articles 13 and 14.

### 6.1 Required Sections Checklist

| #   | Requirement (Art. 13/14)                            | Content Source              | Status         |
| --- | --------------------------------------------------- | --------------------------- | -------------- |
| 1   | Identity of data controller                         | Entity name + contact       | ⬜ Draft needed |
| 2   | Contact for privacy inquiries                       | Email address               | ⬜ Draft needed |
| 3   | Types of personal data collected                    | §1 inventory above          | ⬜ Draft needed |
| 4   | Legal basis for each processing activity            | §1 inventory above          | ⬜ Draft needed |
| 5   | Data retention periods                              | §4 retention schedule       | ⬜ Draft needed |
| 6   | Data subject rights and how to exercise them        | §2 rights matrix            | ⬜ Draft needed |
| 7   | Cross-border data transfers and safeguards          | §5 transfer analysis        | ⬜ Draft needed |
| 8   | Cookie / session token usage                        | §7 cookie assessment        | ⬜ Draft needed |
| 9   | Third-party data processors                         | §5.4 sub-processor register | ⬜ Draft needed |
| 10  | Right to lodge complaint with supervisory authority | Polish DPA: UODO            | ⬜ Draft needed |
| 11  | Special category data consent (health profiles)     | §3 Art. 9 assessment        | ⬜ Draft needed |
| 12  | Automated decision-making disclosure                | Score explanation API       | ⬜ Draft needed |
| 13  | Whether provision of data is statutory/contractual  | Voluntary for all fields    | ⬜ Draft needed |

### 6.2 Supervisory Authority

**Polish DPA:** UODO (Urząd Ochrony Danych Osobowych)
- Website: https://uodo.gov.pl/
- Address: ul. Stawki 2, 00-193 Warszawa, Poland
- Users have the right to lodge complaints directly with UODO

**German DPA** (for DE micro-pilot): Relevant Landesdatenschutzbeauftragte, depending on federal state of the data controller.

### 6.3 Legal Review Notes

- The privacy policy **text** requires legal review before public launch
- This checklist provides the **structure and content requirements** — not the legal language
- Polish and German language versions will be needed for the respective markets

---

## 7. Cookie & Consent Requirements

### 7.1 Current Cookie Usage

| Cookie/Token                | Purpose             | Type               | Consent Required?          |
| --------------------------- | ------------------- | ------------------ | -------------------------- |
| Supabase auth session token | User authentication | Strictly necessary | No (exempt under ePrivacy) |
| Supabase refresh token      | Token refresh       | Strictly necessary | No (exempt under ePrivacy) |
| No analytics cookies        | —                   | —                  | —                          |
| No advertising cookies      | —                   | —                  | —                          |
| No third-party tracking     | —                   | —                  | —                          |

### 7.2 Assessment

The platform **currently uses only strictly necessary cookies** (authentication tokens). Under the ePrivacy Directive (2002/58/EC) and its Polish implementation, strictly necessary cookies do **not** require consent.

**No cookie banner is currently required.**

### 7.3 Future Considerations

If the platform adds any of the following, a cookie consent mechanism will be required:
- Analytics cookies (Google Analytics, Plausible, etc.)
- Third-party tracking pixels
- Marketing/advertising cookies
- Non-essential personalization cookies

---

## 8. User Data Export Procedure (Art. 15 / Art. 20)

### 8.1 Existing Tooling

`scripts/export_user_data.ps1` exports all 8 user data tables to a JSON file. This is an admin-operated tool.

### 8.2 SQL Export Query

For individual user data subject access requests (DSAR):

```sql
-- Export all personal data for a specific user
-- Parameter: $1 = user_id (UUID)

SELECT json_build_object(
  'export_date', NOW(),
  'export_format_version', '1.0',
  'user_id', $1,
  'preferences', (
    SELECT row_to_json(p)
      FROM user_preferences p
     WHERE p.user_id = $1
  ),
  'health_profiles', (
    SELECT json_agg(row_to_json(hp))
      FROM user_health_profiles hp
     WHERE hp.user_id = $1
  ),
  'product_lists', (
    SELECT json_agg(json_build_object(
      'list', row_to_json(l),
      'items', (
        SELECT json_agg(row_to_json(li))
          FROM user_product_list_items li
         WHERE li.list_id = l.list_id
      )
    ))
    FROM user_product_lists l
    WHERE l.user_id = $1
  ),
  'comparisons', (
    SELECT json_agg(row_to_json(c))
      FROM user_comparisons c
     WHERE c.user_id = $1
  ),
  'saved_searches', (
    SELECT json_agg(row_to_json(ss))
      FROM user_saved_searches ss
     WHERE ss.user_id = $1
  ),
  'scan_history', (
    SELECT json_agg(row_to_json(sh))
      FROM scan_history sh
     WHERE sh.user_id = $1
  ),
  'submissions', (
    SELECT json_agg(row_to_json(ps))
      FROM product_submissions ps
     WHERE ps.user_id = $1
  )
) AS user_data_export;
```

### 8.3 Self-Service Export (Future)

A self-service "Download My Data" button in the Settings page would satisfy both Art. 15 (access) and Art. 20 (portability) simultaneously. Implementation:
1. Authenticated RPC function wrapping the export query above
2. Frontend button that calls the RPC and triggers a JSON file download
3. Rate-limit: max 1 export per 24 hours per user

---

## 9. User Data Deletion Procedure (Art. 17)

### 9.1 Deletion SQL

```sql
-- Delete all personal data for a specific user (right to erasure)
-- Parameter: $1 = user_id (UUID)
-- Run in a single transaction. CASCADE handles FK relationships where configured.

BEGIN;
  -- 1. Delete user content (CASCADE handles user_product_list_items)
  DELETE FROM user_product_lists WHERE user_id = $1;
  DELETE FROM user_comparisons WHERE user_id = $1;
  DELETE FROM user_saved_searches WHERE user_id = $1;
  DELETE FROM user_health_profiles WHERE user_id = $1;
  DELETE FROM user_preferences WHERE user_id = $1;

  -- 2. Anonymize scan history (retain for aggregate analytics without PII)
  UPDATE scan_history SET user_id = NULL WHERE user_id = $1;

  -- 3. Anonymize product submissions (retain for product data quality)
  UPDATE product_submissions SET user_id = NULL WHERE user_id = $1;

  -- Note: auth.users deletion is handled separately via Supabase Auth Admin API
COMMIT;
```

### 9.2 Deletion Strategy

| Table                  | Action                        | Rationale                                          |
| ---------------------- | ----------------------------- | -------------------------------------------------- |
| `user_preferences`     | DELETE                        | No value without user context                      |
| `user_health_profiles` | DELETE                        | Special category data — must be fully removed      |
| `user_product_lists`   | DELETE (CASCADE to items)     | User-created content                               |
| `user_comparisons`     | DELETE                        | User-created content                               |
| `user_saved_searches`  | DELETE                        | User-created content                               |
| `scan_history`         | ANONYMIZE (user_id = NULL)    | Retain for aggregate category popularity analytics |
| `product_submissions`  | ANONYMIZE (user_id = NULL)    | Retain to preserve product data contributions      |
| `auth.users`           | DELETE via Supabase Admin API | Handled by Supabase; 30-day grace period           |

### 9.3 Shared Content Handling

When a user is deleted:
- **Share tokens** on their lists and comparisons are invalidated (rows deleted)
- Any publicly shared URLs will return 404 after deletion
- This is acceptable behavior per Art. 17 — deletion takes priority over link persistence

### 9.4 Self-Service Deletion (Future)

A "Delete Account" flow in Settings:
1. Confirmation dialog with clear warning text
2. Require password re-entry or email confirmation
3. 30-day grace period (soft delete) with "undo" option
4. Hard delete after grace period expires (executes deletion SQL above + Supabase Auth deletion)

---

## 10. Country Expansion Privacy Prerequisites

### 10.1 Per-Country Requirements

Before expanding to a new country, the following privacy items must be addressed:

| Step | Action                                                | Effort               |
| ---- | ----------------------------------------------------- | -------------------- |
| 1    | Identify country-specific DPA (supervisory authority) | Research             |
| 2    | Check for local GDPR implementation variations        | Legal review         |
| 3    | Add DPA contact information to privacy policy         | Content update       |
| 4    | Verify data hosting complies with local requirements  | Infrastructure check |
| 5    | Translate privacy policy to local language            | Translation          |
| 6    | Review local cookie/consent requirements              | Legal review         |
| 7    | Check if additional consent mechanisms are needed     | Legal review         |

### 10.2 Current Market Status

| Country          | GDPR Implementation            | DPA            | Privacy Policy Language | Status                  |
| ---------------- | ------------------------------ | -------------- | ----------------------- | ----------------------- |
| **Poland (PL)**  | RODO (Ustawa z 10.05.2018)     | UODO           | Polish required         | ⬜ Pending               |
| **Germany (DE)** | BDSG (Bundesdatenschutzgesetz) | Per-state LfDI | German required         | ⬜ Pending (micro-pilot) |

### 10.3 App Store Requirements

Both Apple App Store and Google Play require:
- Published privacy policy URL
- App Privacy "nutrition labels" (Apple) / Data safety section (Google)
- Disclosure of all data types collected
- Purpose of data collection
- Whether data is linked to user identity
- Whether data is used for tracking

---

## 11. Action Items & Implementation Roadmap

### 11.1 Pre-Launch Blockers (P1 when launch approaches)

| #   | Action                                        | Owner              | Depends On | Status |
| --- | --------------------------------------------- | ------------------ | ---------- | ------ |
| 1   | Verify Supabase DPA is signed/active          | Platform           | —          | ⬜      |
| 2   | Verify Vercel DPA and EU data residency       | Platform           | —          | ⬜      |
| 3   | Verify Sentry DPA and EU data residency       | Platform           | —          | ⬜      |
| 4   | Implement health data explicit consent screen | Frontend           | §3.4       | ⬜      |
| 5   | Draft privacy policy content (all §6.1 items) | Legal/Product      | §1–§7      | ⬜      |
| 6   | Legal review of privacy policy text           | Legal              | #5         | ⬜      |
| 7   | Implement "Delete Account" flow               | Frontend + Backend | §9         | ⬜      |
| 8   | Implement "Download My Data" self-service     | Frontend + Backend | §8         | ⬜      |
| 9   | Translate privacy policy (Polish, German)     | Translation        | #6         | ⬜      |
| 10  | Prepare app store privacy disclosures         | Product            | #5         | ⬜      |

### 11.2 Post-Launch Improvements (P2/P3)

| #   | Action                                                      | Priority |
| --- | ----------------------------------------------------------- | -------- |
| 11  | Automated scan_history retention purge (12 months)          | P2       |
| 12  | Automated product_submissions anonymization (90 days)       | P2       |
| 13  | Account deactivation (restriction of processing)            | P3       |
| 14  | Analytics opt-out mechanism                                 | P3       |
| 15  | Cookie consent banner (only if non-essential cookies added) | P3       |
| 16  | Formal DPIA filing with UODO (if required)                  | P3       |

### 11.3 Quarterly Review Cadence

| Quarter | Review Items                                                                               |
| ------- | ------------------------------------------------------------------------------------------ |
| Q1      | Update personal data inventory; verify sub-processor register; review retention compliance |
| Q2      | Audit DSAR response times; review health consent flow; update privacy policy if needed     |
| Q3      | Check new country expansion requirements; review analytics data practices                  |
| Q4      | Annual comprehensive privacy audit; DPA filing check; prepare year-end compliance report   |

---

## References

- **GDPR Full Text:** https://eur-lex.europa.eu/eli/reg/2016/679/oj
- **RODO (Polish Implementation):** Ustawa z dnia 10 maja 2018 r. o ochronie danych osobowych (Dz.U. 2018 poz. 1000)
- **UODO (Polish DPA):** https://uodo.gov.pl/
- **Art. 9 — Special Categories:** https://gdpr-info.eu/art-9-gdpr/
- **Art. 13 — Information to be Provided:** https://gdpr-info.eu/art-13-gdpr/
- **Art. 17 — Right to Erasure:** https://gdpr-info.eu/art-17-gdpr/
- Related issues: [#198](https://github.com/ericsocrat/poland-food-db/issues/198) (Security & Secrets Governance), [#235](https://github.com/ericsocrat/poland-food-db/issues/235) (Data Access Pattern Audit)
- Related docs: [ACCESS_AUDIT.md](ACCESS_AUDIT.md), [SECURITY.md](../SECURITY.md), [COUNTRY_EXPANSION_GUIDE.md](COUNTRY_EXPANSION_GUIDE.md)
