from dotenv import load_dotenv
load_dotenv()
from dagster import Definitions, load_assets_from_modules, EnvVar

from .assets import mongodb, movies, adhoc
from .resources import snowflake_resource, dlt_resource
from .jobs import movies_job
from .schedules import movies_schedule
from .sensors import adhoc_sensor

mongodb_assets = load_assets_from_modules([mongodb])
movies_assets = load_assets_from_modules([movies], group_name="movies")
adhoc_assets = load_assets_from_modules([adhoc], group_name="ad_hoc")


defs = Definitions(
    assets=[*mongodb_assets, *movies_assets, *adhoc_assets],
    resources={
        "dlt": dlt_resource,
        "snowflake": snowflake_resource
    },
    jobs=[movies_job],
    schedules=[movies_schedule],
    sensors=[adhoc_sensor]
)
