"""
Command-line interface for the ingestion pipeline.

Usage:
    python3 -m src.cli validate   # validate raw CSV files only
    python3 -m src.cli load       # validate, then upload + copy into Snowflake
"""

import logging

import click

from .extract import validate_raw_files
from .load_to_snowflake import load_all

logging.basicConfig(level=logging.INFO, format="%(message)s")
logger = logging.getLogger(__name__)


@click.group()
def cli():
    """Ecommerce pipeline ingestion CLI."""
    pass


@cli.command()
def validate():
    """Validate that all expected raw CSV files exist and are readable."""
    results = validate_raw_files()
    total_rows = sum(r.row_count for r in results.values())

    click.echo(f"\nAll {len(results)} files validated successfully.")
    click.echo(f"Total rows across all files: {total_rows:,}")


@cli.command()
def load():
    """Validate raw files, then upload and load them into Snowflake RAW tables."""
    click.echo("Step 1/2: Validating raw files...")
    validate_raw_files()

    click.echo("\nStep 2/2: Loading into Snowflake...")
    results = load_all()
    total_rows = sum(results.values())

    click.echo(f"\nLoaded {len(results)} tables into Snowflake.")
    click.echo(f"Total rows loaded: {total_rows:,}")


if __name__ == "__main__":
    cli()
