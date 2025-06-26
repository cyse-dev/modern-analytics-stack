from dagster import define_asset_job, AssetSelection

# Define the daily analytics job
daily_analytics_job = define_asset_job(
    name="daily_analytics_job",
    description="Daily batch processing job for HeyMax analytics",
    selection=AssetSelection.all(),
    config={
        "execution": {
            "config": {
                "multiprocess": {
                    "max_concurrent": 4,
                }
            }
        }
    },
)