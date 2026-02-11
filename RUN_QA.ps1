<#
.SYNOPSIS
    Runs all QA test suites against the LOCAL Supabase database.

.DESCRIPTION
    Executes:
        1. QA__null_checks.sql (35 data integrity checks + 6 informational)
        2. QA__scoring_formula_tests.sql (29 algorithm validation checks)
        3. QA__source_coverage.sql (8 source provenance checks — informational)
        4. validate_eans.py (EAN-13 checksum validation — blocking)
        5. QA__api_surfaces.sql (14 API contract validation checks — blocking)
        6. QA__confidence_scoring.sql (10 confidence scoring checks — blocking)
        7. QA__cross_validation.sql (6 cross-validation checks — blocking)
        8. QA__data_quality.sql (28 data quality & plausibility checks — blocking)
        9. QA__referential_integrity.sql (19 referential integrity checks — blocking)
       10. QA__view_consistency.sql (10 view & function consistency checks — blocking)

    Returns exit code 0 if all tests pass, 1 if any violations found.
    Test Suite 3 is informational and does not affect the exit code.

.PARAMETER Json
    Output results as machine-readable JSON instead of colored text.
    JSON includes: timestamp, suites (name, checks, status, violations, runtime_ms),
    inventory, and overall pass/fail.

.PARAMETER OutFile
    Write JSON output to this file path (implies -Json).

.PARAMETER FailOnWarn
    Treat informational suite warnings (Source Coverage) as failures.
    When set, any flagged items in Suite 3 cause a non-zero exit code.

.NOTES
    Prerequisites:
        - Docker Desktop running with local Supabase containers
        - Database populated with scored products
        - Python 3.14+ with validate_eans.py script

    Exit codes:
        0  All critical checks pass (and no warnings if -FailOnWarn)
        1  One or more critical checks failed
        2  Informational warnings present (only with -FailOnWarn)

    Usage:
        .\RUN_QA.ps1                        # Human-readable output
        .\RUN_QA.ps1 -Json                  # Machine-readable JSON to stdout
        .\RUN_QA.ps1 -OutFile qa-results.json  # JSON to file
        .\RUN_QA.ps1 -FailOnWarn            # Fail on informational warnings too
#>

param(
    [switch]$Json,
    [string]$OutFile,
    [switch]$FailOnWarn
)

if ($OutFile) { $Json = $true }

# JSON result accumulator
$jsonResult = @{
    timestamp = (Get-Date -Format "o")
    version   = "2.0"
    suites    = @()
    summary   = @{ total_checks = 0; passed = 0; failed = 0; warnings = 0 }
    inventory = @{}
    overall   = "unknown"
}

# Track warning state for -FailOnWarn
$hasWarnings = $false

$CONTAINER = "supabase_db_poland-food-db"
$DB_USER = "postgres"
$DB_NAME = "postgres"
$SCRIPT_ROOT = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$QA_DIR = Join-Path (Join-Path $SCRIPT_ROOT "db") "qa"

# ─── Database Connection Abstraction ───────────────────────────────────────
# CI mode  (PGHOST set): uses psql directly — PGHOST/PGPORT/PGUSER/PGPASSWORD env vars
# Local mode (default) : uses docker exec into the Supabase container
function Invoke-Psql {
    param(
        [string]$InputSql,
        [switch]$TuplesOnly
    )
    if ($env:PGHOST) {
        $psqlArgs = @()
        if ($TuplesOnly) { $psqlArgs += "--tuples-only" }
        return ($InputSql | psql @psqlArgs 2>&1)
    }
    else {
        $psqlArgs = @("-U", $DB_USER, "-d", $DB_NAME)
        if ($TuplesOnly) { $psqlArgs += "--tuples-only" }
        return ($InputSql | docker exec -i $CONTAINER psql @psqlArgs 2>&1)
    }
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Poland Food DB — QA Test Suite" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

if (-not $Json) {
    # Header already printed above
}

# ─── Test 1: Data Integrity Checks ─────────────────────────────────────────

$test1File = Join-Path $QA_DIR "QA__null_checks.sql"
if (-not (Test-Path $test1File)) {
    Write-Host "ERROR: QA__null_checks.sql not found at: $test1File" -ForegroundColor Red
    exit 1
}

Write-Host "Running Test Suite 1: Data Integrity (35 checks)..." -ForegroundColor Yellow

$sw1 = [System.Diagnostics.Stopwatch]::StartNew()

# Strip final summary query to avoid false-positive
$test1Content = Get-Content $test1File -Raw
$test1ChecksOnly = ($test1Content -split '-- 36\. v_master new column coverage')[0]

$test1Output = Invoke-Psql -InputSql $test1ChecksOnly -TuplesOnly

if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✗ FAILED TO EXECUTE" -ForegroundColor Red
    Write-Host "  $test1Output" -ForegroundColor DarkRed
    exit 1
}

$test1Lines = ($test1Output | Out-String).Trim()
if ($test1Lines -eq "" -or $test1Lines -match '^\s*$') {
    $sw1.Stop()
    Write-Host "  ✓ PASS (35/35 — zero violations) [$([math]::Round($sw1.Elapsed.TotalMilliseconds))ms]" -ForegroundColor Green
    $test1Pass = $true
    $jsonResult.suites += @{ name = "Data Integrity"; suite_id = "integrity"; checks = 35; status = "pass"; violations = @(); runtime_ms = [math]::Round($sw1.Elapsed.TotalMilliseconds) }
    $jsonResult.summary.total_checks += 35; $jsonResult.summary.passed += 35
}
else {
    $sw1.Stop()
    Write-Host "  ✗ FAILED — violations detected:" -ForegroundColor Red
    Write-Host $test1Lines -ForegroundColor DarkRed
    $test1Pass = $false
    $violationList = ($test1Lines -split "`n" | Where-Object { $_ -match '\S' })
    $jsonResult.suites += @{ name = "Data Integrity"; suite_id = "integrity"; checks = 35; status = "fail"; violations = @($violationList); runtime_ms = [math]::Round($sw1.Elapsed.TotalMilliseconds) }
    $jsonResult.summary.total_checks += 35; $jsonResult.summary.failed += $violationList.Count; $jsonResult.summary.passed += (35 - $violationList.Count)
}

# ─── Test 2: Scoring Formula Validation ────────────────────────────────────

$test2File = Join-Path $QA_DIR "QA__scoring_formula_tests.sql"
if (-not (Test-Path $test2File)) {
    Write-Host "ERROR: QA__scoring_formula_tests.sql not found at: $test2File" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Running Test Suite 2: Scoring Formula (29 checks)..." -ForegroundColor Yellow

$sw2 = [System.Diagnostics.Stopwatch]::StartNew()

$test2Content = Get-Content $test2File -Raw
$test2Output = Invoke-Psql -InputSql $test2Content -TuplesOnly

if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✗ FAILED TO EXECUTE" -ForegroundColor Red
    Write-Host "  $test2Output" -ForegroundColor DarkRed
    exit 1
}

$test2Lines = ($test2Output | Out-String).Trim()
if ($test2Lines -eq "" -or $test2Lines -match '^\s*$') {
    $sw2.Stop()
    Write-Host "  ✓ PASS (29/29 — zero violations) [$([math]::Round($sw2.Elapsed.TotalMilliseconds))ms]" -ForegroundColor Green
    $test2Pass = $true
    $jsonResult.suites += @{ name = "Scoring Formula"; suite_id = "scoring"; checks = 29; status = "pass"; violations = @(); runtime_ms = [math]::Round($sw2.Elapsed.TotalMilliseconds) }
    $jsonResult.summary.total_checks += 29; $jsonResult.summary.passed += 29
}
else {
    $sw2.Stop()
    Write-Host "  ✗ FAILED — violations detected:" -ForegroundColor Red
    Write-Host $test2Lines -ForegroundColor DarkRed
    $test2Pass = $false
    $violationList2 = ($test2Lines -split "`n" | Where-Object { $_ -match '\S' })
    $jsonResult.suites += @{ name = "Scoring Formula"; suite_id = "scoring"; checks = 29; status = "fail"; violations = @($violationList2); runtime_ms = [math]::Round($sw2.Elapsed.TotalMilliseconds) }
    $jsonResult.summary.total_checks += 29; $jsonResult.summary.failed += $violationList2.Count; $jsonResult.summary.passed += (29 - $violationList2.Count)
}

# ─── Test 3: Source Coverage (Informational) ───────────────────────────────

$test3File = Join-Path $QA_DIR "QA__source_coverage.sql"
if (Test-Path $test3File) {
    Write-Host ""
    Write-Host "Running Test Suite 3: Source Coverage (8 checks — informational)..." -ForegroundColor Yellow

    $sw3 = [System.Diagnostics.Stopwatch]::StartNew()

    # Run only checks 1-4 (actionable items); 5-7 are informational summaries
    $test3Content = Get-Content $test3File -Raw
    $test3Output = Invoke-Psql -InputSql $test3Content -TuplesOnly

    if ($LASTEXITCODE -ne 0) {
        $sw3.Stop()
        Write-Host "  ⚠ FAILED TO EXECUTE (non-blocking)" -ForegroundColor DarkYellow
        $jsonResult.suites += @{ name = "Source Coverage"; suite_id = "source_coverage"; checks = 8; status = "error"; blocking = $false; runtime_ms = [math]::Round($sw3.Elapsed.TotalMilliseconds) }
    }
    else {
        $sw3.Stop()
        $test3Lines = ($test3Output | Out-String).Trim()
        if ($test3Lines -eq "" -or $test3Lines -match '^\s*$') {
            Write-Host "  ✓ All products have multi-source coverage [$([math]::Round($sw3.Elapsed.TotalMilliseconds))ms]" -ForegroundColor Green
            $jsonResult.suites += @{ name = "Source Coverage"; suite_id = "source_coverage"; checks = 8; status = "pass"; blocking = $false; flagged = 0; runtime_ms = [math]::Round($sw3.Elapsed.TotalMilliseconds) }
        }
        else {
            $singleSourceCount = ($test3Lines -split "`n" | Where-Object { $_ -match '\S' }).Count
            Write-Host "  ⚠ $singleSourceCount items flagged for cross-validation (non-blocking) [$([math]::Round($sw3.Elapsed.TotalMilliseconds))ms]" -ForegroundColor DarkYellow
            Write-Host "    Run QA__source_coverage.sql directly for details." -ForegroundColor DarkGray
            $hasWarnings = $true
            $jsonResult.suites += @{ name = "Source Coverage"; suite_id = "source_coverage"; checks = 8; status = "warn"; blocking = $false; flagged = $singleSourceCount; runtime_ms = [math]::Round($sw3.Elapsed.TotalMilliseconds) }
            $jsonResult.summary.warnings += $singleSourceCount
        }
    }
}

# ─── Test 4: EAN-13 Checksum Validation ────────────────────────────────────

Write-Host ""
Write-Host "Running Test Suite 4: EAN-13 Checksum Validation..." -ForegroundColor Yellow

$validatorScript = Join-Path $SCRIPT_ROOT "validate_eans.py"
if (-not (Test-Path $validatorScript)) {
    Write-Host "  ⚠ SKIPPED (validate_eans.py not found)" -ForegroundColor DarkYellow
    $test4Pass = $true  # Non-blocking if validator doesn't exist
}
else {
    # Run validator and capture output
    $sw4 = [System.Diagnostics.Stopwatch]::StartNew()
    $validatorOutput = & python $validatorScript 2>&1
    $validatorExitCode = $LASTEXITCODE
    $sw4.Stop()

    if ($validatorExitCode -eq 0) {
        Write-Host "  ✓ PASS — All EAN codes have valid checksums [$([math]::Round($sw4.Elapsed.TotalMilliseconds))ms]" -ForegroundColor Green
        $test4Pass = $true
        $jsonResult.suites += @{ name = "EAN Checksum"; suite_id = "ean"; checks = 1; status = "pass"; violations = @(); runtime_ms = [math]::Round($sw4.Elapsed.TotalMilliseconds) }
        $jsonResult.summary.total_checks += 1; $jsonResult.summary.passed += 1
    }
    else {
        # Extract count of invalid EANs from output
        $invalidMatch = $validatorOutput | Select-String -Pattern "Results: (\d+) valid, (\d+) invalid"
        if ($invalidMatch) {
            $validCount = $invalidMatch.Matches.Groups[1].Value
            $invalidCount = $invalidMatch.Matches.Groups[2].Value
            Write-Host "  ✗ FAILED — $invalidCount invalid EAN checksums detected (of $validCount total)" -ForegroundColor Red
            Write-Host "    Run 'python validate_eans.py' for details or see docs/EAN_VALIDATION_STATUS.md" -ForegroundColor DarkGray
        }
        else {
            Write-Host "  ✗ FAILED — EAN validation errors detected" -ForegroundColor Red
        }
        $test4Pass = $false
        $jsonResult.suites += @{ name = "EAN Checksum"; suite_id = "ean"; checks = 1; status = "fail"; violations = @($validatorOutput); runtime_ms = [math]::Round($sw4.Elapsed.TotalMilliseconds) }
        $jsonResult.summary.total_checks += 1; $jsonResult.summary.failed += 1
    }
}

# ─── Test 5: API Surface Validation ────────────────────────────────────────

$test5File = Join-Path $QA_DIR "QA__api_surfaces.sql"
if (-not (Test-Path $test5File)) {
    Write-Host ""
    Write-Host "  ⚠ SKIPPED Test Suite 5: API Surfaces (file not found)" -ForegroundColor DarkYellow
    $test5Pass = $true
}
else {
    Write-Host ""
    Write-Host "Running Test Suite 5: API Surface Validation (14 checks)..." -ForegroundColor Yellow

    $sw5 = [System.Diagnostics.Stopwatch]::StartNew()
    $test5Content = Get-Content $test5File -Raw
    $test5Output = Invoke-Psql -InputSql $test5Content -TuplesOnly

    if ($LASTEXITCODE -ne 0) {
        $sw5.Stop()
        Write-Host "  ✗ FAILED TO EXECUTE" -ForegroundColor Red
        Write-Host "  $test5Output" -ForegroundColor DarkRed
        $test5Pass = $false
        $jsonResult.suites += @{ name = "API Surfaces"; suite_id = "api"; checks = 8; status = "error"; violations = @(); runtime_ms = [math]::Round($sw5.Elapsed.TotalMilliseconds) }
    }
    else {
        $sw5.Stop()
        $test5Lines = ($test5Output | Out-String).Trim()
        # Check for any violations > 0
        $test5Violations = ($test5Lines -split "`n" | Where-Object { $_ -match '\|\s*[1-9]' })
        if ($test5Violations.Count -eq 0) {
            Write-Host "  ✓ PASS (14/14 — zero violations) [$([math]::Round($sw5.Elapsed.TotalMilliseconds))ms]" -ForegroundColor Green
            $test5Pass = $true
            $jsonResult.suites += @{ name = "API Surfaces"; suite_id = "api"; checks = 14; status = "pass"; violations = @(); runtime_ms = [math]::Round($sw5.Elapsed.TotalMilliseconds) }
            $jsonResult.summary.total_checks += 14; $jsonResult.summary.passed += 14
        }
        else {
            Write-Host "  ✗ FAILED — violations detected:" -ForegroundColor Red
            Write-Host $test5Lines -ForegroundColor DarkRed
            $test5Pass = $false
            $violationList5 = ($test5Violations | ForEach-Object { $_.Trim() })
            $jsonResult.suites += @{ name = "API Surfaces"; suite_id = "api"; checks = 14; status = "fail"; violations = @($violationList5); runtime_ms = [math]::Round($sw5.Elapsed.TotalMilliseconds) }
            $jsonResult.summary.total_checks += 14; $jsonResult.summary.failed += $violationList5.Count; $jsonResult.summary.passed += (14 - $violationList5.Count)
        }
    }
}

# ─── Test 6: Confidence Scoring Validation ─────────────────────────────────

$test6File = Join-Path $QA_DIR "QA__confidence_scoring.sql"
if (-not (Test-Path $test6File)) {
    Write-Host ""
    Write-Host "  ⚠ SKIPPED Test Suite 6: Confidence Scoring (file not found)" -ForegroundColor DarkYellow
    $test6Pass = $true
}
else {
    Write-Host ""
    Write-Host "Running Test Suite 6: Confidence Scoring (10 checks)..." -ForegroundColor Yellow

    $sw6 = [System.Diagnostics.Stopwatch]::StartNew()
    $test6Content = Get-Content $test6File -Raw
    $test6Output = Invoke-Psql -InputSql $test6Content -TuplesOnly

    if ($LASTEXITCODE -ne 0) {
        $sw6.Stop()
        Write-Host "  ✗ FAILED TO EXECUTE" -ForegroundColor Red
        Write-Host "  $test6Output" -ForegroundColor DarkRed
        $test6Pass = $false
        $jsonResult.suites += @{ name = "Confidence Scoring"; suite_id = "confidence"; checks = 10; status = "error"; violations = @(); runtime_ms = [math]::Round($sw6.Elapsed.TotalMilliseconds) }
    }
    else {
        $sw6.Stop()
        $test6Lines = ($test6Output | Out-String).Trim()
        $test6Violations = ($test6Lines -split "`n" | Where-Object { $_ -match '\|\s*[1-9]' })
        if ($test6Violations.Count -eq 0) {
            Write-Host "  ✓ PASS (10/10 — zero violations) [$([math]::Round($sw6.Elapsed.TotalMilliseconds))ms]" -ForegroundColor Green
            $test6Pass = $true
            $jsonResult.suites += @{ name = "Confidence Scoring"; suite_id = "confidence"; checks = 10; status = "pass"; violations = @(); runtime_ms = [math]::Round($sw6.Elapsed.TotalMilliseconds) }
            $jsonResult.summary.total_checks += 10; $jsonResult.summary.passed += 10
        }
        else {
            Write-Host "  ✗ FAILED — violations detected:" -ForegroundColor Red
            Write-Host $test6Lines -ForegroundColor DarkRed
            $test6Pass = $false
            $violationList6 = ($test6Violations | ForEach-Object { $_.Trim() })
            $jsonResult.suites += @{ name = "Confidence Scoring"; suite_id = "confidence"; checks = 10; status = "fail"; violations = @($violationList6); runtime_ms = [math]::Round($sw6.Elapsed.TotalMilliseconds) }
            $jsonResult.summary.total_checks += 10; $jsonResult.summary.failed += $violationList6.Count; $jsonResult.summary.passed += (10 - $violationList6.Count)
        }
    }
}

# ─── Test 7: Cross-Validation ──────────────────────────────────────────────

$test7File = Join-Path $QA_DIR "QA__cross_validation.sql"
if (-not (Test-Path $test7File)) {
    Write-Host ""
    Write-Host "  ⚠ SKIPPED Test Suite 7: Cross-Validation (file not found)" -ForegroundColor DarkYellow
    $test7Pass = $true
}
else {
    Write-Host ""
    Write-Host "Running Test Suite 7: Cross-Validation (6 checks)..." -ForegroundColor Yellow

    $sw7 = [System.Diagnostics.Stopwatch]::StartNew()
    $test7Content = Get-Content $test7File -Raw
    $test7Output = Invoke-Psql -InputSql $test7Content -TuplesOnly

    if ($LASTEXITCODE -ne 0) {
        $sw7.Stop()
        Write-Host "  ✗ FAILED TO EXECUTE" -ForegroundColor Red
        Write-Host "  $test7Output" -ForegroundColor DarkRed
        $test7Pass = $false
        $jsonResult.suites += @{ name = "Cross-Validation"; suite_id = "cross_validation"; checks = 6; status = "error"; violations = @(); runtime_ms = [math]::Round($sw7.Elapsed.TotalMilliseconds) }
    }
    else {
        $sw7.Stop()
        $test7Lines = ($test7Output | Out-String).Trim()
        $test7Violations = ($test7Lines -split "`n" | Where-Object { $_ -match '\|\s*[1-9]' })
        if ($test7Violations.Count -eq 0) {
            Write-Host "  ✓ PASS (6/6 — zero violations) [$([math]::Round($sw7.Elapsed.TotalMilliseconds))ms]" -ForegroundColor Green
            $test7Pass = $true
            $jsonResult.suites += @{ name = "Cross-Validation"; suite_id = "cross_validation"; checks = 6; status = "pass"; violations = @(); runtime_ms = [math]::Round($sw7.Elapsed.TotalMilliseconds) }
            $jsonResult.summary.total_checks += 6; $jsonResult.summary.passed += 6
        }
        else {
            Write-Host "  ✗ FAILED — violations detected:" -ForegroundColor Red
            Write-Host $test7Lines -ForegroundColor DarkRed
            $test7Pass = $false
            $violationList7 = ($test7Violations | ForEach-Object { $_.Trim() })
            $jsonResult.suites += @{ name = "Cross-Validation"; suite_id = "cross_validation"; checks = 6; status = "fail"; violations = @($violationList7); runtime_ms = [math]::Round($sw7.Elapsed.TotalMilliseconds) }
            $jsonResult.summary.total_checks += 6; $jsonResult.summary.failed += $violationList7.Count; $jsonResult.summary.passed += (6 - $violationList7.Count)
        }
    }
}

# ─── Test 8: Data Quality & Plausibility ───────────────────────────────────

$test8File = Join-Path $QA_DIR "QA__data_quality.sql"
if (-not (Test-Path $test8File)) {
    Write-Host ""
    Write-Host "  ⚠ SKIPPED Test Suite 8: Data Quality (file not found)" -ForegroundColor DarkYellow
    $test8Pass = $true
}
else {
    Write-Host ""
    Write-Host "Running Test Suite 8: Data Quality (28 checks)..." -ForegroundColor Yellow

    $sw8 = [System.Diagnostics.Stopwatch]::StartNew()
    $test8Content = Get-Content $test8File -Raw
    $test8Output = Invoke-Psql -InputSql $test8Content -TuplesOnly

    if ($LASTEXITCODE -ne 0) {
        $sw8.Stop()
        Write-Host "  ✗ FAILED TO EXECUTE" -ForegroundColor Red
        Write-Host "  $test8Output" -ForegroundColor DarkRed
        $test8Pass = $false
        $jsonResult.suites += @{ name = "Data Quality"; suite_id = "data_quality"; checks = 25; status = "error"; violations = @(); runtime_ms = [math]::Round($sw8.Elapsed.TotalMilliseconds) }
    }
    else {
        $sw8.Stop()
        $test8Lines = ($test8Output | Out-String).Trim()
        $test8Violations = ($test8Lines -split "`n" | Where-Object { $_ -match '\|\s*[1-9]' })
        if ($test8Violations.Count -eq 0) {
            Write-Host "  ✓ PASS (28/28 — zero violations) [$([math]::Round($sw8.Elapsed.TotalMilliseconds))ms]" -ForegroundColor Green
            $test8Pass = $true
            $jsonResult.suites += @{ name = "Data Quality"; suite_id = "data_quality"; checks = 28; status = "pass"; violations = @(); runtime_ms = [math]::Round($sw8.Elapsed.TotalMilliseconds) }
            $jsonResult.summary.total_checks += 28; $jsonResult.summary.passed += 28
        }
        else {
            Write-Host "  ✗ FAILED — violations detected:" -ForegroundColor Red
            Write-Host $test8Lines -ForegroundColor DarkRed
            $test8Pass = $false
            $violationList8 = ($test8Violations | ForEach-Object { $_.Trim() })
            $jsonResult.suites += @{ name = "Data Quality"; suite_id = "data_quality"; checks = 28; status = "fail"; violations = @($violationList8); runtime_ms = [math]::Round($sw8.Elapsed.TotalMilliseconds) }
            $jsonResult.summary.total_checks += 28; $jsonResult.summary.failed += $violationList8.Count; $jsonResult.summary.passed += (28 - $violationList8.Count)
        }
    }
}

# ─── Test 9: Referential Integrity ─────────────────────────────────────────

$test9File = Join-Path $QA_DIR "QA__referential_integrity.sql"
if (-not (Test-Path $test9File)) {
    Write-Host ""
    Write-Host "  ⚠ SKIPPED Test Suite 9: Referential Integrity (file not found)" -ForegroundColor DarkYellow
    $test9Pass = $true
}
else {
    Write-Host ""
    Write-Host "Running Test Suite 9: Referential Integrity (19 checks)..." -ForegroundColor Yellow

    $sw9 = [System.Diagnostics.Stopwatch]::StartNew()
    $test9Content = Get-Content $test9File -Raw
    $test9Output = Invoke-Psql -InputSql $test9Content -TuplesOnly

    if ($LASTEXITCODE -ne 0) {
        $sw9.Stop()
        Write-Host "  ✗ FAILED TO EXECUTE" -ForegroundColor Red
        Write-Host "  $test9Output" -ForegroundColor DarkRed
        $test9Pass = $false
        $jsonResult.suites += @{ name = "Referential Integrity"; suite_id = "referential"; checks = 15; status = "error"; violations = @(); runtime_ms = [math]::Round($sw9.Elapsed.TotalMilliseconds) }
    }
    else {
        $sw9.Stop()
        $test9Lines = ($test9Output | Out-String).Trim()
        $test9Violations = ($test9Lines -split "`n" | Where-Object { $_ -match '\|\s*[1-9]' })
        if ($test9Violations.Count -eq 0) {
            Write-Host "  ✓ PASS (19/19 — zero violations) [$([math]::Round($sw9.Elapsed.TotalMilliseconds))ms]" -ForegroundColor Green
            $test9Pass = $true
            $jsonResult.suites += @{ name = "Referential Integrity"; suite_id = "referential"; checks = 19; status = "pass"; violations = @(); runtime_ms = [math]::Round($sw9.Elapsed.TotalMilliseconds) }
            $jsonResult.summary.total_checks += 19; $jsonResult.summary.passed += 19
        }
        else {
            Write-Host "  ✗ FAILED — violations detected:" -ForegroundColor Red
            Write-Host $test9Lines -ForegroundColor DarkRed
            $test9Pass = $false
            $violationList9 = ($test9Violations | ForEach-Object { $_.Trim() })
            $jsonResult.suites += @{ name = "Referential Integrity"; suite_id = "referential"; checks = 19; status = "fail"; violations = @($violationList9); runtime_ms = [math]::Round($sw9.Elapsed.TotalMilliseconds) }
            $jsonResult.summary.total_checks += 19; $jsonResult.summary.failed += $violationList9.Count; $jsonResult.summary.passed += (19 - $violationList9.Count)
        }
    }
}

# ─── Test 10: View & Function Consistency ──────────────────────────────────

$test10File = Join-Path $QA_DIR "QA__view_consistency.sql"
if (-not (Test-Path $test10File)) {
    Write-Host ""
    Write-Host "  ⚠ SKIPPED Test Suite 10: View Consistency (file not found)" -ForegroundColor DarkYellow
    $test10Pass = $true
}
else {
    Write-Host ""
    Write-Host "Running Test Suite 10: View & Function Consistency (10 checks)..." -ForegroundColor Yellow

    $sw10 = [System.Diagnostics.Stopwatch]::StartNew()
    $test10Content = Get-Content $test10File -Raw
    $test10Output = Invoke-Psql -InputSql $test10Content -TuplesOnly

    if ($LASTEXITCODE -ne 0) {
        $sw10.Stop()
        Write-Host "  ✗ FAILED TO EXECUTE" -ForegroundColor Red
        Write-Host "  $test10Output" -ForegroundColor DarkRed
        $test10Pass = $false
        $jsonResult.suites += @{ name = "View Consistency"; suite_id = "views"; checks = 10; status = "error"; violations = @(); runtime_ms = [math]::Round($sw10.Elapsed.TotalMilliseconds) }
    }
    else {
        $sw10.Stop()
        $test10Lines = ($test10Output | Out-String).Trim()
        $test10Violations = ($test10Lines -split "`n" | Where-Object { $_ -match '\|\s*[1-9]' })
        if ($test10Violations.Count -eq 0) {
            Write-Host "  ✓ PASS (10/10 — zero violations) [$([math]::Round($sw10.Elapsed.TotalMilliseconds))ms]" -ForegroundColor Green
            $test10Pass = $true
            $jsonResult.suites += @{ name = "View Consistency"; suite_id = "views"; checks = 10; status = "pass"; violations = @(); runtime_ms = [math]::Round($sw10.Elapsed.TotalMilliseconds) }
            $jsonResult.summary.total_checks += 10; $jsonResult.summary.passed += 10
        }
        else {
            Write-Host "  ✗ FAILED — violations detected:" -ForegroundColor Red
            Write-Host $test10Lines -ForegroundColor DarkRed
            $test10Pass = $false
            $violationList10 = ($test10Violations | ForEach-Object { $_.Trim() })
            $jsonResult.suites += @{ name = "View Consistency"; suite_id = "views"; checks = 10; status = "fail"; violations = @($violationList10); runtime_ms = [math]::Round($sw10.Elapsed.TotalMilliseconds) }
            $jsonResult.summary.total_checks += 10; $jsonResult.summary.failed += $violationList10.Count; $jsonResult.summary.passed += (10 - $violationList10.Count)
        }
    }
}

# ─── Database Inventory ─────────────────────────────────────────────────────

Write-Host ""
Write-Host "Database Inventory:" -ForegroundColor Cyan

$invQuery = @"
SELECT
    (SELECT COUNT(*) FROM products WHERE is_deprecated IS NOT TRUE) AS active_products,
    (SELECT COUNT(*) FROM products WHERE is_deprecated = true) AS deprecated,
    (SELECT COUNT(*) FROM servings) AS serving_rows,
    (SELECT COUNT(*) FROM servings WHERE serving_basis = 'per 100 g') AS per_100g_servings,
    (SELECT COUNT(*) FROM servings WHERE serving_basis != 'per 100 g') AS per_serving_rows,
    (SELECT COUNT(*) FROM nutrition_facts) AS nutrition_rows,
    (SELECT COUNT(*) FROM scores) AS scores_rows,
    (SELECT COUNT(*) FROM ingredient_ref) AS ingredient_refs,
    (SELECT COUNT(*) FROM product_ingredient) AS product_ingredients,
    (SELECT COUNT(*) FROM product_allergen) AS allergen_rows,
    (SELECT COUNT(*) FROM product_trace) AS trace_rows,
    (SELECT COUNT(DISTINCT category) FROM products WHERE is_deprecated IS NOT TRUE) AS categories;
"@

$invOutput = Invoke-Psql -InputSql $invQuery
Write-Host ($invOutput | Out-String).Trim() -ForegroundColor DarkGray

# ─── Summary ────────────────────────────────────────────────────────────────

$allPass = $test1Pass -and $test2Pass -and $test4Pass -and $test5Pass -and $test6Pass -and $test7Pass -and $test8Pass -and $test9Pass -and $test10Pass
$warnFail = $FailOnWarn -and $hasWarnings
$jsonResult.overall = if (-not $allPass) { "fail" } elseif ($warnFail) { "warn" } else { "pass" }

# Parse inventory into JSON-friendly structure
if ($invOutput) {
    $invText = ($invOutput | Out-String).Trim()
    # Extract numbers from the psql output
    if ($invText -match '(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)') {
        $jsonResult.inventory = @{
            active_products     = [int]$Matches[1]
            deprecated          = [int]$Matches[2]
            serving_rows        = [int]$Matches[3]
            per_100g_servings   = [int]$Matches[4]
            per_serving_rows    = [int]$Matches[5]
            nutrition_rows      = [int]$Matches[6]
            scores_rows         = [int]$Matches[7]
            ingredient_refs     = [int]$Matches[8]
            product_ingredients = [int]$Matches[9]
            allergen_rows       = [int]$Matches[10]
            trace_rows          = [int]$Matches[11]
            categories          = [int]$Matches[12]
        }
    }
}

# JSON output mode
if ($Json) {
    $jsonOutput = $jsonResult | ConvertTo-Json -Depth 4
    if ($OutFile) {
        $jsonOutput | Out-File -FilePath $OutFile -Encoding utf8
        Write-Host "QA results written to: $OutFile" -ForegroundColor Green
    }
    else {
        Write-Output $jsonOutput
    }
    if (-not $allPass) { exit 1 }
    if ($warnFail) { exit 2 }
    exit 0
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Test Summary" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

if ($allPass -and -not $warnFail) {
    Write-Host "  ✓ ALL TESTS PASSED ($($jsonResult.summary.passed)/$($jsonResult.summary.total_checks) checks)" -ForegroundColor Green
    Write-Host ""
    exit 0
}
else {
    if (-not $allPass) {
        Write-Host "  ✗ SOME TESTS FAILED" -ForegroundColor Red
    }
    elseif ($warnFail) {
        Write-Host "  ⚠ PASSED WITH WARNINGS (-FailOnWarn is set)" -ForegroundColor DarkYellow
    }
    Write-Host "    Suite 1 (Integrity):    $(if ($test1Pass) { '✓ PASS' } else { '✗ FAIL' })" -ForegroundColor $(if ($test1Pass) { "Green" } else { "Red" })
    Write-Host "    Suite 2 (Scoring):      $(if ($test2Pass) { '✓ PASS' } else { '✗ FAIL' })" -ForegroundColor $(if ($test2Pass) { "Green" } else { "Red" })
    Write-Host "    Suite 3 (Source):       $(if ($hasWarnings) { '⚠ WARN' } else { '✓ PASS' }) (informational$(if ($FailOnWarn) { ', -FailOnWarn active' }))" -ForegroundColor $(if ($hasWarnings) { "DarkYellow" } else { "Green" })
    Write-Host "    Suite 4 (EAN):          $(if ($test4Pass) { '✓ PASS' } else { '✗ FAIL' })" -ForegroundColor $(if ($test4Pass) { "Green" } else { "Red" })
    Write-Host "    Suite 5 (API):          $(if ($test5Pass) { '✓ PASS' } else { '✗ FAIL' })" -ForegroundColor $(if ($test5Pass) { "Green" } else { "Red" })
    Write-Host "    Suite 6 (Confidence):   $(if ($test6Pass) { '✓ PASS' } else { '✗ FAIL' })" -ForegroundColor $(if ($test6Pass) { "Green" } else { "Red" })
    Write-Host "    Suite 7 (CrossVal):     $(if ($test7Pass) { '✓ PASS' } else { '✗ FAIL' })" -ForegroundColor $(if ($test7Pass) { "Green" } else { "Red" })
    Write-Host "    Suite 8 (DataQuality):  $(if ($test8Pass) { '✓ PASS' } else { '✗ FAIL' })" -ForegroundColor $(if ($test8Pass) { "Green" } else { "Red" })
    Write-Host "    Suite 9 (RefInteg):     $(if ($test9Pass) { '✓ PASS' } else { '✗ FAIL' })" -ForegroundColor $(if ($test9Pass) { "Green" } else { "Red" })
    Write-Host "    Suite 10 (Views):       $(if ($test10Pass) { '✓ PASS' } else { '✗ FAIL' })" -ForegroundColor $(if ($test10Pass) { "Green" } else { "Red" })
    Write-Host ""
    if (-not $allPass) { exit 1 }
    if ($warnFail) { exit 2 }
    exit 0
}

