<#
.SYNOPSIS
    Runs the sanity check pack against any environment (local, staging, production).

.DESCRIPTION
    Executes 17 cross-environment validation checks.
    Checks 1–16 are SQL queries from supabase/sanity/sanity_checks.sql.
    Check 17 is a filesystem check verifying BACKUP.ps1 exists and is syntactically valid.
    All SQL checks are READ-ONLY SELECT queries — safe to run against production at any time
    (§8.1A single-cloud guardrail compliance).
        1.  Required tables exist
        2.  Required views exist
        3.  Required functions exist
        4.  Reference data populated
        5.  Product row count threshold (>= 1000)
        6.  EAN uniqueness — no duplicate active EANs
        7.  Country scoping integrity
        8.  Category integrity
        9.  Deprecated product logic
        10. Scoring coverage
        11. Nutri-Score coverage
        12. Nutrition facts completeness
        13. Health profile invariant (one active per user)
        14. RLS enabled on core tables
        15. Materialized views populated
        16. Foreign key constraints validated
        17. BACKUP.ps1 exists and is syntactically valid

    Each check returns 0 rows on success. Any rows indicate failures.

.PARAMETER Env
    Target environment: local, staging, or production.

.PARAMETER Json
    Output results as machine-readable JSON instead of colored text.

.PARAMETER OutFile
    Write JSON output to this file path (implies -Json).

.NOTES
    Prerequisites:
        - Local:      Docker Desktop + Supabase running
        - Staging:    psql on PATH + SUPABASE_STAGING_DB_PASSWORD
        - Production: psql on PATH + SUPABASE_DB_PASSWORD

    Usage:
        .\RUN_SANITY.ps1 -Env local
        .\RUN_SANITY.ps1 -Env staging
        .\RUN_SANITY.ps1 -Env production
        .\RUN_SANITY.ps1 -Env local -Json -OutFile sanity.json
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, HelpMessage = "Target environment: local, staging, or production.")]
    [ValidateSet("local", "staging", "production")]
    [string]$Env,

    [Parameter(HelpMessage = "Output results as JSON.")]
    [switch]$Json,

    [Parameter(HelpMessage = "Write JSON output to this file path (implies -Json).")]
    [string]$OutFile
)

if ($OutFile) { $Json = $true }

# ─── Configuration ───────────────────────────────────────────────────────────

$PRODUCTION_PROJECT_REF = "uskvezwftkkudvksmken"
$POOLER_HOST = "aws-1-eu-west-1.pooler.supabase.com"
$DOCKER_CONTAINER = "supabase_db_poland-food-db"
$DB_NAME = "postgres"
$DB_USER = "postgres"
$DB_PORT = "5432"

$SANITY_FILE = Join-Path $PSScriptRoot "supabase" "sanity" "sanity_checks.sql"

if (-not (Test-Path $SANITY_FILE)) {
    Write-Host "ERROR: Sanity check file not found: $SANITY_FILE" -ForegroundColor Red
    exit 1
}

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

$usePsql = $false

# CI mode: if PGHOST is set, use psql directly regardless of -Env value
$ciMode = [bool]$env:PGHOST

switch ($Env) {
    "local" {
        if ($ciMode) {
            $envLabel = "CI (psql via PGHOST=$($env:PGHOST))"
            $envColor = "Cyan"
            $usePsql = $true
        }
        else {
            $envLabel = "LOCAL (Docker)"
            $envColor = "Green"
        }
    }
    "staging" {
        $stagingRef = [System.Environment]::GetEnvironmentVariable("SUPABASE_STAGING_PROJECT_REF")
        if (-not $stagingRef) {
            Write-Host "ERROR: SUPABASE_STAGING_PROJECT_REF not set." -ForegroundColor Red
            exit 1
        }
        $dbHost = $POOLER_HOST
        $DB_USER = "postgres.$stagingRef"
        $dbPassword = [System.Environment]::GetEnvironmentVariable("SUPABASE_STAGING_DB_PASSWORD")
        $envLabel = "STAGING ($stagingRef)"
        $envColor = "Yellow"
        $usePsql = $true
    }
    "production" {
        $dbHost = $POOLER_HOST
        $DB_USER = "postgres.$PRODUCTION_PROJECT_REF"
        $dbPassword = [System.Environment]::GetEnvironmentVariable("SUPABASE_DB_PASSWORD")
        $envLabel = "PRODUCTION ($PRODUCTION_PROJECT_REF)"
        $envColor = "Red"
        $usePsql = $true
    }
}

# ─── Banner ──────────────────────────────────────────────────────────────────

if (-not $Json) {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor $envColor
    Write-Host "  Poland Food DB — Sanity Check Pack" -ForegroundColor Cyan
    Write-Host "  Target: $envLabel" -ForegroundColor $envColor
    Write-Host "================================================" -ForegroundColor $envColor
    Write-Host ""
}

# ─── Connect ─────────────────────────────────────────────────────────────────

if ($usePsql) {
    $psqlCmd = Get-Command psql -ErrorAction SilentlyContinue
    if (-not $psqlCmd) {
        Write-Host "ERROR: psql not found on PATH." -ForegroundColor Red
        exit 1
    }
    # In CI mode, PGPASSWORD env var handles authentication — no prompt needed
    if (-not $ciMode -and -not $dbPassword) {
        Write-Host "Enter the database password for $envLabel :" -ForegroundColor Yellow
        $securePassword = Read-Host -AsSecureString
        $dbPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
        )
    }
}
else {
    $dockerCmd = Get-Command docker -ErrorAction SilentlyContinue
    if (-not $dockerCmd) {
        Write-Host "ERROR: docker not found on PATH." -ForegroundColor Red
        exit 1
    }
}

# ─── Parse sanity check file into individual checks ─────────────────────────

$fileContent = Get-Content $SANITY_FILE -Raw
# Split on check headers (-- CHECK N: ...)
$checkBlocks = [regex]::Split($fileContent, '(?=-- ═{5,}\s*\r?\n-- CHECK \d+:)')
$checkBlocks = $checkBlocks | Where-Object { $_ -match '-- CHECK \d+:' }

$checks = @()
foreach ($block in $checkBlocks) {
    if ($block -match '-- CHECK (\d+):\s*(.+)') {
        $checks += @{
            Number = [int]$Matches[1]
            Name   = $Matches[2].Trim()
            SQL    = $block.Trim()
        }
    }
}

if ($checks.Count -eq 0) {
    Write-Host "ERROR: No checks parsed from $SANITY_FILE" -ForegroundColor Red
    exit 1
}

# ─── Execute checks ─────────────────────────────────────────────────────────

$results = @()
$passCount = 0
$failCount = 0
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

foreach ($check in $checks) {
    $checkTimer = [System.Diagnostics.Stopwatch]::StartNew()

    if ($usePsql) {
        if ($ciMode) {
            # CI mode: rely on PGHOST/PGPORT/PGUSER/PGPASSWORD/PGDATABASE env vars
            $output = $check.SQL | & psql --tuples-only --no-align -v ON_ERROR_STOP=1 2>&1
        }
        else {
            $env:PGPASSWORD = $dbPassword
            $output = $check.SQL | & psql -h $dbHost -p $DB_PORT -U $DB_USER -d $DB_NAME --tuples-only --no-align -v ON_ERROR_STOP=1 2>&1
        }
    }
    else {
        $output = $check.SQL | docker exec -i $DOCKER_CONTAINER psql -U $DB_USER -d $DB_NAME --tuples-only --no-align -v ON_ERROR_STOP=1 2>&1
    }

    $checkTimer.Stop()
    $exitCode = $LASTEXITCODE

    # Parse output: non-empty output (excluding blank lines) = failure
    $outputLines = ($output -join "`n").Trim()
    $hasFailures = ($exitCode -ne 0) -or ($outputLines.Length -gt 0 -and $outputLines -ne "")

    $status = if ($hasFailures) { "FAIL" } else { "PASS" }

    if ($hasFailures) { $failCount++ } else { $passCount++ }

    if (-not $Json) {
        $icon = if ($hasFailures) { "✗" } else { "✓" }
        $color = if ($hasFailures) { "Red" } else { "Green" }
        $ms = $checkTimer.ElapsedMilliseconds
        Write-Host "  $icon  Check $($check.Number): $($check.Name) ($($ms)ms)" -ForegroundColor $color

        if ($hasFailures -and $outputLines.Length -gt 0) {
            $outputLines -split "`n" | Select-Object -First 5 | ForEach-Object {
                Write-Host "       $_" -ForegroundColor DarkRed
            }
        }
    }

    $results += @{
        check      = $check.Number
        name       = $check.Name
        status     = $status
        runtime_ms = $checkTimer.ElapsedMilliseconds
        violations = if ($hasFailures -and $outputLines.Length -gt 0) {
            ($outputLines -split "`n" | Select-Object -First 10)
        }
        else { @() }
    }
}

# ─── Check 17: BACKUP.ps1 exists and is syntactically valid (filesystem) ────

$check17Timer = [System.Diagnostics.Stopwatch]::StartNew()
$backupScript = Join-Path $PSScriptRoot "BACKUP.ps1"
$check17Violations = @()

if (-not (Test-Path $backupScript)) {
    $check17Violations += "BACKUP.ps1 not found at $backupScript"
}
else {
    # Validate PowerShell syntax by parsing the script
    $parseErrors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($backupScript, [ref]$null, [ref]$parseErrors) | Out-Null
    if ($parseErrors.Count -gt 0) {
        foreach ($err in $parseErrors) {
            $check17Violations += "Syntax error: $($err.Message) (line $($err.Extent.StartLineNumber))"
        }
    }
}

$check17Timer.Stop()
$check17Status = if ($check17Violations.Count -gt 0) { "FAIL" } else { "PASS" }
if ($check17Violations.Count -gt 0) { $failCount++ } else { $passCount++ }

if (-not $Json) {
    $icon = if ($check17Violations.Count -gt 0) { "✗" } else { "✓" }
    $color = if ($check17Violations.Count -gt 0) { "Red" } else { "Green" }
    Write-Host "  $icon  Check 17: BACKUP.ps1 exists and is syntactically valid ($($check17Timer.ElapsedMilliseconds)ms)" -ForegroundColor $color
    if ($check17Violations.Count -gt 0) {
        $check17Violations | ForEach-Object { Write-Host "       $_" -ForegroundColor DarkRed }
    }
}

$results += @{
    check      = 17
    name       = "BACKUP.ps1 exists and is syntactically valid"
    status     = $check17Status
    runtime_ms = $check17Timer.ElapsedMilliseconds
    violations = $check17Violations
}

$stopwatch.Stop()

# ─── Cleanup ─────────────────────────────────────────────────────────────────

if ($usePsql) {
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}

# ─── Output ──────────────────────────────────────────────────────────────────

$overall = if ($failCount -eq 0) { "pass" } else { "fail" }

if ($Json) {
    $jsonResult = @{
        timestamp   = (Get-Date -Format "o")
        environment = $Env
        target      = $envLabel
        checks      = $results
        summary     = @{
            total  = $checks.Count + 1
            passed = $passCount
            failed = $failCount
        }
        overall     = $overall
        runtime_ms  = $stopwatch.ElapsedMilliseconds
    }
    $jsonString = $jsonResult | ConvertTo-Json -Depth 5
    if ($OutFile) {
        $jsonString | Set-Content -Path $OutFile -Encoding UTF8
        Write-Host "Results written to: $OutFile"
    }
    else {
        Write-Output $jsonString
    }
}
else {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "  Sanity Check Summary" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "  Environment: $envLabel" -ForegroundColor $envColor
    Write-Host "  Checks:      $($checks.Count + 1)" -ForegroundColor White
    Write-Host "  Passed:      $passCount" -ForegroundColor Green
    Write-Host "  Failed:      $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Green" })
    Write-Host "  Duration:    $($stopwatch.Elapsed.TotalSeconds.ToString('F1'))s" -ForegroundColor White
    Write-Host "  Overall:     $($overall.ToUpper())" -ForegroundColor $(if ($overall -eq "pass") { "Green" } else { "Red" })
    Write-Host ""
}

if ($failCount -gt 0) { exit 1 }
exit 0
