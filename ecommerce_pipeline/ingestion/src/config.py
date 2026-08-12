"""
Centralized configuration for the ingestion pipeline.

Loads Snowflake connection settings from environment variables (.env file),
so credentials never get hardcoded or committed to version control.
"""

import os
from dataclasses import dataclass
from pathlib import Path

from dotenv import load_dotenv

# Load variables from ingestion/.env into the process environment
ENV_PATH = Path(__file__).resolve().parent.parent / ".env"
load_dotenv(dotenv_path=ENV_PATH)


@dataclass(frozen=True)
class SnowflakeConfig:
    organization_name: str
    account_name: str
    user: str
    password: str
    role: str
    warehouse: str
    database: str
    schema: str

    @property
    def account_identifier(self) -> str:
        """Full account identifier expected by the Snowflake connector."""
        return f"{self.organization_name}-{self.account_name}"


def _require_env(var_name: str) -> str:
    """Fetch a required environment variable, failing fast if it's missing."""
    value = os.getenv(var_name)
    if not value:
        raise EnvironmentError(
            f"Missing required environment variable: {var_name}. "
            f"Check your ingestion/.env file (see .env.example for reference)."
        )
    return value


def load_snowflake_config() -> SnowflakeConfig:
    """Build a SnowflakeConfig instance from environment variables."""
    return SnowflakeConfig(
        organization_name=_require_env("SNOWFLAKE_ORGANIZATION_NAME"),
        account_name=_require_env("SNOWFLAKE_ACCOUNT_NAME"),
        user=_require_env("SNOWFLAKE_USER"),
        password=_require_env("SNOWFLAKE_PASSWORD"),
        role=_require_env("SNOWFLAKE_ROLE"),
        warehouse=_require_env("SNOWFLAKE_WAREHOUSE"),
        database=_require_env("SNOWFLAKE_DATABASE"),
        schema=_require_env("SNOWFLAKE_SCHEMA"),
    )


# Data directory paths, used by extract.py and load_to_snowflake.py
DATA_DIR = Path(__file__).resolve().parent.parent / "data" / "raw"

RAW_FILES = {
    "customers": "olist_customers_dataset.csv",
    "geolocation": "olist_geolocation_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "order_payments": "olist_order_payments_dataset.csv",
    "order_reviews": "olist_order_reviews_dataset.csv",
    "orders": "olist_orders_dataset.csv",
    "products": "olist_products_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "product_category_translation": "product_category_name_translation.csv",
}
