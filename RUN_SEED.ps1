<#
.SYNOPSIS
    Unified seed runner — loads reference data and product pipelines into any environment.

.DESCRIPTION
    Executes:
        1. Reference data seed (supabase/seed/001_reference_data.sql)
        2. Product pipelines (db/pipelines/*/PIPELINE__*.sql) — all or a single category
        3. Post-pipeline fixup (db/ci_post_pipeline.sql)
        4. Materialized view refresh

    Safety guardrails for production (single-cloud mode — §8.1A):
        - Requires explicit '-Env production' flag (never defaults to cloud)
        - Requires interactive 'YES' confirmation (unless -Force)
        - Blocks execution on non-main branches (unless -Force)
        - Shows existing product count before execution
        - All writes use ON CONFLICT DO UPDATE (upsert) — never drops or truncates

.PARAMETER Env
    Target environment: local, staging, or production.

.PARAMETER Category
    Run only a specific category pipeline (e.g., 'chips-pl'). If omitted, runs all.

.PARAMETER DryRun
    Show what would be executed without running anything.

.PARAMETER Force
    Skip the interactive confirmation prompt. Use with caution.

.PARAMETER SkipPipelines
    Run only the reference data seed, skip product pipelines.

.NOTES
    Prerequisites:
        - Local:      Docker Desktop + Supabase running (supabase start)
        - Staging:    psql on PATH + SUPABASE_STAGING_DB_PASSWORD in env or .env
        - Production: psql on PATH + SUPABASE_DB_PASSWORD in env or .env

    Usage:
        .\RUN_SEED.ps1 -Env local                       # Full seed (local)
        .\RUN_SEED.ps1 -Env local -Category chips-pl    # Single category (local)
        .\RUN_SEED.ps1 -Env staging                      # Full seed (staging)
        .\RUN_SEED.ps1 -Env staging -SkipPipelines       # Reference data only
        .\RUN_SEED.ps1 -Env production -Force            # Full seed (production, no prompt)
        .\RUN_SEED.ps1 -DryRun -Env staging              # Preview files
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, HelpMessage = "Target environment: local, staging, or production.")]
    [ValidateSet("local", "staging", "production")]
    [string]$Env,

    [Parameter(HelpMessage = "Run only a specific category pipeline (e.g., 'chips-pl'). If omitted, runs all.")]
    [string]$Category = "",

    [Parameter(HelpMessage = "Show what would be executed without running anything.")]
    [switch]$DryRun,

    [Parameter(HelpMessage = "Skip the interactive confirmation prompt. Use with caution.")]
    [switch]$Force,

    [Parameter(HelpMessage = "Run only the reference data seed, skip product pipelines.")]
    [switch]$SkipPipelines
)

# ─── Configuration ───────────────────────────────────────────────────────────

$PRODUCTION_PROJECT_REF = "uskvezwftkkudvksmken"
$DOCKER_CONTAINER = "supabase_db_poland-food-db"
$DB_NAME = "postgres"
$DB_USER = "postgres"
$DB_PORT = "5432"

$SEED_ROOT = Join-Path $PSScriptRoot "supabase" "seed"
$PIPELINE_ROOT = Join-Path $PSScriptRoot "db" "pipelines"
$POST_PIPELINE = Join-Path $PSScriptRoot "db" "ci_post_pipeline.sql"

# ─── Load .env if present ────────────────────────────────────────────────────

$dotenvPath = Join-Path $PSScriptRoot ".env"
if (Test-Path $dotenvPath) {
    Get-Content $dotenvPath | ForEach-Object {
        if ($_ -match '^\s*([A-Z_][A-Z0-9_]*)\s*=\s*(.+)$') {
            $key = $Matches[1]
            $val = $Matches[2].Trim().Trim('"', "'")
            if (-not [System.Environment]::GetEnvironmentVariable($key)) {
                [System.Environment]::SetEnvironmentVariable($key, $val)
            }
        }
    }
}

# ─── Environment-specific configuration ──────────────────────────────────────

switch ($Env) {
    "local" {
        $envLabel = "LOCAL (Docker)"
        $envColor = "Green"
        $usePsql = $false
    }
    "staging" {
        $stagingRef = [System.Environment]::GetEnvironmentVariable("SUPABASE_STAGING_PROJECT_REF")
        if (-not $stagingRef) {
            Write-Host "ERROR: SUPABASE_STAGING_PROJECT_REF not set." -ForegroundColor Red
            Write-Host "Set it in your .env file or environment variables." -ForegroundColor Yellow
            exit 1
        }
        $dbHost = "db.$stagingRef.supabase.co"
        $dbPassword = [System.Environment]::GetEnvironmentVariable("SUPABASE_STAGING_DB_PASSWORD")
        $envLabel = "STAGING ($stagingRef)"
        $envColor = "Yellow"
        $usePsql = $true
    }
    "production" {
        $dbHost = "db.$PRODUCTION_PROJECT_REF.supabase.co"
        $dbPassword = [System.Environment]::GetEnvironmentVariable("SUPABASE_DB_PASSWORD")
        $envLabel = "PRODUCTION ($PRODUCTION_PROJECT_REF)"
        $envColor = "Red"
        $usePsql = $true
    }
}

# ─── Banner ──────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "================================================" -ForegroundColor $envColor
Write-Host "  Poland Food DB — Seed Runner" -ForegroundColor Cyan
Write-Host "  Target: $envLabel" -ForegroundColor $envColor
Write-Host "================================================" -ForegroundColor $envColor
Write-Host ""

# ─── Production Guard Rails (§8.1A — single-cloud mode) ─────────────────────

if ($Env -eq "production") {
    Write-Host "  ⚠️  PRODUCTION ENVIRONMENT — Data changes cannot be easily undone." -ForegroundColor Red
    Write-Host "  This is the ONLY cloud project (single-cloud mode)." -ForegroundColor Red
    Write-Host ""

    # Branch check — hard block unless -Force
    $currentBranch = git branch --show-current 2>$null
    if ($currentBranch -and $currentBranch -ne "main") {
        Write-Host "  BLOCKED: You are on branch '$currentBranch', not 'main'." -ForegroundColor Red
        Write-Host "  Production seeds must be run from 'main' to ensure reviewed code." -ForegroundColor Yellow
        if (-not $Force) {
            Write-Host "  Use -Force to override this check (NOT recommended)." -ForegroundColor DarkGray
            Write-Host ""
            exit 1
        }
        Write-Host "  -Force flag detected — overriding branch check." -ForegroundColor DarkYellow
        Write-Host ""
    }
}

# ─── Preflight: psql / Docker check ─────────────────────────────────────────

if ($usePsql) {
    $psqlCmd = Get-Command psql -ErrorAction SilentlyContinue
    if (-not $psqlCmd) {
        Write-Host "ERROR: psql not found on PATH." -ForegroundColor Red
        Write-Host "Install PostgreSQL client tools or add psql to your PATH." -ForegroundColor Yellow
        exit 1
    }

    # Get password if not in env
    if (-not $dbPassword) {
        Write-Host "Enter the database password for $envLabel :" -ForegroundColor Yellow
        $securePassword = Read-Host -AsSecureString
        $dbPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
        )
    }

    # Test connection
    Write-Host "Testing database connection..." -ForegroundColor Yellow
    $env:PGPASSWORD = $dbPassword
    try {
        $testResult = & psql -h $dbHost -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT 1;" 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: Cannot connect to $envLabel." -ForegroundColor Red
            Write-Host "Output: $testResult" -ForegroundColor DarkGray
            Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
            exit 1
        }
        Write-Host "Connection OK." -ForegroundColor Green
    }
    catch {
        Write-Host "ERROR: psql failed — $($_.Exception.Message)" -ForegroundColor Red
        Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
        exit 1
    }

    # Show existing product count (guard rail)
    if ($Env -eq "production" -or $Env -eq "staging") {
        $countResult = & psql -h $dbHost -p $DB_PORT -U $DB_USER -d $DB_NAME --tuples-only -c "SELECT COUNT(*) FROM products WHERE is_deprecated IS NOT TRUE;" 2>&1
        $existingCount = ($countResult -join "").Trim()
        if ($existingCount -match '^\d+$' -and [int]$existingCount -gt 0) {
            Write-Host ""
            Write-Host "  ℹ️  $envLabel currently has $existingCount active products." -ForegroundColor Cyan
            Write-Host "  Pipelines use upsert (ON CONFLICT DO UPDATE) — existing data will be updated, not duplicated." -ForegroundColor DarkGray
            Write-Host ""
        }
    }
}
else {
    # Local: Docker check
    $dockerCmd = Get-Command docker -ErrorAction SilentlyContinue
    if (-not $dockerCmd) {
        Write-Host "ERROR: docker not found on PATH." -ForegroundColor Red
        exit 1
    }
    $testResult = docker exec $DOCKER_CONTAINER psql -U $DB_USER -d $DB_NAME -c "SELECT 1;" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Cannot connect to local database container." -ForegroundColor Red
        Write-Host "Is Docker running? Is Supabase started? (supabase start)" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "Connection OK." -ForegroundColor Green
}

# ─── Discover Files ──────────────────────────────────────────────────────────

$allFiles = @()

# 1. Seed files
$seedFiles = Get-ChildItem -Path $SEED_ROOT -Filter "*.sql" -ErrorAction SilentlyContinue | Sort-Object Name
foreach ($f in $seedFiles) { $allFiles += @{ File = $f; Phase = "seed" } }

# 2. Pipeline files (unless -SkipPipelines)
if (-not $SkipPipelines) {
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

    foreach ($folder in $categoryFolders) {
        $sqlFiles = Get-ChildItem -Path $folder.FullName -Filter "PIPELINE__*.sql" | Sort-Object Name
        foreach ($f in $sqlFiles) { $allFiles += @{ File = $f; Phase = "pipeline" } }
    }

    # 3. Post-pipeline fixup
    if (Test-Path $POST_PIPELINE) {
        $allFiles += @{ File = Get-Item $POST_PIPELINE; Phase = "fixup" }
    }
}

if ($allFiles.Count -eq 0) {
    Write-Host "No files found to execute." -ForegroundColor Yellow
    exit 0
}

# ─── Show Execution Plan ────────────────────────────────────────────────────

$seedCount = ($allFiles | Where-Object { $_.Phase -eq "seed" }).Count
$pipeCount = ($allFiles | Where-Object { $_.Phase -eq "pipeline" }).Count
$fixupCount = ($allFiles | Where-Object { $_.Phase -eq "fixup" }).Count

Write-Host "Execution plan ($($allFiles.Count) files):" -ForegroundColor Cyan
Write-Host "  Seeds:     $seedCount" -ForegroundColor White
Write-Host "  Pipelines: $pipeCount" -ForegroundColor White
Write-Host "  Fixups:    $fixupCount" -ForegroundColor White
Write-Host ""

if ($DryRun) {
    $currentPhase = ""
    foreach ($entry in $allFiles) {
        if ($entry.Phase -ne $currentPhase) {
            Write-Host "  [$($entry.Phase)]" -ForegroundColor Magenta
            $currentPhase = $entry.Phase
        }
        $relativePath = $entry.File.FullName.Replace($PSScriptRoot, "").TrimStart("\", "/")
        Write-Host "    $relativePath" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "DRY RUN — no SQL was executed." -ForegroundColor Yellow
    exit 0
}

# ─── Confirmation Gate ──────────────────────────────────────────────────────

if ($Env -ne "local" -and -not $Force) {
    Write-Host "─────────────────────────────────────────────────" -ForegroundColor $envColor
    Write-Host "  Type 'YES' to proceed, or anything else to abort." -ForegroundColor $envColor
    Write-Host "─────────────────────────────────────────────────" -ForegroundColor $envColor
    $response = Read-Host "  Execute $($allFiles.Count) files against $($envLabel)?"
    if ($response -ne "YES") {
        Write-Host ""
        Write-Host "ABORTED by user." -ForegroundColor Yellow
        exit 0
    }
    Write-Host ""
}

# ─── Helper: Execute SQL ────────────────────────────────────────────────────

function Invoke-Sql {
    param([string]$FilePath)

    if ($usePsql) {
        $env:PGPASSWORD = $dbPassword
        $output = & psql -h $dbHost -p $DB_PORT -U $DB_USER -d $DB_NAME -f $FilePath --single-transaction -v ON_ERROR_STOP=1 2>&1
    }
    else {
        $sqlContent = Get-Content $FilePath -Raw
        $output = $sqlContent | docker exec -i $DOCKER_CONTAINER psql -U $DB_USER -d $DB_NAME --single-transaction -v ON_ERROR_STOP=1 2>&1
    }
    return @{ ExitCode = $LASTEXITCODE; Output = $output }
}

# ─── Execution ──────────────────────────────────────────────────────────────

Write-Host "Executing against $envLabel ..." -ForegroundColor Yellow
Write-Host ""

$successCount = 0
$failCount = 0
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$currentPhase = ""

foreach ($entry in $allFiles) {
    if ($entry.Phase -ne $currentPhase) {
        Write-Host ""
        Write-Host "  ── $($entry.Phase.ToUpper()) ──" -ForegroundColor Magenta
        $currentPhase = $entry.Phase
    }

    $relativePath = $entry.File.FullName.Replace($PSScriptRoot, "").TrimStart("\", "/")
    Write-Host "  RUN  $relativePath" -ForegroundColor Yellow -NoNewline

    $result = Invoke-Sql -FilePath $entry.File.FullName

    if ($result.ExitCode -eq 0) {
        Write-Host "  ✓" -ForegroundColor Green
        $successCount++
    }
    else {
        Write-Host "  ✗ FAILED" -ForegroundColor Red
        Write-Host "    $($result.Output)" -ForegroundColor DarkRed
        $failCount++
        Write-Host ""
        Write-Host "ABORTED: Stopping due to error." -ForegroundColor Red
        break
    }
}

$stopwatch.Stop()

# ─── Refresh Materialized Views ──────────────────────────────────────────────

if ($failCount -eq 0 -and -not $SkipPipelines) {
    Write-Host ""
    Write-Host "Refreshing materialized views..." -ForegroundColor Yellow

    if ($usePsql) {
        $env:PGPASSWORD = $dbPassword
        $mvOutput = & psql -h $dbHost -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT refresh_all_materialized_views();" 2>&1
    }
    else {
        $mvOutput = "SELECT refresh_all_materialized_views();" | docker exec -i $DOCKER_CONTAINER psql -U $DB_USER -d $DB_NAME 2>&1
    }

    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ All materialized views refreshed" -ForegroundColor Green
    }
    else {
        Write-Host "  ⚠ MV refresh failed (non-blocking): $mvOutput" -ForegroundColor DarkYellow
    }
}

# ─── Cleanup sensitive data ──────────────────────────────────────────────────

if ($usePsql) {
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}

# ─── Summary ────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Seed Summary" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Environment: $envLabel" -ForegroundColor $envColor
Write-Host "  Succeeded:   $successCount" -ForegroundColor Green
Write-Host "  Failed:      $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Green" })
Write-Host "  Duration:    $($stopwatch.Elapsed.TotalSeconds.ToString('F1'))s" -ForegroundColor White
Write-Host ""

if ($failCount -gt 0) {
    exit 1
}

Write-Host "Tip: Run .\RUN_SANITY.ps1 -Env $Env to validate." -ForegroundColor DarkGray
Write-Host ""
exit 0
