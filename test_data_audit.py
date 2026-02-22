"""
Tests for run_data_audit.py
Verifies JSON report generation, severity classification, and exit code logic.
"""

import json
import os
import sys
import unittest
from unittest.mock import MagicMock, patch

# Add project root to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import run_data_audit


class TestGetEnv(unittest.TestCase):
    """Tests for get_env helper."""

    @patch.dict(os.environ, {"TEST_VAR": "test_value"})
    def test_returns_value_when_set(self):
        self.assertEqual(run_data_audit.get_env("TEST_VAR"), "test_value")

    @patch.dict(os.environ, {}, clear=True)
    def test_exits_when_missing(self):
        with self.assertRaises(SystemExit) as ctx:
            run_data_audit.get_env("NONEXISTENT_VAR")
        self.assertEqual(ctx.exception.code, 2)

    @patch.dict(os.environ, {"EMPTY_VAR": ""})
    def test_exits_when_empty(self):
        with self.assertRaises(SystemExit) as ctx:
            run_data_audit.get_env("EMPTY_VAR")
        self.assertEqual(ctx.exception.code, 2)


class TestSupabaseHeaders(unittest.TestCase):
    """Tests for supabase_headers."""

    def test_contains_required_headers(self):
        headers = run_data_audit.supabase_headers("test-key")
        self.assertEqual(headers["apikey"], "test-key")
        self.assertEqual(headers["Authorization"], "Bearer test-key")
        self.assertIn("Content-Type", headers)


class TestRunAudit(unittest.TestCase):
    """Tests for run_audit main function."""

    @patch("run_data_audit.requests")
    @patch.dict(
        os.environ,
        {
            "SUPABASE_URL": "https://test.supabase.co",
            "SUPABASE_SERVICE_KEY": "test-service-key",
        },
    )
    def test_exit_0_when_no_critical(self, mock_requests):
        """No critical findings -> exit code 0."""
        mock_resp = MagicMock()
        mock_resp.status_code = 200
        mock_resp.json.return_value = [
            {
                "check_name": "sparse_category",
                "severity": "info",
                "product_id": None,
                "product_name": None,
                "ean": None,
                "details": {"category": "test", "count": 1},
            }
        ]
        mock_store_resp = MagicMock()
        mock_store_resp.status_code = 201
        mock_requests.post.side_effect = [mock_resp, mock_store_resp]

        with self.assertRaises(SystemExit) as ctx:
            run_data_audit.run_audit()
        self.assertEqual(ctx.exception.code, 0)

    @patch("run_data_audit.requests")
    @patch.dict(
        os.environ,
        {
            "SUPABASE_URL": "https://test.supabase.co",
            "SUPABASE_SERVICE_KEY": "test-service-key",
        },
    )
    def test_exit_1_when_critical(self, mock_requests):
        """Critical findings -> exit code 1."""
        mock_resp = MagicMock()
        mock_resp.status_code = 200
        mock_resp.json.return_value = [
            {
                "check_name": "duplicate_ean",
                "severity": "critical",
                "product_id": 42,
                "product_name": "Test Product",
                "ean": "123456789",
                "details": {"count": 2},
            }
        ]
        mock_store_resp = MagicMock()
        mock_store_resp.status_code = 201
        mock_requests.post.side_effect = [mock_resp, mock_store_resp]

        with self.assertRaises(SystemExit) as ctx:
            run_data_audit.run_audit()
        self.assertEqual(ctx.exception.code, 1)

    @patch("run_data_audit.requests")
    @patch.dict(
        os.environ,
        {
            "SUPABASE_URL": "https://test.supabase.co",
            "SUPABASE_SERVICE_KEY": "test-service-key",
        },
    )
    def test_exit_0_when_empty_results(self, mock_requests):
        """Empty audit results -> exit code 0."""
        mock_resp = MagicMock()
        mock_resp.status_code = 200
        mock_resp.json.return_value = []
        mock_requests.post.return_value = mock_resp

        with self.assertRaises(SystemExit) as ctx:
            run_data_audit.run_audit()
        self.assertEqual(ctx.exception.code, 0)

    @patch("run_data_audit.requests")
    @patch.dict(
        os.environ,
        {
            "SUPABASE_URL": "https://test.supabase.co",
            "SUPABASE_SERVICE_KEY": "test-service-key",
        },
    )
    def test_generates_json_report(self, mock_requests):
        """Verifies JSON report file is created with correct structure."""
        mock_resp = MagicMock()
        mock_resp.status_code = 200
        mock_resp.json.return_value = [
            {
                "check_name": "missing_name",
                "severity": "critical",
                "product_id": 1,
                "product_name": None,
                "ean": "12345678",
                "details": {"product_name": None},
            },
            {
                "check_name": "sparse_category",
                "severity": "info",
                "product_id": None,
                "product_name": None,
                "ean": None,
                "details": {"category": "test", "count": 2},
            },
        ]
        mock_store_resp = MagicMock()
        mock_store_resp.status_code = 201
        mock_requests.post.side_effect = [mock_resp, mock_store_resp]

        with self.assertRaises(SystemExit):
            run_data_audit.run_audit()

        # Find the generated report
        report_files = [
            f for f in os.listdir("audit-reports") if f.startswith("audit_")
        ]
        self.assertTrue(len(report_files) > 0)

        with open(os.path.join("audit-reports", report_files[-1])) as f:
            report = json.load(f)

        self.assertIn("run_id", report)
        self.assertIn("timestamp", report)
        self.assertIn("summary", report)
        self.assertEqual(report["summary"]["total_findings"], 2)
        self.assertEqual(report["summary"]["critical"], 1)
        self.assertEqual(report["summary"]["info"], 1)
        self.assertIn("findings", report)
        self.assertEqual(len(report["findings"]), 2)

    @patch("run_data_audit.requests")
    @patch.dict(
        os.environ,
        {
            "SUPABASE_URL": "https://test.supabase.co",
            "SUPABASE_SERVICE_KEY": "test-service-key",
        },
    )
    def test_rpc_failure_exits_2(self, mock_requests):
        """RPC call failure -> exit code 2."""
        mock_resp = MagicMock()
        mock_resp.status_code = 500
        mock_resp.text = "Internal Server Error"
        mock_requests.post.return_value = mock_resp

        with self.assertRaises(SystemExit) as ctx:
            run_data_audit.run_audit()
        self.assertEqual(ctx.exception.code, 2)

    @patch("run_data_audit.requests")
    @patch.dict(
        os.environ,
        {
            "SUPABASE_URL": "https://test.supabase.co",
            "SUPABASE_SERVICE_KEY": "test-service-key",
        },
    )
    def test_severity_classification(self, mock_requests):
        """Verifies correct classification of findings by severity."""
        mock_resp = MagicMock()
        mock_resp.status_code = 200
        mock_resp.json.return_value = [
            {
                "check_name": "a",
                "severity": "critical",
                "product_id": 1,
                "product_name": "A",
                "ean": "1",
                "details": {},
            },
            {
                "check_name": "b",
                "severity": "warning",
                "product_id": 2,
                "product_name": "B",
                "ean": "2",
                "details": {},
            },
            {
                "check_name": "c",
                "severity": "warning",
                "product_id": 3,
                "product_name": "C",
                "ean": "3",
                "details": {},
            },
            {
                "check_name": "d",
                "severity": "info",
                "product_id": None,
                "product_name": None,
                "ean": None,
                "details": {},
            },
        ]
        mock_store_resp = MagicMock()
        mock_store_resp.status_code = 201
        mock_requests.post.side_effect = [mock_resp, mock_store_resp]

        with self.assertRaises(SystemExit):
            run_data_audit.run_audit()

        report_files = sorted(os.listdir("audit-reports"))
        with open(os.path.join("audit-reports", report_files[-1])) as f:
            report = json.load(f)

        self.assertEqual(report["summary"]["critical"], 1)
        self.assertEqual(report["summary"]["warnings"], 2)
        self.assertEqual(report["summary"]["info"], 1)
        self.assertEqual(report["summary"]["total_findings"], 4)

    @patch("run_data_audit.requests")
    @patch.dict(
        os.environ,
        {
            "SUPABASE_URL": "https://test.supabase.co",
            "SUPABASE_SERVICE_KEY": "test-service-key",
        },
    )
    def test_null_findings_handled(self, mock_requests):
        """null response from RPC is handled as empty list."""
        mock_resp = MagicMock()
        mock_resp.status_code = 200
        mock_resp.json.return_value = None
        mock_requests.post.return_value = mock_resp

        with self.assertRaises(SystemExit) as ctx:
            run_data_audit.run_audit()
        self.assertEqual(ctx.exception.code, 0)

    @patch("run_data_audit.requests")
    @patch.dict(
        os.environ,
        {
            "SUPABASE_URL": "https://test.supabase.co",
            "SUPABASE_SERVICE_KEY": "test-service-key",
        },
    )
    def test_store_failure_does_not_crash(self, mock_requests):
        """Storage failure logs warning but doesn't crash the audit."""
        mock_rpc_resp = MagicMock()
        mock_rpc_resp.status_code = 200
        mock_rpc_resp.json.return_value = [
            {
                "check_name": "test",
                "severity": "warning",
                "product_id": 1,
                "product_name": "X",
                "ean": "123",
                "details": {},
            }
        ]
        mock_store_resp = MagicMock()
        mock_store_resp.status_code = 500  # storage fails
        mock_requests.post.side_effect = [mock_rpc_resp, mock_store_resp]

        with self.assertRaises(SystemExit) as ctx:
            run_data_audit.run_audit()
        # Should still exit 0 (no critical findings), not crash
        self.assertEqual(ctx.exception.code, 0)


class TestRunAuditHelpers(unittest.TestCase):
    """Tests for helper formatting."""

    def test_unicode_product_name_in_report(self):
        """Unicode characters don't crash the JSON serialization."""
        report = {
            "findings": [{"check_name": "test", "product_name": "Żubrówka Biała"}]
        }
        result = json.dumps(report, indent=2, default=str, ensure_ascii=False)
        self.assertIn("Żubrówka", result)


if __name__ == "__main__":
    unittest.main()
