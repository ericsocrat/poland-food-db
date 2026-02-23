# Label Taxonomy

Canonical label set for issue and PR triage. Managed via the GitHub UI —
this document is the source of truth for naming, colors, and intended usage.

> **Rule of thumb:** every issue gets exactly **one** Priority, **one** Type, and **one** Domain label.
> Effort and Status labels are optional but encouraged during sprint planning.

---

## Priority

| Label | Color     | Description                               |
| ----- | --------- | ----------------------------------------- |
| `P0`  | `#b60205` | Critical: production outage or data loss  |
| `P1`  | `#d93f0b` | High: significant impact, fix this sprint |
| `P2`  | `#fbca04` | Medium: normal priority                   |
| `P3`  | `#0e8a16` | Low: nice-to-have, backlog                |

## Type

| Label           | Color     | Description                                     |
| --------------- | --------- | ----------------------------------------------- |
| `bug`           | `#d73a4a` | Something isn't working                         |
| `enhancement`   | `#a2eeef` | New feature or request                          |
| `documentation` | `#0075ca` | Improvements or additions to documentation      |
| `type:chore`    | `#ededed` | Maintenance / dependency updates / housekeeping |
| `type:refactor` | `#d4c5f9` | Code restructuring, no behavior change          |
| `question`      | `#d876e3` | Further information is requested                |

## Domain

| Label            | Color     | Description                         |
| ---------------- | --------- | ----------------------------------- |
| `frontend`       | `#1d76db` | Frontend / Next.js / React          |
| `backend`        | `#0052cc` | Backend / API / Supabase functions  |
| `database`       | `#e99695` | Database / SQL / migrations         |
| `migration`      | `#e99695` | Supabase schema migrations          |
| `ci`             | `#5319e7` | CI/CD / GitHub Actions workflows    |
| `security`       | `#b60205` | Security / auth / compliance        |
| `hardening`      | `#b60205` | Security / reliability hardening    |
| `testing`        | `#c2e0c6` | Tests / coverage / QA               |
| `performance`    | `#d4c5f9` | Performance optimization            |
| `accessibility`  | `#0e8a16` | Accessibility (WCAG / a11y)         |
| `ux`             | `#d4c5f9` | User experience improvement         |
| `data-integrity` | `#006b75` | Data pipelines / data quality       |
| `scoring`        | `#006b75` | NutriScore / confidence scoring     |
| `monitoring`     | `#bfd4f2` | Monitoring and alerting             |
| `observability`  | `#bfd4f2` | Logging / tracing / metrics         |
| `analytics`      | `#bfd4f2` | Analytics / dashboards              |
| `admin`          | `#0052cc` | Admin panel / management features   |
| `operations`     | `#f9d0c4` | DevOps / infrastructure             |
| `architecture`   | `#5319e7` | Architecture / system design        |
| `governance`     | `#5319e7` | Project governance / process        |
| `quality`        | `#c2e0c6` | Code quality / technical standards  |
| `multi-country`  | `#0e8a16` | Country expansion (PL, DE, etc.)    |
| `production`     | `#d93f0b` | Production environment issues       |
| `foundational`   | `#0052cc` | Core infrastructure / base features |
| `cross-cutting`  | `#fbca04` | Affects multiple features           |

## Effort

| Label            | Color     | Description          |
| ---------------- | --------- | -------------------- |
| `effort: low`    | `#c2e0c6` | Small: under 2 hours |
| `effort: medium` | `#fbca04` | Medium: 2–8 hours    |
| `effort: high`   | `#d93f0b` | Large: 1–3 days      |

## Status

| Label                 | Color     | Description                              |
| --------------------- | --------- | ---------------------------------------- |
| `status:blocked`      | `#b60205` | Blocked by external dependency           |
| `status:needs-review` | `#fbca04` | Awaiting code review or product decision |
| `deferred`            | `#e6e6e6` | Postponed to a future sprint             |

## Workflow / Meta

| Label              | Color     | Description                               |
| ------------------ | --------- | ----------------------------------------- |
| `good first issue` | `#7057ff` | Good for newcomers                        |
| `help wanted`      | `#008672` | Extra attention is needed                 |
| `duplicate`        | `#cfd3d7` | This issue or pull request already exists |
| `invalid`          | `#e4e669` | This doesn't seem right                   |
| `wontfix`          | `#ffffff` | This will not be worked on                |
| `epic-child`       | `#c5def5` | Child issue of an epic                    |

---

## Conventions

1. **Prefixed labels** (`type:`, `status:`, `effort:`) use a colon namespace to
   keep the label picker tidy.
2. **Colors** follow a severity gradient: red → orange → yellow → green → blue → grey.
3. **Retired labels** should be deleted rather than leaving orphans. Migrate any
   open issues to the replacement label first.
4. **Adding labels** — propose in an issue tagged `governance` before creating.
   Keep the total count under 50.
