from dagster import asset, AssetExecutionContext, MetadataValue
from dagster_dbt import DbtCliResource, dbt_assets
from dagster_gcp import BigQueryResource
from google.cloud import bigquery as bq
import polars as pl
import os
from pathlib import Path
from datetime import datetime
import logging

from ..resources import AnalyticsBigQueryResource, AnalyticsGCSResource


@asset(
    group_name="raw_data",
    description="Raw user events ingested from CSV to BigQuery",
)
def raw_user_events(
    context: AssetExecutionContext,
    bigquery: AnalyticsBigQueryResource,
    gcs: AnalyticsGCSResource,
) -> None:
    """Ingest CSV data from local/GCS to BigQuery raw table"""
    
    # Look for CSV files in the data directory
    data_dir = Path("/opt/dagster/app/data")
    csv_files = list(data_dir.glob("*.csv"))
    
    if not csv_files:
        context.log.warning("No CSV files found in data directory")
        return
    
    latest_csv = max(csv_files, key=os.path.getctime)
    context.log.info(f"Processing CSV file: {latest_csv}")
    
    # Validate CSV with Polars
    try:
        df = pl.read_csv(latest_csv)
        context.log.info(f"CSV validation successful. Shape: {df.shape}")
        context.log.info(f"Columns: {df.columns}")
    except Exception as e:
        context.log.error(f"CSV validation failed: {e}")
        raise
    
    # Upload to GCS
    storage_client = gcs.get_client()
    bucket = storage_client.bucket(gcs.bucket_name)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    blob_name = f"raw_data/user_events_{timestamp}.csv"
    blob = bucket.blob(blob_name)
    blob.upload_from_filename(str(latest_csv))
    
    gcs_uri = f"gs://{gcs.bucket_name}/{blob_name}"
    context.log.info(f"Uploaded to: {gcs_uri}")
    
    # Load to BigQuery
    bq_client = bigquery.get_client()
    
    # Create dataset if it doesn't exist (with new permissions)
    dataset_id = f"{bigquery.project_id}.{bigquery.dataset_id}"
    context.log.info(f"Working with dataset: {dataset_id}")
    
    try:
        bq_client.get_dataset(dataset_id)
        context.log.info(f"Dataset {dataset_id} already exists")
    except Exception:
        context.log.info(f"Creating dataset {dataset_id} in location {bigquery.location}")
        dataset = bq.Dataset(dataset_id)
        dataset.location = bigquery.location  # Use asia-southeast1
        dataset.description = "Analytics dataset for raw and processed user events"
        dataset = bq_client.create_dataset(dataset, timeout=30)
        context.log.info(f"Successfully created dataset {dataset_id} in {dataset.location}")
    
    table_id = f"{bigquery.project_id}.{bigquery.dataset_id}.raw_user_events"
    
    job_config = bq.LoadJobConfig(
        source_format=bq.SourceFormat.CSV,
        skip_leading_rows=1,
        write_disposition=bq.WriteDisposition.WRITE_TRUNCATE,
        schema=[
            bq.SchemaField("event_time", "TIMESTAMP", mode="REQUIRED"),
            bq.SchemaField("user_id", "STRING", mode="REQUIRED"),
            bq.SchemaField("event_type", "STRING", mode="REQUIRED"),
            bq.SchemaField("transaction_category", "STRING", mode="NULLABLE"),
            bq.SchemaField("miles_amount", "FLOAT", mode="NULLABLE"),
            bq.SchemaField("platform", "STRING", mode="REQUIRED"),
            bq.SchemaField("utm_source", "STRING", mode="NULLABLE"),
            bq.SchemaField("country", "STRING", mode="NULLABLE"),
        ]
    )
    
    try:
        load_job = bq_client.load_table_from_uri(gcs_uri, table_id, job_config=job_config)
        load_job.result()  # Wait for job to complete
        
        table = bq_client.get_table(table_id)
        context.log.info(f"Successfully loaded {table.num_rows} rows into {table_id}")
        
        # Add metadata
        context.add_output_metadata({
            "num_rows": MetadataValue.int(table.num_rows),
            "gcs_uri": MetadataValue.text(gcs_uri),
            "table_id": MetadataValue.text(table_id),
        })
        
    except Exception as e:
        context.log.error(f"BigQuery load failed: {e}")
        if "404" in str(e) and "dataset" in str(e).lower():
            context.log.error(f"Dataset {dataset_id} does not exist. Please create it manually in BigQuery console.")
            context.log.error("Required BigQuery dataset creation steps:")
            context.log.error("1. Go to BigQuery console")
            context.log.error(f"2. Create dataset '{bigquery.dataset_id}' in project '{bigquery.project_id}'")
            context.log.error("3. Set location to 'US'")
        raise


@asset(
    group_name="data_quality", 
    description="Data quality checks on raw and processed data",
    deps=[raw_user_events],
)
def data_quality_checks(
    context: AssetExecutionContext,
    bigquery: AnalyticsBigQueryResource,
) -> dict:
    """Run data quality checks on the pipeline"""
    
    bq_client = bigquery.get_client()
    
    quality_checks = {
        "raw_events_count": 0,
        "unique_users": 0,
        "event_types": [],
        "date_range": {},
        "platform_distribution": {},
    }
    
    # Count raw events
    query = f"""
    SELECT 
        COUNT(*) as total_events,
        COUNT(DISTINCT user_id) as unique_users,
        MIN(event_time) as min_date,
        MAX(event_time) as max_date
    FROM `{bigquery.project_id}.{bigquery.dataset_id}.raw_user_events`
    """
    
    result = bq_client.query(query).to_dataframe()
    if not result.empty:
        row = result.iloc[0]
        quality_checks["raw_events_count"] = int(row["total_events"])
        quality_checks["unique_users"] = int(row["unique_users"])
        quality_checks["date_range"] = {
            "min": str(row["min_date"]),
            "max": str(row["max_date"])
        }
    
    # Check event type distribution
    event_type_query = f"""
    SELECT event_type, COUNT(*) as count
    FROM `{bigquery.project_id}.{bigquery.dataset_id}.raw_user_events`
    GROUP BY event_type
    ORDER BY count DESC
    """
    
    event_types = bq_client.query(event_type_query).to_dataframe()
    quality_checks["event_types"] = event_types.to_dict('records')
    
    # Platform distribution
    platform_query = f"""
    SELECT platform, COUNT(DISTINCT user_id) as users
    FROM `{bigquery.project_id}.{bigquery.dataset_id}.raw_user_events`
    GROUP BY platform
    ORDER BY users DESC
    """
    
    platforms = bq_client.query(platform_query).to_dataframe()
    quality_checks["platform_distribution"] = platforms.to_dict('records')
    
    context.log.info(f"Quality checks completed: {quality_checks}")
    
    # Add metadata
    context.add_output_metadata({
        "total_events": MetadataValue.int(quality_checks["raw_events_count"]),
        "unique_users": MetadataValue.int(quality_checks["unique_users"]),
        "event_types": MetadataValue.json(quality_checks["event_types"]),
    })
    
    return quality_checks


# dbt assets - only load if manifest exists
import os
from pathlib import Path

# Support both Docker and local development paths
project_root = Path(__file__).parent.parent.parent
dbt_manifest_path = project_root / "dbt" / "target" / "manifest.json"

def get_dbt_assets():
    """Get dbt assets if manifest exists, otherwise return empty list"""
    if dbt_manifest_path.exists():        
        @dbt_assets(
            manifest=str(dbt_manifest_path),
            select="tag:dagster"  # Only models with dagster tag
        )
        def analytics_dbt_assets(context: AssetExecutionContext, dbt: DbtCliResource):
            """dbt models for analytics platform"""
            yield from dbt.cli(["build"], context=context).stream()
        return [analytics_dbt_assets]
    else:
        return []


# Export all assets
raw_data_assets = [raw_user_events, data_quality_checks]
dbt_assets = get_dbt_assets()
analytics_assets = []  # Will be populated by dbt models