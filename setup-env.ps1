# setup-env.ps1 — TryVit .env Loader
#
# Reads .env (or a specified file) and exports variables into the current
# PowerShell session as environment variables. Optionally verifies
# Supabase and Redis connectivity, and displays masked variable values.
#
# USAGE (dot-source to make vars available in caller's session):
#   . .\setup-env.ps1                         # Load .env silently
#   . .\setup-env.ps1 -Verify                 # Load + test connectivity
#   . .\setup-env.ps1 -ShowValues             # Load + show masked values
#   . .\setup-env.ps1 -File .env.staging      # Load alternate file
#   . .\setup-env.ps1 -Verify -ShowValues     # Both checks
#
# NOTE: Never run without dot-sourcing (.) — plain execution won't
#       persist variables in the parent shell.

[CmdletBinding()]
param(
    [string]$File = ".env",
    [switch]$Verify,
    [switch]$ShowValues
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ─── Helpers ────────────────────────────────────────────────────────────────

function Mask-Secret {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return "(not set)" }
    if ($Value.Length -le 8) { return "***" }
    return $Value.Substring(0, 4) + "..." + $Value.Substring($Value.Length - 4)
}

function Write-Step {
    param([string]$Msg)
    Write-Host "  $Msg" -ForegroundColor Cyan
}

function Write-Ok {
    param([string]$Msg)
    Write-Host "  [OK] $Msg" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Msg)
    Write-Host "  [WARN] $Msg" -ForegroundColor Yellow
}

function Write-Fail {
    param([string]$Msg)
    Write-Host "  [FAIL] $Msg" -ForegroundColor Red
}

# ─── Locate file ────────────────────────────────────────────────────────────

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$EnvPath = Join-Path $ScriptDir $File

if (-not (Test-Path $EnvPath)) {
    Write-Fail "File not found: $EnvPath"
    Write-Host ""
    Write-Host "  Copy .env.example to .env and fill in values:" -ForegroundColor Gray
    Write-Host "    Copy-Item .env.example .env" -ForegroundColor Gray
    return
}

# ─── Parse and load ─────────────────────────────────────────────────────────

Write-Host ""
Write-Host "  TryVit — Environment Loader" -ForegroundColor Green
Write-Host "  File: $EnvPath" -ForegroundColor Gray
Write-Host ""

$loaded = 0
$skipped = 0
$loaded_keys = @()

foreach ($raw in (Get-Content $EnvPath)) {
    # Skip blanks and comments
    $line = $raw.Trim()
    if ($line -eq "" -or $line.StartsWith("#")) { continue }

    # Key=Value (first = only)
    $idx = $line.IndexOf("=")
    if ($idx -lt 1) { $skipped++; continue }

    $key = $line.Substring(0, $idx).Trim()
    $val = $line.Substring($idx + 1).Trim()

    # Strip surrounding quotes (single or double)
    if (($val.StartsWith('"') -and $val.EndsWith('"')) -or
        ($val.StartsWith("'") -and $val.EndsWith("'"))) {
        $val = $val.Substring(1, $val.Length - 2)
    }

    [System.Environment]::SetEnvironmentVariable($key, $val, "Process")
    $loaded_keys += $key
    $loaded++
}

Write-Step "Loaded $loaded variables ($skipped skipped)"

# ─── Show values ────────────────────────────────────────────────────────────

if ($ShowValues) {
    Write-Host ""
    Write-Host "  ── Loaded Variables ──────────────────────────────────" -ForegroundColor Gray

    # Non-secret keys shown in full; secrets masked
    $secret_patterns = @("KEY", "TOKEN", "SECRET", "PASSWORD", "PASS", "PRIVATE", "AUTH")

    foreach ($key in $loaded_keys | Sort-Object) {
        $val = [System.Environment]::GetEnvironmentVariable($key)
        $is_secret = $secret_patterns | Where-Object { $key.ToUpper().Contains($_) }

        $display = if ($is_secret) { Mask-Secret $val } else { if ($val) { $val } else { "(empty)" } }
        Write-Host ("  {0,-45} {1}" -f $key, $display) -ForegroundColor Gray
    }
    Write-Host ""
}

# ─── Connectivity verification ─────────────────────────────────────────────

if ($Verify) {
    Write-Host ""
    Write-Host "  ── Connectivity Checks ───────────────────────────────" -ForegroundColor Gray
    Write-Host ""

    $pass = 0
    $fail = 0

    # 1. Local Supabase (port 54322)
    Write-Step "Local Supabase (127.0.0.1:54322)..."
    try {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $tcp.Connect("127.0.0.1", 54322)
        $tcp.Close()
        Write-Ok "Local Supabase reachable"
        $pass++
    }
    catch {
        Write-Warn "Local Supabase not running — start with: supabase start"
        $fail++
    }

    # 2. Local Supabase Studio (port 54323)
    Write-Step "Local Supabase Studio (127.0.0.1:54323)..."
    try {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $tcp.Connect("127.0.0.1", 54323)
        $tcp.Close()
        Write-Ok "Studio reachable at http://127.0.0.1:54323"
        $pass++
    }
    catch {
        Write-Warn "Studio not reachable (check: supabase start)"
        $fail++
    }

    # 3. Remote Supabase (if SUPABASE_PROJECT_REF is set)
    $ref = [System.Environment]::GetEnvironmentVariable("SUPABASE_PROJECT_REF")
    if (-not [string]::IsNullOrWhiteSpace($ref)) {
        $host_url = "https://$ref.supabase.co/rest/v1/"
        Write-Step "Remote Supabase ($ref.supabase.co)..."
        try {
            $req = [System.Net.WebRequest]::Create($host_url)
            $req.Timeout = 5000
            $resp = $req.GetResponse()
            $resp.Close()
            Write-Ok "Remote Supabase reachable"
            $pass++
        }
        catch {
            # 400/401/404 are expected (no API key) — means host is reachable
            $code = [int]$_.Exception.Response.StatusCode
            if ($code -in @(400, 401, 403, 404)) {
                Write-Ok "Remote Supabase reachable (HTTP $code — expected without auth)"
                $pass++
            }
            else {
                Write-Warn "Remote Supabase unreachable ($($_.Exception.Message))"
                $fail++
            }
        }
    }
    else {
        Write-Warn "SUPABASE_PROJECT_REF not set — skipping remote Supabase check"
    }

    # 4. Upstash Redis (if set)
    $redisUrl = [System.Environment]::GetEnvironmentVariable("UPSTASH_REDIS_REST_URL")
    if (-not [string]::IsNullOrWhiteSpace($redisUrl)) {
        Write-Step "Upstash Redis ($redisUrl)..."
        try {
            $req = [System.Net.WebRequest]::Create($redisUrl + "/ping")
            $req.Timeout = 5000
            $resp = $req.GetResponse()
            $resp.Close()
            Write-Ok "Upstash Redis reachable"
            $pass++
        }
        catch {
            $code = [int]$_.Exception.Response.StatusCode
            if ($code -in @(401, 403)) {
                Write-Ok "Upstash Redis reachable (auth required — as expected)"
                $pass++
            }
            else {
                Write-Warn "Upstash Redis unreachable ($($_.Exception.Message))"
                $fail++
            }
        }
    }
    else {
        Write-Warn "UPSTASH_REDIS_REST_URL not set — skipping Redis check"
    }

    # 5. App URL (if set)
    $appUrl = [System.Environment]::GetEnvironmentVariable("NEXT_PUBLIC_APP_URL")
    if (-not [string]::IsNullOrWhiteSpace($appUrl)) {
        Write-Step "App URL ($appUrl)..."
        try {
            $req = [System.Net.WebRequest]::Create($appUrl)
            $req.Timeout = 8000
            $resp = $req.GetResponse()
            $resp.Close()
            Write-Ok "App URL reachable"
            $pass++
        }
        catch {
            $code = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { 0 }
            if ($code -gt 0) {
                Write-Ok "App URL reachable (HTTP $code)"
                $pass++
            }
            else {
                Write-Warn "App URL unreachable ($($_.Exception.Message))"
                $fail++
            }
        }
    }

    Write-Host ""
    $color = if ($fail -eq 0) { "Green" } else { "Yellow" }
    Write-Host ("  Checks: {0} passed, {1} failed/skipped" -f $pass, $fail) -ForegroundColor $color
}

Write-Host ""
Write-Host "  Done. Variables available in this session." -ForegroundColor Green
Write-Host ""
