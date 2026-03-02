# Repository Settings Instructions

> **Last updated:** 2026-03-13

Step-by-step guide for configuring GitHub repository settings for `ericsocrat/tryvit`.

---

## 1. Repository Description & Topics

**Already applied** (via `gh repo edit`):

- **Description:** `TryVit — Food Health Scanner. Scan, score & compare food products with multi-axis health scoring (v3.2). 1,281 products, 2,995 ingredients, EFSA concern analysis, allergen tracking, barcode scanning. PostgreSQL + Supabase + Next.js + TypeScript.`
- **Topics (20):** `tryvit`, `food-health`, `nutrition`, `health`, `nutri-score`, `nova-score`, `food-safety`, `allergens`, `ingredients`, `barcode-scanner`, `poland`, `food-scoring`, `postgresql`, `supabase`, `nextjs`, `typescript`, `open-food-facts`, `efsa`, `food-science`, `health-tech`

**To update manually:**

1. Go to the repo main page → click the ⚙️ gear icon next to "About"
2. Paste the description above
3. Add/remove topics as needed
4. Set **Website** URL (e.g., Vercel deployment URL) once available
5. Click **Save changes**

---

## 2. Social Preview Image

1. Go to **Settings → General**
2. Scroll to **Social preview**
3. Click **Edit → Upload an image**
4. Upload `docs/assets/banners/social-preview.png` (1280×640px) — _created in #411_
5. Click **Save**

> **Note:** Social preview image (#411) is not yet created. This step will be completed when #411 is done.

---

## 3. Repository Features

1. Go to **Settings → General → Features**
2. Ensure these are **enabled**:
   - ✅ Issues
   - ✅ Discussions (for community Q&A)
3. Ensure these are **disabled**:
   - ❌ Wiki (we use `docs/` instead)
   - ❌ Projects (use GitHub Issues + Milestones)

---

## 4. Release Banner Usage

A release banner SVG template is provided at:

```
docs/assets/banners/release-template.svg
```

**To customize for a new release:**

1. Copy the template SVG
2. Edit these text elements:
   - `v0.0.0` → actual version number (e.g., `v3.2.1`)
   - `Release Title Goes Here` → release name (e.g., `Recipe Integration`)
   - 5 highlight lines → actual feature highlights
3. Save as `release-vX.Y.Z.svg`
4. Reference in the GitHub Release notes with:
   ```markdown
   ![Release vX.Y.Z](docs/assets/banners/release-vX.Y.Z.svg)
   ```

---

## 5. Template Headers

Issue and PR templates now include branded SVG headers from `.github/assets/`:

| Template             | Header File                  | Preview Text           |
| -------------------- | ---------------------------- | ---------------------- |
| Bug Report           | `bug-report-header.svg`      | 🐛 Bug Report           |
| Feature Request      | `feature-request-header.svg` | ✨ Feature Request      |
| Data / Schema Change | `data-schema-header.svg`     | 🗄️ Data / Schema Change |
| Pull Request         | `pr-header.svg`              | 🔀 Pull Request         |

Headers are referenced via `raw.githubusercontent.com` URLs so they render in GitHub's issue/PR creation UI.
