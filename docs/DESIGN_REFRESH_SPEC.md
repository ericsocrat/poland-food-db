# Mobile-First Design System & UX Refresh Spec

> **Last updated:** 2026-03-14
> **Status:** Draft — planning deliverable, not yet implemented
> **Audience:** Designer, frontend engineer, AI agent
> **Scope:** Mobile-first redesign of TryVit's 86+ component library and 14 app routes
> **Prerequisite reading:** `DESIGN_SYSTEM.md` (tokens), `UX_UI_DESIGN.md` (wireframes), `BRAND_GUIDELINES.md` (identity)

---

## Table of Contents

1. [Design Principles](#1-design-principles)
2. [Mobile-First Layout Rules](#2-mobile-first-layout-rules)
3. [Visual Hierarchy Rules](#3-visual-hierarchy-rules)
4. [Component-by-Component Redesign Spec](#4-component-by-component-redesign-spec)
5. [Copy & Microcopy Rules](#5-copy--microcopy-rules)
6. [Recommended Implementation Order](#6-recommended-implementation-order)

---

## 1. Design Principles

These extend the existing five UX principles (clarity, explainability, trust, no health halos, progressive disclosure) with mobile-specific refinements.

### 1.1 Trust Before Score

The score is TryVit's core value proposition, but **trust in the score** is more important than the score itself. Every product screen must answer three questions in order:

1. **"Where does this data come from?"** — Source badge visible without scrolling.
2. **"How confident is this rating?"** — Confidence shield adjacent to the score.
3. **"What does this number mean?"** — Score interpretation text below the gauge.

**Invariant:** The score number alone is never displayed without at least one trust signal (source badge or confidence indicator) within the same visual card.

### 1.2 One Primary Action Per Viewport

On a 375px-wide screen, the user should never face more than one competing CTA at a time. Action hierarchy:

| Priority | Action                     | Visual Treatment           |
| -------- | -------------------------- | -------------------------- |
| 1        | View healthier alternative | Filled brand-action button |
| 2        | Scan another product       | Bottom-nav highlight       |
| 3        | Add to list / compare      | Ghost or icon-only button  |
| 4        | Share / export             | Overflow menu              |

When multiple actions are visible, only P1 gets a filled button. P2–P4 use progressively quieter treatments.

### 1.3 Glanceable Health Signals

A user scanning a grocery shelf needs answers in under 2 seconds. Above-the-fold content on any product view must pass the **"2-second glance test"**:

- **Score gauge** large enough to read at arm's length (min 64×64px on mobile).
- **Band color** visible as a background tint — not just a small badge.
- **Worst flag** (if any) visible as a single-line chip below the score.
- No more than 3 visual elements competing for attention above the fold.

### 1.4 Progressive Disclosure by Default

Start with the minimum viable answer; let the user pull for more detail. This is already implemented via the `QuickSummary` → full analysis toggle — extend it consistently:

| Level        | What's Shown                                                    | Trigger to Expand                  |
| ------------ | --------------------------------------------------------------- | ---------------------------------- |
| L0 — Glance  | Score gauge + band label + worst flag                           | Tap product card                   |
| L1 — Summary | Traffic lights + top 2 alternatives + score interpretation      | "Show full analysis" button        |
| L2 — Full    | Tabbed analysis (overview / nutrition / alternatives / scoring) | Already open; swipe between tabs   |
| L3 — Deep    | Score breakdown radar, ingredient list, NOVA details            | Within tabs (scroll or sub-expand) |

### 1.5 Consistency Through Constraint

Reduce visual noise by constraining the number of distinct element patterns:

| Element              | Max Variants Allowed                                   |
| -------------------- | ------------------------------------------------------ |
| Card styles          | 3 (standard `.card`, score hero, flag alert)           |
| Badge shapes         | 2 (pill rounded-full, square rounded-lg)               |
| Button sizes         | 3 (sm, md, lg) — no custom sizes                       |
| Text sizes on mobile | 5 (xs 12px, sm 14px, base 16px, lg 18px, xl 20px)      |
| Spacing scale        | 6 stops (1 4px, 2 8px, 3 12px, 4 16px, 6 24px, 8 32px) |

Any component using values outside these constraints must be refactored or get an explicit exemption in this document.

### 1.6 Accessibility as Structure

Accessibility drives layout decisions, not the reverse:

- **Touch targets:** Minimum 48×48px on all interactive elements (per WCAG 2.5.8). The current Navigation already enforces `min-h-[48px] min-w-[64px]`.
- **Color independence:** Score information must be understandable without color (number + text label, not just a colored circle).
- **Motion sensitivity:** All animations respect `prefers-reduced-motion` (already implemented for skeleton shimmer and theme transitions — extend to page transitions and micro-interactions).
- **Focus management:** Tab order follows visual order. Modals trap focus. Page transitions announce route changes via `RouteAnnouncer`.

---

## 2. Mobile-First Layout Rules

### 2.1 Viewport Breakpoint System

Use the existing Tailwind defaults with semantic intent:

| Breakpoint       | px    | Intent                         | Layout                                |
| ---------------- | ----- | ------------------------------ | ------------------------------------- |
| Default (mobile) | 0–639 | Phone portrait                 | Single column, full-width cards       |
| `sm`             | 640+  | Phone landscape / small tablet | 2-column product grids                |
| `lg`             | 1024+ | Tablet / small laptop          | Bottom nav hidden; top header visible |
| `xl`             | 1280+ | Desktop                        | Sidebar + 2-column product detail     |

**Rule:** Always design mobile-default first. Desktop is the enhancement, not the other way around. Every new component must render correctly at 320px width (iPhone SE) before any responsive adjustments.

### 2.2 Spacing System

Standardize on a 4px base grid. Currently globals.css defines spacing tokens — formalize usage rules:

| Token           | Value | Use Case                                                           |
| --------------- | ----- | ------------------------------------------------------------------ |
| `gap-1` / `p-1` | 4px   | Intra-element spacing (between icon and label inside a badge)      |
| `gap-2` / `p-2` | 8px   | Between sibling elements within a card (badge row, flag chips)     |
| `gap-3` / `p-3` | 12px  | Card internal padding on mobile                                    |
| `gap-4` / `p-4` | 16px  | Card internal padding on desktop; between sibling cards            |
| `gap-6`         | 24px  | Section separators (between major page sections)                   |
| `gap-8`         | 32px  | Page-level vertical rhythm (between page header and first section) |

**Card padding rule:** Cards use `p-3` on mobile, `p-4` on `lg+`. Never `p-5` or `p-6` inside cards — that wastes scarce vertical space.

### 2.3 Card Sizes and Touch Zones

| Card Type         | Min Height | Tap Target                 | Use Case                                 |
| ----------------- | ---------- | -------------------------- | ---------------------------------------- |
| Product list item | 72px       | Full card is tappable link | Search results (list view), alternatives |
| Category card     | 80px       | Full card                  | Category grid                            |
| Score hero card   | 120px      | None (informational)       | Product detail left column               |
| Flag chip         | 28px       | Tap to expand explanation  | Health flags row                         |
| Navigation item   | 48px       | Full item                  | Bottom nav, drawer items                 |

### 2.4 Bottom-Nav Safe Area

The fixed bottom navigation is 56px tall + `env(safe-area-inset-bottom)`. All scrollable content must have:

```css
padding-bottom: calc(56px + env(safe-area-inset-bottom) + 16px);
```

The extra 16px prevents the last card from visually touching the nav bar.

### 2.5 Scroll Behavior Rules

| Context                      | Behavior                                                                         |
| ---------------------------- | -------------------------------------------------------------------------------- |
| Product detail — left column | Sticky on desktop (`lg:sticky lg:top-20`); flows normally on mobile              |
| Tab bar                      | Stays in viewport (no sticky needed — it's inline, not fixed)                    |
| Tab content                  | Swipe-to-change tabs (existing `SWIPE_THRESHOLD=50`); vertical scroll within tab |
| Modal/drawer                 | Body scroll locked; drawer/modal content scrolls internally                      |
| Pull-to-refresh              | `PullToRefresh` wrapper on product detail and search results                     |

### 2.6 Image Sizing

| Context                  | Aspect Ratio | Max Width                         | Loading                      |
| ------------------------ | ------------ | --------------------------------- | ---------------------------- |
| Product hero image       | 1:1          | 280px on mobile, 400px on desktop | Skeleton → blur-up           |
| Product thumbnail (list) | 1:1          | 48px                              | Skeleton placeholder         |
| Category icon            | 1:1          | 48px (xl size)                    | Inline SVG, no loading state |
| Scan result image        | 1:1          | 120px                             | Skeleton                     |

---

## 3. Visual Hierarchy Rules

### 3.1 Above-the-Fold Product Detail

The most critical viewport in the app. On a 375×667 phone screen (iPhone SE), the user should see:

```
┌─────────────────────────────┐
│ ← Breadcrumbs               │  12px text, muted
│                              │
│  ┌──────────────────────┐   │
│  │  [Product Image]     │   │  max 180px tall on mobile
│  │                      │   │
│  │  Product Name        │   │  18px bold
│  │  Brand               │   │  14px secondary
│  │  [Share] [Avoid] … │   │  icon buttons, 32px
│  │                      │   │
│  │  NutriScore │ NOVA │ Band│  inline badges
│  │  Category · EAN      │   │  12px muted
│  └──────────────────────┘   │
│                              │
│  ┌──────────────────────┐   │
│  │  ██████████ 82       │   │  Score gauge (64px circle)
│  │  "Excellent"         │   │  Band label
│  │  Headline text       │   │  Score interpretation
│  └──────────────────────┘   │
│                              │
│  [Traffic Light Strip]       │  Nutrition highlights
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  │  fold line (~667px)
└─────────────────────────────┘
```

**Critical ordering (top to bottom):**
1. Product identity (image + name + brand) — "What am I looking at?"
2. Score hero (gauge + band + headline) — "Is this good or bad?"
3. Nutrition highlights (traffic lights) — "Why?"
4. Allergen badges — "Is this safe for me?"
5. Health flags — "Any red flags?"
6. Quick summary / full analysis toggle — "Tell me more"

**Current gap (Issue #891):** Score hero and nutrition highlights may render below the fold on smaller phones. Consolidating the identity card + score into a single compact above-the-fold layout is the primary goal of #891.

### 3.2 Score Display Hierarchy

Three independent scoring systems — never averaged, never combined, always visually distinct:

| System              | Primary Display               | Size                           | Where                          |
| ------------------- | ----------------------------- | ------------------------------ | ------------------------------ |
| **TryVit Score**    | Circular gauge with arc fill  | 64px (mobile) / 80px (desktop) | Score hero card                |
| **Nutri-Score**     | Horizontal letter badge (A–E) | `sm` (16px tall)               | Identity card inline badge row |
| **Data Confidence** | Shield icon with percentage   | `sm`                           | Trust section (below fold)     |

**Visual separation rule:** TryVit Score uses `ScoreGauge` (circular) with band background colors. Nutri-Score uses `NutriScoreBadge` (horizontal letter strip) with EU-regulation colors. Confidence uses a shield icon. These three shapes must never look similar.

### 3.3 Warning Severity System

Health flags and warnings need a unified severity model across the entire app:

| Severity     | Visual             | Token                         | Use Case                            |
| ------------ | ------------------ | ----------------------------- | ----------------------------------- |
| **Critical** | Red chip with icon | `error-bg` / `error-text`     | High sugar, high salt, high sat fat |
| **Warning**  | Amber/orange chip  | `warning-bg` / `warning-text` | Palm oil, many additives            |
| **Info**     | Blue/teal chip     | `info-bg` / `info-text`       | NOVA group 4, low confidence        |
| **Positive** | Green chip         | `success-bg` / `success-text` | No allergens, verified source       |

**Rules:**
- Critical flags always render above the fold if present.
- Maximum 3 flags visible in the chip row; overflow into "Show N more" expandable.
- Flag chips are tappable — tapping reveals a one-sentence explanation (already implemented via `FlagWithExplanation`).
- Never display more than one icon per chip. Text + icon, not icon + icon.

### 3.4 Typography Hierarchy (Mobile)

| Level        | Element                   | Size                        | Weight    | Token                                           |
| ------------ | ------------------------- | --------------------------- | --------- | ----------------------------------------------- |
| H1           | Page title                | 20px                        | 700       | `text-xl font-bold`                             |
| H2           | Section heading           | 14px                        | 600       | `text-sm font-semibold`                         |
| H3           | Card title / product name | 18px (detail) / 14px (list) | 700 / 600 | `text-lg font-bold` / `text-sm font-semibold`   |
| Body         | Content text              | 14px                        | 400       | `text-sm`                                       |
| Caption      | Metadata, secondary info  | 12px                        | 400       | `text-xs`                                       |
| Score number | TryVit Score display      | 20px                        | 700       | `font-score text-xl font-bold` (JetBrains Mono) |
| Badge text   | Inside badges/chips       | 12px                        | 500–600   | `text-xs font-medium`                           |

**Rule:** On mobile, never use `text-base` (16px) for body text inside cards — it's too large. Reserve 16px for standalone paragraphs (onboarding text, empty states, error messages).

### 3.5 Color Usage by Purpose

| Purpose              | Light Theme                                    | Dark Theme                   | Notes                                             |
| -------------------- | ---------------------------------------------- | ---------------------------- | ------------------------------------------------- |
| Primary action       | `brand` (#0d7377)                              | `brand` (#2dd4bf)            | Buttons, active nav, links                        |
| Positive outcome     | `success` green                                | `success` green              | "Better alternative" indicator                    |
| Negative signal      | `error` red                                    | `error` red                  | Health flags, high-severity warnings              |
| Neutral info         | `foreground-secondary`                         | `foreground-secondary`       | Metadata, captions                                |
| Score bands          | Band-specific (5 tiers)                        | Same hues, adjusted contrast | **Invariant across themes**                       |
| Nutri-Score          | EU regulation colors                           | Same colors                  | **Immutable — regulatory**                        |
| Background hierarchy | `surface` → `surface-muted` → `surface-sunken` | Inverted                     | Cards sit on surface; page sits on surface-sunken |

### 3.6 Iconography Rules

| Category                       | Source                          | Size          | Color                                                         |
| ------------------------------ | ------------------------------- | ------------- | ------------------------------------------------------------- |
| Navigation icons               | Lucide React                    | 20px          | `text-foreground-secondary` (inactive), `text-brand` (active) |
| Action icons (share, overflow) | Lucide React                    | 16px          | `text-foreground-secondary`                                   |
| Category icons                 | Custom `CategoryIcon` component | 48px (xl)     | Themed per category                                           |
| Score-related icons            | Custom (gauge, shield)          | Per component | Band-colored                                                  |
| Flag icons                     | Inline with chip text           | 12px          | Matches chip severity color                                   |

**Rule:** Do not mix icon libraries. Lucide is the sole icon source. Custom SVGs are allowed only for brand-specific elements (score gauge, category icons, illustrations).

---

## 4. Component-by-Component Redesign Spec

### 4.1 Product Score Hero — Redesign Target (Issue #891)

**Current:** Separate card below the product identity card. On small screens, the score may render below the fold.

**Proposed:** Merge score display into the identity card as an inline score sidebar:

```
┌──────────────────────────────────────┐
│  [Image]   Product Name          [82]│  ← Score badge inline, right-aligned
│            Brand                Green│  ← Band label below score
│            NutriScore B · NOVA 2     │
│            ⚠ High sugar · Palm oil   │  ← Worst flags inline
│            "Lower concern than 78%…" │  ← Headline as caption
└──────────────────────────────────────┘
```

**Key changes:**
- Score gauge moves from a dedicated card to an inline element (top-right of identity card).
- Band color becomes the card's left border accent (`border-l-4`), not a full background.
- Health flags become inline chips below the badges, not a separate card.
- Trade-off: Loses the large circular gauge on mobile. Retains it on desktop (left column sticky).

**Affected components:** `ProductScoreHero.tsx`, `ScoreGauge.tsx`, product detail `page.tsx`.

### 4.2 Scanner UX States

**Current:** State machine with `idle | scanning | looking-up | found | not-found | error`. Camera view with manual EAN fallback.

**Proposed state-to-layout mapping:**

| State        | Layout                               | Primary Visual                              | CTA                                                         |
| ------------ | ------------------------------------ | ------------------------------------------- | ----------------------------------------------------------- |
| `idle`       | Full camera viewfinder               | Scan frame overlay with crosshair           | "Point at barcode" instruction text                         |
| `scanning`   | Camera + pulse animation on frame    | Subtle pulse on the scan region border      | None (auto-detecting)                                       |
| `looking-up` | Camera freezes or dims               | Score skeleton card slides up from bottom   | Loading spinner in card                                     |
| `found`      | Result card slides up (bottom sheet) | Product name + score gauge + "View details" | "View Details" (primary), "Scan Again" (secondary)          |
| `not-found`  | Bottom sheet with submission prompt  | `ScanMissSubmitCTA`                         | "Submit Product" (primary), "Try Again" (secondary)         |
| `error`      | Classification-specific error card   | Error illustration + recovery action        | Per-error-type CTA (retry, open settings, switch to manual) |

**Micro-interactions:**
- State transitions should animate (slide up, fade) with `duration-normal` (200ms).
- Camera viewfinder: thin white border frame (2px) centered in viewport.
- Manual EAN input: Collapsible text field at bottom — tap "Enter manually" to expand.
- Batch mode: Small count badge on the "Scan Again" button showing items scanned.

### 4.3 Onboarding Wizard

**Current:** 3 steps (WelcomeRegion → DietAllergens → GoalsCategories). Progress indicator. localStorage persistence.

**Proposed improvements:**

| Step | Current Title        | Proposed Title              | Key UX Fix                                            |
| ---- | -------------------- | --------------------------- | ----------------------------------------------------- |
| 1    | "Welcome & Region"   | "Where do you shop?"        | Lead with the actionable question, not a greeting     |
| 2    | "Diet & Allergens"   | "Any dietary needs?"        | Optional step — explicitly label "Skip if none"       |
| 3    | "Goals & Categories" | "What matters most to you?" | Interest tags, not checkboxes — pill-selector pattern |

**Progress indicator (Issue #894):** Replace linear dots with a breadcrumb-style bar showing step names: `Where you shop → Dietary needs → Your priorities`. Each completed step gets a checkmark. User can tap back to a completed step.

**Skip affordance:** Every step except step 1 (region) should have a visible "Skip" text link in the top-right corner. Step 1 is mandatory (region determines product catalog).

### 4.4 Category Browsing

**Current:** 2-column grid of `CategoryCard` components with icon + name + product count + avg score badge.

**Proposed improvements:**

| Element        | Current                                           | Proposed                                                                    |
| -------------- | ------------------------------------------------- | --------------------------------------------------------------------------- |
| Grid           | `grid-cols-2 gap-3 sm:grid-cols-3 xl:grid-cols-4` | Keep columns; increase `gap-4` on mobile                                    |
| Card height    | Variable (content-dependent)                      | Fixed min-height: 100px for visual rhythm                                   |
| Score display  | Small 36px square badge                           | Integrated score bar (existing `CategoryScoreBar`) as bottom strip          |
| Sort/filter    | None                                              | Add "Sort by: Name / Score / Products" dropdown above grid                  |
| Empty category | Never occurs (all have data)                      | If future categories have 0 products: show disabled card with "Coming soon" |

### 4.5 Loading States

Standardize loading patterns across all pages:

| Context                     | Pattern                                   | Component                                            | Duration                |
| --------------------------- | ----------------------------------------- | ---------------------------------------------------- | ----------------------- |
| Page load (route change)    | Full-page skeleton matching target layout | Per-page `*Skeleton` component                       | Until data arrives      |
| Section load (within page)  | Inline skeleton replacing the section     | `Skeleton` (text/rect variants)                      | Until data arrives      |
| Action in progress (button) | Button disabled + spinner inside          | `LoadingSpinner size="sm"` inside button             | Until action completes  |
| Pull-to-refresh             | Spinner at top of scroll area             | `PullToRefresh` wrapper                              | Until refetch completes |
| Image loading               | Gray skeleton → image fade-in             | `Skeleton variant="rect"` + CSS `opacity` transition | Until `onLoad` fires    |

**Rules:**
- Every skeleton must match the shape and approximate size of the content it replaces. No generic "Loading…" text.
- Skeleton shimmer runs at 1.5s cycle (already implemented in globals.css). Respects `prefers-reduced-motion`.
- Never show a spinner and a skeleton simultaneously. Spinner = action; skeleton = content.
- Minimum skeleton display time: 300ms (prevents flash-of-skeleton for fast responses). Use a `setTimeout` delay before showing real content if the fetch resolves in <300ms.

### 4.6 Empty States

Standardize using the existing `EmptyState` component with four variants:

| Variant      | Icon            | Title Pattern              | When                                        |
| ------------ | --------------- | -------------------------- | ------------------------------------------- |
| `no-data`    | `ClipboardList` | "No {items} yet"           | Lists page with 0 lists, scan history empty |
| `no-results` | `Search`        | "No results for '{query}'" | Search with 0 results                       |
| `error`      | `AlertTriangle` | "Something went wrong"     | API error, network failure                  |
| `offline`    | `WifiOff`       | "You're offline"           | No network, cached data unavailable         |

**Rules:**
- Every empty state must have one actionable CTA (e.g., "Start scanning", "Clear filters", "Try again").
- Empty state illustrations (`EmptyStateIllustration`) are optional — use only for `no-data` on primary pages (search, lists). Do not add illustrations to every empty state.
- Empty state minimum height: 180px (already implemented).

### 4.7 Error States

Three-level error boundary system (already implemented — formalize usage):

| Level       | Use Case                         | Recovery                    | Visual                                      |
| ----------- | -------------------------------- | --------------------------- | ------------------------------------------- |
| `page`      | Entire page crashes              | "Try again" + "Go home"     | Full-page centered layout with illustration |
| `section`   | One section of a page crashes    | "Try again"                 | Dashed-border card replacing the section    |
| `component` | A single badge or widget crashes | None (graceful degradation) | Minimal `—` placeholder                     |

**Error category mapping** (already implemented in `ErrorBoundary`):
- `network` → offline illustration + "Check your connection"
- `auth` → server illustration + "Sign in again"
- `server` → server illustration + "Something went wrong"
- `unknown` → server illustration + generic message

**Rule:** Every data-dependent section must be wrapped in `<ErrorBoundary level="section">`. The product detail page already does this for `HealthWarningsCard` and tab content — extend to all sections.

### 4.8 Badge Inventory — Standardization

Current badge components and their intended visual language:

| Component         | Shape                     | Use                    | Size Options |
| ----------------- | ------------------------- | ---------------------- | ------------ |
| `ScoreBadge`      | Pill (sm/md) or Ring (lg) | TryVit Score           | sm, md, lg   |
| `NutriScoreBadge` | Horizontal letter strip   | Nutri-Score A–E        | sm, md       |
| `NovaBadge`       | Square with number        | NOVA 1–4               | sm, md       |
| `ConfidenceBadge` | Shield icon + text        | Data confidence 0–100  | One size     |
| `PercentileBadge` | Pill                      | Category ranking       | One size     |
| `Badge` (generic) | Pill                      | General purpose labels | default      |
| `Chip`            | Pill with optional close  | Filter chips, tags     | default      |

**Rule:** Do not create new badge components. Map new information types to an existing badge shape. If none fits, extend `Badge` with a new `variant` prop.

### 4.9 Cards — Three Standard Patterns

| Pattern           | CSS                            | Internal Padding               | Use Cases                                          |
| ----------------- | ------------------------------ | ------------------------------ | -------------------------------------------------- |
| **Standard card** | `.card`                        | `p-3` (mobile) `p-4` (desktop) | Product identity, nutrition facts, ingredient list |
| **Score hero**    | `.card` + band bg color        | `p-4`                          | Score gauge display                                |
| **Alert card**    | `.card` + severity border-left | `p-3`                          | Health warnings, flags                             |

**Rule:** No new card patterns. Everything is a `.card` with optional left-border accent for severity. Background color tinting (band colors) is reserved for score hero only.

---

## 5. Copy & Microcopy Rules

### 5.1 Voice & Tone

Inherited directly from `BRAND_GUIDELINES.md` — restated here for quick reference:

| Context              | Voice                  | Example ✅                                          | Anti-Example ❌                             |
| -------------------- | ---------------------- | -------------------------------------------------- | ------------------------------------------ |
| Score interpretation | Factual, neutral       | "Lower concern than 78% of Dairy"                  | "This is a great healthy choice!"          |
| Health flag          | Descriptive            | "High sugar (22g per 100g)"                        | "Too much sugar — avoid this!"             |
| Empty state          | Helpful, inviting      | "No products scanned yet. Try scanning a barcode." | "Nothing here. You haven't done anything." |
| Error message        | Empathetic, actionable | "We couldn't load this section. Tap to retry."     | "Error 500. Internal server error."        |
| CTA button           | Imperative, concise    | "View details" / "Scan barcode"                    | "Click here to see more info"              |

### 5.2 Length Constraints

| Element                    | Max Characters     | Overflow Handling                                |
| -------------------------- | ------------------ | ------------------------------------------------ |
| Product name (card)        | 2 lines            | `line-clamp-2`                                   |
| Product name (detail page) | Unlimited          | Wraps naturally                                  |
| Brand name                 | 1 line             | `truncate`                                       |
| Badge label                | 12 characters      | Abbreviate (e.g., "Sat Fat" not "Saturated Fat") |
| Button label               | 20 characters      | Use shorter verb form                            |
| Toast / notification       | 1 line (~60 chars) | Truncate with "…"                                |
| Score headline             | 2 lines            | `line-clamp-2`                                   |

### 5.3 Number Formatting

| Value              | Format                            | Example         |
| ------------------ | --------------------------------- | --------------- |
| TryVit Score       | Integer, no decimal               | "82"            |
| Nutrition per 100g | 1 decimal max                     | "3.5g"          |
| Percentage         | Integer unless <1%                | "78%" or "0.5%" |
| Product count      | Integer with "products" label     | "142 products"  |
| EAN                | Raw 13-digit string, no separator | "5901234567890" |

### 5.4 i18n Key Naming Convention

All user-facing strings live in `/messages/{locale}.json`. Keys follow:

```
{domain}.{subject}.{action/descriptor}
```

Examples:
- `product.score.excellent` — Score band label
- `scanner.error.cameraBlocked` — Scanner error message
- `onboarding.step.region` — Onboarding step title
- `common.retry` — Shared button label

**Rules:**
- 3-segment keys minimum. Never `retry` alone — always `common.retry`.
- Boolean conditions use `{key}Yes` / `{key}No` suffix, not separate keys.
- Counts use ICU `{count, plural, one {# product} other {# products}}` (via `next-intl` or manual interpolation).

### 5.5 Never Say These

| ❌ Forbidden               | ✅ Use Instead                             | Reason                                                |
| ------------------------- | ----------------------------------------- | ----------------------------------------------------- |
| "Healthy" / "Unhealthy"   | "Lower/higher concern"                    | Binary health claims are inaccurate and legally risky |
| "Best" / "Worst"          | "Lowest/highest score in category"        | Superlatives imply absolute judgment                  |
| "Safe" / "Dangerous"      | "No flagged concerns" / "High [nutrient]" | We're not medical advice                              |
| "You should" / "You must" | "Consider" / "You may want to"            | Autonomous choice, not prescription                   |
| "Diet" (as weight loss)   | "Dietary preferences"                     | We mean food restrictions, not weight management      |
| "Clean" / "Dirty" (food)  | "Fewer additives" / "More additives"      | Moralization of food choices                          |
| "Natural"                 | "Minimal processing" (NOVA 1–2)           | "Natural" has no regulatory definition                |

---

## 6. Recommended Implementation Order

Based on: user impact, issue dependencies, codebase readiness, and the scanner observation pause.

### Phase 1 — Foundation (No Visual Changes, Enables Everything Else)

**Goal:** Codify rules into enforceable patterns before changing any UI.

| Step | Deliverable                                                                                  | Effort | Issue |
| ---- | -------------------------------------------------------------------------------------------- | ------ | ----- |
| 1.1  | Add `CardPattern` component wrapping `.card` with `variant` prop (standard / hero / alert)   | S      | New   |
| 1.2  | Add `FlagChip` component standardizing severity chips (critical / warning / info / positive) | S      | New   |
| 1.3  | Audit all badge components — ensure consistent size mapping (sm/md/lg)                       | S      | New   |
| 1.4  | Document spacing constants and enforce `p-3`/`p-4` card rule in linting or code review       | S      | New   |

### Phase 2 — Above-the-Fold Product Detail (Highest User Impact)

**Goal:** Ensure score is visible without scrolling on all phone sizes.

| Step | Deliverable                                                                                   | Effort | Issue |
| ---- | --------------------------------------------------------------------------------------------- | ------ | ----- |
| 2.1  | Consolidate identity card + score hero into single compact card per spec §4.1                 | M      | #891  |
| 2.2  | Inline health flags as chips inside identity card                                             | S      | #891  |
| 2.3  | Verify above-fold rendering on 375×667 (iPhone SE), 390×844 (iPhone 14), 360×800 (Galaxy S21) | S      | #891  |
| 2.4  | Add visual regression Playwright tests for product detail at 3 viewport sizes                 | S      | #891  |

### Phase 3 — Onboarding Polish

**Goal:** Reduce onboarding abandonment with clearer step titles and navigation.

| Step | Deliverable                                            | Effort | Issue |
| ---- | ------------------------------------------------------ | ------ | ----- |
| 3.1  | Add breadcrumb-style progress bar with step names      | S      | #894  |
| 3.2  | Add back navigation between steps                      | S      | #894  |
| 3.3  | Update step titles per spec §4.3 (question-led titles) | S      | #894  |

### Phase 4 — Category & Search Polish

**Goal:** Improve browsing rhythm and visual consistency.

| Step | Deliverable                                                           | Effort | Issue |
| ---- | --------------------------------------------------------------------- | ------ | ----- |
| 4.1  | Add sort controls to category overview grid (Name / Score / Products) | S      | New   |
| 4.2  | Standardize category card min-height for visual rhythm                | S      | New   |
| 4.3  | Verify search results list/grid view consistency with new card rules  | S      | New   |

### Phase 5 — Scanner State UX (After Observation Window)

**Goal:** Refine scanner micro-interactions based on telemetry data from #889 Phase 1.

| Step | Deliverable                                                   | Effort | Issue   |
| ---- | ------------------------------------------------------------- | ------ | ------- |
| 5.1  | Implement bottom-sheet result card (slide-up) for found state | M      | #889 P2 |
| 5.2  | Add classification-specific error illustrations               | S      | #889 P2 |
| 5.3  | Add batch mode count badge                                    | S      | #889 P2 |

**Gating condition:** Do not start Phase 5 until the 7-day telemetry observation window is complete and thresholds from the review plan have been evaluated.

### Phase 6 — Health Goal Personalization (Design Phase)

**Goal:** Design the data model for personalized health warnings.

| Step | Deliverable                                           | Effort | Issue |
| ---- | ----------------------------------------------------- | ------ | ----- |
| 6.1  | Define health-goal → nutrient-threshold mapping model | M      | #892  |
| 6.2  | Design personalized warning card UI                   | S      | #892  |
| 6.3  | Plan API changes (RPC parameters, response shape)     | S      | #892  |

### Phase 7 — Data Provenance Indicators

**Goal:** Surface data quality signals to build user trust.

| Step | Deliverable                                                         | Effort | Issue |
| ---- | ------------------------------------------------------------------- | ------ | ----- |
| 7.1  | Populate `nutri_score_source` via pipeline                          | M      | #893  |
| 7.2  | Add source provenance badge to product detail                       | S      | #893  |
| 7.3  | Add confidence-aware visual de-emphasis for low-confidence products | S      | #893  |

### Phase 8 — Ingredient Language Model (Architecture)

**Goal:** Enable multilingual ingredient display.

| Step | Deliverable                                                | Effort | Issue |
| ---- | ---------------------------------------------------------- | ------ | ----- |
| 8.1  | Define `language_ref` table + seed data                    | S      | #890  |
| 8.2  | Design `ingredient_translations` population strategy       | M      | #890  |
| 8.3  | Plan `resolve_ingredient_name()` integration with frontend | S      | #890  |

---

## Appendix A — Component Inventory (Current State)

### Product Domain (36 components)

| Component                    | Purpose                                  | Redesign Priority                           |
| ---------------------------- | ---------------------------------------- | ------------------------------------------- |
| `ProductScoreHero`           | Score card with gauge + band             | **HIGH** — consolidate into identity (§4.1) |
| `ScoreGauge`                 | Circular SVG score ring                  | Medium — keep but make responsive           |
| `ScoreBreakdownPanel`        | Factor-by-factor score table             | Low — L2 content                            |
| `ScoreRadarChart`            | Radar visualization of score factors     | Low — L3 content                            |
| `ScoreHistoryPanel`          | Score changes over time                  | Low — L3 content                            |
| `ScoreTrendChart`            | Line chart of historical scores          | Low — L3 content                            |
| `ScoreChangeIndicator`       | Delta badge showing score change         | Low                                         |
| `AllergenMatrix`             | Full allergen grid                       | Low — L2 content                            |
| `AllergenQuickBadges`        | Above-fold allergen pills                | Medium — verify visibility                  |
| `AvoidBadge`                 | "Avoid" toggle badge                     | Low                                         |
| `ConflictWarnings`           | Score conflict alerts                    | Medium                                      |
| `HealthWarningsCard`         | Personalized health warnings             | Medium                                      |
| `IngredientList`             | Full ingredient list with concerns       | Low — L2 content                            |
| `NovaIndicator`              | NOVA group display                       | Low                                         |
| `TrafficLightChip` / `Strip` | UK-style nutrition traffic lights        | Medium — key above-fold element             |
| `NutritionDVBar`             | Daily value percentage bar               | Low — L2 content                            |
| `NutritionHighlights`        | Key nutrient summary                     | Medium — above-fold candidate               |
| `ProductHeroImage`           | Product photo with fallback              | Medium — affects above-fold height          |
| `ShareButton`                | Share action                             | Low                                         |
| `WatchButton`                | Watchlist toggle                         | Low                                         |
| `ActionOverflowMenu`         | Mobile overflow (⋯)                      | Low                                         |
| `AddToListMenu`              | Add to list dropdown                     | Low                                         |
| `CrossCountryLinks`          | Links to same product in other countries | Low                                         |

### Common / Shared (47 components)

All are stable and well-tested. No redesign needed — just ensure compliance with spacing and size constraints in §2.

### Scan (2 components)

| Component           | Redesign Priority                          |
| ------------------- | ------------------------------------------ |
| `ContributorBadge`  | Low                                        |
| `ScanMissSubmitCTA` | Medium — part of scanner `not-found` state |

---

## Appendix B — Design Token Gap Analysis

### Tokens Present and Well-Used
- Surface hierarchy (surface, surface-muted, surface-sunken) ✅
- Score band colors (5 tiers, invariant across themes) ✅
- Nutri-Score colors (EU-immutable) ✅
- Semantic feedback (success, warning, error, info) ✅
- Typography scale ✅
- Spacing scale ✅
- Border radius scale ✅
- Transition durations ✅
- Elevation (shadow tokens) ✅

### Tokens Missing or Underspecified

| Gap                                                 | Recommendation                                                                                                                     | Priority |
| --------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | -------- |
| No severity-specific border tokens                  | Add `--color-border-critical`, `--color-border-warning`, `--color-border-info` for alert card left borders                         | Medium   |
| No explicit "above-fold" spacing token              | Add `--spacing-above-fold-max` = 600px as a reminder constant (not a CSS property — a design lint rule)                            | Low      |
| Accent gold (`brand-accent`) fails WCAG AA on white | Document: "gold is decorative only — never use for text on light backgrounds". Already noted in DESIGN_SYSTEM.md but not enforced. | Low      |
| No skeleton-specific color tokens                   | Currently hardcoded in `.skeleton` CSS. Extract to `--color-skeleton-base` and `--color-skeleton-shine` for theme consistency.     | Low      |

---

## Appendix C — Cross-References

| This Spec Section    | Existing Doc                      | Relationship                                |
| -------------------- | --------------------------------- | ------------------------------------------- |
| §1 Design Principles | `UX_UI_DESIGN.md` §1              | Extends with mobile-specific refinements    |
| §2 Layout Rules      | `DESIGN_SYSTEM.md` spacing tokens | Formalizes usage rules for existing tokens  |
| §3.2 Score Display   | `SCORING_METHODOLOGY.md`          | References scoring bands (invariant)        |
| §3.5 Color Usage     | `BRAND_GUIDELINES.md` §4          | Restates color roles with UI-specific rules |
| §4.1 Product Detail  | Issue #891                        | Direct implementation target                |
| §4.3 Onboarding      | Issue #894                        | Direct implementation target                |
| §4.2 Scanner         | Issue #889 Phase 2                | Gated by telemetry observation              |
| §5 Copy Rules        | `BRAND_GUIDELINES.md` §6          | Extends voice/tone for UI microcopy         |

---

## Changelog

| Date       | Author         | Change                                                             |
| ---------- | -------------- | ------------------------------------------------------------------ |
| 2026-03-14 | GitHub Copilot | Initial spec — 6 sections, 10 focus areas, based on codebase audit |
