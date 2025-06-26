from dagster import ConfigurableResource
from dagster_gcp import BigQueryResource, GCSResource
from dagster_dbt import DbtCliResource
from google.cloud import bigquery, storage
from google.oauth2 import service_account
import os


class AnalyticsBigQueryResource(ConfigurableResource):
    """BigQuery resource for analytics platform"""
    project_id: str
    dataset_id: str
    location: str = "asia-southeast1"
    
    def get_client(self) -> bigquery.Client:
        # Try multiple paths for the credentials file, prioritizing Docker secret
        possible_paths = [
            os.getenv("GOOGLE_APPLICATION_CREDENTIALS"),  # Docker secret or custom path
            "/run/secrets/gcp_service_account_key",        # Docker secret default location
            "/opt/dagster/app/service-account-key.json",   # Legacy mount path (fallback)
        ]
        
        credentials_path = None
        for path in possible_paths:
            if path and os.path.exists(path):
                credentials_path = path
                break
        
        print(f"DEBUG BQ: Using credentials path: {repr(credentials_path)}")
        
        if credentials_path:
            try:
                credentials = service_account.Credentials.from_service_account_file(credentials_path)
                print(f"DEBUG BQ: Successfully loaded credentials from {credentials_path}")
                return bigquery.Client(project=self.project_id, credentials=credentials)
            except Exception as e:
                print(f"DEBUG BQ: Error loading credentials from {credentials_path}: {e}")
        
        # If we get here, we couldn't load explicit credentials
        print(f"DEBUG BQ: Could not load explicit credentials, environment may not be set correctly")
        raise RuntimeError(f"Could not load BigQuery credentials. Tried paths: {possible_paths}")


class AnalyticsGCSResource(ConfigurableResource):
    """GCS resource for analytics data storage"""
    bucket_name: str
    project_id: str
    
    def get_client(self) -> storage.Client:
        # Try multiple paths for the credentials file, prioritizing Docker secret
        possible_paths = [
            os.getenv("GOOGLE_APPLICATION_CREDENTIALS"),  # Docker secret or custom path
            "/run/secrets/gcp_service_account_key",        # Docker secret default location
            "/opt/dagster/app/service-account-key.json",   # Legacy mount path (fallback)
        ]
        
        credentials_path = None
        for path in possible_paths:
            if path and os.path.exists(path):
                credentials_path = path
                break
        
        print(f"DEBUG GCS: Using credentials path: {repr(credentials_path)}")
        
        if credentials_path:
            try:
                credentials = service_account.Credentials.from_service_account_file(credentials_path)
                print(f"DEBUG GCS: Successfully loaded credentials from {credentials_path}")
                return storage.Client(project=self.project_id, credentials=credentials)
            except Exception as e:
                print(f"DEBUG GCS: Error loading credentials from {credentials_path}: {e}")
        
        # If we get here, we couldn't load explicit credentials
        print(f"DEBUG GCS: Could not load explicit credentials, environment may not be set correctly")
        raise RuntimeError(f"Could not load GCS credentials. Tried paths: {possible_paths}")


# Resource instances - configured with proper defaults and env var handling
def get_bigquery_resource():
    return AnalyticsBigQueryResource(
        project_id=os.getenv("GCP_PROJECT_ID", "heymax-interview"),
        dataset_id=os.getenv("BIGQUERY_DATASET", "heymax_data"),
        location="asia-southeast1"
    )

def get_gcs_resource():
    return AnalyticsGCSResource(
        bucket_name=os.getenv("GCS_BUCKET", "heymax-ingestion"),
        project_id=os.getenv("GCP_PROJECT_ID", "heymax-interview"),
    )

bigquery_resource = get_bigquery_resource()
gcs_resource = get_gcs_resource()

# Configure dbt resource to work in both local and Docker environments
from pathlib import Path

def get_dbt_resource():
    """Get dbt resource with path detection for local/Docker environments"""
    # Get project root
    project_root = Path(__file__).parent.parent.parent
    
    # Try Docker path first, then local path
    docker_dbt_path = Path("/opt/dagster/app/dbt")
    local_dbt_path = project_root / "dbt"
    
    if docker_dbt_path.exists():
        dbt_path = docker_dbt_path
    else:
        dbt_path = local_dbt_path
    
    return DbtCliResource(
        project_dir=str(dbt_path),
        profiles_dir=str(dbt_path),
        target="dev"
    )

dbt_resource = get_dbt_resource()