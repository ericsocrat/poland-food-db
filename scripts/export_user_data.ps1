<#
.SYNOPSIS
    Exports all user-generated data tables to a JSON file.

.DESCRIPTION
    Queries each user data table and writes the combined output as a single
    JSON file to backups/user_data_YYYYMMDD_HHmmss.json.

    Tables exported (in FK dependency order):
        1. user_preferences
        2. user_health_profiles
        3. user_product_lists
        4. user_product_list_items
        5. user_comparisons
        6. user_saved_searches
        7. scan_history
        8. product_submissions

    Connection details are read from environment variables — never hardcoded.

.PARAMETER Env
    Target environment: local or remote.

.NOTES
    Prerequisites:
        - psql on PATH
        - Local:  Docker Desktop + Supabase running
        - Remote: SUPABASE_DB_PASSWORD environment variable set

    Usage:
        .\scripts\export_user_data.ps1 -Env local
        .\scripts\export_user_data.ps1 -Env remote
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, HelpMessage = "Target environment: local or remote.")]
    [ValidateSet("local", "remote")]
    [string]$Env
)

# ─── Configuration ───────────────────────────────────────────────────────────

$PROJECT_REF = "uskvezwftkkudvksmken"
$REMOTE_HOST = "aws-1-eu-west-1.pooler.supabase.com"
$REMOTE_PORT = "5432"
$REMOTE_USER = "postgres.$PROJECT_REF"
$DB_NAME = "postgres"

$LOCAL_HOST = "127.0.0.1"
$LOCAL_PORT = "54322"
$LOCAL_USER = "postgres"
$LOCAL_PASSWORD = "postgres"

$SCRIPT_ROOT = Split-Path -Parent $PSScriptRoot  # scripts/ → project root
$BACKUP_DIR = Join-Path $SCRIPT_ROOT "backups"
$TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"
$OUTPUT_FILE = Join-Path $BACKUP_DIR "user_data_${TIMESTAMP}.json"

# Tables in FK dependency order (parents before children)
$USER_TABLES = @(
    "user_preferences",
    "user_health_profiles",
    "user_product_lists",
    "user_product_list_items",
    "user_comparisons",
    "user_saved_searches",
    "scan_history",
    "product_submissions"
)

# ─── Banner ──────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Poland Food DB — User Data Export" -ForegroundColor Cyan
Write-Host "  Environment: $($Env.ToUpper())" -ForegroundColor $(if ($Env -eq "remote") { "Red" } else { "Green" })
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# ─── Preflight ───────────────────────────────────────────────────────────────

$psqlCmd = Get-Command psql -ErrorAction SilentlyContinue
if (-not $psqlCmd) {
    Write-Host "ERROR: psql not found on PATH." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $BACKUP_DIR)) {
    New-Item -ItemType Directory -Path $BACKUP_DIR -Force | Out-Null
}

# ─── Connection Setup ────────────────────────────────────────────────────────

switch ($Env) {
    "local" {
        $dbHost = $LOCAL_HOST
        $dbPort = $LOCAL_PORT
        $dbUser = $LOCAL_USER
        $dbPassword = $LOCAL_PASSWORD
    }
    "remote" {
        $dbHost = $REMOTE_HOST
        $dbPort = $REMOTE_PORT
        $dbUser = $REMOTE_USER
        if ($env:SUPABASE_DB_PASSWORD) {
            $dbPassword = $env:SUPABASE_DB_PASSWORD
        }
        else {
            Write-Host "Enter the remote database password:" -ForegroundColor Yellow
            $securePassword = Read-Host -AsSecureString
            $dbPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
            )
        }
    }
}

# Test connection
Write-Host "Testing database connection..." -ForegroundColor Yellow
$env:PGPASSWORD = $dbPassword
$testResult = & psql -h $dbHost -p $dbPort -U $dbUser -d $DB_NAME -c "SELECT 1;" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Cannot connect to database." -ForegroundColor Red
    Write-Host "Output: $testResult" -ForegroundColor DarkGray
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
    exit 1
}
Write-Host "Connection OK." -ForegroundColor Green
Write-Host ""

# ─── Export Each Table ───────────────────────────────────────────────────────

$exportData = @{}
$totalRows = 0
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

foreach ($table in $USER_TABLES) {
    Write-Host "  Exporting $table..." -ForegroundColor Yellow -NoNewline

    # Check if table exists
    $existsQuery = "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = '$table');"
    $env:PGPASSWORD = $dbPassword
    $exists = & psql -h $dbHost -p $dbPort -U $dbUser -d $DB_NAME --tuples-only --no-align -c $existsQuery 2>&1
    $exists = $exists.Trim()

    if ($exists -ne "t") {
        Write-Host "  SKIP (table not found)" -ForegroundColor DarkGray
        $exportData[$table] = @()
        continue
    }

    # Export as JSON array
    $jsonQuery = "SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) FROM public.$table t;"
    $env:PGPASSWORD = $dbPassword
    $jsonOutput = & psql -h $dbHost -p $dbPort -U $dbUser -d $DB_NAME --tuples-only --no-align -c $jsonQuery 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Host "  FAILED" -ForegroundColor Red
        Write-Host "    $jsonOutput" -ForegroundColor DarkRed
        Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
        exit 1
    }

    # Parse JSON to get row count
    try {
        $parsed = $jsonOutput | ConvertFrom-Json
        $rowCount = $parsed.Count
        $exportData[$table] = $parsed
        $totalRows += $rowCount
        Write-Host "  $rowCount rows" -ForegroundColor Green
    }
    catch {
        # If parsing fails, store raw string and count lines
        $exportData[$table] = $jsonOutput
        Write-Host "  exported (raw)" -ForegroundColor DarkYellow
    }
}

$stopwatch.Stop()

# ─── Write Output File ──────────────────────────────────────────────────────

Write-Host ""
Write-Host "Writing export file..." -ForegroundColor Yellow

$output = @{
    exported_at = (Get-Date -Format "o")
    environment = $Env
    tables      = $exportData
    table_order = $USER_TABLES
}

$output | ConvertTo-Json -Depth 100 | Set-Content -Path $OUTPUT_FILE -Encoding UTF8

# ─── Cleanup ────────────────────────────────────────────────────────────────

Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue

# ─── Summary ────────────────────────────────────────────────────────────────

$fileInfo = Get-Item $OUTPUT_FILE
$sizeMB = [math]::Round($fileInfo.Length / 1MB, 2)

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "  User Data Export Complete" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host "  File:       $($fileInfo.Name)" -ForegroundColor White
Write-Host "  Size:       $sizeMB MB" -ForegroundColor White
Write-Host "  Tables:     $($USER_TABLES.Count)" -ForegroundColor White
Write-Host "  Total Rows: $totalRows" -ForegroundColor White
Write-Host "  Duration:   $($stopwatch.Elapsed.TotalSeconds.ToString('F1'))s" -ForegroundColor White
Write-Host "  Path:       $($fileInfo.FullName)" -ForegroundColor DarkGray
Write-Host ""

exit 0
