#!/usr/bin/env pwsh
# ═══════════════════════════════════════════════════════════════════════════════
# repo_verify.ps1 — Deterministic repository hygiene checks
# ═══════════════════════════════════════════════════════════════════════════════
# Policy:      docs/REPO_GOVERNANCE.md
# CI enforcer: .github/workflows/repo-verify.yml
# Triggered:   After structural changes (see copilot-instructions.md §16)
#
# Design: Static filesystem checks ONLY. No heuristics, no network calls,
#         no fuzzy logic, no PR diff parsing. Exit 0 (pass) or exit 1 (fail).
#         Runs in < 5 seconds on any machine. Idempotent.
# ═══════════════════════════════════════════════════════════════════════════════

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$failed = 0
$passed = 0

function Test-Check {
    param([string]$Name, [scriptblock]$Check)
    try {
        $errors = @(& $Check)
        $errors = @($errors | Where-Object { $_ })
        if ($errors.Count -gt 0) {
            Write-Host "FAIL  $Name" -ForegroundColor Red
            foreach ($e in $errors) { Write-Host "       $e" -ForegroundColor Yellow }
            $script:failed++
        } else {
            Write-Host "PASS  $Name" -ForegroundColor Green
            $script:passed++
        }
    } catch {
        Write-Host "FAIL  $Name (exception: $_)" -ForegroundColor Red
        $script:failed++
    }
}

# ── Check 1: Root cleanliness ────────────────────────────────────────────────
Test-Check "Root cleanliness" {
    $errors = @()
    $forbidden = @(
        'tmp-*', 'qa_*.json', 'qa-test.json',
        '_func_dump.txt', '__api_defs.txt', '*.log'
    )
    foreach ($pattern in $forbidden) {
        $matches = Get-ChildItem -Path . -Filter $pattern -File -ErrorAction SilentlyContinue
        foreach ($m in $matches) {
            $errors += "Forbidden file in root: $($m.Name)"
        }
    }
    # Check for forbidden directories in root
    $forbiddenDirs = @('tmp-*')
    foreach ($pattern in $forbiddenDirs) {
        $matches = Get-ChildItem -Path . -Filter $pattern -Directory -ErrorAction SilentlyContinue
        foreach ($m in $matches) {
            $errors += "Forbidden directory in root: $($m.Name)/"
        }
    }
    $errors
}

# ── Check 2: Docs index coverage ────────────────────────────────────────────
Test-Check "Docs index coverage" {
    $errors = @()
    $indexPath = 'docs/INDEX.md'
    if (-not (Test-Path $indexPath)) {
        $errors += "docs/INDEX.md not found"
    } else {
        $indexContent = Get-Content $indexPath -Raw
        $mdFiles = Get-ChildItem -Path docs -Filter '*.md' -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -ne 'INDEX.md' }
        foreach ($f in $mdFiles) {
            if ($indexContent -notmatch [regex]::Escape($f.Name)) {
                $errors += "Not listed in INDEX.md: docs/$($f.Name)"
            }
        }
    }
    $errors
}

# ── Check 3: ADR naming convention ──────────────────────────────────────────
Test-Check "ADR naming convention" {
    $errors = @()
    $adrDir = 'docs/decisions'
    if (Test-Path $adrDir) {
        $adrFiles = Get-ChildItem -Path $adrDir -Filter '*.md' -File
        foreach ($f in $adrFiles) {
            if ($f.Name -notmatch '^\d{3}-.*\.md$') {
                $errors += "Invalid ADR name: $($f.Name) (expected NNN-*.md)"
            }
        }
    }
    $errors
}

# ── Check 4: Migration ordering ─────────────────────────────────────────────
Test-Check "Migration ordering" {
    $errors = @()
    $migDir = 'supabase/migrations'
    if (Test-Path $migDir) {
        $files = Get-ChildItem -Path $migDir -Filter '*.sql' -File |
            Where-Object { $_.Name -ne '_TEMPLATE.sql' } | Sort-Object Name
        $prevTs = ''
        foreach ($f in $files) {
            if ($f.Name -match '^(\d{14})_') {
                $ts = $Matches[1]
                if ($prevTs -and $ts -le $prevTs) {
                    $errors += "Non-monotonic timestamp: $($f.Name) (after $prevTs)"
                }
                $prevTs = $ts
            } else {
                $errors += "Invalid migration name: $($f.Name) (expected YYYYMMDDHHMMSS_*.sql)"
            }
        }
    }
    $errors
}

# ── Check 5: No tracked build artifacts ─────────────────────────────────────
Test-Check "No tracked artifacts" {
    $errors = @()
    $artifactDirs = @(
        'coverage/', 'test-results/', 'playwright-report/',
        'node_modules/', '__pycache__/', '.next/'
    )
    # Check if any of these are tracked in git
    try {
        $tracked = git ls-files 2>$null
        if ($tracked) {
            foreach ($dir in $artifactDirs) {
                $dirClean = $dir.TrimEnd('/')
                $found = $tracked | Where-Object { $_ -like "$dirClean/*" }
                if ($found) {
                    $errors += "Tracked artifact directory: $dir ($($found.Count) files)"
                }
            }
        }
    } catch {
        # Not a git repo or git not available — skip
    }
    $errors
}

# ── Check 6: No temp files tracked ──────────────────────────────────────────
Test-Check "No temp files tracked" {
    $errors = @()
    try {
        $tracked = git ls-files 2>$null
        if ($tracked) {
            $tempFiles = $tracked | Where-Object {
                $_ -match '^tmp-' -or
                $_ -match '/tmp-' -or
                $_ -match '^qa_.*\.json$' -or
                $_ -match '^qa-test\.json$'
            }
            foreach ($f in $tempFiles) {
                $errors += "Temp file tracked in git: $f"
            }
        }
    } catch {
        # Not a git repo or git not available — skip
    }
    $errors
}

# ── Summary ──────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "─── repo_verify: $passed passed, $failed failed ───" -ForegroundColor $(if ($failed -eq 0) { 'Green' } else { 'Red' })

if ($failed -gt 0) { exit 1 } else { exit 0 }
