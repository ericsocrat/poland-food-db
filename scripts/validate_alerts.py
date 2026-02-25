"""Validate monitoring/alerts.yml — schema and field checks.

Exit 0 if valid, exit 1 if any errors found.
Uses only Python stdlib (yaml is safe_load from PyYAML — but we use the
built-in approach via a minimal parser to avoid needing PyYAML in CI).

Actually, PyYAML is the simplest approach and is pre-installed on GitHub
Actions runners. If not available, fall back to a basic check.
"""

from __future__ import annotations

import sys
from pathlib import Path

ALERTS_FILE = Path("monitoring/alerts.yml")
REQUIRED_FIELDS = {"name", "severity", "condition", "threshold", "channel", "ack_target_minutes", "escalation_policy"}
VALID_SEVERITIES = {"critical", "warning", "info"}
VALID_CHANNELS = {"page", "slack", "dashboard"}


def validate() -> list[str]:
    """Validate alerts.yml and return a list of error messages."""
    errors: list[str] = []

    if not ALERTS_FILE.exists():
        errors.append(f"File not found: {ALERTS_FILE}")
        return errors

    try:
        import yaml
    except ImportError:
        # Fallback: at minimum verify the file is readable and non-empty
        content = ALERTS_FILE.read_text(encoding="utf-8").strip()
        if not content:
            errors.append("alerts.yml is empty")
        if "alerts:" not in content:
            errors.append("alerts.yml missing top-level 'alerts:' key")
        return errors

    content = ALERTS_FILE.read_text(encoding="utf-8")
    try:
        data = yaml.safe_load(content)
    except yaml.YAMLError as exc:
        errors.append(f"YAML parse error: {exc}")
        return errors

    if not isinstance(data, dict):
        errors.append("Root must be a YAML mapping")
        return errors

    if "alerts" not in data:
        errors.append("Missing top-level 'alerts' key")
        return errors

    alerts = data["alerts"]
    if not isinstance(alerts, list):
        errors.append("'alerts' must be a list")
        return errors

    if len(alerts) == 0:
        errors.append("'alerts' list is empty — expected at least 1 alert")
        return errors

    names_seen: set[str] = set()

    for i, alert in enumerate(alerts):
        prefix = f"alerts[{i}]"

        if not isinstance(alert, dict):
            errors.append(f"{prefix}: expected mapping, got {type(alert).__name__}")
            continue

        # Check required fields
        for field in REQUIRED_FIELDS:
            if field not in alert:
                errors.append(f"{prefix}: missing required field '{field}'")

        # Validate name uniqueness
        name = alert.get("name")
        if name:
            if name in names_seen:
                errors.append(f"{prefix}: duplicate alert name '{name}'")
            names_seen.add(name)

        # Validate severity enum
        severity = alert.get("severity")
        if severity and severity not in VALID_SEVERITIES:
            errors.append(f"{prefix} ({name}): invalid severity '{severity}' — must be one of {VALID_SEVERITIES}")

        # Validate channel enum
        channel = alert.get("channel")
        if channel and channel not in VALID_CHANNELS:
            errors.append(f"{prefix} ({name}): invalid channel '{channel}' — must be one of {VALID_CHANNELS}")

        # Validate ack_target_minutes is a positive integer
        ack = alert.get("ack_target_minutes")
        if ack is not None and (not isinstance(ack, int) or ack <= 0):
            errors.append(f"{prefix} ({name}): ack_target_minutes must be a positive integer, got {ack}")

    return errors


def main() -> None:
    """Run validation and report results."""
    errors = validate()

    if errors:
        print(f"FAIL — {len(errors)} error(s) in {ALERTS_FILE}:\n")
        for err in errors:
            print(f"  ✗ {err}")
        sys.exit(1)
    else:
        alert_count = 0
        try:
            import yaml

            data = yaml.safe_load(ALERTS_FILE.read_text(encoding="utf-8"))
            alert_count = len(data.get("alerts", []))
        except ImportError:
            pass
        print(f"OK — {ALERTS_FILE} is valid ({alert_count} alerts)")
        sys.exit(0)


if __name__ == "__main__":
    main()
