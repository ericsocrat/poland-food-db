<#
.SYNOPSIS
    Imports user-generated data from a JSON export back into the database.

.DESCRIPTION
    Reads a JSON file produced by export_user_data.ps1 and upserts the data
    back into each user table using ON CONFLICT DO UPDATE semantics.

    Tables are imported in FK dependency order (parents before children) to
    preserve referential integrity.

    This script is IDEMPOTENT — safe to run multiple times on the same data.

.PARAMETER Env
    Target environment: local or remote.

.PARAMETER File
    Path to the JSON export file to import.

.NOTES
    Prerequisites:
        - psql on PATH
        - Local:  Docker Desktop + Supabase running
        - Remote: SUPABASE_DB_PASSWORD environment variable set

    Usage:
        .\scripts\import_user_data.ps1 -Env local -File backups\user_data_20260222_120000.json
        .\scripts\import_user_data.ps1 -Env remote -File backups\user_data_20260222_120000.json
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, HelpMessage = "Target environment: local or remote.")]
    [ValidateSet("local", "remote")]
    [string]$Env,

    [Parameter(Mandatory = $true, HelpMessage = "Path to the JSON export file to import.")]
    [string]$File
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

# Primary key columns for each table (used for ON CONFLICT)
$TABLE_PK = @{
    "user_preferences"        = "user_id"
    "user_health_profiles"    = "id"
    "user_product_lists"      = "id"
    "user_product_list_items" = "id"
    "user_comparisons"        = "id"
    "user_saved_searches"     = "id"
    "scan_history"            = "id"
    "product_submissions"     = "id"
}

# ─── Banner ──────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Poland Food DB — User Data Import" -ForegroundColor Cyan
Write-Host "  Environment: $($Env.ToUpper())" -ForegroundColor $(if ($Env -eq "remote") { "Red" } else { "Green" })
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# ─── Preflight ───────────────────────────────────────────────────────────────

$psqlCmd = Get-Command psql -ErrorAction SilentlyContinue
if (-not $psqlCmd) {
    Write-Host "ERROR: psql not found on PATH." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $File)) {
    Write-Host "ERROR: Import file not found: $File" -ForegroundColor Red
    exit 1
}

# ─── Load JSON ────────────────────────────────────────────────────────────────

Write-Host "Loading export file: $File" -ForegroundColor Yellow
try {
    $jsonContent = Get-Content -Path $File -Raw -Encoding UTF8 | ConvertFrom-Json
}
catch {
    Write-Host "ERROR: Failed to parse JSON — $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

if (-not $jsonContent.tables) {
    Write-Host "ERROR: JSON file missing 'tables' property." -ForegroundColor Red
    exit 1
}

$tableOrder = if ($jsonContent.table_order) { $jsonContent.table_order } else { $TABLE_PK.Keys }
Write-Host "  Exported at: $($jsonContent.exported_at)" -ForegroundColor DarkGray
Write-Host "  Source env:  $($jsonContent.environment)" -ForegroundColor DarkGray
Write-Host "  Tables:      $($tableOrder.Count)" -ForegroundColor DarkGray
Write-Host ""

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

if ($Env -eq "remote") {
    Write-Host "================================================================" -ForegroundColor Red
    Write-Host "  ⚠️   IMPORTING TO REMOTE (PRODUCTION) DATABASE   ⚠️" -ForegroundColor Red
    Write-Host "================================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Type 'YES' to proceed, or anything else to abort." -ForegroundColor Red
    $response = Read-Host "  Import user data into REMOTE database?"
    if ($response -ne "YES") {
        Write-Host ""
        Write-Host "ABORTED by user." -ForegroundColor Yellow
        Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
        exit 0
    }
    Write-Host ""
}

# ─── Import Each Table ──────────────────────────────────────────────────────

$successCount = 0
$skipCount = 0
$failCount = 0
$totalRows = 0
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

foreach ($table in $tableOrder) {
    $tableData = $jsonContent.tables.$table

    if (-not $tableData -or $tableData.Count -eq 0) {
        Write-Host "  SKIP  $table (no data)" -ForegroundColor DarkGray
        $skipCount++
        continue
    }

    $rowCount = $tableData.Count
    Write-Host "  IMPORT $table ($rowCount rows)..." -ForegroundColor Yellow -NoNewline

    $pk = $TABLE_PK[$table]
    if (-not $pk) {
        Write-Host "  SKIP (no PK mapping)" -ForegroundColor DarkYellow
        $skipCount++
        continue
    }

    # Build upsert SQL using json_populate_recordset for bulk import
    # Escape the JSON for SQL embedding
    $jsonArray = $tableData | ConvertTo-Json -Depth 100 -Compress
    # Escape single quotes for SQL
    $jsonArrayEscaped = $jsonArray -replace "'", "''"

    # Get column names from the first row (excluding system columns)
    $columns = $tableData[0].PSObject.Properties.Name
    $updateCols = $columns | Where-Object { $_ -ne $pk } | ForEach-Object { "`"$_`" = EXCLUDED.`"$_`"" }
    $updateClause = $updateCols -join ", "

    $upsertSQL = @"
INSERT INTO public.$table
SELECT * FROM json_populate_recordset(null::public.$table, '$jsonArrayEscaped'::json)
ON CONFLICT ($pk) DO UPDATE SET $updateClause;
"@

    $env:PGPASSWORD = $dbPassword
    $output = $upsertSQL | & psql -h $dbHost -p $dbPort -U $dbUser -d $DB_NAME -v ON_ERROR_STOP=1 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "  OK" -ForegroundColor Green
        $successCount++
        $totalRows += $rowCount
    }
    else {
        Write-Host "  FAILED" -ForegroundColor Red
        Write-Host "    $output" -ForegroundColor DarkRed
        $failCount++
    }
}

$stopwatch.Stop()

# ─── Cleanup ────────────────────────────────────────────────────────────────

Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue

# ─── Summary ────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  User Data Import Summary" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Environment: $($Env.ToUpper())" -ForegroundColor $(if ($Env -eq "remote") { "Red" } else { "Green" })
Write-Host "  Succeeded:   $successCount tables" -ForegroundColor Green
Write-Host "  Skipped:     $skipCount tables" -ForegroundColor DarkGray
Write-Host "  Failed:      $failCount tables" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Green" })
Write-Host "  Total Rows:  $totalRows" -ForegroundColor White
Write-Host "  Duration:    $($stopwatch.Elapsed.TotalSeconds.ToString('F1'))s" -ForegroundColor White
Write-Host ""

if ($failCount -gt 0) {
    Write-Host "  Some tables failed to import. Review errors above." -ForegroundColor Red
    Write-Host ""
    exit 1
}

Write-Host "  All user data imported successfully." -ForegroundColor Green
Write-Host ""
exit 0
