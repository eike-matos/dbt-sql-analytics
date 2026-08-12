"""
Unit tests for the extraction/validation layer.

These tests use temporary CSV files created on the fly (via pytest's
tmp_path fixture), so they never depend on the real Olist dataset being
present on disk - this keeps them fast and CI-friendly.
"""

import csv
from pathlib import Path

import pytest

from src.extract import (
    MissingDataFileError,
    _validate_single_file,
    validate_raw_files,
)
import src.config as config_module


@pytest.fixture
def sample_csv(tmp_path: Path) -> Path:
    """Create a small, valid CSV file with a known number of rows."""
    file_path = tmp_path / "sample.csv"
    with open(file_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["id", "name", "value"])
        writer.writerow(["1", "alpha", "10"])
        writer.writerow(["2", "beta", "20"])
        writer.writerow(["3", "gamma", "30"])
    return file_path


def test_validate_single_file_missing_raises_error(tmp_path, monkeypatch):
    """A missing file should raise MissingDataFileError, not a generic error."""
    monkeypatch.setattr(config_module, "DATA_DIR", tmp_path)

    with pytest.raises(MissingDataFileError):
        _validate_single_file("nonexistent", "does_not_exist.csv")

def test_validate_single_file_counts_rows_and_columns(sample_csv, monkeypatch):
    """Row and column counts should exactly match the source CSV."""
    import src.extract as extract_module

    monkeypatch.setattr(extract_module, "DATA_DIR", sample_csv.parent)

    result = _validate_single_file("sample", sample_csv.name)

    assert result.row_count == 3
    assert result.column_count == 3
    assert result.columns == ["id", "name", "value"]


def test_validate_raw_files_returns_result_per_key(sample_csv, monkeypatch):
    """validate_raw_files should key results by logical name, not filename."""
    monkeypatch.setattr(config_module, "DATA_DIR", sample_csv.parent)
    monkeypatch.setattr(
        config_module, "RAW_FILES", {"sample": sample_csv.name}
    )
    # extract.py imports DATA_DIR/RAW_FILES directly, so patch there too
    import src.extract as extract_module

    monkeypatch.setattr(extract_module, "DATA_DIR", sample_csv.parent)
    monkeypatch.setattr(extract_module, "RAW_FILES", {"sample": sample_csv.name})

    results = validate_raw_files()

    assert "sample" in results
    assert results["sample"].row_count == 3
