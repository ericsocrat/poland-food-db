<#
.SYNOPSIS
    Runs all SQL pipelines against the LOCAL Supabase database.

.DESCRIPTION
    Executes every pipeline SQL file in the correct order against:
        postgresql://postgres:postgres@127.0.0.1:54322/postgres

    This script is SAFE to run repeatedly (all pipelines are idempotent).
    It does NOT touch the remote Supabase instance.

.NOTES
    Prerequisites:
        - Docker Desktop running with local Supabase containers
        - Local Supabase started: supabase start
        - No psql installation required (uses docker exec)

    Usage:
        .\RUN_LOCAL.ps1
        .\RUN_LOCAL.ps1 -Category chips
        .\RUN_LOCAL.ps1 -DryRun
        .\RUN_LOCAL.ps1 -RunQA
        .\RUN_LOCAL.ps1 -Category chips -RunQA
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Run only a specific category pipeline (e.g., 'chips', 'zabka'). If omitted, runs all.")]
    [string]$Category = "",

    [Parameter(HelpMessage = "Print the SQL files that would be executed without running them.")]
    [switch]$DryRun,

    [Parameter(HelpMessage = "Run the full QA suite (via RUN_QA.ps1) after pipeline execution.")]
    [switch]$RunQA
)

# ─── Configuration ───────────────────────────────────────────────────────────

$CONTAINER = "supabase_db_poland-food-db"
$DB_NAME = "postgres"
$DB_USER = "postgres"

$PIPELINE_ROOT = Join-Path $PSScriptRoot "db" "pipelines"

# ─── Preflight Checks ───────────────────────────────────────────────────────

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Poland Food DB — Local Pipeline Runner" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Target: LOCAL (docker exec $CONTAINER)" -ForegroundColor Green
Write-Host ""

# Check Docker is available
$dockerCmd = Get-Command docker -ErrorAction SilentlyContinue
if (-not $dockerCmd) {
    Write-Host "ERROR: docker not found on PATH." -ForegroundColor Red
    Write-Host "Install Docker Desktop from https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
    exit 1
}

# Test connection via docker exec
Write-Host "Testing database connection..." -ForegroundColor Yellow
try {
    $testResult = docker exec $CONTAINER psql -U $DB_USER -d $DB_NAME -c "SELECT 1;" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Cannot connect to local database." -ForegroundColor Red
        Write-Host "Is Docker running? Is Supabase started? (supabase start)" -ForegroundColor Yellow
        Write-Host "Output: $testResult" -ForegroundColor DarkGray
        exit 1
    }
    Write-Host "Connection OK." -ForegroundColor Green
}
catch {
    Write-Host "ERROR: docker exec failed — $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# ─── Discover Pipeline Files ────────────────────────────────────────────────

if (-not (Test-Path $PIPELINE_ROOT)) {
    Write-Host "ERROR: Pipeline root not found: $PIPELINE_ROOT" -ForegroundColor Red
    exit 1
}

# Get category folders
if ($Category -ne "") {
    $categoryPath = Join-Path $PIPELINE_ROOT $Category
    if (-not (Test-Path $categoryPath)) {
        Write-Host "ERROR: Category folder not found: $categoryPath" -ForegroundColor Red
        Write-Host "Available categories:" -ForegroundColor Yellow
        Get-ChildItem -Path $PIPELINE_ROOT -Directory | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Yellow }
        exit 1
    }
    $categoryFolders = @(Get-Item $categoryPath)
}
else {
    $categoryFolders = Get-ChildItem -Path $PIPELINE_ROOT -Directory | Sort-Object Name
}

# Collect all SQL files in execution order
$allFiles = @()
foreach ($folder in $categoryFolders) {
    $sqlFiles = Get-ChildItem -Path $folder.FullName -Filter "PIPELINE__*.sql" | Sort-Object Name
    if ($sqlFiles.Count -eq 0) {
        Write-Host "  SKIP: $($folder.Name) (no pipeline files)" -ForegroundColor DarkGray
        continue
    }
    foreach ($file in $sqlFiles) {
        $allFiles += $file
    }
}

if ($allFiles.Count -eq 0) {
    Write-Host "No pipeline files found to execute." -ForegroundColor Yellow
    exit 0
}

# ─── Execution ──────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "Pipeline files to execute ($($allFiles.Count) total):" -ForegroundColor Cyan
Write-Host "─────────────────────────────────────────────────" -ForegroundColor DarkGray

$currentCategory = ""
foreach ($file in $allFiles) {
    $cat = $file.Directory.Name
    if ($cat -ne $currentCategory) {
        Write-Host ""
        Write-Host "  [$cat]" -ForegroundColor Magenta
        $currentCategory = $cat
    }
    Write-Host "    $($file.Name)" -ForegroundColor White
}

Write-Host ""

if ($DryRun) {
    Write-Host "DRY RUN — no SQL was executed." -ForegroundColor Yellow
    exit 0
}

# Execute each file
$successCount = 0
$failCount = 0
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

foreach ($file in $allFiles) {
    $relativePath = $file.FullName.Replace($PSScriptRoot, "").TrimStart("\", "/")
    Write-Host "  RUN  $relativePath" -ForegroundColor Yellow -NoNewline

    $sqlContent = Get-Content $file.FullName -Raw
    $output = $sqlContent | docker exec -i $CONTAINER psql -U $DB_USER -d $DB_NAME --single-transaction -v ON_ERROR_STOP=1 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓" -ForegroundColor Green
        $successCount++
    }
    else {
        Write-Host "  ✗ FAILED" -ForegroundColor Red
        Write-Host "    $output" -ForegroundColor DarkRed
        $failCount++
        # Stop on first error to prevent cascading failures
        Write-Host ""
        Write-Host "ABORTED: Stopping pipeline due to error." -ForegroundColor Red
        break
    }
}

$stopwatch.Stop()

# ─── Summary ────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Execution Summary" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Succeeded:  $successCount" -ForegroundColor Green
Write-Host "  Failed:     $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Green" })
Write-Host "  Duration:   $($stopwatch.Elapsed.TotalSeconds.ToString('F1'))s" -ForegroundColor White
Write-Host "  Target:     LOCAL (docker exec $CONTAINER)" -ForegroundColor Green
Write-Host ""

if ($failCount -gt 0) {
    exit 1
}

# ─── Refresh Materialized Views ─────────────────────────────────────────────────────

Write-Host "Refreshing materialized views..." -ForegroundColor Yellow
$mvOutput = "SELECT refresh_all_materialized_views();" | docker exec -i $CONTAINER psql -U $DB_USER -d $DB_NAME 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ All materialized views refreshed" -ForegroundColor Green
}
else {
    Write-Host "  ⚠ MV refresh failed (non-blocking): $mvOutput" -ForegroundColor DarkYellow
}

# ─── QA Checks (optional) ──────────────────────────────────────────────────────────

if ($RunQA) {
    $qaScript = Join-Path $PSScriptRoot "RUN_QA.ps1"
    if (-not (Test-Path $qaScript)) {
        Write-Host "WARNING: RUN_QA.ps1 not found: $qaScript" -ForegroundColor Yellow
    }
    else {
        Write-Host ""
        & $qaScript
        if ($LASTEXITCODE -ne 0) {
            exit 1
        }
    }
}

exit 0
