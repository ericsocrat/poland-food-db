#!/usr/bin/env python3
"""
Data Integrity Audit Runner
Issue: #184 — [Hardening 2/7] Automated Data Integrity Audits (Nightly)

Connects to Supabase via REST API, runs the master audit function,
stores results in audit_results table, and generates a JSON report.

Exit code:
  0 = no critical findings
  1 = critical findings detected (requires review)

Environment variables:
  SUPABASE_URL         - Supabase project URL (required)
  SUPABASE_SERVICE_KEY - Service role key (required, bypasses RLS)
"""

import json
import os
import sys
import uuid
from datetime import datetime, timezone

import requests


def get_env(name: str) -> str:
    """Get required environment variable or exit."""
    value = os.environ.get(name)
    if not value:
        print(f"ERROR: {name} environment variable is required", file=sys.stderr)
        sys.exit(2)
    return value


def supabase_headers(service_key: str) -> dict:
    """Build headers for Supabase REST API."""
    return {
        "apikey": service_key,
        "Authorization": f"Bearer {service_key}",
        "Content-Type": "application/json",
        "Prefer": "return=minimal",
    }


def run_audit() -> None:
    """Execute the full data integrity audit."""
    url = get_env("SUPABASE_URL")
    key = get_env("SUPABASE_SERVICE_KEY")
    headers = supabase_headers(key)

    run_id = str(uuid.uuid4())
    timestamp = datetime.now(timezone.utc).isoformat()

    # ── Execute master audit via RPC ──────────────────────────────────────
    print(f"Connecting to {url.split('//')[1].split('.')[0]}...")
    rpc_url = f"{url}/rest/v1/rpc/run_full_data_audit"
    resp = requests.post(rpc_url, headers=headers, json={}, timeout=120)

    if resp.status_code != 200:
        print(f"ERROR: RPC call failed with status {resp.status_code}", file=sys.stderr)
        print(resp.text, file=sys.stderr)
        sys.exit(2)

    findings = resp.json() or []

    # ── Classify findings ─────────────────────────────────────────────────
    critical = [f for f in findings if f["severity"] == "critical"]
    warnings = [f for f in findings if f["severity"] == "warning"]
    infos = [f for f in findings if f["severity"] == "info"]

    # ── Store results in audit_results table ──────────────────────────────
    if findings:
        insert_url = f"{url}/rest/v1/audit_results"
        rows = [
            {
                "run_id": run_id,
                "run_timestamp": timestamp,
                "check_name": f["check_name"],
                "severity": f["severity"],
                "product_id": f.get("product_id"),
                "product_name": f.get("product_name"),
                "ean": f.get("ean"),
                "details": f.get("details"),
            }
            for f in findings
        ]
        store_resp = requests.post(insert_url, headers=headers, json=rows, timeout=60)
        if store_resp.status_code not in (200, 201):
            print(
                f"WARNING: Failed to store results (status {store_resp.status_code})",
                file=sys.stderr,
            )

    # ── Generate JSON report ──────────────────────────────────────────────
    report = {
        "run_id": run_id,
        "timestamp": timestamp,
        "summary": {
            "total_findings": len(findings),
            "critical": len(critical),
            "warnings": len(warnings),
            "info": len(infos),
        },
        "findings": findings,
    }

    os.makedirs("audit-reports", exist_ok=True)
    date_str = timestamp[:10]
    report_path = f"audit-reports/audit_{date_str}.json"
    with open(report_path, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2, default=str)

    # ── Print summary ─────────────────────────────────────────────────────
    sep = "=" * 60
    print(f"\n{sep}")
    print(f"DATA INTEGRITY AUDIT — {timestamp}")
    print(sep)
    print(f"Run ID: {run_id}")
    print(f"Total findings: {len(findings)}")
    print(f"  Critical: {len(critical)}")
    print(f"  Warning:  {len(warnings)}")
    print(f"  Info:     {len(infos)}")

    if critical:
        print(f"\n{'—' * 40}")
        print("CRITICAL FINDINGS:")
        for finding in critical[:20]:
            name = finding.get("product_name", "N/A")
            ean_val = finding.get("ean", "N/A")
            print(f"  * {finding['check_name']}: {name} (EAN: {ean_val})")
            print(f"    Details: {json.dumps(finding.get('details', {}), indent=4)}")

    print(f"\nReport saved to: {report_path}")

    # ── Exit code ─────────────────────────────────────────────────────────
    if critical:
        print(f"\n  {len(critical)} CRITICAL findings — review required!")
        sys.exit(1)
    else:
        print("\n  No critical findings.")
        sys.exit(0)


if __name__ == "__main__":
    run_audit()
