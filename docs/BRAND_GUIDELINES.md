# Brand Guidelines — Poland Food Quality Database

> **Last updated:** 2026-03-14
> **Status:** Active (incremental — updates as #407/#408 complete)
> **Owner issue:** [#410](https://github.com/ericsocrat/poland-food-db/issues/410)
> **Parent epic:** [#397](https://github.com/ericsocrat/poland-food-db/issues/397) — Brand Identity Foundation

This document is the single source of truth for the project's visual identity. It enables any contributor or designer to produce on-brand assets without guessing. All color values are sourced from `docs/assets/design-tokens.json` and `frontend/src/styles/globals.css`.

---

## Table of Contents

1. [Brand Overview](#1-brand-overview)
2. [Logo Usage](#2-logo-usage)
3. [Color System](#3-color-system)
4. [Typography](#4-typography)
5. [Iconography](#5-iconography)
6. [Illustration Style](#6-illustration-style)
7. [Photography Direction](#7-photography-direction)
8. [Component Patterns](#8-component-patterns)
9. [Spacing & Layout](#9-spacing--layout)
10. [Motion & Animation](#10-motion--animation)
11. [Accessibility](#11-accessibility)
12. [Dark Mode](#12-dark-mode)
13. [Co-branding](#13-co-branding)
14. [Asset Inventory](#14-asset-inventory)

---

## 1. Brand Overview

### Mission

Empower consumers in Poland (and expanding to Europe) to make healthier food choices by providing transparent, science-driven quality scores for grocery products — grounded in real EU label data, never invented.

### Brand Personality

| Trait            | Expression                                                                                  |
| ---------------- | ------------------------------------------------------------------------------------------- |
| **Trustworthy**  | Every data point traced to a source. Confidence bands show data quality. No hidden logic.  |
| **Scientific**   | EFSA-based additive classification. Nutri-Score follows EU regulation. Peer-reviewable formula. |
| **Clean**        | Minimal UI, generous whitespace, no clutter. Data-dense but visually breathable.           |
| **Data-driven**  | Numbers first. Score breakdowns, not opinion. Quantified ingredient concerns, not vague warnings. |
| **Health-focused** | Green = low risk, red = high risk. Every visual decision reinforces health-conscious choices. |
| **European**     | Poland-first, EU regulatory alignment, RODO/GDPR compliant, multi-language ready.          |

### Voice & Tone

| Context             | Tone                  | Example                                                             |
| ------------------- | --------------------- | ------------------------------------------------------------------- |
| **Score labels**     | Factual, neutral     | "Elevated risk" (not "Unhealthy!"), "Low risk" (not "Super healthy") |
| **Error messages**   | Helpful, brief       | "Product not found. Try scanning the barcode again."                |
| **Onboarding**       | Encouraging, simple  | "Pick your country to see local products."                          |
| **Data confidence**  | Transparent, honest  | "Confidence: Estimated — some nutrition data may be incomplete."    |
| **Health warnings**  | Clinical, objective  | "High in saturated fat (12g per 100g). Daily reference: 20g."      |

**Writing rules:**

- Never use superlatives ("best", "worst", "healthiest") — use comparative language ("lower score", "fewer additives").
- Never moralize ("you should avoid") — present data and let users decide.
- Prefer metric units (g, kcal, mg). No imperial units.
- Product names are legal label text — never modify, abbreviate, or translate them.

---

## 2. Logo Usage

> **Status:** Active — logomark (#407) and lockups (#408) finalized.

### Logo Variants

| Variant                | File                         | Use Case                                  |
| ---------------------- | ---------------------------- | ----------------------------------------- |
| Icon-only (full color) | `logomark.svg`               | App icons, favicons (32px+), badges       |
| Icon-only (dark mode)  | `logomark-dark.svg`          | App icons on dark backgrounds             |
| Icon-only (mono)       | `logomark-mono.svg`          | Single-color contexts, watermarks, print  |
| Horizontal lockup      | `lockup-horizontal.svg`      | Navigation bar, email headers, banners    |
| Horizontal lockup (dark) | `lockup-horizontal-dark.svg` | Nav bar on dark backgrounds            |
| Stacked lockup         | `lockup-stacked.svg`         | Marketing materials, splash screens       |
| Stacked lockup (dark)  | `lockup-stacked-dark.svg`    | Splash screens on dark backgrounds        |
| Wordmark               | `wordmark.svg`               | Text-only contexts (placeholder name)     |
| Wordmark (dark)        | `wordmark-dark.svg`          | Text-only on dark backgrounds             |

> **Wordmark note:** The wordmark is a deliberate placeholder. When the project name changes, regenerate `wordmark.svg` and `wordmark-dark.svg`. The lockup architecture makes this swap trivial — only the `<text>` element changes.

### Clear Space Rules

- **Minimum clear space around logomark:** icon height × 0.5 on all sides.
- **Minimum clear space in horizontal lockup:** icon height × 0.5 between icon and wordmark.
- **Minimum clear space in stacked lockup:** icon height × 0.3 between icon and wordmark.
- **Minimum padding around entire lockup:** icon height × 0.25 on all sides.

### Minimum Size Rules

| Context                | Minimum Size | Action                            |
| ---------------------- | ------------ | --------------------------------- |
| Digital icon-only      | 16×16px      | Use monochrome variant (`logomark-mono.svg`) |
| Digital icon-only      | 32×32px+     | Use full-color variant            |
| Horizontal lockup      | 120px width  | Below this, switch to icon-only   |
| Stacked lockup         | 80px width   | Below this, switch to icon-only   |
| Print icon-only        | 10mm         | Use monochrome variant            |

### Do's and Don'ts

| Do                                                  | Don't                                            |
| --------------------------------------------------- | ------------------------------------------------ |
| Use the correct variant for the theme (light/dark)  | Stretch or distort the logo                      |
| Maintain minimum clear space                        | Change logo colors outside approved palette      |
| Use the monochrome variant on photos                | Add drop shadows or outlines to the logo         |
| Center-align when used as a standalone mark         | Place logo smaller than minimum size             |
| Use lockup SVGs as-is (they embed the logomark)     | Recompose icon + text manually                   |
| Switch to icon-only below lockup minimum width      | Crop or partially obscure the logomark           |

---

## 3. Color System

All colors are defined as CSS custom properties in `frontend/src/styles/globals.css` and documented in `docs/assets/design-tokens.json`. Never use hardcoded hex values in components — always reference the token.

### 3.1 Brand Identity Colors

| Role            | Token                       | Light        | Dark         | WCAG on bg | Usage                                          |
| --------------- | --------------------------- | ------------ | ------------ | ---------- | ---------------------------------------------- |
| Primary         | `--color-brand-primary`     | `#0d7377`    | `#2dd4bf`    | 5.6:1 (AA) | Logos, headers, primary CTA backgrounds        |
| Primary Dark    | `--color-brand-primary-dark`| `#095456`    | `#0d7377`    | 8.5:1 (AAA)| Hover states on primary, gradient endpoints     |
| Secondary       | `--color-brand-secondary`   | `#f8fafc`    | `#1e293b`    | Background | Page backgrounds, card fills                   |
| Accent (Gold)   | `--color-brand-accent`      | `#d4a844`    | `#fbbf24`    | 2.2:1 / 12.3:1 | Decorative only on light; text-safe on dark |

> **Warning:** Brand accent (gold) does NOT meet WCAG AA for text on white. Use it only for decorative elements, badge borders, or on dark backgrounds where it achieves 12.3:1.

### 3.2 Action Colors (UI)

| Role            | Token                  | Light        | Dark         | Usage                                   |
| --------------- | ---------------------- | ------------ | ------------ | --------------------------------------- |
| Action          | `--color-brand`        | `#15803d`    | `#4ade80`    | Buttons, links, toggles                 |
| Action Hover    | `--color-brand-hover`  | `#166534`    | `#22c55e`    | Hover/focus states                      |
| Action Subtle   | `--color-brand-subtle` | `#dcfce7`    | `#14532d`    | Selected states, soft highlights        |

### 3.3 Health Score Bands

These colors are the most critical visual element in the application. They must remain consistent across themes — same hues, only brightness adjusted.

| Band      | Score   | Token                   | Light        | Dark         | Text Token                      | Text Light   | Text Dark    |
| --------- | ------- | ----------------------- | ------------ | ------------ | ------------------------------- | ------------ | ------------ |
| Green     | 1–20    | `--color-score-green`   | `#22c55e`    | `#4ade80`    | `--color-score-green-text`      | `#15803d`    | `#4ade80`    |
| Yellow    | 21–40   | `--color-score-yellow`  | `#eab308`    | `#facc15`    | `--color-score-yellow-text`     | `#854d0e`    | `#facc15`    |
| Orange    | 41–60   | `--color-score-orange`  | `#f97316`    | `#fb923c`    | `--color-score-orange-text`     | `#c2410c`    | `#fb923c`    |
| Red       | 61–80   | `--color-score-red`     | `#ef4444`    | `#f87171`    | `--color-score-red-text`        | `#b91c1c`    | `#f87171`    |
| Dark Red  | 81–100  | `--color-score-darkred` | `#991b1b`    | `#dc2626`    | `--color-score-darkred-text`    | `#991b1b`    | `#dc2626`    |

**Invariant:** Score band colors use the same hues in both themes. Users learn the color associations; never change them between themes.

### 3.4 Nutri-Score (EU Standard)

These colors are defined by EU regulation and **must not be modified**.

| Grade | Token             | Light        | Dark         |
| ----- | ----------------- | ------------ | ------------ |
| A     | `--color-nutri-A` | `#038141`    | `#34d399`    |
| B     | `--color-nutri-B` | `#85bb2f`    | `#a3e635`    |
| C     | `--color-nutri-C` | `#fecb02`    | `#fde047`    |
| D     | `--color-nutri-D` | `#ee8100`    | `#fb923c`    |
| E     | `--color-nutri-E` | `#e63e11`    | `#f87171`    |

### 3.5 NOVA Processing Groups

| Group | Label              | Token            | Light        | Dark         |
| ----- | ------------------ | ---------------- | ------------ | ------------ |
| 1     | Unprocessed        | `--color-nova-1` | `#22c55e`    | `#4ade80`    |
| 2     | Processed culinary | `--color-nova-2` | `#84cc16`    | `#a3e635`    |
| 3     | Processed          | `--color-nova-3` | `#f59e0b`    | `#fbbf24`    |
| 4     | Ultra-processed    | `--color-nova-4` | `#ef4444`    | `#f87171`    |

### 3.6 Confidence Bands

| Band   | Token                       | Light        | Dark         |
| ------ | --------------------------- | ------------ | ------------ |
| High   | `--color-confidence-high`   | `#22c55e`    | `#4ade80`    |
| Medium | `--color-confidence-medium` | `#f59e0b`    | `#fbbf24`    |
| Low    | `--color-confidence-low`    | `#ef4444`    | `#f87171`    |

### 3.7 Allergen Severity

| Level   | Token                      | Light        | Dark         |
| ------- | -------------------------- | ------------ | ------------ |
| Present | `--color-allergen-present` | `#ef4444`    | `#f87171`    |
| Traces  | `--color-allergen-traces`  | `#f59e0b`    | `#fbbf24`    |
| Free    | `--color-allergen-free`    | `#22c55e`    | `#4ade80`    |

### 3.8 Semantic Feedback

| Role    | Token             | Light        | Dark         |
| ------- | ----------------- | ------------ | ------------ |
| Success | `--color-success` | `#22c55e`    | `#4ade80`    |
| Warning | `--color-warning` | `#f59e0b`    | `#fbbf24`    |
| Error   | `--color-error`   | `#ef4444`    | `#f87171`    |
| Info    | `--color-info`    | `#3b82f6`    | `#60a5fa`    |

### 3.9 Nutrition Traffic Light (FSA/EFSA)

| Level  | Token                     | Light        | Dark         |
| ------ | ------------------------- | ------------ | ------------ |
| Low    | `--color-nutrient-low`    | `#22c55e`    | `#4ade80`    |
| Medium | `--color-nutrient-medium` | `#f59e0b`    | `#fbbf24`    |
| High   | `--color-nutrient-high`   | `#ef4444`    | `#f87171`    |

### 3.10 Surfaces, Borders & Neutrals

| Token                     | Light               | Dark                | Usage                          |
| ------------------------- | -------------------- | ------------------- | ------------------------------ |
| `--color-surface`         | `#ffffff`            | `#111827`           | Page/card background           |
| `--color-surface-subtle`  | `#f9fafb`            | `#1f2937`           | Alternating rows, body bg      |
| `--color-surface-muted`   | `#f3f4f6`            | `#374151`           | Disabled states, skeleton base |
| `--color-surface-overlay` | `rgba(0,0,0,0.5)`   | `rgba(0,0,0,0.7)`  | Modal backdrop                 |
| `--color-border`          | `#e5e7eb`            | `#374151`           | Card borders, dividers         |
| `--color-border-strong`   | `#d1d5db`            | `#4b5563`           | Input borders, emphasis lines  |
| `--color-neutral-50`      | `#f8fafc`            | `#0f172a`           | Lightest neutral               |
| `--color-neutral-200`     | `#e2e8f0`            | `#334155`           | Dividers                       |
| `--color-neutral-400`     | `#94a3b8`            | `#94a3b8`           | Placeholder text               |
| `--color-neutral-600`     | `#475569`            | `#cbd5e1`           | Secondary content              |
| `--color-neutral-900`     | `#0f172a`            | `#f8fafc`           | Darkest neutral / headings     |

### Color Usage Rules

1. **Never hardcode hex values** in components. Always use CSS custom properties or Tailwind utility classes.
2. **Brand primary** (`#0d7377`) is for identity — logos, headers, diagrams. **Action** (`#15803d`) is for interactive elements — buttons, links.
3. **Score colors must never be repurposed** for non-scoring contexts. Green always means low-risk; red always means high-risk.
4. **Nutri-Score colors are immutable** — they follow EU regulation.
5. **Test all color pairings** for WCAG AA (4.5:1 normal text, 3:1 large text/UI) before use.

---

## 4. Typography

### Font Stack

The application uses the system font stack for performance — no web font downloads required:

```css
font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont,
             "Segoe UI", Roboto, "Helvetica Neue", Arial, "Noto Sans",
             sans-serif, "Apple Color Emoji", "Segoe UI Emoji",
             "Segoe UI Symbol", "Noto Color Emoji";
```

For monospaced contexts (EAN codes, score values, data tables):

```css
font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas,
             "Liberation Mono", "Courier New", monospace;
```

### Type Scale

| Level      | Token         | Size    | Pixels | Weight         | Line Height | Usage                                    |
| ---------- | ------------- | ------- | ------ | -------------- | ----------- | ---------------------------------------- |
| Display    | `--text-3xl`  | 1.875rem | 30px  | Bold (700)     | 1.25        | Hero headings, landing page              |
| H1         | `--text-2xl`  | 1.5rem  | 24px   | Bold (700)     | 1.25        | Page titles                              |
| H2         | `--text-xl`   | 1.25rem | 20px   | Semibold (600) | 1.25        | Section headings                         |
| H3         | `--text-lg`   | 1.125rem| 18px   | Semibold (600) | 1.5         | Card titles, subsection headings         |
| H4         | `--text-base` | 1rem    | 16px   | Semibold (600) | 1.5         | Field labels, list group headers         |
| Body       | `--text-base` | 1rem    | 16px   | Normal (400)   | 1.5         | Paragraphs, descriptions                |
| Body Small | `--text-sm`   | 0.875rem| 14px   | Normal (400)   | 1.5         | Secondary text, table cells              |
| Caption    | `--text-xs`   | 0.75rem | 12px   | Normal (400)   | 1.5         | Timestamps, metadata, disclaimers        |
| Overline   | `--text-xs`   | 0.75rem | 12px   | Semibold (600) | 1.5         | Section labels (uppercase, letter-spaced)|
| Code       | `--text-sm`   | 0.875rem| 14px   | Normal (400)   | 1.5         | EAN barcodes, score numbers              |

### Font Weights

| Token              | Value | Usage                                        |
| ------------------ | ----- | -------------------------------------------- |
| `--font-normal`    | 400   | Body text, descriptions                      |
| `--font-medium`    | 500   | Navigation items, emphasized body            |
| `--font-semibold`  | 600   | Headings (H2-H4), button labels, badges      |
| `--font-bold`      | 700   | Display text, H1, score values               |

### Line Heights

| Token                | Value | Usage                                       |
| -------------------- | ----- | ------------------------------------------- |
| `--leading-tight`    | 1.25  | Headings, display text                      |
| `--leading-normal`   | 1.5   | Body text (default)                         |
| `--leading-relaxed`  | 1.625 | Long-form content, descriptions             |

### Typography Rules

1. **Minimum 16px for body text** on mobile — never go below `--text-base` for primary content.
2. **Score values always use tabular/monospaced figures** to maintain alignment in tables and comparison views.
3. **Product names are displayed as-is** from the database — they contain Polish/German characters and must not be truncated without an ellipsis indicator.
4. **Overline text** is always uppercase with `letter-spacing: 0.05em` — used for section labels like "NUTRITION FACTS" or "INGREDIENTS".
5. **Never use more than 3 font weights** on a single screen to maintain visual consistency.

---

## 5. Iconography

> **Status:** Guidelines established; detailed icon library depends on [#407](https://github.com/ericsocrat/poland-food-db/issues/407) for the brand icon system.

### Icon Style

| Property          | Value                                                      |
| ----------------- | ---------------------------------------------------------- |
| Style             | Outlined (not filled), consistent 1.5px stroke width       |
| Corner radius     | 2px rounded corners on path joins                          |
| Grid              | 24×24px base grid (can scale to 16, 20, 32, 48)           |
| Visual weight     | Uniform — no icon should appear heavier than another       |
| Color             | Inherits `currentColor` — adapts to text/foreground theme |

### Category Icons

Each of the 20 food categories has an emoji icon defined in `category_ref.icon_emoji`:

| Category            | Emoji | Notes                                 |
| ------------------- | ----- | ------------------------------------- |
| Alcohol             | 🍺    | Beer mug — neutral, recognizable      |
| Baby                | 🍼    | Baby bottle — clear category signal   |
| Bread               | 🍞    | Bread loaf                            |
| Cereals             | 🥣    | Bowl of cereal                        |
| Chips               | 🥔    | Potato — source ingredient            |
| Condiments          | 🧂    | Salt shaker                           |
| Dairy               | 🥛    | Glass of milk                         |
| Drinks              | 🥤    | Takeaway cup                          |
| Frozen & Prepared   | 🧊    | Ice cube                              |
| Instant & Frozen    | 🍜    | Noodle bowl                           |
| Meat                | 🥩    | Cut of meat                           |
| Nuts, Seeds & Legumes | 🥜  | Peanut                                |
| Plant-Based         | 🌱    | Seedling                              |
| Sauces              | 🫙    | Jar                                   |
| Seafood & Fish      | 🐟    | Fish                                  |
| Snacks              | 🍿    | Popcorn                               |
| Sweets              | 🍫    | Chocolate bar                         |
| Żabka               | 🐸    | Frog — matches store branding         |

### UI Icons

Use [Lucide React](https://lucide.dev/) icons for all UI elements (navigation, actions, status indicators). Rules:

- Always use `size={20}` for inline icons, `size={24}` for standalone icons.
- Use `strokeWidth={1.5}` consistently.
- Icons are decorative when paired with text — add `aria-hidden="true"`.
- Icons are informative when standalone — add `aria-label="Description"`.

---

## 6. Illustration Style

> **Status:** Foundational guidelines established. Visual examples will be added when illustration assets are created.

### Style Direction

| Property     | Value                                                                        |
| ------------ | ---------------------------------------------------------------------------- |
| Style        | Abstract/geometric — not realistic, not cartoonish                          |
| Perspective  | Flat (2D) — no isometric, no 3D effects                                     |
| Line weight  | 2px strokes, matching icon system proportions                                |
| Color usage  | Brand primary + accent as key colors; score band colors for data visualizations |
| Mood         | Friendly, encouraging, educational — never alarming or judgmental            |
| Complexity   | Simple compositions with clear focal point — max 3-4 elements per illustration |

### Usage Contexts

| Context            | Guidelines                                                             |
| ------------------ | ---------------------------------------------------------------------- |
| Empty states       | Simple icon + brief message. Use brand primary color palette.          |
| Onboarding         | Step illustrations showing the core flow (scan → score → compare).     |
| Error pages        | Friendly illustration, not alarming. Offer a clear next action.        |
| Marketing          | Can be more detailed, but must stay within the geometric style.        |
| Data visualization | Use score band colors exclusively. No decorative colors in charts.     |

### Colors in Illustrations

- **Primary use:** Brand primary (`#0d7377` light / `#2dd4bf` dark) for main shapes.
- **Accent highlights:** Brand accent (`#d4a844` light / `#fbbf24` dark) for small emphasis elements.
- **Backgrounds:** Always transparent or brand secondary (`#f8fafc` light / `#1e293b` dark).
- **Never use:** Score band colors for decorative purposes in illustrations — reserve them for data.

---

## 7. Photography Direction

### Product Photography

| Property          | Guideline                                                                          |
| ----------------- | ---------------------------------------------------------------------------------- |
| Background        | Plain white or light gray (`#f8fafc`) — no textured or patterned backgrounds       |
| Lighting          | Even, diffused lighting — no harsh shadows or specular highlights                  |
| Angle             | Front-facing, label visible — the product as a consumer would see it on a shelf    |
| Branding          | Store branding/price tags must be removed or cropped                               |
| Resolution        | Minimum 400×400px for product cards, 800×800px for detail pages                    |
| Format            | WebP preferred (with JPEG fallback), max 200KB per product image                   |
| Consistency       | All products in a category should have matching framing and scale                  |

### User-Submitted Photos (via `product_submissions`)

- Accepted: Clear front-of-pack photo showing product name, brand, and barcode.
- Rejected: Blurry, rotated, or partial images. Multiple products in one photo.
- Processing: Images are resized to max 1200px longest edge before storage.

### Photography in Marketing

- Lifestyle photography (food on plates, grocery shopping) may be used for marketing but never in the core data application.
- Always pair lifestyle photos with the actual product data — never present photography without corresponding nutrition information.

---

## 8. Component Patterns

All component classes are defined in `frontend/src/styles/globals.css` under `@layer components`. Components use CSS custom properties through Tailwind utility classes — never hardcoded values.

### Buttons

| Variant     | Tailwind Class   | Usage                                        |
| ----------- | ---------------- | -------------------------------------------- |
| Primary     | `.btn-primary`   | Main CTAs: "Scan", "Compare", "Save"         |
| Secondary   | `.btn-secondary` | Secondary actions: "Cancel", "Reset", "Back" |

**Button specs:**
- Border radius: `rounded-lg` (12px)
- Padding: `px-4 py-2.5`
- Font: `text-sm font-semibold`
- Shadow: `shadow-sm`
- Focus: 2px brand-colored outline with 2px offset
- Disabled: 50% opacity, `cursor-not-allowed`
- Touch: `touch-action: manipulation` (prevents double-tap zoom)
- Press feedback: `scale(0.97)` on `:active` (via `.press-scale`)

### Cards

```css
.card → rounded-xl border bg-surface p-3 shadow-sm sm:p-4 lg:p-5
```

- Responsive padding: 12px (mobile) → 16px (sm) → 20px (lg)
- Border: uses `--color-border` (theme-aware)
- Shadow: `--shadow-sm` (subtle elevation)
- Page-break avoidance in print

### Input Fields

```css
.input-field → rounded-lg border border-strong bg-surface px-3.5 py-2.5 text-sm
              focus:border-brand focus:ring-1 focus:ring-brand
```

### Score Badges

Score badges use the corresponding score band color:

| Score Range | Background Class    | Text Class            | Label       |
| ----------- | ------------------- | --------------------- | ----------- |
| 1–20        | `bg-score-green`    | `text-score-green-text`| Low risk    |
| 21–40       | `bg-score-yellow`   | `text-score-yellow-text`| Moderate  |
| 41–60       | `bg-score-orange`   | `text-score-orange-text`| Elevated  |
| 61–80       | `bg-score-red`      | `text-score-red-text`  | High risk  |
| 81–100      | `bg-score-darkred`  | `text-score-darkred-text`| Very high |

### Nutri-Score Badges

Use the EU-standard letter (A–E) with the corresponding Nutri-Score color. The active grade is highlighted; inactive grades are dimmed.

### NOVA Badges

Display as a numeric badge (1–4) with the corresponding NOVA color.

### Confidence Indicators

| Band   | Visual                                       |
| ------ | -------------------------------------------- |
| High   | ✓ checkmark + "Verified" in confidence-high  |
| Medium | ~ tilde + "Estimated" in confidence-medium   |
| Low    | ! exclamation + "Low" in confidence-low      |

### Chips / Tags

- Allergen chips: colored by severity (present/traces/free).
- Category chips: neutral background, category emoji prefix.
- Filter chips: brand-subtle background, dismissible "×" icon.
- Enter animation: `chip-enter` (scale from 0.85 → 1.0, 150ms decelerate).

---

## 9. Spacing & Layout

### Spacing Scale

The spacing system uses a 4px base unit, matching Tailwind's default scale:

| Token        | Value     | Pixels | Tailwind | Usage                                    |
| ------------ | --------- | ------ | -------- | ---------------------------------------- |
| `--space-1`  | 0.25rem   | 4px    | `p-1`    | Tight padding inside badges              |
| `--space-2`  | 0.5rem    | 8px    | `p-2`    | Icon-to-text spacing, chip padding       |
| `--space-3`  | 0.75rem   | 12px   | `p-3`    | Card padding (mobile)                    |
| `--space-4`  | 1rem      | 16px   | `p-4`    | Card padding (sm), section gaps          |
| `--space-5`  | 1.25rem   | 20px   | `p-5`    | Card padding (lg)                        |
| `--space-6`  | 1.5rem    | 24px   | `p-6`    | Section separators                       |
| `--space-8`  | 2rem      | 32px   | `p-8`    | Major section gaps                       |
| `--space-10` | 2.5rem    | 40px   | `p-10`   | Page-level padding                       |
| `--space-12` | 3rem      | 48px   | `p-12`   | Hero section vertical padding            |
| `--space-16` | 4rem      | 64px   | `p-16`   | Landing page section separators          |

### Responsive Breakpoints

| Name   | Min Width | Tailwind Prefix | Usage                                |
| ------ | --------- | --------------- | ------------------------------------ |
| `xs`   | 375px     | `xs:`           | Minimum supported width (iPhone SE)  |
| `sm`   | 640px     | `sm:`           | Large phones, small tablets           |
| `md`   | 768px     | `md:`           | Tablets (portrait)                    |
| `lg`   | 1024px    | `lg:`           | Tablets (landscape), small desktops   |
| `xl`   | 1280px    | `xl:`           | Desktop                               |
| `2xl`  | 1440px    | `2xl:`          | Large desktop                          |

### Layout Rules

1. **Mobile-first:** All layouts start at `xs` (375px) and scale up.
2. **Container queries:** Product cards, compare cells, and filter panels use `container-type: inline-size` for component-level responsiveness.
3. **Safe areas:** Horizontal `env(safe-area-inset-left/right)` on body for notched/foldable devices. Bottom safe area via `.safe-area-bottom`.
4. **Max content width:** Main content column max-width of 1280px, centered.
5. **Grid:** Use CSS Grid or Flexbox through Tailwind utilities. No custom grid framework.
6. **Horizontal overflow:** Prevented globally via `overflow-x: hidden` on `<html>`.

### Border Radius

| Token          | Value     | Pixels | Tailwind       | Usage                      |
| -------------- | --------- | ------ | -------------- | -------------------------- |
| `--radius-sm`  | 0.375rem  | 6px    | `rounded-sm`   | Small badges, chips        |
| `--radius-md`  | 0.5rem    | 8px    | `rounded-md`   | Input fields, skeleton     |
| `--radius-lg`  | 0.75rem   | 12px   | `rounded-lg`   | Buttons, modals            |
| `--radius-xl`  | 1rem      | 16px   | `rounded-xl`   | Cards, panels              |
| `--radius-full`| 9999px    | —      | `rounded-full` | Avatars, circular badges   |

---

## 10. Motion & Animation

### Duration Scale

| Token                | Value  | Usage                                                |
| -------------------- | ------ | ---------------------------------------------------- |
| `--duration-instant`  | 100ms  | Press feedback, micro-interactions                   |
| `--duration-fast`     | 150ms  | Hovers, chip enters, tooltips                        |
| `--duration-normal`   | 200ms  | Page element entrances, theme transitions            |
| `--duration-slow`     | 300ms  | Sheet slides, emphasis animations                    |

### Easing Functions

| Token               | Value                              | Usage                                    |
| -------------------- | ---------------------------------- | ---------------------------------------- |
| `--ease-standard`    | `cubic-bezier(0.4, 0, 0.2, 1)`    | General transitions (move, resize)       |
| `--ease-decelerate`  | `cubic-bezier(0, 0, 0.2, 1)`      | Entrances (fade in, slide up)            |
| `--ease-accelerate`  | `cubic-bezier(0.4, 0, 1, 1)`      | Exits (fade out, slide away)             |
| `--ease-spring`      | `cubic-bezier(0.68, -0.55, 0.265, 1.55)` | Playful bounces (trust badge verify) |

### Animation Patterns

| Pattern            | CSS Class             | Behavior                                          |
| ------------------ | --------------------- | ------------------------------------------------- |
| Fade in up         | `.animate-fade-in-up` | translateY(8px→0) + opacity(0→1), normal+decelerate |
| Scale in           | `.animate-scale-in`   | scale(0.92→1) + opacity(0→1), fast+decelerate     |
| Chip enter         | `.animate-chip-enter` | scale(0.85→1) + opacity(0→1), fast+decelerate     |
| Trust verified     | `.animate-trust-verified` | scale(1→1.15→1), 600ms+decelerate, 300ms delay |
| Hover lift         | `.hover-lift`         | translateY(-2px) + shadow-md on hover              |
| Press scale        | `.press-scale`        | scale(0.97) on :active                             |
| Hover lift + press | `.hover-lift-press`   | Lift on hover, scale+flatten on press              |
| Skeleton shimmer   | `.skeleton`           | Horizontal gradient sweep, 1.5s infinite           |
| Slide up sheet     | `.animate-slide-up-sheet` | translateY(100%→0), slow+decelerate            |

### Motion Rules

1. **Entrances use decelerate** — elements arrive quickly and settle.
2. **Exits use accelerate** — elements depart with increasing speed.
3. **Interactive feedback is instant** (100ms) — the user must feel the press immediately.
4. **No animation exceeds 300ms** except special emphasis animations (trust badge).
5. **Staggered lists:** Each item delays by 50ms × index. Max stagger delay: 500ms (10 items).
6. **Theme transitions:** Body background/color transitions at 150ms, disabled during initial load.

### Reduced Motion

All animations are fully disabled when `prefers-reduced-motion: reduce` is active:

```css
@media (prefers-reduced-motion: reduce) {
  :root {
    --duration-instant: 0ms;
    --duration-fast: 0ms;
    --duration-normal: 0ms;
    --duration-slow: 0ms;
  }
  /* All animation-duration → 0.01ms, transition-duration → 0.01ms */
}
```

---

## 11. Accessibility

### Contrast Requirements

All text and UI elements follow WCAG 2.1 Level AA:

| Element Type               | Minimum Ratio | Standard     |
| -------------------------- | ------------- | ------------ |
| Normal text (< 18px)       | 4.5:1         | WCAG AA      |
| Large text (≥ 18px bold or ≥ 24px) | 3:1  | WCAG AA      |
| UI components (borders, icons) | 3:1       | WCAG AA      |
| Decorative elements        | No requirement| —            |

### Verified Contrast Ratios

| Color Pair                                     | Ratio   | Pass |
| ---------------------------------------------- | ------- | ---- |
| Brand primary `#0d7377` on white `#ffffff`     | 5.6:1   | AA   |
| Brand primary dark `#095456` on white          | 8.5:1   | AAA  |
| Text primary `#111827` on surface `#ffffff`    | 17.1:1  | AAA  |
| Text secondary `#4b5563` on surface            | 7.08:1  | AAA  |
| Text muted `#6b7280` on surface                | 4.63:1  | AA   |
| Score green text `#15803d` on white             | 5.1:1   | AA   |
| Score yellow text `#854d0e` on white            | 5.9:1   | AA   |
| Score orange text `#c2410c` on white            | 5.2:1   | AA   |
| Score red text `#b91c1c` on white               | 5.9:1   | AA   |
| Score darkred text `#991b1b` on white           | 8.3:1   | AAA  |
| Brand accent `#d4a844` on white                 | 2.2:1   | FAIL |
| Dark mode primary `#2dd4bf` on dark `#111827`  | 8.6:1   | AAA  |
| Dark mode accent `#fbbf24` on dark `#111827`   | 12.3:1  | AAA  |

> **Brand accent (`#d4a844`) fails WCAG AA on white backgrounds.** Use only for decorative purposes (badge borders, gold accents) on light backgrounds. Safe for text on dark backgrounds.

### Focus Indicators

All interactive elements receive a visible focus indicator via `:focus-visible`:

```css
*:focus-visible {
  outline: 2px solid var(--color-brand);
  outline-offset: 2px;
  border-radius: 2px;
}
```

- Focus outline color matches brand action color (context-aware).
- Offset prevents the outline from overlapping element content.
- Hidden when `:focus` but not `:focus-visible` (mouse clicks don't trigger outlines).

### Touch Targets

| Requirement                | Size    | Implementation                    |
| -------------------------- | ------- | --------------------------------- |
| Minimum touch target       | 44×44px | `.touch-target` class              |
| Expanded hit area (small elements) | 44×44px | `.touch-target-expanded` (pseudo-element) |
| Button double-tap prevention | —     | `touch-action: manipulation`       |

### Screen Reader Considerations

1. **Decorative icons** paired with visible text use `aria-hidden="true"`.
2. **Standalone icons** (no visible text) require `aria-label="Description"`.
3. **Score values** include `aria-label` with the risk band label (e.g., `aria-label="Score 45, Elevated risk"`).
4. **Color-blind safe:** Score bands are never conveyed by color alone — they always include a text label or numeric value.
5. **Dynamic content** uses `aria-live="polite"` for non-urgent updates (score recalculation) and `aria-live="assertive"` for errors.

### Reduced Motion (reiterated)

All motion tokens collapse to 0ms when `prefers-reduced-motion: reduce` is active. Skeleton shimmer falls back to a static muted background. See [§10 — Motion & Animation](#10-motion--animation).

---

## 12. Dark Mode

### Theme Implementation

Dark mode is applied via the `data-theme="dark"` attribute on the root element:

```html
<html data-theme="dark">
```

**Fallback:** If no `data-theme` is set, `@media (prefers-color-scheme: dark)` activates dark mode automatically — until the user makes an explicit choice.

### Full Light → Dark Mapping Table

| Token                       | Light             | Dark              |
| --------------------------- | ----------------- | ----------------- |
| **Surfaces**                |                   |                   |
| `--color-surface`           | `#ffffff`         | `#111827`         |
| `--color-surface-subtle`    | `#f9fafb`         | `#1f2937`         |
| `--color-surface-muted`     | `#f3f4f6`         | `#374151`         |
| `--color-surface-overlay`   | `rgba(0,0,0,0.5)` | `rgba(0,0,0,0.7)` |
| **Text**                    |                   |                   |
| `--color-text-primary`      | `#111827`         | `#f9fafb`         |
| `--color-text-secondary`    | `#4b5563`         | `#d1d5db`         |
| `--color-text-muted`        | `#6b7280`         | `#9ca3af`         |
| `--color-text-inverse`      | `#ffffff`         | `#111827`         |
| **Border**                  |                   |                   |
| `--color-border`            | `#e5e7eb`         | `#374151`         |
| `--color-border-strong`     | `#d1d5db`         | `#4b5563`         |
| **Brand Action**            |                   |                   |
| `--color-brand`             | `#15803d`         | `#4ade80`         |
| `--color-brand-hover`       | `#166534`         | `#22c55e`         |
| `--color-brand-subtle`      | `#dcfce7`         | `#14532d`         |
| **Brand Identity**          |                   |                   |
| `--color-brand-primary`     | `#0d7377`         | `#2dd4bf`         |
| `--color-brand-primary-dark`| `#095456`         | `#0d7377`         |
| `--color-brand-secondary`   | `#f8fafc`         | `#1e293b`         |
| `--color-brand-accent`      | `#d4a844`         | `#fbbf24`         |
| **Neutral Scale**           |                   |                   |
| `--color-neutral-50`        | `#f8fafc`         | `#0f172a`         |
| `--color-neutral-200`       | `#e2e8f0`         | `#334155`         |
| `--color-neutral-400`       | `#94a3b8`         | `#94a3b8`         |
| `--color-neutral-600`       | `#475569`         | `#cbd5e1`         |
| `--color-neutral-900`       | `#0f172a`         | `#f8fafc`         |
| **Score Bands**             |                   |                   |
| `--color-score-green`       | `#22c55e`         | `#4ade80`         |
| `--color-score-yellow`      | `#eab308`         | `#facc15`         |
| `--color-score-orange`      | `#f97316`         | `#fb923c`         |
| `--color-score-red`         | `#ef4444`         | `#f87171`         |
| `--color-score-darkred`     | `#991b1b`         | `#dc2626`         |
| **Score Text**              |                   |                   |
| `--color-score-green-text`  | `#15803d`         | `#4ade80`         |
| `--color-score-yellow-text` | `#854d0e`         | `#facc15`         |
| `--color-score-orange-text` | `#c2410c`         | `#fb923c`         |
| `--color-score-red-text`    | `#b91c1c`         | `#f87171`         |
| `--color-score-darkred-text`| `#991b1b`         | `#dc2626`         |
| **Nutri-Score**             |                   |                   |
| `--color-nutri-A`           | `#038141`         | `#34d399`         |
| `--color-nutri-B`           | `#85bb2f`         | `#a3e635`         |
| `--color-nutri-C`           | `#fecb02`         | `#fde047`         |
| `--color-nutri-D`           | `#ee8100`         | `#fb923c`         |
| `--color-nutri-E`           | `#e63e11`         | `#f87171`         |
| **NOVA**                    |                   |                   |
| `--color-nova-1`            | `#22c55e`         | `#4ade80`         |
| `--color-nova-2`            | `#84cc16`         | `#a3e635`         |
| `--color-nova-3`            | `#f59e0b`         | `#fbbf24`         |
| `--color-nova-4`            | `#ef4444`         | `#f87171`         |
| **Nutrition Traffic Light** |                   |                   |
| `--color-nutrient-low`      | `#22c55e`         | `#4ade80`         |
| `--color-nutrient-medium`   | `#f59e0b`         | `#fbbf24`         |
| `--color-nutrient-high`     | `#ef4444`         | `#f87171`         |
| **Confidence**              |                   |                   |
| `--color-confidence-high`   | `#22c55e`         | `#4ade80`         |
| `--color-confidence-medium` | `#f59e0b`         | `#fbbf24`         |
| `--color-confidence-low`    | `#ef4444`         | `#f87171`         |
| **Allergen**                |                   |                   |
| `--color-allergen-present`  | `#ef4444`         | `#f87171`         |
| `--color-allergen-traces`   | `#f59e0b`         | `#fbbf24`         |
| `--color-allergen-free`     | `#22c55e`         | `#4ade80`         |
| **Semantic**                |                   |                   |
| `--color-success`           | `#22c55e`         | `#4ade80`         |
| `--color-warning`           | `#f59e0b`         | `#fbbf24`         |
| `--color-error`             | `#ef4444`         | `#f87171`         |
| `--color-info`              | `#3b82f6`         | `#60a5fa`         |
| **Shadows**                 |                   |                   |
| `--shadow-sm`               | `rgba(0,0,0,0.05)` | `rgba(0,0,0,0.3)` |
| `--shadow-md`               | `rgba(0,0,0,0.1)` | `rgba(0,0,0,0.4)` |
| `--shadow-lg`               | `rgba(0,0,0,0.1)` | `rgba(0,0,0,0.4)` |

### Design Principles for Dark Mode

1. **Don't invert — remap.** Dark mode is not a simple inversion. Background goes dark, text goes light, but colored data indicators (scores, Nutri-Score) retain their hue identity.
2. **Increase shadow opacity.** Shadows need higher opacity on dark backgrounds to maintain visual hierarchy.
3. **Neutral scale inverts.** `neutral-50` (lightest in light mode) becomes the darkest value in dark mode and vice versa.
4. **Score band hues are preserved** — only the lightness adjusts to maintain readability. Users must recognize "green = good" regardless of theme.
5. **Logo variant selection:** Use the dark-mode logo variant (when available from #407/#408) on dark backgrounds. Never place the light logo on dark backgrounds.
6. **Theme transition:** 150ms ease on background-color and color, disabled during initial page load to prevent flash.

---

## 13. Co-branding

### Partner Logos

This project acknowledges the following partners and data sources:

| Partner           | Context                           | Logo Source                    |
| ----------------- | --------------------------------- | ------------------------------ |
| Open Food Facts   | Primary data source               | [openfoodfacts.org](https://world.openfoodfacts.org/) |
| Supabase          | Database & auth platform          | [supabase.com/brand-assets](https://supabase.com/brand-assets) |
| PostgreSQL        | Database engine                   | [postgresql.org](https://www.postgresql.org/about/press/presskit15/) |
| Vercel            | Frontend hosting                  | [vercel.com/design](https://vercel.com/design) |

### Co-branding Rules

1. **Never imply endorsement.** Use "Powered by" or "Data from" language, never "In partnership with" unless formally agreed.
2. **Maintain partner brand guidelines.** Follow each partner's official logo usage rules.
3. **Spacing:** Minimum 24px (1.5rem) gap between the project logo and any partner logo.
4. **Size relationship:** Partner logos should be no larger than the project logo. Maintain visual hierarchy.
5. **Placement:** Footer or dedicated "About" page — never in the primary navigation or product detail content.
6. **Monochrome option:** When co-branding with multiple partners, use monochrome versions of all logos for visual consistency.

### Open Food Facts Attribution

As per the [Open Food Facts Terms of Use](https://world.openfoodfacts.org/terms-of-use):

- Data is licensed under ODbL 1.0 (database) and DbCL 1.0 (individual contents).
- Attribution must link back to Open Food Facts.
- Include in the footer: "Product data from [Open Food Facts](https://world.openfoodfacts.org/) (ODbL)".

---

## 14. Asset Inventory

### Diagrams (`docs/diagrams/`)

| File                                 | Dimensions | Format | Dark Variant | Last Updated | Issue |
| ------------------------------------ | ---------- | ------ | ------------ | ------------ | ----- |
| `architecture-overview.svg`          | 800×600    | SVG    | Yes          | 2026-03-13   | #426  |
| `architecture-overview-dark.svg`     | 800×600    | SVG    | (is dark)    | 2026-03-13   | #426  |
| `erd-full.svg`                       | ~1200×2000 | SVG    | Yes          | 2026-03-13   | #428  |
| `erd-full-dark.svg`                  | ~1200×2000 | SVG    | (is dark)    | 2026-03-13   | #428  |
| `erd-core.svg`                       | ~900×700   | SVG    | Yes          | 2026-03-13   | #428  |
| `erd-core-dark.svg`                  | ~900×700   | SVG    | (is dark)    | 2026-03-13   | #428  |
| `pipeline-flow.svg`                  | ~800×400   | SVG    | No           | 2026-03-13   | #429  |
| `ci-cd-pipeline.svg`                 | ~1000×600  | SVG    | No           | 2026-03-13   | #429  |
| `qa-overview.svg`                    | ~800×500   | SVG    | No           | 2026-03-13   | #429  |
| `confidence-model.svg`              | ~800×400   | SVG    | No           | 2026-03-13   | #429  |
| `concern-tiers.svg`                  | ~800×300   | SVG    | No           | 2026-03-13   | #429  |
| `country-expansion.svg`             | ~800×400   | SVG    | No           | 2026-03-13   | #429  |
| `scoring-v32-infographic.svg`        | 800×1400   | SVG    | Yes          | 2026-03-13   | #427  |
| `scoring-v32-infographic-dark.svg`   | 800×1400   | SVG    | (is dark)    | 2026-03-13   | #427  |
| `scoring-v32-breakdown.svg`          | 800×400    | SVG    | No           | 2026-03-13   | #427  |

### Diagram Section Banners (`docs/diagrams/headers/`)

| File                       | Dimensions | Format | Dark Variant | Last Updated | Issue |
| -------------------------- | ---------- | ------ | ------------ | ------------ | ----- |
| `header-architecture.svg`  | 800×120    | SVG    | No           | 2026-03-13   | #429  |
| `header-scoring.svg`       | 800×120    | SVG    | No           | 2026-03-13   | #429  |
| `header-api.svg`           | 800×120    | SVG    | No           | 2026-03-13   | #429  |
| `header-qa.svg`            | 800×120    | SVG    | No           | 2026-03-13   | #429  |
| `header-deployment.svg`    | 800×120    | SVG    | No           | 2026-03-13   | #429  |

### Mermaid Source Files (`docs/diagrams/`)

| File                          | Generates                        | Last Updated |
| ----------------------------- | -------------------------------- | ------------ |
| `architecture-overview.mmd`   | `architecture-overview.svg`      | 2026-03-13   |
| `architecture-overview-dark.mmd` | `architecture-overview-dark.svg` | 2026-03-13 |
| `erd-full.mmd`                | `erd-full.svg`                   | 2026-03-13   |
| `erd-full-dark.mmd`           | `erd-full-dark.svg`              | 2026-03-13   |
| `erd-core.mmd`                | `erd-core.svg`                   | 2026-03-13   |
| `erd-core-dark.mmd`           | `erd-core-dark.svg`              | 2026-03-13   |
| `pipeline-flow.mmd`           | `pipeline-flow.svg`              | 2026-03-13   |
| `ci-cd-pipeline.mmd`          | `ci-cd-pipeline.svg`             | 2026-03-13   |
| `qa-overview.mmd`             | `qa-overview.svg`                | 2026-03-13   |
| `confidence-model.mmd`        | `confidence-model.svg`           | 2026-03-13   |
| `concern-tiers.mmd`           | `concern-tiers.svg`              | 2026-03-13   |
| `country-expansion.mmd`       | `country-expansion.svg`          | 2026-03-13   |

### Template Headers (`.github/assets/`)

| File                         | Dimensions | Format | Purpose                  | Last Updated | Issue |
| ---------------------------- | ---------- | ------ | ------------------------ | ------------ | ----- |
| `bug-report-header.svg`     | 800×100    | SVG    | Bug report template      | 2026-03-13   | #414  |
| `feature-request-header.svg`| 800×100    | SVG    | Feature request template | 2026-03-13   | #414  |
| `data-schema-header.svg`    | 800×100    | SVG    | Data/schema template     | 2026-03-13   | #414  |
| `pr-header.svg`             | 800×100    | SVG    | Pull request template    | 2026-03-13   | #414  |

### Logo & Brand Mark (`docs/assets/logo/`)

| File                         | Dimensions | Format | Dark Variant            | Last Updated | Issue |
| ---------------------------- | ---------- | ------ | ----------------------- | ------------ | ----- |
| `logomark.svg`               | 512×512    | SVG    | `logomark-dark.svg`     | 2026-03-14   | #407  |
| `logomark-dark.svg`          | 512×512    | SVG    | (is dark)               | 2026-03-14   | #407  |
| `logomark-mono.svg`          | 512×512    | SVG    | N/A (currentColor)      | 2026-03-14   | #407  |
| `logomark-{16–512}.png`      | 16–512px   | PNG    | N/A                     | 2026-03-14   | #407  |
| `wordmark.svg`               | 480×72     | SVG    | `wordmark-dark.svg`     | 2026-03-14   | #408  |
| `wordmark-dark.svg`          | 480×72     | SVG    | (is dark)               | 2026-03-14   | #408  |
| `lockup-horizontal.svg`      | 660×120    | SVG    | `lockup-horizontal-dark.svg` | 2026-03-14 | #408 |
| `lockup-horizontal-dark.svg` | 660×120    | SVG    | (is dark)               | 2026-03-14   | #408  |
| `lockup-stacked.svg`         | 320×380    | SVG    | `lockup-stacked-dark.svg` | 2026-03-14 | #408  |
| `lockup-stacked-dark.svg`    | 320×380    | SVG    | (is dark)               | 2026-03-14   | #408  |

### Banners (`docs/assets/banners/`)

| File                    | Dimensions | Format | Purpose                     | Last Updated | Issue |
| ----------------------- | ---------- | ------ | --------------------------- | ------------ | ----- |
| `release-template.svg`  | 1280×640   | SVG    | GitHub release social image | 2026-03-13   | #414  |

### Design Tokens (`docs/assets/`)

| File                  | Format | Purpose                                 | Last Updated | Issue |
| --------------------- | ------ | --------------------------------------- | ------------ | ----- |
| `design-tokens.json`  | JSON   | Machine-readable token definitions      | 2026-03-12   | #406  |

### Pending Assets

| Asset              | Issue | Status                     |
| ------------------ | ----- | -------------------------- |
| Social preview     | #409  | Open — blocked by #407     |
| Favicon set        | #413  | Open — blocked by #407     |
| OG images          | #416  | Open — blocked by #407     |
| App icons          | #419  | Open — blocked by #407     |

---

## Related Documents

| Document                                                                       | Relationship                                      |
| ------------------------------------------------------------------------------ | ------------------------------------------------- |
| [`frontend/docs/DESIGN_SYSTEM.md`](../frontend/docs/DESIGN_SYSTEM.md)          | Token reference with Tailwind mappings (technical) |
| [`docs/assets/design-tokens.json`](assets/design-tokens.json)                  | Machine-readable color definitions                |
| [`frontend/src/styles/globals.css`](../frontend/src/styles/globals.css)         | CSS custom property definitions (source of truth) |
| [`frontend/tailwind.config.ts`](../frontend/tailwind.config.ts)                | Tailwind utility class mappings                   |
| [`docs/UX_UI_DESIGN.md`](UX_UI_DESIGN.md)                                     | UI/UX design guidelines                           |
| [`docs/SCORING_METHODOLOGY.md`](SCORING_METHODOLOGY.md)                        | Score band definitions and formula                 |
