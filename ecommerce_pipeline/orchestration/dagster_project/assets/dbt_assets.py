"""
Dagster assets for the dbt transformation layer.

Uses dagster-dbt to auto-discover every dbt model (staging, intermediate,
marts) as an individual Dagster asset, preserving the exact dependency
graph (lineage) defined in dbt.
"""

from pathlib import Path

from dagster_dbt import DbtCliResource, DbtProject, dbt_assets

DBT_PROJECT_DIR = Path(__file__).resolve().parents[3] / "dbt_project"
DBT_PROFILES_DIR = Path.home() / ".dbt"

dbt_project = DbtProject(
    project_dir=DBT_PROJECT_DIR,
    profiles_dir=DBT_PROFILES_DIR,
)

dbt_resource = DbtCliResource(project_dir=dbt_project)


@dbt_assets(manifest=dbt_project.manifest_path)
def ecommerce_dbt_assets(context, dbt: DbtCliResource):
    yield from dbt.cli(["build"], context=context).stream()
