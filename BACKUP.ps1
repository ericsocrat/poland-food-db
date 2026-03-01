<#
.SYNOPSIS
    Creates a pg_dump backup of the Poland Food DB (local or remote).

.DESCRIPTION
    Produces a compressed custom-format backup (.dump) using pg_dump.
    The file is written to backups/ with an ISO-8601 timestamp in the filename.

    Connection details are read from environment variables — never hardcoded.
    The script validates connectivity before starting the dump and prints
    backup size and key table row counts on success.

    Exit codes:
        0  Success
        1  Failure (connection error, pg_dump error, missing tools)

.PARAMETER Env
    Target environment: local or remote.
    - local:  uses the local Docker Supabase instance (port 54322)
    - remote: uses $env:SUPABASE_DB_PASSWORD + pooler host

.NOTES
    Prerequisites:
        - pg_dump available on PATH
        - Local:  Docker Desktop + Supabase running (supabase start)
        - Remote: SUPABASE_DB_PASSWORD environment variable set

    Usage:
        .\BACKUP.ps1 -Env local
        .\BACKUP.ps1 -Env remote
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

$BACKUP_DIR = Join-Path $PSScriptRoot "backups"
$TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"
$BACKUP_FILE = Join-Path $BACKUP_DIR "cloud_backup_${TIMESTAMP}.dump"

# Key tables to report row counts for
$KEY_TABLES = @(
    "products",
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
Write-Host "  Poland Food DB — Backup" -ForegroundColor Cyan
Write-Host "  Environment: $($Env.ToUpper())" -ForegroundColor $(if ($Env -eq "remote") { "Red" } else { "Green" })
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# ─── Preflight ───────────────────────────────────────────────────────────────

# Check pg_dump is available
$pgDumpCmd = Get-Command pg_dump -ErrorAction SilentlyContinue
if (-not $pgDumpCmd) {
    Write-Host "ERROR: pg_dump not found on PATH." -ForegroundColor Red
    Write-Host "Install PostgreSQL client tools or add pg_dump to your PATH." -ForegroundColor Yellow
    exit 1
}

# Check psql is available (for connectivity test and row counts)
$psqlCmd = Get-Command psql -ErrorAction SilentlyContinue
if (-not $psqlCmd) {
    Write-Host "ERROR: psql not found on PATH." -ForegroundColor Red
    Write-Host "Install PostgreSQL client tools or add psql to your PATH." -ForegroundColor Yellow
    exit 1
}

# Ensure backup directory exists
if (-not (Test-Path $BACKUP_DIR)) {
    New-Item -ItemType Directory -Path $BACKUP_DIR -Force | Out-Null
    Write-Host "Created backup directory: $BACKUP_DIR" -ForegroundColor DarkGray
}

# ─── Environment-specific connection ─────────────────────────────────────────

switch ($Env) {
    "local" {
        $dbHost = $LOCAL_HOST
        $dbPort = $LOCAL_PORT
        $dbUser = $LOCAL_USER
        $dbPassword = $LOCAL_PASSWORD
        Write-Host "  Host: $dbHost`:$dbPort (Docker)" -ForegroundColor Green
    }
    "remote" {
        $dbHost = $REMOTE_HOST
        $dbPort = $REMOTE_PORT
        $dbUser = $REMOTE_USER

        if ($env:SUPABASE_DB_PASSWORD) {
            $dbPassword = $env:SUPABASE_DB_PASSWORD
            Write-Host "  Using password from SUPABASE_DB_PASSWORD env var." -ForegroundColor Green
        }
        else {
            Write-Host "Enter the remote database password:" -ForegroundColor Yellow
            $securePassword = Read-Host -AsSecureString
            $dbPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
            )
        }
        Write-Host "  Host: $dbHost`:$dbPort" -ForegroundColor Yellow
    }
}

Write-Host "  Database: $DB_NAME" -ForegroundColor White
Write-Host "  Output:   $BACKUP_FILE" -ForegroundColor White
Write-Host ""

# ─── Connectivity Test ───────────────────────────────────────────────────────

Write-Host "Testing database connection..." -ForegroundColor Yellow
$env:PGPASSWORD = $dbPassword
try {
    $testResult = & psql -h $dbHost -p $dbPort -U $dbUser -d $DB_NAME -c "SELECT 1;" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Cannot connect to database." -ForegroundColor Red
        Write-Host "Check your password and connection settings." -ForegroundColor Yellow
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

# ─── Row Counts (pre-backup) ────────────────────────────────────────────────

Write-Host ""
Write-Host "Pre-backup row counts:" -ForegroundColor Cyan

$rowCountQuery = @"
SELECT t.table_name,
       (xpath('//cnt/text()', xml_count))[1]::text::bigint AS row_count
FROM (
    VALUES $(($KEY_TABLES | ForEach-Object { "('$_')" }) -join ", ")
) AS t(table_name)
LEFT JOIN LATERAL (
    SELECT query_to_xml('SELECT COUNT(*) AS cnt FROM public.' || t.table_name, false, false, '')
) AS x(xml_count) ON true
ORDER BY t.table_name;
"@

$env:PGPASSWORD = $dbPassword
$rowCountOutput = $rowCountQuery | & psql -h $dbHost -p $dbPort -U $dbUser -d $DB_NAME --tuples-only --no-align -F "|" 2>&1
if ($LASTEXITCODE -eq 0) {
    $rowCountOutput -split "`n" | Where-Object { $_.Trim() -ne "" } | ForEach-Object {
        $parts = $_ -split "\|"
        if ($parts.Length -ge 2) {
            $tbl = $parts[0].Trim()
            $cnt = $parts[1].Trim()
            Write-Host "  $($tbl.PadRight(30)) $cnt rows" -ForegroundColor White
        }
    }
}
else {
    Write-Host "  WARNING: Could not retrieve row counts." -ForegroundColor DarkYellow
}

# ─── Execute pg_dump ─────────────────────────────────────────────────────────

Write-Host ""
Write-Host "Running pg_dump..." -ForegroundColor Yellow

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

$env:PGPASSWORD = $dbPassword
& pg_dump -h $dbHost -p $dbPort -U $dbUser -d $DB_NAME `
    --format=custom `
    --no-owner `
    --no-privileges `
    --file=$BACKUP_FILE `
    2>&1 | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }

$dumpExitCode = $LASTEXITCODE
$stopwatch.Stop()

# ─── Cleanup ────────────────────────────────────────────────────────────────

Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue

# ─── Result ──────────────────────────────────────────────────────────────────

Write-Host ""

if ($dumpExitCode -ne 0) {
    Write-Host "ERROR: pg_dump failed (exit code $dumpExitCode)." -ForegroundColor Red
    Write-Host "Check the error output above." -ForegroundColor Yellow
    # Remove potentially corrupt dump file
    if (Test-Path $BACKUP_FILE) {
        Remove-Item $BACKUP_FILE -Force
        Write-Host "Removed incomplete backup file." -ForegroundColor DarkGray
    }
    exit 1
}

if (-not (Test-Path $BACKUP_FILE)) {
    Write-Host "ERROR: Backup file was not created." -ForegroundColor Red
    exit 1
}

$fileInfo = Get-Item $BACKUP_FILE
$sizeMB = [math]::Round($fileInfo.Length / 1MB, 2)

Write-Host "================================================" -ForegroundColor Green
Write-Host "  Backup Complete" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host "  File:     $($fileInfo.Name)" -ForegroundColor White
Write-Host "  Size:     $sizeMB MB" -ForegroundColor White
Write-Host "  Duration: $($stopwatch.Elapsed.TotalSeconds.ToString('F1'))s" -ForegroundColor White
Write-Host "  Path:     $($fileInfo.FullName)" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Restore with:" -ForegroundColor Cyan
Write-Host "    pg_restore --no-owner --no-privileges -d <database> $($fileInfo.Name)" -ForegroundColor White
Write-Host ""

exit 0
