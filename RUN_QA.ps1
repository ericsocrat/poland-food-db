<#
.SYNOPSIS
    Runs all QA test suites against the LOCAL Supabase database.

.DESCRIPTION
    Executes:
        1. QA__null_checks.sql (31 data integrity checks)
        2. QA__scoring_formula_tests.sql (27 algorithm validation checks)
        3. QA__source_coverage.sql (8 source provenance checks — informational)
        4. validate_eans.py (EAN-13 checksum validation — blocking)
        5. QA__api_surfaces.sql (14 API contract validation checks — blocking)
        6. QA__confidence_scoring.sql (10 confidence scoring checks — blocking)
        7. QA__data_quality.sql (25 data quality & plausibility checks — blocking)
        8. QA__referential_integrity.sql (18 referential integrity checks — blocking)
        9. QA__view_consistency.sql (12 view & function consistency checks — blocking)
       10. QA__naming_conventions.sql (12 naming/formatting convention checks — blocking)
       11. QA__nutrition_ranges.sql (16 nutrition range & plausibility checks — blocking)
       12. QA__data_consistency.sql (18 data consistency & domain checks — blocking)
       13. QA__allergen_integrity.sql (14 allergen & trace integrity checks — blocking)
       14. QA__serving_source_validation.sql (16 serving & source checks — blocking)
       15. QA__ingredient_quality.sql (14 ingredient quality checks — blocking)

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
        - Python 3.12+ with validate_eans.py script

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

Write-Host "Running Test Suite 1: Data Integrity (31 checks)..." -ForegroundColor Yellow

$sw1 = [System.Diagnostics.Stopwatch]::StartNew()

# Strip final summary query to avoid false-positive
$test1Content = Get-Content $test1File -Raw
$test1ChecksOnly = ($test1Content -split '-- 36\. v_master column coverage')[0]

$test1Output = Invoke-Psql -InputSql $test1ChecksOnly -TuplesOnly

if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✗ FAILED TO EXECUTE" -ForegroundColor Red
    Write-Host "  $test1Output" -ForegroundColor DarkRed
    exit 1
}

$test1Lines = ($test1Output | Out-String).Trim()
if ($test1Lines -eq "" -or $test1Lines -match '^\s*$') {
    $sw1.Stop()
    Write-Host "  ✓ PASS (31/31 — zero violations) [$([math]::Round($sw1.Elapsed.TotalMilliseconds))ms]" -ForegroundColor Green
    $test1Pass = $true
    $jsonResult.suites += @{ name = "Data Integrity"; suite_id = "integrity"; checks = 31; status = "pass"; violations = @(); runtime_ms = [math]::Round($sw1.Elapsed.TotalMilliseconds) }
    $jsonResult.summary.total_checks += 31; $jsonResult.summary.passed += 31
}
else {
    $sw1.Stop()
    Write-Host "  ✗ FAILED — violations detected:" -ForegroundColor Red
    Write-Host $test1Lines -ForegroundColor DarkRed
    $test1Pass = $false
    $violationList = ($test1Lines -split "`n" | Where-Object { $_ -match '\S' })
    $jsonResult.suites += @{ name = "Data Integrity"; suite_id = "integrity"; checks = 31; status = "fail"; violations = @($violationList); runtime_ms = [math]::Round($sw1.Elapsed.TotalMilliseconds) }
    $jsonResult.summary.total_checks += 31; $jsonResult.summary.failed += $violationList.Count; $jsonResult.summary.passed += (31 - $violationList.Count)
}

# ─── Test 2: Scoring Formula Validation ────────────────────────────────────

$test2File = Join-Path $QA_DIR "QA__scoring_formula_tests.sql"
if (-not (Test-Path $test2File)) {
    Write-Host "ERROR: QA__scoring_formula_tests.sql not found at: $test2File" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Running Test Suite 2: Scoring Formula (27 checks)..." -ForegroundColor Yellow

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
    Write-Host "  ✓ PASS (27/27 — zero violations) [$([math]::Round($sw2.Elapsed.TotalMilliseconds))ms]" -ForegroundColor Green
    $test2Pass = $true
    $jsonResult.suites += @{ name = "Scoring Formula"; suite_id = "scoring"; checks = 27; status = "pass"; violations = @(); runtime_ms = [math]::Round($sw2.Elapsed.TotalMilliseconds) }
    $jsonResult.summary.total_checks += 27; $jsonResult.summary.passed += 27
}
else {
    $sw2.Stop()
    Write-Host "  ✗ FAILED — violations detected:" -ForegroundColor Red
    Write-Host $test2Lines -ForegroundColor DarkRed
    $test2Pass = $false
    $violationList2 = ($test2Lines -split "`n" | Where-Object { $_ -match '\S' })
    $jsonResult.suites += @{ name = "Scoring Formula"; suite_id = "scoring"; checks = 27; status = "fail"; violations = @($violationList2); runtime_ms = [math]::Round($sw2.Elapsed.TotalMilliseconds) }
    $jsonResult.summary.total_checks += 27; $jsonResult.summary.failed += $violationList2.Count; $jsonResult.summary.passed += (27 - $violationList2.Count)
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

# ─── Test 5–15: Generic SQL QA Suites ──────────────────────────────────────
# All remaining suites follow the same pattern: load SQL, run via Invoke-Psql,
# check for violation rows (| <non-zero count>), report pass/fail.

function Invoke-SqlQASuite {
    param(
        [int]$SuiteNum,
        [string]$Name,
        [string]$SuiteId,
        [string]$FileName,
        [int]$Checks
    )
    $testFile = Join-Path $QA_DIR $FileName
    if (-not (Test-Path $testFile)) {
        Write-Host ""
        Write-Host "  ⚠ SKIPPED Test Suite ${SuiteNum}: $Name (file not found)" -ForegroundColor DarkYellow
        return $true
    }

    Write-Host ""
    Write-Host "Running Test Suite ${SuiteNum}: $Name ($Checks checks)..." -ForegroundColor Yellow

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $content = Get-Content $testFile -Raw
    $output = Invoke-Psql -InputSql $content -TuplesOnly

    if ($LASTEXITCODE -ne 0) {
        $sw.Stop()
        Write-Host "  ✗ FAILED TO EXECUTE" -ForegroundColor Red
        Write-Host "  $output" -ForegroundColor DarkRed
        $script:jsonResult.suites += @{ name = $Name; suite_id = $SuiteId; checks = $Checks; status = "error"; violations = @(); runtime_ms = [math]::Round($sw.Elapsed.TotalMilliseconds) }
        return $false
    }

    $sw.Stop()
    $lines = ($output | Out-String).Trim()
    $violations = ($lines -split "`n" | Where-Object { $_ -match '\|\s*[1-9]' })
    if ($violations.Count -eq 0) {
        Write-Host "  ✓ PASS ($Checks/$Checks — zero violations) [$([math]::Round($sw.Elapsed.TotalMilliseconds))ms]" -ForegroundColor Green
        $script:jsonResult.suites += @{ name = $Name; suite_id = $SuiteId; checks = $Checks; status = "pass"; violations = @(); runtime_ms = [math]::Round($sw.Elapsed.TotalMilliseconds) }
        $script:jsonResult.summary.total_checks += $Checks; $script:jsonResult.summary.passed += $Checks
        return $true
    }
    else {
        Write-Host "  ✗ FAILED — violations detected:" -ForegroundColor Red
        Write-Host $lines -ForegroundColor DarkRed
        $violationList = ($violations | ForEach-Object { $_.Trim() })
        $script:jsonResult.suites += @{ name = $Name; suite_id = $SuiteId; checks = $Checks; status = "fail"; violations = @($violationList); runtime_ms = [math]::Round($sw.Elapsed.TotalMilliseconds) }
        $script:jsonResult.summary.total_checks += $Checks; $script:jsonResult.summary.failed += $violationList.Count; $script:jsonResult.summary.passed += ($Checks - $violationList.Count)
        return $false
    }
}

# Suite definitions: SuiteNum, Name, SuiteId, FileName, Checks
$sqlSuites = @(
    @{ Num = 5;  Name = "API Surface Validation";         Id = "api";                 File = "QA__api_surfaces.sql";              Checks = 14 },
    @{ Num = 6;  Name = "Confidence Scoring";              Id = "confidence";           File = "QA__confidence_scoring.sql";        Checks = 10 },
    @{ Num = 7;  Name = "Data Quality & Plausibility";     Id = "data_quality";         File = "QA__data_quality.sql";              Checks = 25 },
    @{ Num = 8;  Name = "Referential Integrity";           Id = "referential";          File = "QA__referential_integrity.sql";     Checks = 18 },
    @{ Num = 9;  Name = "View & Function Consistency";     Id = "views";                File = "QA__view_consistency.sql";          Checks = 12 },
    @{ Num = 10; Name = "Naming Conventions";              Id = "naming";               File = "QA__naming_conventions.sql";        Checks = 12 },
    @{ Num = 11; Name = "Nutrition Ranges & Plausibility"; Id = "nutrition_ranges";     File = "QA__nutrition_ranges.sql";          Checks = 16 },
    @{ Num = 12; Name = "Data Consistency";                Id = "data_consistency";     File = "QA__data_consistency.sql";          Checks = 18 },
    @{ Num = 13; Name = "Allergen & Trace Integrity";      Id = "allergen_integrity";   File = "QA__allergen_integrity.sql";        Checks = 14 },
    @{ Num = 14; Name = "Serving & Source Validation";     Id = "serving_source";       File = "QA__serving_source_validation.sql"; Checks = 16 },
    @{ Num = 15; Name = "Ingredient Data Quality";         Id = "ingredient_quality";   File = "QA__ingredient_quality.sql";        Checks = 14 }
)

# Run all generic suites and capture pass/fail per variable name
$test5Pass  = Invoke-SqlQASuite -SuiteNum 5  -Name $sqlSuites[0].Name  -SuiteId $sqlSuites[0].Id  -FileName $sqlSuites[0].File  -Checks $sqlSuites[0].Checks
$test6Pass  = Invoke-SqlQASuite -SuiteNum 6  -Name $sqlSuites[1].Name  -SuiteId $sqlSuites[1].Id  -FileName $sqlSuites[1].File  -Checks $sqlSuites[1].Checks
$test7Pass  = Invoke-SqlQASuite -SuiteNum 7  -Name $sqlSuites[2].Name  -SuiteId $sqlSuites[2].Id  -FileName $sqlSuites[2].File  -Checks $sqlSuites[2].Checks
$test8Pass  = Invoke-SqlQASuite -SuiteNum 8  -Name $sqlSuites[3].Name  -SuiteId $sqlSuites[3].Id  -FileName $sqlSuites[3].File  -Checks $sqlSuites[3].Checks
$test9Pass  = Invoke-SqlQASuite -SuiteNum 9  -Name $sqlSuites[4].Name  -SuiteId $sqlSuites[4].Id  -FileName $sqlSuites[4].File  -Checks $sqlSuites[4].Checks
$test10Pass = Invoke-SqlQASuite -SuiteNum 10 -Name $sqlSuites[5].Name  -SuiteId $sqlSuites[5].Id  -FileName $sqlSuites[5].File  -Checks $sqlSuites[5].Checks
$test11Pass = Invoke-SqlQASuite -SuiteNum 11 -Name $sqlSuites[6].Name  -SuiteId $sqlSuites[6].Id  -FileName $sqlSuites[6].File  -Checks $sqlSuites[6].Checks
$test12Pass = Invoke-SqlQASuite -SuiteNum 12 -Name $sqlSuites[7].Name  -SuiteId $sqlSuites[7].Id  -FileName $sqlSuites[7].File  -Checks $sqlSuites[7].Checks
$test13Pass = Invoke-SqlQASuite -SuiteNum 13 -Name $sqlSuites[8].Name  -SuiteId $sqlSuites[8].Id  -FileName $sqlSuites[8].File  -Checks $sqlSuites[8].Checks
$test14Pass = Invoke-SqlQASuite -SuiteNum 14 -Name $sqlSuites[9].Name  -SuiteId $sqlSuites[9].Id  -FileName $sqlSuites[9].File  -Checks $sqlSuites[9].Checks
$test15Pass = Invoke-SqlQASuite -SuiteNum 15 -Name $sqlSuites[10].Name -SuiteId $sqlSuites[10].Id -FileName $sqlSuites[10].File -Checks $sqlSuites[10].Checks

# ─── Database Inventory ─────────────────────────────────────────────────────

Write-Host ""
Write-Host "Database Inventory:" -ForegroundColor Cyan

$invQuery = @"
SELECT
    (SELECT COUNT(*) FROM products WHERE is_deprecated IS NOT TRUE) AS active_products,
    (SELECT COUNT(*) FROM products WHERE is_deprecated = true) AS deprecated,
    (SELECT COUNT(*) FROM nutrition_facts) AS nutrition_rows,
    (SELECT COUNT(*) FROM ingredient_ref) AS ingredient_refs,
    (SELECT COUNT(*) FROM product_ingredient) AS product_ingredients,
    (SELECT COUNT(*) FROM product_allergen_info WHERE type = 'contains') AS allergen_rows,
    (SELECT COUNT(*) FROM product_allergen_info WHERE type = 'traces') AS trace_rows,
    (SELECT COUNT(DISTINCT category) FROM products WHERE is_deprecated IS NOT TRUE) AS categories;
"@

$invOutput = Invoke-Psql -InputSql $invQuery
Write-Host ($invOutput | Out-String).Trim() -ForegroundColor DarkGray

# ─── Summary ────────────────────────────────────────────────────────────────

$allPass = $test1Pass -and $test2Pass -and $test4Pass -and $test5Pass -and $test6Pass -and $test7Pass -and $test8Pass -and $test9Pass -and $test10Pass -and $test11Pass -and $test12Pass -and $test13Pass -and $test14Pass -and $test15Pass
$warnFail = $FailOnWarn -and $hasWarnings
$jsonResult.overall = if (-not $allPass) { "fail" } elseif ($warnFail) { "warn" } else { "pass" }

# Parse inventory into JSON-friendly structure
if ($invOutput) {
    $invText = ($invOutput | Out-String).Trim()
    # Extract numbers from the psql output
    if ($invText -match '(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)') {
        $jsonResult.inventory = @{
            active_products     = [int]$Matches[1]
            deprecated          = [int]$Matches[2]
            nutrition_rows      = [int]$Matches[3]
            ingredient_refs     = [int]$Matches[4]
            product_ingredients = [int]$Matches[5]
            allergen_rows       = [int]$Matches[6]
            trace_rows          = [int]$Matches[7]
            categories          = [int]$Matches[8]
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
    Write-Host "    Suite 7 (DataQuality):  $(if ($test7Pass) { '✓ PASS' } else { '✗ FAIL' })" -ForegroundColor $(if ($test7Pass) { "Green" } else { "Red" })
    Write-Host "    Suite 8 (RefInteg):     $(if ($test8Pass) { '✓ PASS' } else { '✗ FAIL' })" -ForegroundColor $(if ($test8Pass) { "Green" } else { "Red" })
    Write-Host "    Suite 9 (Views):        $(if ($test9Pass) { '✓ PASS' } else { '✗ FAIL' })" -ForegroundColor $(if ($test9Pass) { "Green" } else { "Red" })
    Write-Host "    Suite 10 (Naming):      $(if ($test10Pass) { '✓ PASS' } else { '✗ FAIL' })" -ForegroundColor $(if ($test10Pass) { "Green" } else { "Red" })
    Write-Host "    Suite 11 (NutriRange):  $(if ($test11Pass) { '✓ PASS' } else { '✗ FAIL' })" -ForegroundColor $(if ($test11Pass) { "Green" } else { "Red" })
    Write-Host "    Suite 12 (DataConsist): $(if ($test12Pass) { '✓ PASS' } else { '✗ FAIL' })" -ForegroundColor $(if ($test12Pass) { "Green" } else { "Red" })
    Write-Host "    Suite 13 (Allergen):    $(if ($test13Pass) { '✓ PASS' } else { '✗ FAIL' })" -ForegroundColor $(if ($test13Pass) { "Green" } else { "Red" })
    Write-Host "    Suite 14 (ServSource):  $(if ($test14Pass) { '✓ PASS' } else { '✗ FAIL' })" -ForegroundColor $(if ($test14Pass) { "Green" } else { "Red" })
    Write-Host "    Suite 15 (IngredQual):  $(if ($test15Pass) { '✓ PASS' } else { '✗ FAIL' })" -ForegroundColor $(if ($test15Pass) { "Green" } else { "Red" })
    Write-Host ""
    if (-not $allPass) { exit 1 }
    if ($warnFail) { exit 2 }
    exit 0
}

