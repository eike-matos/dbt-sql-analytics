"""
Extraction layer: validates the presence and basic shape of the raw Olist
CSV files before they get loaded into Snowflake.

This module does not transform data - it only confirms the files exist,
are readable, and have the expected structure. Transformation logic lives
in dbt, not here.
"""

import csv
import logging
from dataclasses import dataclass
from pathlib import Path

from .config import DATA_DIR, RAW_FILES

logger = logging.getLogger(__name__)


@dataclass(frozen=True)
class FileValidationResult:
    key: str
    filename: str
    path: Path
    row_count: int
    column_count: int
    columns: list[str]


class MissingDataFileError(FileNotFoundError):
    """Raised when an expected raw CSV file is not found on disk."""


def _validate_single_file(key: str, filename: str) -> FileValidationResult:
    file_path = DATA_DIR / filename

    if not file_path.exists():
        raise MissingDataFileError(
            f"Expected file not found: {file_path}. "
            f"Download the Olist dataset and place the CSVs under {DATA_DIR}."
        )

    with open(file_path, newline="", encoding="utf-8") as f:
        reader = csv.reader(f)
        header = next(reader)
        row_count = sum(1 for _ in reader)

    return FileValidationResult(
        key=key,
        filename=filename,
        path=file_path,
        row_count=row_count,
        column_count=len(header),
        columns=header,
    )


def validate_raw_files() -> dict[str, FileValidationResult]:
    """
    Validate every file listed in RAW_FILES.

    Returns a dict keyed by the same logical names used in RAW_FILES
    (e.g. "customers", "orders"), so downstream code can look up results
    by name instead of by filename.
    """
    results: dict[str, FileValidationResult] = {}

    for key, filename in RAW_FILES.items():
        logger.info("Validating %s (%s)...", key, filename)
        result = _validate_single_file(key, filename)
        results[key] = result
        logger.info(
            "  -> %s rows, %s columns", result.row_count, result.column_count
        )

    return results


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format="%(message)s")
    validation_results = validate_raw_files()

    total_rows = sum(r.row_count for r in validation_results.values())
    print(f"\nAll {len(validation_results)} files validated successfully.")
    print(f"Total rows across all files: {total_rows:,}")
