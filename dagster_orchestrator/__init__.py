from dagster import Definitions, load_assets_from_modules

from .assets import mongodb
from dagster_embedded_elt import DagsterDltResource

mongodb_assets = load_assets_from_modules([assets])

defs = Definitions(
    assets=[*mongodb_assets],
    resources={
        "dlt": DagsterDltResource()
    }
)