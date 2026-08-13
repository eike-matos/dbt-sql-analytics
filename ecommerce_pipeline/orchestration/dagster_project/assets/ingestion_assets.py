"""
Dagster assets for the ingestion layer.

Wraps the existing Python ingestion pipeline (extract + load_to_snowflake)
as a multi_asset with one output per raw table. Each output's AssetKey
matches the AssetKey dagster-dbt generates by default for the corresponding
dbt source, so the ingestion step is a real upstream node connected to
every staging model that reads from it - not a disconnected node.
"""

import sys
from pathlib import Path

from dagster import AssetExecutionContext, AssetKey, AssetOut, MaterializeResult, multi_asset

INGESTION_SRC = Path(__file__).resolve().parents[3] / "ingestion"

RAW_TABLE_KEYS = {
    "customers": "raw_customers",
    "geolocation": "raw_geolocation",
    "order_items": "raw_order_items",
    "order_payments": "raw_order_payments",
    "order_reviews": "raw_order_reviews",
    "orders": "raw_orders",
    "products": "raw_products",
    "sellers": "raw_sellers",
    "product_category_translation": "raw_product_category_translation",
}

_outs = {
    key: AssetOut(key=AssetKey(["raw", table_name]))
    for key, table_name in RAW_TABLE_KEYS.items()
}


@multi_asset(
    outs=_outs,
    group_name="ingestion",
    description="Uploads Olist CSV files to the Snowflake internal stage "
    "and loads them into RAW tables, one output per table.",
)
def raw_ecommerce_data(context: AssetExecutionContext):
    # Inserted here (not just at module import time) so it's guaranteed to
    # run in whichever process actually executes this step, since Dagster
    # may run steps in a different process than the one that loaded the
    # asset definitions.
    ingestion_src_str = str(INGESTION_SRC)
    if ingestion_src_str not in sys.path:
        sys.path.insert(0, ingestion_src_str)

    from src.extract import validate_raw_files
    from src.load_to_snowflake import load_all

    context.log.info("Validating raw files...")
    validation_results = validate_raw_files()
    total_rows_source = sum(r.row_count for r in validation_results.values())
    context.log.info(f"Validated {len(validation_results)} files, {total_rows_source:,} rows.")

    context.log.info("Loading into Snowflake...")
    load_results = load_all()

    for key, row_count in load_results.items():
        yield MaterializeResult(
            asset_key=AssetKey(["raw", RAW_TABLE_KEYS[key]]),
            metadata={"row_count": row_count},
        )
