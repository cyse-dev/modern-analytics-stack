FROM python:3.11-slim

# Set working directory
WORKDIR /opt/dagster/app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create directories for dbt and data
RUN mkdir -p /opt/dagster/app/dbt/target
RUN mkdir -p /opt/dagster/app/data

# Set environment variables
ENV DAGSTER_HOME=/opt/dagster/app/dagster_home
ENV PYTHONPATH=/opt/dagster/app

# Create dagster home directory
RUN mkdir -p $DAGSTER_HOME

# Copy dbt files
COPY dbt/ /opt/dagster/app/dbt/

# Generate dbt manifest (will be done at runtime with proper credentials)
RUN cd /opt/dagster/app/dbt && dbt deps --profiles-dir . || true

# Expose port
EXPOSE 3000

# Default command
CMD ["dagster", "dev", "--host", "0.0.0.0", "--port", "3000"]