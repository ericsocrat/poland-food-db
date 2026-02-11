# Poland Food DB — UX/UI Design Document

> **Status:** Production-ready specification — architecture, data contracts, and UX rules locked.
> **Last updated:** 2026-02-10 (incremental hardening: score disambiguation, API-to-component mapping, misinterpretation defense v2)
> **Implementation stage:** Spec-complete. No front-end code yet. All API endpoints exist and pass QA (152/152 checks). This document is the single source of truth for any future front-end implementation.

---

## 1. Design Philosophy

| Principle                  | Meaning                                                                                         |
| -------------------------- | ----------------------------------------------------------------------------------------------- |
| **Clarity**                | Every number, score, and label must be instantly understandable. No jargon without explanation. |
| **Explainability**         | Users can always ask "why?" — every score links to the data behind it.                          |
| **Trust**                  | Show data sources, methodology, confidence levels. Never hide limitations.                      |
| **No health halos**        | Avoid misleading binary "healthy/unhealthy" labels. Show nuance via multi-axis scoring.         |
| **Progressive disclosure** | Show summary first, then let users drill into detail on demand.                                 |

---

## 2. Information Architecture

### 2.1 Navigation Structure

```
Home (Dashboard)
├── Browse by Category  →  Category Grid  →  Product List  →  Product Detail
├── Compare Products    →  Side-by-side comparison (up to 4)
├── Search              →  Full-text search with filters
├── Best Choices        →  "Top picks" per category (lowest unhealthiness)
├── My Watchlist        →  Saved products for quick access (future)
└── About / Methodology →  How scores are calculated, data sources
```

### 2.2 URL Scheme (Web)

```
/                           →  Dashboard
/category/:slug             →  Category listing (e.g. /category/dairy)
/product/:id                →  Product detail
/compare?ids=1,2,3          →  Comparison view
/search?q=mleko&cat=dairy   →  Search results
/best/:category             →  Best choices for a category
/about                      →  Methodology & data sources
```

---

## 3. Core Views

### 3.1 Dashboard (Home)

**Purpose:** At-a-glance overview of the entire database.

**Layout:**
```
┌─────────────────────────────────────────────────────────┐
│  🇵🇱  Poland Food DB                    [Search bar]    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Category Grid (5 × 4)                                  │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐         │
│  │Dairy │ │Chips │ │Meat  │ │Drinks│ │Sweets│         │
│  │ 28   │ │ 28   │ │ 28   │ │ 28   │ │ 28   │         │
│  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘         │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐         │
│  │Bread │ │Cereal│ │Canned│ │Sauce │ │Condi │         │
│  │ 28   │ │ 28   │ │ 28   │ │ 28   │ │ 28   │         │
│  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘         │
│  ... (4 rows total)                                     │
│                                                         │
│  ┌─────────────────────┐  ┌──────────────────────────┐  │
│  │ Quick Stats         │  │ Recently Scored           │  │
│  │ 560 active products │  │ 1. Lay's Classic     72   │  │
│  │ 20 categories       │  │ 2. Mlekovita Kefir   12   │  │
│  │ 139 brands          │  │ 3. Alpro Soja        18   │  │
│  └─────────────────────┘  └──────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

**Interactions:**
- Each category card shows: icon, name, product count, average unhealthiness score (colour-coded)
- Click a card → navigate to category listing
- Search bar: instant results as you type (debounced 300ms)

---

### 3.2 Category Listing

**Purpose:** Explore all products in a category with sorting and filtering.

**Layout:**
```
┌─────────────────────────────────────────────────────────┐
│  ← Back    Dairy (28 products)         [Sort ▼] [Filter]│
├─────────────────────────────────────────────────────────┤
│  Sort: Unhealthiness ↑ | Calories | Name | Nutri-Score  │
│  Filter: [Brand ▼] [Nutri-Score ▼] [Processing ▼]      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────────────────────────────────────────┐    │
│  │ [img]  Mlekovita Kefir Naturalny         12 🟢  │    │
│  │        Mlekovita · Nutri-Score A · NOVA 1       │    │
│  │        85 kcal · 3.2g fat · 4.0g protein        │    │
│  └─────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────┐    │
│  │ [img]  Piątnica Twaróg Półtłusty          18 🟢  │    │
│  │        Piątnica · Nutri-Score A · NOVA 1        │    │
│  │        112 kcal · 4.0g fat · 18.0g protein      │    │
│  └─────────────────────────────────────────────────┘    │
│  ...                                                    │
└─────────────────────────────────────────────────────────┘
```

**Key elements per product card:**
- Product name + brand
- Unhealthiness score (numeric + colour dot: 🟢 0-25, 🟡 26-50, 🟠 51-75, 🔴 76-100)
- Nutri-Score badge (A-E with standard colours)
- NOVA group indicator
- Key nutrition highlights (calories, fat, protein)
- Click → product detail

**Sort options:**
- Unhealthiness score (default, ascending = healthiest first)
- Calories (low→high)
- Protein (high→low)
- Name (A-Z)
- Nutri-Score (A first)

**Filter options:**
- Brand (multi-select dropdown)
- Nutri-Score grade (A, B, C, D, E)
- Processing risk (Low, Moderate, High)
- Flags (high salt, high sugar, high sat fat — toggle)
- Prep method

---

### 3.3 Product Detail

**Purpose:** Deep dive into a single product — all nutrition, scores, and context.

**Layout:**
```
┌─────────────────────────────────────────────────────────┐
│  ← Dairy    Mlekovita Kefir Naturalny                   │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────┐   Brand: Mlekovita                        │
│  │          │   Category: Dairy                         │
│  │  [image] │   Type: kefir                             │
│  │          │   EAN: 5900512345678                       │
│  └──────────┘   Stores: Biedronka, Lidl                 │
│                                                         │
│  ╔═══════════════════════════════════════════════════╗   │
│  ║  HEALTH SUMMARY                                   ║   │
│  ║                                                   ║   │
│  ║  Unhealthiness Score    12 / 100  ████░░░░░░ 🟢   ║   │
│  ║  Nutri-Score            A        [green badge]    ║   │
│  ║  Processing Risk        Low      NOVA 1           ║   │
│  ║  Data Confidence        High (92/100)  🟢         ║   │
│  ╚═══════════════════════════════════════════════════╝   │
│                                                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │  NUTRITION FACTS (per 100g)                       │  │
│  │  ─────────────────────────────────────────────    │  │
│  │  Calories           85 kcal                       │  │
│  │  Total Fat          3.2 g        ██░░░░░░░░       │  │
│  │  · Saturated Fat    2.0 g        █░░░░░░░░░       │  │
│  │  · Trans Fat        0.0 g        ░░░░░░░░░░       │  │
│  │  Carbohydrates      4.1 g        █░░░░░░░░░       │  │
│  │  · Sugars           4.0 g        █░░░░░░░░░       │  │
│  │  Fibre              0.0 g        ░░░░░░░░░░       │  │
│  │  Protein            4.0 g        ██░░░░░░░░       │  │
│  │  Salt               0.1 g        ░░░░░░░░░░       │  │
│  └───────────────────────────────────────────────────┘  │
│                                                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │  FLAGS & WARNINGS                                 │  │
│  │  ✅ Salt OK    ✅ Sugar OK    ✅ Sat Fat OK        │  │
│  │  ✅ Low additive load (0 additives)               │  │
│  │  ✅ No controversies                              │  │
│  └───────────────────────────────────────────────────┘  │
│                                                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │  INGREDIENTS                                      │  │
│  │  Mleko pasteryzowane, kultury bakterii...         │  │
│  └───────────────────────────────────────────────────┘  │
│                                                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │  WHY THIS SCORE?  [expandable ▼]                  │  │
│  │  ─────────────────────────────────────────────    │  │
│  │  "This product scores well thanks to low sugar,   │  │
│  │   low fat, and minimal processing."               │  │
│  │                                                   │  │
│  │  Factor Breakdown:                                │  │
│  │  ├─ Sugar penalty      2/20  ██░░░░░░░░░░░░░░    │  │
│  │  ├─ Sat fat penalty    3/20  ███░░░░░░░░░░░░░    │  │
│  │  ├─ Salt penalty       1/15  █░░░░░░░░░░░░░░░    │  │
│  │  ├─ Calorie penalty    2/10  ██░░░░░░░░░░░░░░    │  │
│  │  ├─ Processing risk    0/10  ░░░░░░░░░░░░░░░░    │  │
│  │  ├─ Additive load      0/10  ░░░░░░░░░░░░░░░░    │  │
│  │  └─ Other factors      4/15  ████░░░░░░░░░░░░    │  │
│  │                                                   │  │
│  │  Category context: Ranked #3 of 28 in Dairy       │  │
│  │  (avg: 28, this product: 61% better than avg)     │  │
│  └───────────────────────────────────────────────────┘  │
│                                                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │  BETTER ALTERNATIVES (same category)              │  │
│  │  ─────────────────────────────────────────────    │  │
│  │  1. Jogurt Naturalny (Score: 8)      -4 pts 🟢   │  │
│  │  2. Maślanka Naturalna (Score: 10)   -2 pts 🟢   │  │
│  │  3. Kefir Lekki (Score: 11)          -1 pt  🟢   │  │
│  │                                    [See all →]    │  │
│  └───────────────────────────────────────────────────┘  │
│                                                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │  DATA CONFIDENCE  [expandable ▼]                  │  │
│  │  ─────────────────────────────────────────────    │  │
│  │  Overall: 92/100 (High)                           │  │
│  │  ├─ Nutrition data     30/30  ████████████████    │  │
│  │  ├─ Ingredient data    25/25  ████████████████    │  │
│  │  ├─ Source quality     18/20  ███████████████░    │  │
│  │  ├─ EAN present        10/10  ████████████████    │  │
│  │  ├─ Allergen info       0/10  ░░░░░░░░░░░░░░░░   │  │
│  │  └─ Serving data        5/5   ████████████████    │  │
│  │  Missing: allergen declarations                   │  │
│  └───────────────────────────────────────────────────┘  │
│                                                         │
│  [Compare with...]  [Add to Watchlist]                  │
│                                                         │
│  Data source: Open Food Facts + Żabka manual            │
│  Scoring version: v3.2 · Last scored: 2026-02-10        │
└─────────────────────────────────────────────────────────┘
```

**Hover/tooltip behaviour (links to `column_metadata`):**
- Hovering over any score or label shows `tooltip_text` from `column_metadata`
- Example: hover "Nutri-Score" → "Nutri-Score: A (healthiest) to E (least healthy)."
- Example: hover "NOVA 1" → "NOVA: 1=natural, 2=basic, 3=processed, 4=ultra-processed."
- Example: hover "Unhealthiness Score" → "Higher means less healthy. Combines sugar, fat, salt, processing."

**Mini bar charts:**
- Each nutrition value has a proportional bar (relative to daily reference intake)
- Reference: Calories 2000, Fat 70g, Sat Fat 20g, Carbs 260g, Sugars 90g, Fibre 30g, Protein 50g, Salt 6g

---

### 3.4 Compare View

**Purpose:** Side-by-side comparison of 2-4 products.

**Layout:**
```
┌──────────────────────────────────────────────────────────────┐
│  Compare Products (3 selected)                  [+ Add]      │
├──────────────┬──────────────┬──────────────┬─────────────────┤
│              │ Mlekovita    │ Danone       │ Piątnica        │
│              │ Kefir Nat.   │ Activia Nat. │ Jogurt Nat.     │
├──────────────┼──────────────┼──────────────┼─────────────────┤
│ Unhealthiness│ 12 🟢        │ 22 🟢        │ 15 🟢           │
│ Nutri-Score  │ A            │ B            │ A               │
│ NOVA         │ 1            │ 3            │ 1               │
│ Processing   │ Low          │ Moderate     │ Low             │
├──────────────┼──────────────┼──────────────┼─────────────────┤
│ Calories     │ 85           │ 95           │ 78              │
│ Total Fat    │ 3.2          │ 2.8          │ 3.0             │
│ Sat Fat      │ 2.0          │ 1.8          │ 1.9             │
│ Carbs        │ 4.1          │ 12.0         │ 4.5             │
│ Sugars       │ 4.0          │ 11.5         │ 4.2             │
│ Protein      │ 4.0          │ 4.5          │ 5.0             │
│ Salt         │ 0.1          │ 0.12         │ 0.08            │
│ Fibre        │ 0.0          │ 0.0          │ 0.0             │
├──────────────┼──────────────┼──────────────┼─────────────────┤
│ Flags        │ None         │ ⚠ sugar      │ None            │
│ Additives    │ 0            │ 3            │ 0               │
│ Controversies│ none         │ none         │ none            │
├──────────────┼──────────────┼──────────────┼─────────────────┤
│ Winner       │ ★ Best pick  │              │ ★ Runner-up     │
└──────────────┴──────────────┴──────────────┴─────────────────┘
```

**Interactions:**
- Row highlighting: the best value in each row is highlighted (green background)
- Products can be added from search or category listing
- "Winner" row automatically highlights the product with the lowest unhealthiness score
- Each column header links to the full product detail page

---

### 3.5 Best Choices

**Purpose:** Curated "healthiest option" per category — like a recommendation engine.

**Logic:**
1. Filter: `is_deprecated = false`
2. Sort: `unhealthiness_score ASC`
3. Show top 5 per category
4. Add "Why this is a good pick" explainer for each (based on flags/NOVA/nutri-score)

**Anti-health-halo safeguards:**
- Always show the actual score, not just "good" / "bad"
- Include a disclaimer: "Scores are based on available nutrition data and should not replace professional dietary advice."
- Show data completeness — a product with 60% completeness gets a visible "⚠ Limited data" badge
- Show the NOVA group to prevent ultra-processed products with good Nutri-Scores from looking "healthy"

---

### 3.6 Search

**Features:**
- Full-text search across product_name, brand, ingredients_raw
- Auto-suggest from existing product names
- Filters persist from category view
- Results show the same card format as category listing

---

## 4. Scoring Visualisation Strategy

### 4.0 Three Distinct Scoring Systems — What They Are and Are Not

This database shows three independent scores. They measure **different things**, are computed **differently**, and must never be conflated in the UI.

| System                      | What It Measures                                                                         | Range | Source                                    | What It Does NOT Mean                                                                                                             |
| --------------------------- | ---------------------------------------------------------------------------------------- | ----- | ----------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| **Unhealthiness Score**     | Nutritional risk from 9 weighted factors (sugar, fat, salt, processing, additives, etc.) | 1–100 | Computed by `compute_unhealthiness_v32()` | NOT a "health score." A low number ≠ "eat unlimited amounts." Does not capture vitamins, minerals, portions, or individual needs. |
| **Nutri-Score (A–E)**       | EU-style front-of-pack nutrition grade. Positive & negative nutrient balance.            | A–E   | Assigned from `nutri_score_ref` lookup    | NOT a safety rating. Nutri-Score B ≠ "healthy." A NOVA 4 product can still be Nutri-Score A if its macro profile is favourable.   |
| **Data Confidence (0–100)** | How much data we have about the product, NOT how good the product is.                    | 0–100 | Computed by `compute_data_confidence()`   | NOT a quality score. Confidence 95 ≠ "trustworthy product." It means we have comprehensive data to score it accurately.           |

**Critical UX rule:** These three numbers must never appear in a single "overall score" or be averaged. They are always displayed separately with distinct visual treatments (bar, badge, shield).

**Why Nutri-Score B ≠ "Healthy":**
Nutri-Score evaluates macro-nutrient balance (fibre, protein vs. sugar, fat, salt, calories) but ignores: processing level (NOVA), additive load, ingredient concern tiers, trans fats, and controversies. A breakfast cereal with added vitamins can score Nutri-Score A while being NOVA 4 (ultra-processed) with 6 additives. Our unhealthiness score captures these dimensions; Nutri-Score does not.

**Why Confidence ≠ Healthiness:**
A product with confidence 95/100 has comprehensive, verified data — it could still have an unhealthiness score of 55 (elevated). A product with confidence 40/100 has incomplete data — its actual score might be higher OR lower than displayed. Confidence tells you how much to trust the displayed score, not how good the product is.

### 4.1 Unhealthiness Score (0-100)

**Visual treatment:**
- Horizontal progress bar with colour gradient
- 0-25: Green (#22c55e) — "Low concern"
- 26-50: Yellow (#eab308) — "Moderate concern"
- 51-75: Orange (#f97316) — "High concern"
- 76-100: Red (#ef4444) — "Very high concern"
- Always show the numeric value alongside the bar

**Never say "healthy" or "unhealthy" as a binary label.** Instead:
- "Lower concern" / "Higher concern"
- "Relatively better" / "Relatively worse"
- Always in context: "within this category" or "compared to similar products"

### 4.2 Nutri-Score (A-E)

**Visual treatment:** Standard EU Nutri-Score badge format
- A: Dark green
- B: Light green
- C: Yellow
- D: Orange
- E: Red
- UNKNOWN: Grey with "?" icon

### 4.3 NOVA (1-4)

**Visual treatment:** Numbered badge with colour
- 1: Green — "Unprocessed or minimally processed"
- 2: Yellow — "Processed culinary ingredients"
- 3: Orange — "Processed foods"
- 4: Red — "Ultra-processed food and drink products"

### 4.4 Flags

**Visual treatment:** Simple YES/NO indicators
- YES: Warning icon (⚠) with red text
- NO: Check icon (✅) with muted text
- NULL: Dash (—) to indicate "not assessed"

### 4.5 Data Confidence (0-100)

**Visual treatment:**
- Small shield icon + score + band label
- High (≥80): Green shield — "High confidence · Data is comprehensive"
- Medium (50-79): Amber shield — "Medium confidence · Some data may be estimated"
- Low (<50): Red shield — "Low confidence · Limited data available"

**When confidence is medium or low:**
- Show a subtle banner below the Health Summary box:
  `"⚠ This product's score is based on incomplete data. Some values may be estimated."`
- Visually de-emphasize the unhealthiness score (reduce opacity to 70%)
- Add `(estimated)` suffix to any score shown in listings

**Expandable breakdown:**
- On click/tap, reveal the 6-component breakdown (nutrition, ingredients, source, EAN, allergens, serving data)
- Each component shows points earned vs. max as a micro progress bar
- List missing data items explicitly (e.g., "Missing: allergen declarations, per-serving data")

**In listings (Category Listing, Search Results, Compare View):**
- Show small confidence indicator next to score: `12 🛡️` (high), `28 ⚠` (medium/low)
- Filter dropdown: "Show: All / High confidence only"

### 4.6 Score Explanation

**Visual treatment:** Expandable panel on Product Detail page.

**Header (always visible):**
- Human-readable headline from `api_score_explanation().headline`:
  e.g., *"This product scores well thanks to low sugar and minimal processing."*

**Expanded content:**
- **Factor breakdown:** Horizontal bar chart showing each scoring factor's contribution
  - Sort by impact (largest penalty first)
  - Each bar shows: factor name, points/max, input value, visual bar
  - Colour: green (0-30% of max), yellow (30-60%), orange (60-80%), red (>80%)

- **Category context:** Comparative positioning
  - "Ranked #3 of 28 in Dairy"
  - "61% better than the category average (28)"
  - Small histogram showing score distribution in the category with this product highlighted

- **Warnings array:** Displayed as amber callout boxes
  - e.g., "⚠ Ultra-processed (NOVA 4) — high additive load"
  - e.g., "⚠ Contains palm oil"

**Anti-misinterpretation rules:**
- Never show the breakdown without the headline narrative
- Always show category context — raw numbers without comparison are misleading
- If confidence < 50, prefix with: "Note: This breakdown is based on limited data."

---

## 5. Mobile App Design

### 5.1 Navigation (Bottom Tab Bar)

```
┌─────────────────────────────────────┐
│           [Screen Content]           │
├────────┬────────┬────────┬──────────┤
│ 🏠     │ 🔍     │ ⚖️     │ ★        │
│ Home   │ Search │ Compare│ Best     │
└────────┴────────┴────────┴──────────┘
```

### 5.2 Mobile-Specific Features

**Barcode Scanner (future):**
- Tap camera icon in search → scan EAN barcode
- Instant lookup against products.ean
- If found: show product detail
- If not found: "Not in our database yet" with suggestion to add

**Swipe Gestures:**
- Swipe left on product card → add to compare
- Swipe right on product card → add to watchlist
- Pull down to refresh / re-sort

### 5.3 Mobile Layout Adaptations

**Category grid:** 2×10 instead of 5×4
**Product cards:** Full-width, stacked vertically
**Compare view:** Horizontal scroll between products (1 visible at a time) with dot indicator
**Nutrition table:** Collapsible accordion sections

---

## 6. Tooltip / Hover System (from `column_metadata`)

### 6.1 Implementation Plan

The `column_metadata` table drives all tooltips:

```
API endpoint:  GET /api/metadata/:table_name/:column_name
Response:      { display_label, description, tooltip_text, unit, value_range }
```

**Web:** On hover, show a small popover with:
- `display_label` as title
- `tooltip_text` as body
- `unit` and `value_range` as footnote

**Mobile:** On long-press, show a bottom sheet with:
- `display_label` as title
- `description` (full text)
- `example_values` for context

### 6.2 Example Tooltips

| Column                | Tooltip                                                                                                                         |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| unhealthiness_score   | "Higher means less healthy. Combines sugar, fat, salt, processing."                                                             |
| nutri_score_label     | "Nutri-Score: A (healthiest) to E (least healthy)."                                                                             |
| nova_classification   | "NOVA: 1=natural, 2=basic, 3=processed, 4=ultra-processed."                                                                     |
| high_salt_flag        | "Flags products with salt > 1.5g per 100g."                                                                                     |
| confidence_score      | "How reliable the data is (0-100). Based on nutrition completeness, ingredient availability, source quality, and EAN coverage." |
| confidence_band       | "High (≥80): comprehensive data. Medium (50-79): partial data. Low (<50): limited data."                                        |
| prep_method           | "How the product is typically prepared: ready-to-eat, needs-heating, needs-cooking, etc."                                       |
| ingredients_english   | "Ingredients translated to English from the Polish label."                                                                      |
| store_availability    | "Retail chains where this product has been confirmed available."                                                                |
| data_completeness_pct | "How complete the source data was for scoring."                                                                                 |
| calories              | "Kilocalories per serving."                                                                                                     |
| ean                   | "Barcode number. 590 prefix indicates Polish origin."                                                                           |

---

## 7. Colour Palette & Typography

### 7.1 Colours

| Token          | Hex       | Usage                                    |
| -------------- | --------- | ---------------------------------------- |
| `--green-500`  | `#22c55e` | Good scores, Nutri-Score A, NOVA 1       |
| `--green-700`  | `#15803d` | Nutri-Score A badge                      |
| `--yellow-500` | `#eab308` | Moderate scores, Nutri-Score C, NOVA 2   |
| `--orange-500` | `#f97316` | High concern, Nutri-Score D, NOVA 3      |
| `--red-500`    | `#ef4444` | Very high concern, Nutri-Score E, NOVA 4 |
| `--slate-50`   | `#f8fafc` | Background                               |
| `--slate-900`  | `#0f172a` | Primary text                             |
| `--slate-500`  | `#64748b` | Secondary text                           |
| `--blue-600`   | `#2563eb` | Links, interactive elements              |
| `--white`      | `#ffffff` | Cards, surfaces                          |

### 7.2 Typography

| Element           | Font           | Size            | Weight         |
| ----------------- | -------------- | --------------- | -------------- |
| Page title        | Inter          | 24px / 1.5rem   | 700 (Bold)     |
| Section heading   | Inter          | 18px / 1.125rem | 600 (Semibold) |
| Card title        | Inter          | 16px / 1rem     | 600            |
| Body text         | Inter          | 14px / 0.875rem | 400 (Regular)  |
| Caption / tooltip | Inter          | 12px / 0.75rem  | 400            |
| Score number      | JetBrains Mono | 20px / 1.25rem  | 700            |

---

## 8. Data Flow Architecture

```
┌──────────────┐    ┌───────────────┐    ┌──────────────┐
│ PostgreSQL   │───▶│ Supabase      │───▶│ REST / RPC   │
│ (Docker)     │    │ PostgREST     │    │ API          │
└──────────────┘    └───────────────┘    └──────┬───────┘
                                                │
                                    ┌───────────┴──────────┐
                                    │                      │
                              ┌─────▼─────┐         ┌─────▼────┐
                              │ Web App   │         │ Mobile   │
                              │ (Next.js) │         │ (React   │
                              │           │         │  Native) │
                              └───────────┘         └──────────┘
```

**API endpoints (via Supabase PostgREST):**

Views (direct GET):
- `GET /rest/v1/v_api_category_overview` — Dashboard category grid (20 rows)
- `GET /rest/v1/v_product_confidence?confidence_band=eq.low` — Confidence filtering
- `GET /rest/v1/column_metadata?table_name=eq.scores` — Tooltip/help text

RPC functions (POST /rpc/):
- `POST /rpc/api_product_detail` — Full product detail as structured JSONB
- `POST /rpc/api_category_listing` — Paged category listing with sort/filter
- `POST /rpc/api_search_products` — Full-text + trigram search
- `POST /rpc/api_score_explanation` — Score breakdown + category context
- `POST /rpc/api_better_alternatives` — Healthier substitutes
- `POST /rpc/api_data_confidence` — Data confidence score + breakdown

> **See [API_CONTRACTS.md](API_CONTRACTS.md) for complete response shapes and field documentation.**

### 8.2 API-to-Component Mapping

Every UI component maps to exactly one API call. No component should ever call multiple endpoints and merge results client-side.

| UI Component                    | API Endpoint                        | Key Response Fields                                                                | Caching Strategy    |
| ------------------------------- | ----------------------------------- | ---------------------------------------------------------------------------------- | ------------------- |
| Dashboard — Category Grid       | `GET v_api_category_overview`       | `category`, `product_count`, `avg_unhealthiness`, `score_band`                     | 5 min TTL           |
| Category Listing — Product List | `POST /rpc/api_category_listing`    | `product_id`, `product_name`, `brand`, `unhealthiness_score`, `nutri_score_label`  | 2 min TTL           |
| Product Detail — Identity       | `POST /rpc/api_product_detail`      | Full JSONB: identity, nutrition, flags, ingredients, allergens, traces, confidence | On navigation       |
| Product Detail — Score Panel    | `POST /rpc/api_score_explanation`   | `headline`, `factor_breakdown[]`, `category_rank`, `category_avg`, `warnings[]`    | On navigation       |
| Product Detail — Confidence     | `POST /rpc/api_data_confidence`     | `total_score`, `band`, `components[]`, `missing_items[]`                           | On navigation       |
| Product Detail — Alternatives   | `POST /rpc/api_better_alternatives` | `product_id`, `product_name`, `score`, `score_diff`                                | On navigation       |
| Search Results                  | `POST /rpc/api_search_products`     | Same as category listing + `rank` from `ts_rank_cd`                                | No cache (live)     |
| Tooltips                        | `GET column_metadata`               | `tooltip_text`, `display_label`, `unit`                                            | Session-level cache |

### 8.3 Product Detail — Render Order

The Product Detail page loads data from 4 API calls (parallelised) and renders sections in this fixed order:

1. **Identity** — from `api_product_detail`: name, brand, category, EAN, stores
2. **Health Summary** — from `api_product_detail`: unhealthiness score bar + nutri-score badge + NOVA badge + confidence shield
3. **Nutrition Facts** — from `api_product_detail`: per-100g table with mini bars
4. **Flags & Warnings** — from `api_product_detail`: salt/sugar/sat-fat/additive flags
5. **Score Explanation** — from `api_score_explanation`: headline → factor breakdown → category context → warnings (expandable, collapsed by default)
6. **Data Confidence** — from `api_data_confidence`: overall score → 6-component breakdown → missing items (expandable, collapsed by default)
7. **Ingredients** — from `api_product_detail`: raw Polish text + English translation
8. **Better Alternatives** — from `api_better_alternatives`: up to 3 products with score diff (expandable, collapsed by default)
9. **Footer** — data source, scoring version, last scored date

**Key Postgres functions (internal, not exposed directly):**
- `compute_unhealthiness_v32()` — 9-factor scoring formula
- `compute_data_confidence()` — 6-component confidence scoring
- `find_similar_products()` — Jaccard ingredient similarity
- `find_better_alternatives()` — Healthier alternatives ranking
- `refresh_all_materialized_views()` — Refresh all MVs after data changes
- `mv_staleness_check()` — Check if MVs need refresh

---

## 9. Accessibility

- WCAG 2.1 AA compliance minimum
- All colour-coded elements also have text labels (never colour alone)
- Score bars have aria-labels: `aria-label="Unhealthiness score: 12 out of 100, low concern"`
- Nutri-Score badges have alt text: `alt="Nutri-Score A"`
- Focus management: keyboard-navigable product cards, modals trap focus
- High-contrast mode: ensure score colours pass 4.5:1 contrast ratio on both light and dark backgrounds
- Screen reader: all tooltips also accessible via `aria-describedby`

---

## 10. Trust & Transparency

### 10.1 Source Attribution
Every product shows: data source (may be multi-source), scoring version, last scored date, and data confidence score with band.

### 10.2 Limitations Badge
Products with `confidence_band = 'low'` (score < 50) show a visible warning:
`"⚠ Limited data — this score has lower reliability. Check the product label for details."`

Products with `confidence_band = 'medium'` (score 50-79) show a subtle note:
`"ℹ Some data may be estimated. Confidence: Medium (score/100)."`

Products with `confidence_band = 'high'` (score ≥ 80) show a green shield:
`"🛡️ High confidence — comprehensive data from verified sources."`

### 10.3 Methodology Page (`/about`)
- How unhealthiness_score is calculated (9-factor formula breakdown with weights)
- What each NOVA group means and how it affects the score
- How Nutri-Score is assigned
- Data sources (Open Food Facts API, Żabka manual data, other category-specific sources)
- How data confidence is calculated (6 components, full formula)
- Update frequency and MV refresh strategy
- Known limitations and caveats

### 10.4 Anti-Health-Halo Principles
1. **Never rank a category as "healthy" overall** — e.g. "Dairy" is not inherently healthy.
2. **Always show NOVA alongside Nutri-Score** — prevents ultra-processed foods with good Nutri-Scores from appearing "healthy."
3. **Show context**: "12/100 within Dairy" not just "12/100."
4. **Disclaimers visible (not buried in footer)**: "This data is for informational purposes only."
5. **Show conflicting signals explicitly**: When Nutri-Score is A/B but NOVA is 4, show a prominent amber callout: "Good nutrition score but ultra-processed. Consider the processing level."
6. **De-emphasize uncertain scores**: When confidence is medium/low, visually reduce score prominence (opacity, smaller font) and add "(estimated)" suffix.

---

## 11. Misinterpretation Defense

This section defines patterns to prevent users from drawing incorrect conclusions from the data.

### 11.1 Conflicting Signal Patterns

| Scenario                        | Signal Conflict                                | UX Response                                                                                                           |
| ------------------------------- | ---------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| Good Nutri-Score (A/B) + NOVA 4 | Nutrition looks good but highly processed      | Amber callout: *"Good nutrition profile but ultra-processed. Processing adds additives not captured by Nutri-Score."* |
| Low score + High salt flag      | Score seems fine but salt is extreme           | Red flag badge remains visible even when overall score is green                                                       |
| Low score + Low confidence      | Score looks good but data is incomplete        | De-emphasize score visually, show confidence warning prominently                                                      |
| NOVA 1 + High score             | Minimally processed but high in sugar/fat/salt | Note: *"While minimally processed, this product has high sugar/fat/salt content."*                                    |

### 11.2 Score Context Rules

1. **Never show a score without category context.** A score of 25 in "Candy" is excellent; in "Water" it's terrible.
   - Always display: "X/100 in [Category]" with the category average
   - On listings: show rank badge (#3 of 28)

2. **Never compare scores across categories without a disclaimer.**
   - Cross-category comparison view must show: *"Scores are relative within each category. A low score in Chips ≠ a low score in Dairy."*

3. **Show the score distribution, not just the number.**
   - On Product Detail, include a mini histogram of the category's score distribution
   - Highlight the current product's position

### 11.3 "What This Score Doesn't Tell You"

Display this as an expandable section or info icon on the methodology page and Product Detail:

> **What this score captures:**
> - Nutrient density (sugar, salt, saturated fat, calories)
> - Processing level (NOVA classification)
> - Additive load (EFSA concern tiers)
> - Data quality (confidence scoring)
>
> **What this score does NOT capture:**
> - Individual dietary needs (allergies, medications, pregnancy)
> - Portion sizes as actually consumed
> - Micronutrient content (vitamins, minerals)
> - Environmental impact or ethical sourcing
> - Taste, freshness, or preparation quality
> - Whether this product is appropriate for your specific health goals
>
> **Always consult a healthcare professional for dietary advice.**

### 11.4 Confidence-Aware Display Rules

| Confidence Band | Score Display                                    | Comparison Allowed?       | Better Alternatives?                                   |
| --------------- | ------------------------------------------------ | ------------------------- | ------------------------------------------------------ |
| High (≥80)      | Full colour, normal size                         | Yes                       | Yes                                                    |
| Medium (50-79)  | Muted colour (70% opacity), "(estimated)" suffix | Yes, with caveat          | Yes, with caveat                                       |
| Low (<50)       | Grey, "(limited data)" suffix, warning banner    | No — hide from comparison | Show with warning: "Alternatives may be more reliable" |

**Hard UX guardrails (non-negotiable):**
1. If `confidence_band = 'low'`, the product MUST NOT appear in Compare View. The "Compare" button is disabled with tooltip: "Insufficient data for reliable comparison."
2. If `confidence_band = 'low'`, the "Better Alternatives" section header shows: "⚠ These alternatives have higher data confidence and may be more reliably scored."
3. If ANY product in a comparison has `confidence_band = 'medium'`, show a persistent banner: "One or more products have estimated data. Differences under 5 points may not be meaningful."
4. Sort tiebreaker: when two products have identical unhealthiness scores, rank the higher-confidence product first.
5. Never auto-select a "Winner" in Compare View if the score difference is <3 points — show "Too close to call" instead.

### 11.5 Copy Blocks for Common Scenarios

**Product with perfect score (0-10):**
> "This product has one of the lowest unhealthiness scores in its category. However, 'low unhealthiness' does not mean 'eat unlimited amounts.' Portion size and your overall diet matter."

**Product with very high score (80+):**
> "This product scores high on our unhealthiness scale. This doesn't mean you should never eat it — occasional consumption as part of a balanced diet is fine. Consider the 'Better Alternatives' section for everyday options."

**Product missing key data:**
> "We don't have complete data for this product (confidence: X/100). The score shown may not fully reflect its nutritional profile. We recommend checking the product label for accurate information."

**Score explanation unavailable:**
> "Score breakdown is not available for this product because it uses an older scoring version. The overall score is still valid."

### 11.6 Comparison View Safeguards

1. **Block comparing products with confidence_band = 'low'** — show message: *"This product has insufficient data for reliable comparison."* Disable the "Add to compare" button entirely; don't just warn after the fact.
2. **When comparing across categories**, show a persistent banner: *"These products belong to different categories. Scores are most meaningful when compared within the same category."*
3. **Highlight the winner clearly but add nuance**: Instead of "Product A is healthier", say "Product A has a lower unhealthiness score (12 vs 38 in Dairy). Both are relatively low concern."
4. **Never auto-rank by score alone** — default sort should consider confidence, so low-confidence products don't appear at the top.
5. **Score difference thresholds for comparison language:**
   - Difference <3 points: "Too close to distinguish meaningfully"
   - Difference 3-10 points: "Slightly lower unhealthiness"
   - Difference 11-25 points: "Noticeably lower unhealthiness"
   - Difference >25 points: "Substantially lower unhealthiness"
6. **Never use the word "healthier"** in comparison results. Always use "lower unhealthiness score" or "fewer nutritional risk factors."

---

## 12. EU Expansion Readiness

When expanding beyond Poland, the following UX elements must adapt:

| Element                | Poland (Current)    | Multi-Country (Future)                             |
| ---------------------- | ------------------- | -------------------------------------------------- |
| Country filter         | Hardcoded PL        | Dropdown: PL, DE, CZ, etc. (from `country_ref`)    |
| Nutri-Score display    | Standard EU badge   | May vary — some countries use traffic-light labels |
| Currency in prices     | PLN (future)        | EUR, CZK, etc. — locale-aware formatting           |
| Ingredient language    | Polish + English    | Native language + English translation              |
| Store chains           | Polish retailers    | Country-specific retailer lists                    |
| EAN prefix validation  | 590 = Polish origin | Country-specific prefix mapping                    |
| Regulatory disclaimers | Polish food law     | Country-specific legal requirements                |

**UX rule:** All country-specific data must come from the database (reference tables), never from front-end hardcoding. See [COUNTRY_EXPANSION_GUIDE.md](COUNTRY_EXPANSION_GUIDE.md).
