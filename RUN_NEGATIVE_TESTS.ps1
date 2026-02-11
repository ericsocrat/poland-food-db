<#
.SYNOPSIS
    Runs negative (destructive-intent) tests against QA checks.

.DESCRIPTION
    Injects deliberately malformed data inside a transaction, verifies
    that QA checks catch each violation, then rolls back.
    The database is NOT modified.

.NOTES
    Prerequisites: Supabase running locally (docker).
    Usage:   .\RUN_NEGATIVE_TESTS.ps1
#>

$CONTAINER = "supabase_db_poland-food-db"
$DB_USER = "postgres"
$DB_NAME = "postgres"
$SCRIPT_ROOT = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$SQL_FILE = Join-Path (Join-Path $SCRIPT_ROOT "db") "qa\TEST__negative_checks.sql"

if (-not (Test-Path $SQL_FILE)) {
    Write-Host "ERROR: $SQL_FILE not found" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Negative Test Suite — QA Check Validation" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Injecting bad data, verifying checks catch it, rolling back..." -ForegroundColor Yellow
Write-Host ""

$sw = [System.Diagnostics.Stopwatch]::StartNew()

$sqlContent = Get-Content $SQL_FILE -Raw -Encoding UTF8
$output = $sqlContent | docker exec -i $CONTAINER psql -U $DB_USER -d $DB_NAME -t --no-psqlrc 2>&1

$sw.Stop()

if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✗ SQL EXECUTION FAILED" -ForegroundColor Red
    Write-Host ($output | Out-String) -ForegroundColor DarkRed
    exit 1
}

# Parse result lines
$lines = ($output | Out-String) -split "`n" | Where-Object { $_ -match '(CAUGHT|MISSED)' }

$caught = 0
$missed = 0
$total = 0

foreach ($line in $lines) {
    $total++
    $trimmed = $line.Trim()
    if ($trimmed -match 'CAUGHT') {
        Write-Host "  $trimmed" -ForegroundColor Green
        $caught++
    }
    elseif ($trimmed -match 'MISSED') {
        Write-Host "  $trimmed" -ForegroundColor Red
        $missed++
    }
    else {
        Write-Host "  $trimmed" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Negative Test Summary" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Total tests:  $total" -ForegroundColor White
Write-Host "  Caught:       $caught" -ForegroundColor Green
if ($missed -gt 0) {
    Write-Host "  Missed:       $missed" -ForegroundColor Red
}
else {
    Write-Host "  Missed:       0" -ForegroundColor Green
}
Write-Host "  Runtime:      $([math]::Round($sw.Elapsed.TotalMilliseconds))ms" -ForegroundColor DarkGray
Write-Host "  DB modified:  NO (transaction rolled back)" -ForegroundColor DarkGray
Write-Host ""

if ($missed -gt 0) {
    Write-Host "  ✗ $missed check(s) FAILED to detect injected violations" -ForegroundColor Red
    exit 1
}
else {
    Write-Host "  ✓ ALL $caught checks correctly detected violations" -ForegroundColor Green
    exit 0
}
