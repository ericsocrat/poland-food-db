<#
.SYNOPSIS
    Runs all QA test suites against the LOCAL Supabase database.

.DESCRIPTION
    Executes:
        1. QA__null_checks.sql (11 data integrity checks)
        2. QA__scoring_formula_tests.sql (14 algorithm validation checks)

    Returns exit code 0 if all tests pass, 1 if any violations found.

.NOTES
    Prerequisites:
        - Docker Desktop running with local Supabase containers
        - Database populated with scored products

    Usage:
        .\RUN_QA.ps1
#>

$CONTAINER = "supabase_db_poland-food-db"
$DB_USER = "postgres"
$DB_NAME = "postgres"
$QA_DIR = Join-Path $PSScriptRoot "db" "qa"

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

Write-Host "Running Test Suite 1: Data Integrity (11 checks)..." -ForegroundColor Yellow

# Strip final summary query to avoid false-positive
$test1Content = Get-Content $test1File -Raw
$test1ChecksOnly = ($test1Content -split '-- 12\. Summary counts')[0]

$test1Output = $test1ChecksOnly | docker exec -i $CONTAINER psql -U $DB_USER -d $DB_NAME --tuples-only 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✗ FAILED TO EXECUTE" -ForegroundColor Red
    Write-Host "  $test1Output" -ForegroundColor DarkRed
    exit 1
}

$test1Lines = ($test1Output | Out-String).Trim()
if ($test1Lines -eq "" -or $test1Lines -match '^\s*$') {
    Write-Host "  ✓ PASS (11/11 — zero violations)" -ForegroundColor Green
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
Write-Host "Running Test Suite 2: Scoring Formula (20 checks)..." -ForegroundColor Yellow

$test2Content = Get-Content $test2File -Raw
$test2Output = $test2Content | docker exec -i $CONTAINER psql -U $DB_USER -d $DB_NAME --tuples-only 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✗ FAILED TO EXECUTE" -ForegroundColor Red
    Write-Host "  $test2Output" -ForegroundColor DarkRed
    exit 1
}

$test2Lines = ($test2Output | Out-String).Trim()
if ($test2Lines -eq "" -or $test2Lines -match '^\s*$') {
    Write-Host "  ✓ PASS (21/21 — zero violations)" -ForegroundColor Green
    $test2Pass = $true
}
else {
    Write-Host "  ✗ FAILED — violations detected:" -ForegroundColor Red
    Write-Host $test2Lines -ForegroundColor DarkRed
    $test2Pass = $false
}

# ─── Database Inventory ─────────────────────────────────────────────────────

Write-Host ""
Write-Host "Database Inventory:" -ForegroundColor Cyan

$invQuery = @"
SELECT
    (SELECT COUNT(*) FROM products WHERE is_deprecated IS NOT TRUE) AS active_products,
    (SELECT COUNT(*) FROM products WHERE is_deprecated = true) AS deprecated,
    (SELECT COUNT(*) FROM nutrition_facts) AS nutrition_rows,
    (SELECT COUNT(*) FROM scores) AS scores_rows,
    (SELECT COUNT(DISTINCT category) FROM products WHERE is_deprecated IS NOT TRUE) AS categories,
    (SELECT STRING_AGG(DISTINCT category, ', ' ORDER BY category) FROM products WHERE is_deprecated IS NOT TRUE) AS category_list;
"@

$invOutput = echo $invQuery | docker exec -i $CONTAINER psql -U $DB_USER -d $DB_NAME 2>&1
Write-Host ($invOutput | Out-String).Trim() -ForegroundColor DarkGray

# ─── Summary ────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Test Summary" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

if ($test1Pass -and $test2Pass) {
    Write-Host "  ✓ ALL TESTS PASSED (32/32 checks)" -ForegroundColor Green
    Write-Host ""
    exit 0
}
else {
    Write-Host "  ✗ SOME TESTS FAILED" -ForegroundColor Red
    Write-Host "    Test Suite 1 (Integrity):  $(if ($test1Pass) { '✓ PASS' } else { '✗ FAIL' })" -ForegroundColor $(if ($test1Pass) { "Green" } else { "Red" })
    Write-Host "    Test Suite 2 (Formula):    $(if ($test2Pass) { '✓ PASS' } else { '✗ FAIL' })" -ForegroundColor $(if ($test2Pass) { "Green" } else { "Red" })
    Write-Host ""
    exit 1
}
