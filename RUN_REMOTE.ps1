<#
.SYNOPSIS
    Runs all SQL pipelines against a REMOTE Supabase database (staging or production).

.DESCRIPTION
    Executes every pipeline SQL file in the correct order against the
    selected Supabase cloud project.

    ⚠️  THIS MODIFIES CLOUD DATA. ⚠️

    Safety features:
        - Requires explicit -Env parameter (no default — forces conscious choice)
        - Requires explicit -Force flag OR interactive confirmation
        - Blocks execution on non-main branches (unless -Force)
        - Displays a warning banner before execution
        - Shows exact files that will be executed before prompting
        - All pipelines use ON CONFLICT DO UPDATE (upsert) — never drops or truncates
        - Automatically runs BACKUP.ps1 before deployment (unless -SkipBackup)

.PARAMETER Env
    Target environment: staging or production.

.NOTES
    Prerequisites:
        - psql available on PATH
        - pg_dump available on PATH (for pre-deployment backup)
        - Remote database password available via env var or interactive prompt:
            - Production: SUPABASE_DB_PASSWORD
            - Staging:    SUPABASE_STAGING_DB_PASSWORD + SUPABASE_STAGING_PROJECT_REF

    Usage:
        .\RUN_REMOTE.ps1 -Env staging              # Staging — interactive confirmation + backup
        .\RUN_REMOTE.ps1 -Env production            # Production — interactive confirmation + backup
        .\RUN_REMOTE.ps1 -Env staging -Category chips  # Run only chips pipeline on staging
        .\RUN_REMOTE.ps1 -Env staging -DryRun       # Preview without executing
        .\RUN_REMOTE.ps1 -Env production -Force     # Skip interactive prompt (production)
        .\RUN_REMOTE.ps1 -Env staging -SkipBackup   # Skip pre-deployment backup (emergency)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, HelpMessage = "Target environment: staging or production.")]
    [ValidateSet("staging", "production")]
    [string]$Env,

    [Parameter(HelpMessage = "Run only a specific category pipeline (e.g., 'chips', 'zabka'). If omitted, runs all.")]
    [string]$Category = "",

    [Parameter(HelpMessage = "Print the SQL files that would be executed without running them.")]
    [switch]$DryRun,

    [Parameter(HelpMessage = "Skip the interactive confirmation prompt. Use with caution.")]
    [switch]$Force,

    [Parameter(HelpMessage = "Skip the pre-deployment backup. Emergency use only.")]
    [switch]$SkipBackup
)

# ─── Configuration ───────────────────────────────────────────────────────────

$PRODUCTION_PROJECT_REF = "uskvezwftkkudvksmken"
$POOLER_HOST = "aws-1-eu-west-1.pooler.supabase.com"
$DB_PORT = "5432"
$DB_NAME = "postgres"

$PIPELINE_ROOT = Join-Path $PSScriptRoot "db" "pipelines"

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
    "staging" {
        $stagingRef = [System.Environment]::GetEnvironmentVariable("SUPABASE_STAGING_PROJECT_REF")
        if (-not $stagingRef) {
            Write-Host "ERROR: SUPABASE_STAGING_PROJECT_REF not set." -ForegroundColor Red
            Write-Host "Add it to your .env file or set as an environment variable." -ForegroundColor Yellow
            exit 1
        }
        $PROJECT_REF = $stagingRef
        $DB_HOST = $POOLER_HOST
        $DB_USER = "postgres.$stagingRef"
        $envLabel = "STAGING ($stagingRef)"
        $envColor = "Yellow"
        $passwordEnvVar = "SUPABASE_STAGING_DB_PASSWORD"
    }
    "production" {
        $PROJECT_REF = $PRODUCTION_PROJECT_REF
        $DB_HOST = $POOLER_HOST
        $DB_USER = "postgres.$PRODUCTION_PROJECT_REF"
        $envLabel = "PRODUCTION ($PRODUCTION_PROJECT_REF)"
        $envColor = "Red"
        $passwordEnvVar = "SUPABASE_DB_PASSWORD"
    }
}

# ─── Warning Banner ─────────────────────────────────────────────────────────

Write-Host ""
Write-Host "================================================================" -ForegroundColor $envColor
Write-Host "  ⚠️   REMOTE DATABASE — $($Env.ToUpper()) ENVIRONMENT   ⚠️" -ForegroundColor $envColor
Write-Host "================================================================" -ForegroundColor $envColor
Write-Host ""
Write-Host "  Project:  $PROJECT_REF" -ForegroundColor Yellow
Write-Host "  Host:     $DB_HOST" -ForegroundColor Yellow
Write-Host "  Database: $DB_NAME" -ForegroundColor Yellow
Write-Host ""
Write-Host "  This script will execute SQL pipelines against your" -ForegroundColor White
Write-Host "  REMOTE Supabase database. Changes cannot be easily undone." -ForegroundColor White
Write-Host ""

# ─── Preflight Checks ───────────────────────────────────────────────────────

# Branch check — hard block unless -Force (§8.1A)
$currentBranch = git branch --show-current 2>$null
if ($currentBranch -and $currentBranch -ne "main") {
    Write-Host "  BLOCKED: You are on branch '$currentBranch', not 'main'." -ForegroundColor Red
    Write-Host "  Remote pipelines must be run from 'main' to ensure reviewed code." -ForegroundColor Yellow
    if (-not $Force) {
        Write-Host "  Use -Force to override this check (NOT recommended)." -ForegroundColor DarkGray
        Write-Host ""
        exit 1
    }
    Write-Host "  -Force flag detected — overriding branch check." -ForegroundColor DarkYellow
    Write-Host ""
}

# Check psql is available
$psqlCmd = Get-Command psql -ErrorAction SilentlyContinue
if (-not $psqlCmd) {
    Write-Host "ERROR: psql not found on PATH." -ForegroundColor Red
    Write-Host "Install PostgreSQL client tools or add psql to your PATH." -ForegroundColor Yellow
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

# ─── Show Execution Plan ────────────────────────────────────────────────────

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

# ─── Confirmation Gate ──────────────────────────────────────────────────────

if (-not $Force) {
    Write-Host "─────────────────────────────────────────────────" -ForegroundColor $envColor
    Write-Host "  Type 'YES' to proceed, or anything else to abort." -ForegroundColor $envColor
    Write-Host "─────────────────────────────────────────────────" -ForegroundColor $envColor
    Write-Host ""
    $response = Read-Host "  Execute $($allFiles.Count) files against $envLabel?"
    if ($response -ne "YES") {
        Write-Host ""
        Write-Host "ABORTED by user." -ForegroundColor Yellow
        exit 0
    }
    Write-Host ""
}

# ─── Pre-Deployment Backup ───────────────────────────────────────────────────

if ($SkipBackup) {
    Write-Host "================================================================" -ForegroundColor DarkYellow
    Write-Host "  ⚠️  BACKUP SKIPPED — -SkipBackup flag is set" -ForegroundColor DarkYellow
    Write-Host "  Proceeding WITHOUT a pre-deployment backup." -ForegroundColor DarkYellow
    Write-Host "  This is NOT recommended for production deployments." -ForegroundColor DarkYellow
    Write-Host "================================================================" -ForegroundColor DarkYellow
    Write-Host ""
}
else {
    Write-Host "Creating pre-deployment backup..." -ForegroundColor Yellow
    $backupScript = Join-Path $PSScriptRoot "BACKUP.ps1"
    if (-not (Test-Path $backupScript)) {
        Write-Host "ERROR: BACKUP.ps1 not found at $backupScript" -ForegroundColor Red
        Write-Host "Cannot proceed without backup script. Use -SkipBackup to override (NOT recommended)." -ForegroundColor Yellow
        exit 1
    }
    & $backupScript -Env remote
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "ERROR: Pre-deployment backup FAILED (exit code $LASTEXITCODE)." -ForegroundColor Red
        Write-Host "Deployment ABORTED — fix the backup issue or use -SkipBackup to override." -ForegroundColor Yellow
        Write-Host ""
        exit 1
    }
    Write-Host ""
    Write-Host "Pre-deployment backup complete." -ForegroundColor Green
    Write-Host ""
}

# ─── Get Database Password ──────────────────────────────────────────────────

# Check for password in environment variable first
$dbPassword = [System.Environment]::GetEnvironmentVariable($passwordEnvVar)
if ($dbPassword) {
    Write-Host "Using database password from $passwordEnvVar environment variable." -ForegroundColor Green
}
else {
    Write-Host "Enter the database password for $envLabel :" -ForegroundColor Yellow
    $securePassword = Read-Host -AsSecureString
    $dbPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
    )
}

# Test connection
Write-Host "Testing remote database connection..." -ForegroundColor Yellow
$env:PGPASSWORD = $dbPassword
try {
    $testResult = & psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT 1;" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Cannot connect to remote database." -ForegroundColor Red
        Write-Host "Check your password and network connection." -ForegroundColor Yellow
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

# ─── Execution ──────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "Executing pipelines against $envLabel..." -ForegroundColor Yellow
Write-Host ""

$successCount = 0
$failCount = 0
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

foreach ($file in $allFiles) {
    $relativePath = $file.FullName.Replace($PSScriptRoot, "").TrimStart("\", "/")
    Write-Host "  RUN  $relativePath" -ForegroundColor Yellow -NoNewline

    $env:PGPASSWORD = $dbPassword
    $output = & psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f $file.FullName --single-transaction -v ON_ERROR_STOP=1 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "  OK" -ForegroundColor Green
        $successCount++
    }
    else {
        Write-Host "  FAILED" -ForegroundColor Red
        Write-Host "    $output" -ForegroundColor DarkRed
        $failCount++
        # Stop on first error to prevent cascading failures
        Write-Host ""
        Write-Host "ABORTED: Stopping pipeline due to error in remote execution." -ForegroundColor Red
        Write-Host "Review the error above and fix before re-running." -ForegroundColor Yellow
        break
    }
}

$stopwatch.Stop()

# ─── Post-Pipeline: CI fixup + MV Refresh ───────────────────────────────────

if ($failCount -eq 0) {
    Write-Host ""
    Write-Host "Applying post-pipeline fixup..." -ForegroundColor Yellow
    $env:PGPASSWORD = $dbPassword
    $output = & psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f (Join-Path $PSScriptRoot "db" "ci_post_pipeline.sql") -v ON_ERROR_STOP=1 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Post-pipeline fixup complete." -ForegroundColor Green
    }
    else {
        Write-Host "  Post-pipeline fixup FAILED: $output" -ForegroundColor Red
        $failCount++
    }

    Write-Host "Refreshing materialized views..." -ForegroundColor Yellow
    $env:PGPASSWORD = $dbPassword
    $output = & psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT refresh_all_materialized_views();" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Materialized views refreshed." -ForegroundColor Green
    }
    else {
        Write-Host "  MV refresh FAILED: $output" -ForegroundColor Red
        $failCount++
    }
}

# ─── Cleanup ────────────────────────────────────────────────────────────────

# Clear password from environment
Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue

# ─── Summary ────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  Remote Execution Summary — $envLabel" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  Succeeded:  $successCount" -ForegroundColor Green
Write-Host "  Failed:     $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Green" })
Write-Host "  Duration:   $($stopwatch.Elapsed.TotalSeconds.ToString('F1'))s" -ForegroundColor White
Write-Host "  Target:     $envLabel ($DB_HOST`:$DB_PORT/$DB_NAME)" -ForegroundColor $envColor
Write-Host ""

if ($failCount -gt 0) {
    Write-Host "  Some pipelines failed. DO NOT re-run blindly." -ForegroundColor Red
    Write-Host "  Review errors, fix the SQL, test locally first, then retry." -ForegroundColor Yellow
    Write-Host ""
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
    exit 1
}

Write-Host "  All pipelines completed successfully." -ForegroundColor Green
Write-Host ""
Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
exit 0
