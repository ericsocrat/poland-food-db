<#
.SYNOPSIS
    Runs all QA test suites against the LOCAL Supabase database.

.DESCRIPTION
    Executes:
        1. QA__null_checks.sql (29 data integrity checks)
        2. QA__scoring_formula_tests.sql (29 algorithm validation checks)
        3. QA__source_coverage.sql (8 source provenance checks — informational)
        4. validate_eans.py (EAN-8/EAN-13 checksum validation — blocking)
        5. QA__api_surfaces.sql (18 API contract validation checks — blocking)
        6. QA__confidence_scoring.sql (13 confidence scoring checks — blocking)
        7. QA__data_quality.sql (25 data quality & plausibility checks — blocking)
        8. QA__referential_integrity.sql (18 referential integrity checks — blocking)
        9. QA__view_consistency.sql (13 view & function consistency checks — blocking)
       10. QA__naming_conventions.sql (12 naming/formatting convention checks — blocking)
       11. QA__nutrition_ranges.sql (18 nutrition range & plausibility checks — blocking)
       12. QA__data_consistency.sql (22 data consistency & domain checks — blocking)
       13. QA__allergen_integrity.sql (14 allergen & trace integrity checks — blocking)
       14. QA__serving_source_validation.sql (16 serving & source checks — blocking)
       15. QA__ingredient_quality.sql (14 ingredient quality checks — blocking)
       16. QA__security_posture.sql (29 security posture checks — blocking)
       17. QA__api_contract.sql (30 API contract checks — blocking)
       18. QA__scale_guardrails.sql (23 scale guardrails checks — blocking)
       19. QA__country_isolation.sql (6 country isolation checks — blocking)
       20. QA__diet_filtering.sql (6 diet filtering checks — blocking)
       21. QA__allergen_filtering.sql (6 allergen filtering checks — blocking)
       22. QA__barcode_lookup.sql (6 barcode scanner checks — blocking)
       23. QA__auth_onboarding.sql (8 auth & onboarding checks — blocking)
       24. QA__confidence_reporting.sql (7 confidence reporting checks — blocking)
       25. QA__health_profiles.sql (14 health profile checks — blocking)
       26. QA__lists_comparisons.sql (12 lists & comparisons checks — blocking)
       27. QA__scanner_submissions.sql (12 scanner & submissions checks — blocking)
       28. QA__index_temporal.sql (19 index coverage & temporal checks — blocking)
       29. QA__attribute_contradiction.sql (5 attribute contradiction checks — blocking)
       30. QA__monitoring.sql (7 monitoring & health checks — blocking)
       31. QA__scoring_determinism.sql (17 scoring determinism checks — blocking)
       32. QA__multi_country_consistency.sql (10 multi-country consistency checks — blocking)
       33. QA__performance_regression.sql (6 performance regression checks — informational)
       34. QA__event_intelligence.sql (18 event intelligence checks — blocking)
       35. QA__store_integrity.sql (12 store architecture checks — blocking)

    Returns exit code 0 if all tests pass, 1 if any violations found.
    Test Suites 3 and 33 are informational and do not affect the exit code.

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

$script:JsonMode = [bool]$Json

function Write-Host {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
        [object[]]$Object,
        [ConsoleColor]$ForegroundColor,
        [ConsoleColor]$BackgroundColor,
        [switch]$NoNewline,
        [object]$Separator
    )

    if (-not $script:JsonMode) {
        Microsoft.PowerShell.Utility\Write-Host @PSBoundParameters
    }
}

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

# Single source of truth for suite metadata (names, counts, blocking behavior)
$suiteCatalog = @(
    @{ Num = 1; Name = "Data Integrity"; Short = "Integrity"; Id = "integrity"; Checks = 29; Blocking = $true; Kind = "sql-special"; File = "QA__null_checks.sql" },
    @{ Num = 2; Name = "Scoring Formula"; Short = "Scoring"; Id = "scoring"; Checks = 29; Blocking = $true; Kind = "sql-special"; File = "QA__scoring_formula_tests.sql" },
    @{ Num = 3; Name = "Source Coverage"; Short = "Source"; Id = "source_coverage"; Checks = 8; Blocking = $false; Kind = "sql-special"; File = "QA__source_coverage.sql" },
    @{ Num = 4; Name = "EAN Checksum Validation"; Short = "EAN"; Id = "ean"; Checks = 1; Blocking = $true; Kind = "python"; File = "validate_eans.py" },
    @{ Num = 5; Name = "API Surface Validation"; Short = "API"; Id = "api"; Checks = 18; Blocking = $true; Kind = "sql"; File = "QA__api_surfaces.sql" },
    @{ Num = 6; Name = "Confidence Scoring"; Short = "Confidence"; Id = "confidence"; Checks = 13; Blocking = $true; Kind = "sql"; File = "QA__confidence_scoring.sql" },
    @{ Num = 7; Name = "Data Quality & Plausibility"; Short = "DataQuality"; Id = "data_quality"; Checks = 25; Blocking = $true; Kind = "sql"; File = "QA__data_quality.sql" },
    @{ Num = 8; Name = "Referential Integrity"; Short = "RefInteg"; Id = "referential"; Checks = 18; Blocking = $true; Kind = "sql"; File = "QA__referential_integrity.sql" },
    @{ Num = 9; Name = "View & Function Consistency"; Short = "Views"; Id = "views"; Checks = 13; Blocking = $true; Kind = "sql"; File = "QA__view_consistency.sql" },
    @{ Num = 10; Name = "Naming Conventions"; Short = "Naming"; Id = "naming"; Checks = 12; Blocking = $true; Kind = "sql"; File = "QA__naming_conventions.sql" },
    @{ Num = 11; Name = "Nutrition Ranges & Plausibility"; Short = "NutriRange"; Id = "nutrition_ranges"; Checks = 18; Blocking = $true; Kind = "sql"; File = "QA__nutrition_ranges.sql" },
    @{ Num = 12; Name = "Data Consistency"; Short = "DataConsist"; Id = "data_consistency"; Checks = 22; Blocking = $true; Kind = "sql"; File = "QA__data_consistency.sql" },
    @{ Num = 13; Name = "Allergen & Trace Integrity"; Short = "Allergen"; Id = "allergen_integrity"; Checks = 15; Blocking = $true; Kind = "sql"; File = "QA__allergen_integrity.sql" },
    @{ Num = 14; Name = "Serving & Source Validation"; Short = "ServSource"; Id = "serving_source"; Checks = 16; Blocking = $true; Kind = "sql"; File = "QA__serving_source_validation.sql" },
    @{ Num = 15; Name = "Ingredient Data Quality"; Short = "IngredQual"; Id = "ingredient_quality"; Checks = 14; Blocking = $true; Kind = "sql"; File = "QA__ingredient_quality.sql" },
    @{ Num = 16; Name = "Security Posture"; Short = "Security"; Id = "security_posture"; Checks = 29; Blocking = $true; Kind = "sql"; File = "QA__security_posture.sql" },
    @{ Num = 17; Name = "API Contract"; Short = "Contract"; Id = "api_contract"; Checks = 33; Blocking = $true; Kind = "sql"; File = "QA__api_contract.sql" },
    @{ Num = 18; Name = "Scale Guardrails"; Short = "Scale"; Id = "scale_guardrails"; Checks = 23; Blocking = $true; Kind = "sql"; File = "QA__scale_guardrails.sql" },
    @{ Num = 19; Name = "Country Isolation"; Short = "Country"; Id = "country_isolation"; Checks = 11; Blocking = $true; Kind = "sql"; File = "QA__country_isolation.sql" },
    @{ Num = 20; Name = "Diet Filtering"; Short = "Diet"; Id = "diet_filtering"; Checks = 6; Blocking = $true; Kind = "sql"; File = "QA__diet_filtering.sql" },
    @{ Num = 21; Name = "Allergen Filtering"; Short = "Allergen"; Id = "allergen_filtering"; Checks = 6; Blocking = $true; Kind = "sql"; File = "QA__allergen_filtering.sql" },
    @{ Num = 22; Name = "Barcode Lookup"; Short = "Barcode"; Id = "barcode_lookup"; Checks = 6; Blocking = $true; Kind = "sql"; File = "QA__barcode_lookup.sql" },
    @{ Num = 23; Name = "Auth & Onboarding"; Short = "AuthOnboard"; Id = "auth_onboarding"; Checks = 8; Blocking = $true; Kind = "sql"; File = "QA__auth_onboarding.sql" },
    @{ Num = 24; Name = "Confidence Reporting"; Short = "ConfReport"; Id = "confidence_reporting"; Checks = 7; Blocking = $true; Kind = "sql"; File = "QA__confidence_reporting.sql" },
    @{ Num = 25; Name = "Health Profiles"; Short = "Health"; Id = "health_profiles"; Checks = 14; Blocking = $true; Kind = "sql"; File = "QA__health_profiles.sql" },
    @{ Num = 26; Name = "Lists & Comparisons"; Short = "ListsComp"; Id = "lists_comparisons"; Checks = 12; Blocking = $true; Kind = "sql"; File = "QA__lists_comparisons.sql" },
    @{ Num = 27; Name = "Scanner & Submissions"; Short = "Scanner"; Id = "scanner_submissions"; Checks = 12; Blocking = $true; Kind = "sql"; File = "QA__scanner_submissions.sql" },
    @{ Num = 28; Name = "Index & Temporal Integrity"; Short = "IdxTemporal"; Id = "index_temporal"; Checks = 19; Blocking = $true; Kind = "sql"; File = "QA__index_temporal.sql" },
    @{ Num = 29; Name = "Attribute Contradictions"; Short = "AttrContra"; Id = "attribute_contradiction"; Checks = 5; Blocking = $true; Kind = "sql"; File = "QA__attribute_contradiction.sql" },
    @{ Num = 30; Name = "Monitoring & Health Check"; Short = "Monitoring"; Id = "monitoring"; Checks = 9; Blocking = $true; Kind = "sql"; File = "QA__monitoring.sql" },
    @{ Num = 31; Name = "Scoring Determinism"; Short = "Determinism"; Id = "scoring_determinism"; Checks = 17; Blocking = $true; Kind = "sql"; File = "QA__scoring_determinism.sql" },
    @{ Num = 32; Name = "Multi-Country Consistency"; Short = "MultiCountry"; Id = "multi_country_consistency"; Checks = 10; Blocking = $true; Kind = "sql"; File = "QA__multi_country_consistency.sql" },
    @{ Num = 33; Name = "Performance Regression"; Short = "PerfRegress"; Id = "performance_regression"; Checks = 6; Blocking = $false; Kind = "sql"; File = "QA__performance_regression.sql" },
    @{ Num = 34; Name = "Event Intelligence"; Short = "EventIntel"; Id = "event_intelligence"; Checks = 18; Blocking = $true; Kind = "sql"; File = "QA__event_intelligence.sql" },
    @{ Num = 35; Name = "Store Architecture"; Short = "StoreArch"; Id = "store_integrity"; Checks = 12; Blocking = $true; Kind = "sql"; File = "QA__store_integrity.sql" }
)

$suiteByNum = @{}
foreach ($suite in $suiteCatalog) {
    $suiteByNum[$suite.Num] = $suite
}

$suitePass = @{}

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

function Get-NonEmptyLines {
    param([string]$Text)
    return @($Text -split "`n" | ForEach-Object { $_.TrimEnd() } | Where-Object { $_ -match '\S' })
}

function Get-FailedCheckLines {
    param([string]$Text)
    $allLines = Get-NonEmptyLines -Text $Text
    return @($allLines | Where-Object { $_ -match '^\s*\d+\.\s+.+\|\s*[1-9]\d*\s*$' })
}

function Write-TrimmedViolationOutput {
    param(
        [string]$Text,
        [int]$MaxLines = 40
    )

    $lines = @(Get-NonEmptyLines -Text $Text)
    if ($lines.Count -le $MaxLines) {
        Write-Host $Text -ForegroundColor DarkRed
        return
    }

    $head = @($lines | Select-Object -First $MaxLines)
    Write-Host ($head -join "`n") -ForegroundColor DarkRed
    Write-Host "  ... ($($lines.Count - $MaxLines) additional lines omitted; use individual QA SQL for full details)" -ForegroundColor DarkGray
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

$suite1Checks = $suiteByNum[1].Checks
Write-Host "Running Test Suite 1: Data Integrity ($suite1Checks checks)..." -ForegroundColor Yellow

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
    Write-Host "  ✓ PASS ($suite1Checks/$suite1Checks — zero violations) [$([math]::Round($sw1.Elapsed.TotalMilliseconds))ms]" -ForegroundColor Green
    $test1Pass = $true
    $jsonResult.suites += @{ name = $suiteByNum[1].Name; suite_id = $suiteByNum[1].Id; checks = $suite1Checks; status = "pass"; violations = @(); runtime_ms = [math]::Round($sw1.Elapsed.TotalMilliseconds) }
    $jsonResult.summary.total_checks += $suite1Checks; $jsonResult.summary.passed += $suite1Checks
}
else {
    $sw1.Stop()
    Write-Host "  ✗ FAILED — violations detected:" -ForegroundColor Red
    $test1Pass = $false
    $failedCheckLines = @(Get-FailedCheckLines -Text $test1Lines)
    $nonEmptyLines = @(Get-NonEmptyLines -Text $test1Lines)
    if ($failedCheckLines.Count -gt 0) {
        $violationList = $failedCheckLines
        $failedCount = $failedCheckLines.Count
        Write-Host ($violationList -join "`n") -ForegroundColor DarkRed
        if ($nonEmptyLines.Count -gt $failedCheckLines.Count) {
            Write-Host "  ... ($($nonEmptyLines.Count - $failedCheckLines.Count) zero-violation rows omitted)" -ForegroundColor DarkGray
        }
    }
    else {
        $violationList = @($nonEmptyLines | Select-Object -First 20)
        $failedCount = 1
        Write-TrimmedViolationOutput -Text $test1Lines -MaxLines 20
    }
    $jsonResult.suites += @{ name = $suiteByNum[1].Name; suite_id = $suiteByNum[1].Id; checks = $suite1Checks; status = "fail"; violations = @($violationList); runtime_ms = [math]::Round($sw1.Elapsed.TotalMilliseconds) }
    $jsonResult.summary.total_checks += $suite1Checks; $jsonResult.summary.failed += $failedCount; $jsonResult.summary.passed += ($suite1Checks - $failedCount)
}
$suitePass[1] = $test1Pass

# ─── Test 2: Scoring Formula Validation ────────────────────────────────────

$test2File = Join-Path $QA_DIR "QA__scoring_formula_tests.sql"
if (-not (Test-Path $test2File)) {
    Write-Host "ERROR: QA__scoring_formula_tests.sql not found at: $test2File" -ForegroundColor Red
    exit 1
}

Write-Host ""
$suite2Checks = $suiteByNum[2].Checks
Write-Host "Running Test Suite 2: Scoring Formula ($suite2Checks checks)..." -ForegroundColor Yellow

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
    Write-Host "  ✓ PASS ($suite2Checks/$suite2Checks — zero violations) [$([math]::Round($sw2.Elapsed.TotalMilliseconds))ms]" -ForegroundColor Green
    $test2Pass = $true
    $jsonResult.suites += @{ name = $suiteByNum[2].Name; suite_id = $suiteByNum[2].Id; checks = $suite2Checks; status = "pass"; violations = @(); runtime_ms = [math]::Round($sw2.Elapsed.TotalMilliseconds) }
    $jsonResult.summary.total_checks += $suite2Checks; $jsonResult.summary.passed += $suite2Checks
}
else {
    $sw2.Stop()
    Write-Host "  ✗ FAILED — violations detected:" -ForegroundColor Red
    $test2Pass = $false
    $failedCheckLines2 = @(Get-FailedCheckLines -Text $test2Lines)
    $nonEmptyLines2 = @(Get-NonEmptyLines -Text $test2Lines)
    if ($failedCheckLines2.Count -gt 0) {
        $violationList2 = $failedCheckLines2
        $failedCount2 = $failedCheckLines2.Count
        Write-Host ($violationList2 -join "`n") -ForegroundColor DarkRed
        if ($nonEmptyLines2.Count -gt $failedCheckLines2.Count) {
            Write-Host "  ... ($($nonEmptyLines2.Count - $failedCheckLines2.Count) zero-violation rows omitted)" -ForegroundColor DarkGray
        }
    }
    else {
        $violationList2 = @($nonEmptyLines2 | Select-Object -First 20)
        $failedCount2 = 1
        Write-TrimmedViolationOutput -Text $test2Lines -MaxLines 20
    }
    $jsonResult.suites += @{ name = $suiteByNum[2].Name; suite_id = $suiteByNum[2].Id; checks = $suite2Checks; status = "fail"; violations = @($violationList2); runtime_ms = [math]::Round($sw2.Elapsed.TotalMilliseconds) }
    $jsonResult.summary.total_checks += $suite2Checks; $jsonResult.summary.failed += $failedCount2; $jsonResult.summary.passed += ($suite2Checks - $failedCount2)
}
$suitePass[2] = $test2Pass

# ─── Test 3: Source Coverage (Informational) ───────────────────────────────

$test3File = Join-Path $QA_DIR "QA__source_coverage.sql"
if (Test-Path $test3File) {
    Write-Host ""
    $suite3Checks = $suiteByNum[3].Checks
    Write-Host "Running Test Suite 3: Source Coverage ($suite3Checks checks — informational)..." -ForegroundColor Yellow

    $sw3 = [System.Diagnostics.Stopwatch]::StartNew()

    # Run only checks 1-4 (actionable items); 5-7 are informational summaries
    $test3Content = Get-Content $test3File -Raw
    $test3Output = Invoke-Psql -InputSql $test3Content -TuplesOnly

    if ($LASTEXITCODE -ne 0) {
        $sw3.Stop()
        Write-Host "  ⚠ FAILED TO EXECUTE (non-blocking)" -ForegroundColor DarkYellow
        $jsonResult.suites += @{ name = $suiteByNum[3].Name; suite_id = $suiteByNum[3].Id; checks = $suite3Checks; status = "error"; blocking = $false; runtime_ms = [math]::Round($sw3.Elapsed.TotalMilliseconds) }
    }
    else {
        $actionableCountQuery = @"
SELECT COUNT(DISTINCT p.product_id)
FROM products p
WHERE p.is_deprecated IS NOT TRUE
  AND (
      p.source_type IS NULL
      OR p.source_type = 'off_api'
      OR (p.source_type IS NOT NULL AND p.source_type NOT IN ('label_scan', 'retailer_api'))
      OR p.confidence = 'estimated'
  );
"@

        $actionableOutput = Invoke-Psql -InputSql $actionableCountQuery -TuplesOnly
        $actionableCount = 0
        if ($LASTEXITCODE -eq 0) {
            $actionableText = ($actionableOutput | Out-String).Trim()
            if ($actionableText -match '(\d+)') {
                $actionableCount = [int]$Matches[1]
            }
        }

        $sw3.Stop()
        $test3Lines = ($test3Output | Out-String).Trim()
        $infoRowCount = if ($test3Lines -eq "" -or $test3Lines -match '^\s*$') { 0 } else { (Get-NonEmptyLines -Text $test3Lines).Count }
        if ($actionableCount -eq 0) {
            Write-Host "  ✓ All products have multi-source coverage [$([math]::Round($sw3.Elapsed.TotalMilliseconds))ms]" -ForegroundColor Green
            $jsonResult.suites += @{ name = $suiteByNum[3].Name; suite_id = $suiteByNum[3].Id; checks = $suite3Checks; status = "pass"; blocking = $false; flagged_actionable = 0; flagged_rows_total = $infoRowCount; runtime_ms = [math]::Round($sw3.Elapsed.TotalMilliseconds) }
            $suitePass[3] = $true
        }
        else {
            Write-Host "  ⚠ $actionableCount products flagged for cross-validation (non-blocking) [$([math]::Round($sw3.Elapsed.TotalMilliseconds))ms]" -ForegroundColor DarkYellow
            Write-Host "    Informational rows returned by suite query set: $infoRowCount" -ForegroundColor DarkGray
            Write-Host "    Run QA__source_coverage.sql directly for details." -ForegroundColor DarkGray
            $hasWarnings = $true
            $jsonResult.suites += @{ name = $suiteByNum[3].Name; suite_id = $suiteByNum[3].Id; checks = $suite3Checks; status = "warn"; blocking = $false; flagged_actionable = $actionableCount; flagged_rows_total = $infoRowCount; runtime_ms = [math]::Round($sw3.Elapsed.TotalMilliseconds) }
            $jsonResult.summary.warnings += $actionableCount
            $suitePass[3] = $false
        }
    }
}

# ─── Test 4: EAN Checksum Validation (EAN-8/EAN-13) ───────────────────────

Write-Host ""
Write-Host "Running Test Suite 4: EAN Checksum Validation (EAN-8/EAN-13)..." -ForegroundColor Yellow

$suite4Checks = $suiteByNum[4].Checks

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
        $jsonResult.suites += @{ name = $suiteByNum[4].Name; suite_id = $suiteByNum[4].Id; checks = $suite4Checks; status = "pass"; violations = @(); runtime_ms = [math]::Round($sw4.Elapsed.TotalMilliseconds) }
        $jsonResult.summary.total_checks += $suite4Checks; $jsonResult.summary.passed += $suite4Checks
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
        $jsonResult.suites += @{ name = $suiteByNum[4].Name; suite_id = $suiteByNum[4].Id; checks = $suite4Checks; status = "fail"; violations = @($validatorOutput); runtime_ms = [math]::Round($sw4.Elapsed.TotalMilliseconds) }
        $jsonResult.summary.total_checks += $suite4Checks; $jsonResult.summary.failed += $suite4Checks
    }
}
$suitePass[4] = $test4Pass

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
        $allLineItems = @(Get-NonEmptyLines -Text $lines)
        $violationList = @($violations | ForEach-Object { $_.Trim() })
        if ($violationList.Count -gt 0) {
            Write-Host ($violationList -join "`n") -ForegroundColor DarkRed
            if ($allLineItems.Count -gt $violationList.Count) {
                Write-Host "  ... ($($allLineItems.Count - $violationList.Count) zero-violation rows omitted)" -ForegroundColor DarkGray
            }
        }
        else {
            Write-TrimmedViolationOutput -Text $lines
        }
        $script:jsonResult.suites += @{ name = $Name; suite_id = $SuiteId; checks = $Checks; status = "fail"; violations = @($violationList); runtime_ms = [math]::Round($sw.Elapsed.TotalMilliseconds) }
        $script:jsonResult.summary.total_checks += $Checks; $script:jsonResult.summary.failed += $violationList.Count; $script:jsonResult.summary.passed += ($Checks - $violationList.Count)
        return $false
    }
}

$sqlSuites = $suiteCatalog | Where-Object { $_.Kind -eq 'sql' } | Sort-Object Num
foreach ($suite in $sqlSuites) {
    $suitePass[$suite.Num] = Invoke-SqlQASuite -SuiteNum $suite.Num -Name $suite.Name -SuiteId $suite.Id -FileName $suite.File -Checks $suite.Checks
}

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

$allPass = $true
foreach ($suite in $suiteCatalog | Where-Object { $_.Blocking }) {
    if (-not $suitePass[$suite.Num]) {
        $allPass = $false
        break
    }
}
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
    foreach ($suite in $suiteCatalog | Sort-Object Num) {
        $label = "Suite $($suite.Num) ($($suite.Short))".PadRight(28)
        if ($suite.Num -eq 3) {
            $statusText = "$(if ($hasWarnings) { '⚠ WARN' } else { '✓ PASS' }) (informational$(if ($FailOnWarn) { ', -FailOnWarn active' }))"
            $statusColor = if ($hasWarnings) { "DarkYellow" } else { "Green" }
        }
        else {
            $statusText = if ($suitePass[$suite.Num]) { '✓ PASS' } else { '✗ FAIL' }
            $statusColor = if ($suitePass[$suite.Num]) { "Green" } else { "Red" }
        }
        Write-Host "    $label $statusText" -ForegroundColor $statusColor
    }
    Write-Host ""
    if (-not $allPass) { exit 1 }
    if ($warnFail) { exit 2 }
    exit 0
}

