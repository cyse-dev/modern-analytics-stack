"""
Data ingestion script to load CSV data into BigQuery
"""
import polars as pl
from google.cloud import bigquery, storage
import os
from datetime import datetime
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class DataIngestion:
    def __init__(self, project_id: str, dataset_id: str, bucket_name: str):
        self.project_id = project_id
        self.dataset_id = dataset_id
        self.bucket_name = bucket_name
        self.bq_client = bigquery.Client(project=project_id)
        self.storage_client = storage.Client(project=project_id)
        
    def create_dataset_if_not_exists(self):
        """Create BigQuery dataset if it doesn't exist"""
        dataset_id = f"{self.project_id}.{self.dataset_id}"
        
        try:
            self.bq_client.get_dataset(dataset_id)
            logger.info(f"Dataset {dataset_id} already exists")
        except Exception:
            dataset = bigquery.Dataset(dataset_id)
            dataset.location = "asia-southeast1"
            dataset = self.bq_client.create_dataset(dataset, timeout=30)
            logger.info(f"Created dataset {dataset_id}")
    
    def upload_to_gcs(self, local_file_path: str, blob_name: str):
        """Upload file to Google Cloud Storage"""
        bucket = self.storage_client.bucket(self.bucket_name)
        blob = bucket.blob(blob_name)
        
        blob.upload_from_filename(local_file_path)
        logger.info(f"Uploaded {local_file_path} to gs://{self.bucket_name}/{blob_name}")
        
        return f"gs://{self.bucket_name}/{blob_name}"
    
    def load_csv_to_bigquery(self, gcs_uri: str, table_id: str, schema=None):
        """Load CSV from GCS to BigQuery"""
        table_ref = self.bq_client.dataset(self.dataset_id).table(table_id)
        
        job_config = bigquery.LoadJobConfig(
            source_format=bigquery.SourceFormat.CSV,
            skip_leading_rows=1,
            autodetect=True if schema is None else False,
            write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
        )
        
        if schema:
            job_config.schema = schema
        
        load_job = self.bq_client.load_table_from_uri(
            gcs_uri, table_ref, job_config=job_config
        )
        
        load_job.result()  # Wait for job to complete
        
        destination_table = self.bq_client.get_table(table_ref)
        logger.info(f"Loaded {destination_table.num_rows} rows into {table_id}")
    
    def validate_csv_with_polars(self, csv_file_path: str):
        """Validate CSV structure using Polars"""
        try:
            df = pl.read_csv(csv_file_path)
            logger.info(f"CSV validation successful. Shape: {df.shape}")
            logger.info(f"Columns: {df.columns}")
            return df.head(5)
        except Exception as e:
            logger.error(f"CSV validation failed: {e}")
            raise
    
    def process_user_events_csv(self, csv_file_path: str):
        """Process user events CSV and load into BigQuery"""
        # Validate CSV first
        sample_data = self.validate_csv_with_polars(csv_file_path)
        logger.info(f"Sample data:\n{sample_data}")
        
        # Upload to GCS
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        gcs_blob_name = f"raw_data/user_events_{timestamp}.csv"
        gcs_uri = self.upload_to_gcs(csv_file_path, gcs_blob_name)
        
        # Define schema for user events
        schema = [
            bigquery.SchemaField("event_time", "TIMESTAMP", mode="REQUIRED"),
            bigquery.SchemaField("user_id", "STRING", mode="REQUIRED"),
            bigquery.SchemaField("event_type", "STRING", mode="REQUIRED"),
            bigquery.SchemaField("transaction_category", "STRING", mode="NULLABLE"),
            bigquery.SchemaField("miles_amount", "FLOAT", mode="NULLABLE"),
            bigquery.SchemaField("platform", "STRING", mode="REQUIRED"),
            bigquery.SchemaField("utm_source", "STRING", mode="NULLABLE"),
            bigquery.SchemaField("country", "STRING", mode="NULLABLE"),
        ]
        
        # Load to BigQuery
        self.load_csv_to_bigquery(gcs_uri, "raw_user_events", schema)

if __name__ == "__main__":
    import os
    from dotenv import load_dotenv
    
    load_dotenv()
    
    project_id = os.getenv("GCP_PROJECT_ID")
    dataset_id = os.getenv("BIGQUERY_DATASET", "heymax_data")
    bucket_name = os.getenv("GCS_BUCKET")
    
    if not all([project_id, bucket_name]):
        raise ValueError("Please set GCP_PROJECT_ID and GCS_BUCKET in .env file")
    
    ingestion = DataIngestion(project_id, dataset_id, bucket_name)
    ingestion.create_dataset_if_not_exists()
    
    # Example usage - replace with your CSV file path
    # ingestion.process_user_events_csv("data/user_events.csv")