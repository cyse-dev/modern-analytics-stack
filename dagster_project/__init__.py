from dagster import Definitions

from .assets import raw_data_assets, dbt_assets, analytics_assets
from .resources import bigquery_resource, gcs_resource, dbt_resource
from .jobs import daily_analytics_job
from .schedules import daily_schedule

defs = Definitions(
    assets=[
        *raw_data_assets, 
        *dbt_assets,
        *analytics_assets
    ],
    resources={
        "bigquery": bigquery_resource,
        "gcs": gcs_resource, 
        "dbt": dbt_resource,
    },
    jobs=[daily_analytics_job],
    schedules=[daily_schedule],
)