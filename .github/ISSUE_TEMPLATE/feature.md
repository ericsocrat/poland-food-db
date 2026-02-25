---
name: Feature / Significant Change
about: Use for any change introducing new tables, modifying API contracts, adding scoring dimensions, expanding countries/languages, touching >5 files, or introducing new CI/infrastructure.
labels: []
---

# [PREFIX] Title — Crisp Noun-Phrase Subtitle

> **Priority:** P0 / P1 / P2 / P3
> **Workstream:** Frontend / Backend / Data / CI / Security / Governance
> **Estimated effort:** X–Y days
> **Depends on:** #NNN (title), #NNN (title)

---

## Parent Epic (if applicable)

#NNN — Epic Title

---

## Problem Statement

- **What user/developer/system problem does this solve?** (concrete scenario)
- **What current limitation exists?** (link to specific code, schema, or workflow gaps)
- **What measurable improvement does this introduce?** (new coverage, fewer errors, faster pipeline, etc.)
- Quantify current state (e.g., "2,500+ products with no automated integrity check")

## Why This Matters

Bullet list of consequences if this is NOT done:

- **User safety / data trust**: ...
- **Scale / reliability**: ...
- **Regulatory / compliance**: ...

---

## Scope

### In-Scope

1. Specific deliverable A
2. Specific deliverable B

### Out-of-Scope

- Explicit exclusion X (reason or "separate issue")
- Explicit exclusion Y

---

## Architecture Evaluation (if applicable)

| Approach | Verdict     | Reason |
| -------- | ----------- | ------ |
| A. ...   | ❌ Rejected | ...    |
| B. ...   | ✅ Chosen   | ...    |

---

## Technical Implementation Plan

Break into **sequential, independently-shippable steps**.
Each step should include runnable code (SQL, TypeScript, Python, YAML) — not pseudocode.

### Step 1 — [Title]

```sql
-- Actual implementation code
```

### Step N — [Title]

...

---

## Architecture Notes

```
┌──────────────┐     ┌──────────────┐
│  Component A │────▶│  Component B │
└──────────────┘     └──────────────┘
```

---

## Database Changes (if applicable)

- Migration: `YYYYMMDDHHMMSS_description.sql`
- Tables created / altered: ...
- Functions created / altered: ...
- Indexes added: ... (justify each)
- Rollback note: `DROP TABLE IF EXISTS ...`

## API Contract Impact (if applicable)

| Function | Changes | Backward Compatible? |
| -------- | ------- | -------------------- |

## Search & Indexing Impact (if applicable)

- `search_vector` trigger updated?
- New GIN/GiST indexes?
- Synonym entries needed?

## Fallback Logic (if applicable)

```
If A → use X
Else if B → use Y
Else → fallback Z (always safe, always returns a value)
```

---

## Security Considerations

- **Secrets**: Which secrets does this touch? How are they protected?
- **Access control**: RLS impact? Role restrictions? `SECURITY DEFINER` usage?
- **Data exposure**: Does any report/artifact contain PII or sensitive tokens?

## Performance Considerations

- Estimated runtime on current data volume
- Index utilization
- Scale projection (at 2×, 10× current data)

---

## Acceptance Criteria

- [ ] Deliverable A exists and works as described
- [ ] Deliverable B passes [specific test]
- [ ] CI gate / workflow runs green
- [ ] Documentation updated
- [ ] No false positives on clean data
- [ ] Edge cases handled (empty input, NULL, Unicode, etc.)

## Test Requirements

- **SQL / pgTAP**: ...
- **Python**: ...
- **Frontend (Vitest)**: ...
- **E2E (Playwright)**: ...
- **Edge cases**: empty tables, NULL values, Unicode, concurrent access

## Monitoring Requirements (if applicable)

- What to track over time (trend metrics)
- Alert conditions (threshold → notification channel)

---

## Decision Log

| Decision | Choice | Rationale |
| -------- | ------ | --------- |

## Rollback Plan

1. Revert migration: `DROP FUNCTION / DROP TABLE IF EXISTS ...`
2. Remove workflow file / script
3. **Total rollback time:** < N minutes
4. **Data impact:** none / describe

## Risks

| Risk | Likelihood | Impact     | Mitigation |
| ---- | ---------- | ---------- | ---------- |

## Dependencies

| Issue | Relationship                  |
| ----- | ----------------------------- |
| #NNN  | Depends on / Blocks / Related |

## Estimated Effort

- **Complexity:** Small / Medium / Large
- **Duration:** X–Y working days

---

## File Impact

**N files changed, +X / -Y lines:**

- DB migrations, test files, frontend, CI, docs

## Expansion Checklist (if applicable)

| Step | Action | Effort |
| ---- | ------ | ------ |
