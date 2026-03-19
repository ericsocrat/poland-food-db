<#
.SYNOPSIS
  Captures screenshots of pages affected by the current branch's changes.

.DESCRIPTION
  Detects which files have changed (vs main or uncommitted), maps them to
  page URLs via e2e/helpers/page-map.ts, and captures mobile + desktop
  screenshots using Playwright.

  Output: frontend/pr-screenshots/{mobile,desktop}/

  Requires:
  - Dev server running at http://localhost:3000
  - SUPABASE_SERVICE_ROLE_KEY set (for authenticated pages)

.PARAMETER All
  Capture all mapped pages regardless of file changes (useful for full review).

.EXAMPLE
  .\RUN_PR_SCREENSHOTS.ps1            # Only changed pages
  .\RUN_PR_SCREENSHOTS.ps1 -All       # All pages
#>
[CmdletBinding()]
param(
    [switch]$All
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "`n═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  PR Screenshots — Changed Pages Only" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════`n" -ForegroundColor Cyan

# ── Pre-flight checks ───────────────────────────────────────────────────────

if (-not $env:SUPABASE_SERVICE_ROLE_KEY) {
    Write-Host "ERROR: SUPABASE_SERVICE_ROLE_KEY not set." -ForegroundColor Red
    Write-Host "  Set it via: `$env:SUPABASE_SERVICE_ROLE_KEY = 'your-key'" -ForegroundColor Yellow
    exit 1
}

try {
    $null = Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 5 -ErrorAction Stop
    Write-Host "✅ Dev server running at http://localhost:3000" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Dev server not running at http://localhost:3000" -ForegroundColor Red
    Write-Host "  Start it via: cd frontend && npm run dev" -ForegroundColor Yellow
    exit 1
}

# ── Detect changed files ────────────────────────────────────────────────────

if ($All) {
    Write-Host "ℹ️  -All flag: capturing all mapped pages" -ForegroundColor Yellow
    # Leave CHANGED_FILES unset — page-map.ts will fall back to git diff
    # and if that's empty on main, the spec shows "no pages". Instead, we
    # pass a wildcard so every pattern matches.
    $changedFiles = "frontend/src/app/page.tsx`nfrontend/src/styles/globals.css`nfrontend/messages/en.json"
}
else {
    # Try branch diff first, fall back to uncommitted changes
    $changedFiles = ""
    try {
        $changedFiles = git diff --name-only main...HEAD 2>$null
    }
    catch { }

    if ([string]::IsNullOrWhiteSpace($changedFiles)) {
        $changedFiles = git diff --name-only HEAD 2>$null
    }
    if ([string]::IsNullOrWhiteSpace($changedFiles)) {
        # Also check staged files
        $changedFiles = git diff --name-only --cached 2>$null
    }
}

if ([string]::IsNullOrWhiteSpace($changedFiles)) {
    Write-Host "ℹ️  No changed files detected. Nothing to screenshot." -ForegroundColor Yellow
    exit 0
}

$fileCount = ($changedFiles -split "`n" | Where-Object { $_.Trim() }).Count
Write-Host "📂 $fileCount changed file(s) detected" -ForegroundColor White

# ── Clean output directory ──────────────────────────────────────────────────

$outputDir = Join-Path $PSScriptRoot "frontend\pr-screenshots"
if (Test-Path $outputDir) {
    Remove-Item $outputDir -Recurse -Force
    Write-Host "🧹 Cleaned previous screenshots" -ForegroundColor Gray
}

# ── Run Playwright ──────────────────────────────────────────────────────────

Write-Host "`n📸 Capturing PR screenshots...`n" -ForegroundColor Cyan

Push-Location "$PSScriptRoot\frontend"

$env:PR_SCREENSHOTS = "true"
$env:CHANGED_FILES = $changedFiles

try {
    npx playwright test --project=pr-screenshots --reporter=list
    $exitCode = $LASTEXITCODE
}
finally {
    Remove-Item Env:\PR_SCREENSHOTS -ErrorAction SilentlyContinue
    Remove-Item Env:\CHANGED_FILES -ErrorAction SilentlyContinue
    Pop-Location
}

# ── Report results ──────────────────────────────────────────────────────────

Write-Host "`n═══════════════════════════════════════" -ForegroundColor Cyan

if ($exitCode -eq 0) {
    $mobileCount = (Get-ChildItem "frontend\pr-screenshots\mobile\*.png" -ErrorAction SilentlyContinue).Count
    $desktopCount = (Get-ChildItem "frontend\pr-screenshots\desktop\*.png" -ErrorAction SilentlyContinue).Count
    $total = $mobileCount + $desktopCount

    Write-Host "✅ PR screenshots captured!" -ForegroundColor Green
    Write-Host "`n  Mobile:  $mobileCount" -ForegroundColor White
    Write-Host "  Desktop: $desktopCount" -ForegroundColor White
    Write-Host "  Total:   $total`n" -ForegroundColor Cyan

    if ($total -gt 0) {
        Write-Host "  📁 Output: frontend/pr-screenshots/" -ForegroundColor White
        Write-Host "     mobile/  — 390×844 viewport" -ForegroundColor Gray
        Write-Host "     desktop/ — 1440×900 viewport" -ForegroundColor Gray
    }
}
else {
    Write-Host "⚠️  Some screenshots failed (exit code: $exitCode)" -ForegroundColor Yellow
    Write-Host "  Check Playwright HTML report: npx playwright show-report" -ForegroundColor Yellow
}

Write-Host "═══════════════════════════════════════`n" -ForegroundColor Cyan

exit $exitCode
