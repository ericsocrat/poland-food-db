<#
.SYNOPSIS
    Runs all QA test suites against the LOCAL Supabase database.

.DESCRIPTION
    Executes:
        1. QA__null_checks.sql (32 data integrity checks + 6 informational)
        2. QA__scoring_formula_tests.sql (29 algorithm validation checks)
        3. QA__source_coverage.sql (8 source provenance checks — informational)
        4. validate_eans.py (EAN-13 checksum validation — blocking)

    Returns exit code 0 if all tests pass, 1 if any violations found.
    Test Suite 3 is informational and does not affect the exit code.

.NOTES
    Prerequisites:
        - Docker Desktop running with local Supabase containers
        - Database populated with scored products
        - Python 3.14+ with validate_eans.py script

    Usage:
        .\RUN_QA.ps1
#>

$CONTAINER = "supabase_db_poland-food-db"
$DB_USER = "postgres"
$DB_NAME = "postgres"
$SCRIPT_ROOT = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$QA_DIR = Join-Path (Join-Path $SCRIPT_ROOT "db") "qa"

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Poland Food DB — QA Test Suite" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# ─── Test 1: Data Integrity Checks ─────────────────────────────────────────

$test1File = Join-Path $QA_DIR "QA__null_checks.sql"
if (-not (Test-Path $test1File)) {
    Write-Host "ERROR: QA__null_checks.sql not found at: $test1File" -ForegroundColor Red
    exit 1
}

Write-Host "Running Test Suite 1: Data Integrity (32 checks)..." -ForegroundColor Yellow

# Strip final summary query to avoid false-positive
$test1Content = Get-Content $test1File -Raw
$test1ChecksOnly = ($test1Content -split '-- 33\. v_master new column coverage')[0]

$test1Output = $test1ChecksOnly | docker exec -i $CONTAINER psql -U $DB_USER -d $DB_NAME --tuples-only 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✗ FAILED TO EXECUTE" -ForegroundColor Red
    Write-Host "  $test1Output" -ForegroundColor DarkRed
    exit 1
}

$test1Lines = ($test1Output | Out-String).Trim()
if ($test1Lines -eq "" -or $test1Lines -match '^\s*$') {
    Write-Host "  ✓ PASS (32/32 — zero violations)" -ForegroundColor Green
    $test1Pass = $true
}
else {
    Write-Host "  ✗ FAILED — violations detected:" -ForegroundColor Red
    Write-Host $test1Lines -ForegroundColor DarkRed
    $test1Pass = $false
}

# ─── Test 2: Scoring Formula Validation ────────────────────────────────────

$test2File = Join-Path $QA_DIR "QA__scoring_formula_tests.sql"
if (-not (Test-Path $test2File)) {
    Write-Host "ERROR: QA__scoring_formula_tests.sql not found at: $test2File" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Running Test Suite 2: Scoring Formula (29 checks)..." -ForegroundColor Yellow

$test2Content = Get-Content $test2File -Raw
$test2Output = $test2Content | docker exec -i $CONTAINER psql -U $DB_USER -d $DB_NAME --tuples-only 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✗ FAILED TO EXECUTE" -ForegroundColor Red
    Write-Host "  $test2Output" -ForegroundColor DarkRed
    exit 1
}

$test2Lines = ($test2Output | Out-String).Trim()
if ($test2Lines -eq "" -or $test2Lines -match '^\s*$') {
    Write-Host "  ✓ PASS (29/29 — zero violations)" -ForegroundColor Green
    $test2Pass = $true
}
else {
    Write-Host "  ✗ FAILED — violations detected:" -ForegroundColor Red
    Write-Host $test2Lines -ForegroundColor DarkRed
    $test2Pass = $false
}

# ─── Test 3: Source Coverage (Informational) ───────────────────────────────

$test3File = Join-Path $QA_DIR "QA__source_coverage.sql"
if (Test-Path $test3File) {
    Write-Host ""
    Write-Host "Running Test Suite 3: Source Coverage (8 checks — informational)..." -ForegroundColor Yellow

    # Run only checks 1-4 (actionable items); 5-7 are informational summaries
    $test3Content = Get-Content $test3File -Raw
    $test3Output = $test3Content | docker exec -i $CONTAINER psql -U $DB_USER -d $DB_NAME --tuples-only 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ⚠ FAILED TO EXECUTE (non-blocking)" -ForegroundColor DarkYellow
    }
    else {
        $test3Lines = ($test3Output | Out-String).Trim()
        if ($test3Lines -eq "" -or $test3Lines -match '^\s*$') {
            Write-Host "  ✓ All products have multi-source coverage" -ForegroundColor Green
        }
        else {
            $singleSourceCount = ($test3Lines -split "`n" | Where-Object { $_ -match '\S' }).Count
            Write-Host "  ⚠ $singleSourceCount items flagged for cross-validation (non-blocking)" -ForegroundColor DarkYellow
            Write-Host "    Run QA__source_coverage.sql directly for details." -ForegroundColor DarkGray
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
    $validatorOutput = & python $validatorScript 2>&1
    $validatorExitCode = $LASTEXITCODE

    if ($validatorExitCode -eq 0) {
        Write-Host "  ✓ PASS — All EAN codes have valid checksums" -ForegroundColor Green
        $test4Pass = $true
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

$invOutput = echo $invQuery | docker exec -i $CONTAINER psql -U $DB_USER -d $DB_NAME 2>&1
Write-Host ($invOutput | Out-String).Trim() -ForegroundColor DarkGray

# ─── Summary ────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Test Summary" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

if ($test1Pass -and $test2Pass -and $test4Pass) {
    Write-Host "  ✓ ALL TESTS PASSED" -ForegroundColor Green
    Write-Host ""
    exit 0
}
else {
    Write-Host "  ✗ SOME TESTS FAILED" -ForegroundColor Red
    Write-Host "    Test Suite 1 (Integrity):  $(if ($test1Pass) { '✓ PASS' } else { '✗ FAIL' })" -ForegroundColor $(if ($test1Pass) { "Green" } else { "Red" })
    Write-Host "    Test Suite 2 (Formula):    $(if ($test2Pass) { '✓ PASS' } else { '✗ FAIL' })" -ForegroundColor $(if ($test2Pass) { "Green" } else { "Red" })
    Write-Host "    Test Suite 4 (EAN):        $(if ($test4Pass) { '✓ PASS' } else { '✗ FAIL' })" -ForegroundColor $(if ($test4Pass) { "Green" } else { "Red" })
    Write-Host ""
    exit 1
}
