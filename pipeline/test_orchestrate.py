"""Unit tests for pipeline.orchestrate — the data refresh orchestrator."""

from __future__ import annotations

import json
import subprocess
from pathlib import Path
from unittest import mock

import pytest

from pipeline.orchestrate import (
    DB_CONTAINER,
    PipelineOrchestrator,
    _psql_cmd,
)

# ─── _psql_cmd ───────────────────────────────────────────────────────────


class TestPsqlCmd:
    def test_docker_mode(self, monkeypatch: pytest.MonkeyPatch) -> None:
        """Without DATABASE_URL, uses docker exec."""
        monkeypatch.delenv("DATABASE_URL", raising=False)
        cmd = _psql_cmd("SELECT 1;")
        assert "docker" in cmd
        assert DB_CONTAINER in cmd
        assert "SELECT 1;" in cmd

    def test_direct_mode(self, monkeypatch: pytest.MonkeyPatch) -> None:
        """With DATABASE_URL, uses psql directly."""
        monkeypatch.setenv("DATABASE_URL", "postgresql://localhost/test")
        cmd = _psql_cmd("SELECT 1;")
        assert cmd[0] == "psql"
        assert "postgresql://localhost/test" in cmd
        assert "docker" not in cmd


# ─── PipelineOrchestrator.__init__ ────────────────────────────────────────


class TestOrchestratorInit:
    def test_default_categories(self) -> None:
        """All categories loaded when none specified."""
        orch = PipelineOrchestrator(country="PL", dry_run=True)
        assert len(orch.categories) > 0
        assert orch.country == "PL"
        assert orch.dry_run is True

    def test_custom_categories(self) -> None:
        """Only specified categories are used."""
        orch = PipelineOrchestrator(
            country="DE",
            categories=["Dairy", "Bread"],
            dry_run=True,
        )
        assert orch.categories == ["Dairy", "Bread"]
        assert orch.country == "DE"

    def test_unknown_category_raises(self) -> None:
        """Unknown category names raise ValueError."""
        with pytest.raises(ValueError, match="Unknown categories"):
            PipelineOrchestrator(
                country="PL",
                categories=["NonexistentCategory"],
            )

    def test_country_uppercase(self) -> None:
        """Country is normalized to uppercase."""
        orch = PipelineOrchestrator(country="pl", dry_run=True)
        assert orch.country == "PL"


# ─── PipelineOrchestrator.run_category ────────────────────────────────────


class TestRunCategory:
    @mock.patch("pipeline.orchestrate._run_psql", return_value="0")
    @mock.patch("pipeline.orchestrate.run_pipeline")
    def test_dry_run_skips_execution(
        self,
        mock_run_pipeline: mock.MagicMock,
        mock_psql: mock.MagicMock,
    ) -> None:
        """In dry-run mode, pipeline runs but SQL is not executed."""
        orch = PipelineOrchestrator(
            country="PL",
            categories=["Dairy"],
            dry_run=True,
        )
        result = orch.run_category("Dairy")
        assert result["status"] == "dry_run"
        mock_run_pipeline.assert_called_once()
        call_kwargs = mock_run_pipeline.call_args
        # dry_run should be passed through
        assert call_kwargs.kwargs.get("dry_run") is True or call_kwargs[1].get("dry_run") is True

    @mock.patch("pipeline.orchestrate._run_psql", return_value="0")
    @mock.patch("pipeline.orchestrate.run_pipeline", side_effect=Exception("API error"))
    def test_category_error_captured(
        self,
        mock_run_pipeline: mock.MagicMock,
        mock_psql: mock.MagicMock,
    ) -> None:
        """Category errors are captured, not raised."""
        orch = PipelineOrchestrator(
            country="PL",
            categories=["Dairy"],
            dry_run=False,
        )
        result = orch.run_category("Dairy")
        assert result["status"] == "error"
        assert "API error" in result["error"]
        assert len(orch._report["errors"]) == 1

    @mock.patch("pipeline.orchestrate._run_psql", return_value="0")
    def test_stale_only_skips_fresh(
        self,
        mock_psql: mock.MagicMock,
    ) -> None:
        """Stale-only mode skips categories with no stale products."""
        orch = PipelineOrchestrator(
            country="PL",
            categories=["Dairy"],
            stale_only=True,
        )
        result = orch.run_category("Dairy")
        assert result["status"] == "skipped"
        assert result["stale_count"] == 0


# ─── PipelineOrchestrator.run_all ─────────────────────────────────────────


class TestRunAll:
    @mock.patch("pipeline.orchestrate.run_pipeline")
    def test_run_all_dry_run(
        self,
        mock_run_pipeline: mock.MagicMock,
    ) -> None:
        """run_all in dry-run mode processes all categories."""
        orch = PipelineOrchestrator(
            country="PL",
            categories=["Dairy", "Bread"],
            dry_run=True,
        )
        report = orch.run_all()
        assert report["categories_processed"] == 2
        assert report["dry_run"] is True
        assert isinstance(report["duration_seconds"], float)
        assert mock_run_pipeline.call_count == 2

    @mock.patch("pipeline.orchestrate.run_pipeline")
    def test_report_written(
        self,
        mock_run_pipeline: mock.MagicMock,
        tmp_path: Path,
    ) -> None:
        """Execution report is written to disk."""
        orch = PipelineOrchestrator(
            country="PL",
            categories=["Dairy"],
            dry_run=True,
        )
        # Patch REPORTS_DIR to use tmp_path
        with mock.patch("pipeline.orchestrate.REPORTS_DIR", tmp_path):
            orch.run_all()

        report_files = list(tmp_path.glob("refresh_PL_*.json"))
        assert len(report_files) == 1

        data = json.loads(report_files[0].read_text())
        assert data["country"] == "PL"
        assert data["dry_run"] is True


# ─── _detect_stale_products ───────────────────────────────────────────────


class TestDetectStale:
    @mock.patch("pipeline.orchestrate._run_psql", return_value="15")
    def test_returns_count(self, mock_psql: mock.MagicMock) -> None:
        orch = PipelineOrchestrator(country="PL", categories=["Dairy"], dry_run=True)
        count = orch._detect_stale_products("Dairy")
        assert count == 15
        # Verify query contains category and country
        call_arg = mock_psql.call_args[0][0]
        assert "Dairy" in call_arg
        assert "PL" in call_arg

    @mock.patch(
        "pipeline.orchestrate._run_psql",
        side_effect=subprocess.CalledProcessError(1, "psql"),
    )
    def test_error_returns_zero(self, mock_psql: mock.MagicMock) -> None:
        orch = PipelineOrchestrator(country="PL", categories=["Dairy"], dry_run=True)
        count = orch._detect_stale_products("Dairy")
        assert count == 0


# ─── _execute_sql_files ───────────────────────────────────────────────────


class TestExecuteSqlFiles:
    def test_nonexistent_directory(self, tmp_path: Path) -> None:
        orch = PipelineOrchestrator(country="PL", categories=["Dairy"], dry_run=True)
        count = orch._execute_sql_files(tmp_path / "no-such-dir")
        assert count == 0

    @mock.patch("pipeline.orchestrate._execute_sql_file")
    def test_executes_in_order(
        self,
        mock_exec: mock.MagicMock,
        tmp_path: Path,
    ) -> None:
        # Create mock SQL files
        (tmp_path / "PIPELINE__test__01_insert.sql").write_text("SELECT 1;")
        (tmp_path / "PIPELINE__test__03_nutrition.sql").write_text("SELECT 2;")
        (tmp_path / "PIPELINE__test__04_scoring.sql").write_text("SELECT 3;")
        (tmp_path / "other_file.sql").write_text("SKIP")

        orch = PipelineOrchestrator(country="PL", categories=["Dairy"], dry_run=True)
        count = orch._execute_sql_files(tmp_path)
        assert count == 3
        assert mock_exec.call_count == 3
        # Verify sorted order
        called_names = [Path(c.args[0]).name for c in mock_exec.call_args_list]
        assert called_names == sorted(called_names)
