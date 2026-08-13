"""
Dagster Definitions: wires together all assets, resources, and jobs for
the ecommerce_pipeline project.
"""

from dagster import Definitions, define_asset_job, AssetSelection
from dagster_dbt import DbtCliResource

from dagster_project.assets.ingestion_assets import raw_ecommerce_data
from dagster_project.assets.dbt_assets import ecommerce_dbt_assets, dbt_project

# Job that runs the full pipeline: ingestion first, then all dbt models,
# respecting the dependency defined in dbt_assets.py's asset deps.
full_pipeline_job = define_asset_job(
    name="full_pipeline",
    selection=AssetSelection.all(),
)

defs = Definitions(
    assets=[raw_ecommerce_data, ecommerce_dbt_assets],
    resources={
        "dbt": DbtCliResource(project_dir=dbt_project),
    },
    jobs=[full_pipeline_job],
)
