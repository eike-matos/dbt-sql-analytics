"""
Load layer: uploads raw CSV files into the Snowflake internal stage and
copies them into RAW tables.

Design decisions:
- RAW tables use VARCHAR for every column. Type casting and cleaning
  happen later in dbt staging models, not here. This keeps the ingestion
  layer simple and resilient to source data quirks (e.g. malformed
  numbers, inconsistent date formats).
- Tables are created with CREATE OR REPLACE, so re-running ingestion is
  idempotent - safe to run multiple times without manual cleanup.
"""

import csv
import logging
from pathlib import Path

import snowflake.connector

from .config import DATA_DIR, RAW_FILES, load_snowflake_config

logger = logging.getLogger(__name__)

STAGE_NAME = "RAW_STAGE"
FILE_FORMAT_NAME = "CSV_FORMAT"


def _get_connection():
    config = load_snowflake_config()
    return snowflake.connector.connect(
        account=config.account_identifier,
        user=config.user,
        password=config.password,
        role=config.role,
        warehouse=config.warehouse,
        database=config.database,
        schema=config.schema,
    )

def _read_header(file_path: Path) -> list[str]:
    with open(file_path, newline="", encoding="utf-8-sig") as f:
        return next(csv.reader(f))

def _create_raw_table(cursor, table_name: str, columns: list[str]) -> None:
    column_defs = ", ".join(f'"{col.upper()}" VARCHAR' for col in columns)
    ddl = f'CREATE OR REPLACE TABLE "{table_name}" ({column_defs})'
    logger.info("Creating table %s (%s columns)", table_name, len(columns))
    cursor.execute(ddl)


def _upload_and_copy(cursor, key: str, filename: str) -> int:
    file_path = DATA_DIR / filename
    table_name = f"RAW_{key.upper()}"

    columns = _read_header(file_path)
    _create_raw_table(cursor, table_name, columns)

    logger.info("Uploading %s to stage @%s...", filename, STAGE_NAME)
    cursor.execute(
        f"PUT file://{file_path} @{STAGE_NAME} AUTO_COMPRESS=TRUE OVERWRITE=TRUE"
    )

    logger.info("Copying %s into %s...", filename, table_name)
    cursor.execute(
        f'COPY INTO "{table_name}" '
        f"FROM @{STAGE_NAME}/{file_path.name}.gz "
        f"FILE_FORMAT = (FORMAT_NAME = '{FILE_FORMAT_NAME}') "
        f"ON_ERROR = 'ABORT_STATEMENT'"
    )

    cursor.execute(f'SELECT COUNT(*) FROM "{table_name}"')
    row_count = cursor.fetchone()[0]
    logger.info("  -> %s rows loaded into %s", row_count, table_name)
    return row_count


def load_all() -> dict[str, int]:
    """Upload every file in RAW_FILES and load it into its RAW table."""
    conn = _get_connection()
    results: dict[str, int] = {}

    try:
        cursor = conn.cursor()
        for key, filename in RAW_FILES.items():
            results[key] = _upload_and_copy(cursor, key, filename)
    finally:
        conn.close()

    return results


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format="%(message)s")
    load_results = load_all()

    total_rows = sum(load_results.values())
    print(f"\nLoaded {len(load_results)} tables into Snowflake.")
    print(f"Total rows loaded: {total_rows:,}")
