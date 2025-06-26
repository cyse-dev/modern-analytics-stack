# Modern Analytics Stack

A comprehensive end-to-end analytics solution for tracking user growth and engagement metrics using Dagster, dbt, BigQuery, and Apache Superset. Built with the Social Capital growth accounting framework for sophisticated user behavior analysis.

## 🏗️ Architecture Overview

```
CSV Data → Dagster → BigQuery → dbt → Apache Superset
                      ↓
                   Data Quality Tests
```

## 📊 Key Features

- **Social Capital Growth Framework**: MAU decomposition with new/retained/resurrected/churned classification
- **Advanced Retention Analysis**: User lifecycle tracking and consecutive day patterns
- **Rewards Economy Monitoring**: Business health metrics for points/rewards systems
- **Quick Ratio Analysis**: Growth quality tracking with strategic alerts
- **Automated Data Pipeline**: Daily batch processing with Dagster orchestration
- **Data Quality Monitoring**: 179 automated tests ensuring data integrity
- **Interactive Dashboards**: Modern Apache Superset dashboards with exploration tools

## 📁 Project Structure

```
modern-analytics-stack/
├── README.md                          # This comprehensive guide
├── dagster_project/                   # Dagster pipeline code
│   ├── __init__.py
│   ├── assets/                        # Data pipeline assets
│   │   └── __init__.py
│   ├── resources/                     # BigQuery, GCS connections
│   │   └── __init__.py
│   ├── jobs/                          # Dagster jobs
│   │   └── __init__.py
│   └── schedules/                     # Pipeline schedules
│       └── __init__.py
│
├── dbt/                               # dbt analytics models
│   ├── dbt_project.yml                # dbt project configuration
│   ├── profiles.yml                   # Database connections
│   ├── packages.yml                   # dbt dependencies
│   ├── dbt_packages/                  # Installed packages
│   ├── target/                        # Build artifacts
│   ├── logs/
│   │   └── dbt.log
│   ├── macros/                        # Custom dbt macros
│   ├── tests/                         # Custom data tests
│   └── models/
│       ├── staging/                   # Staging layer
│       │   ├── schema.yml
│       │   └── stg_raw_user_events.sql
│       └── marts/                     # Analytics layer (11 models)
│           ├── schema.yml             # Comprehensive documentation
│           ├── dim_users.sql          # User dimension
│           ├── fct_events.sql         # Event fact table
│           ├── growth_metrics.sql     # Daily growth metrics
│           ├── growth_drivers.sql     # Business growth drivers
│           ├── miles_analytics.sql    # Miles economy health
│           ├── quick_ratio_analysis.sql
│           ├── social_capital_growth_accounting.sql
│           ├── retention_cohorts.sql
│           ├── retention_quality_framework.sql
│           ├── user_resurrection_analysis.sql
│           └── users_with_negative_miles.sql
│
│
├── scripts/                           # Utility scripts
│   ├── data_ingestion.py             # CSV to BigQuery
│   └── setup.sh                      # Initial setup
│
│
├── logs/                             # Application logs
│   └── dbt.log
│
│
├── docker-compose.yml                # Dagster services setup
├── Dockerfile                        # Container definition
├── Makefile                          # Development commands
├── dagster.yaml                      # Dagster configuration
├── pyproject.toml                    # Python project config
├── requirements.txt                  # Python dependencies
├── .env.example                      # Example env file
├── .gitignore                        # Git Ignore
```

## 📈 Analytics Data Models

### Core Models (11 Production Tables)

#### Event and User Tables
- **`fct_events`**: Primary event fact table with session tracking
- **`dim_users`**: User dimension with lifecycle metrics and miles balances
- **`users_with_negative_miles`**: Data quality monitoring for miles economy

#### Social Capital Growth Analytics
- **`social_capital_growth_accounting`**: Monthly MAU decomposition framework
- **`quick_ratio_analysis`**: Growth quality tracking with strategic alerts
- **`growth_metrics`**: Enhanced daily growth metrics with Social Capital methodology

#### Advanced Retention Analysis
- **`retention_quality_framework`**: Deep retention analysis with user lifecycle stages
- **`user_resurrection_analysis`**: Dormancy and comeback pattern analysis
- **`retention_cohorts`**: Daily cohort retention tracking

#### Business-Specific Analytics
- **`growth_drivers`**: Business growth factors and platform performance
- **`miles_analytics`**: Miles economy health metrics and transaction patterns

### Data Quality Framework
- **179 automated data quality tests**
- **Comprehensive schema validation**
- **Business rule enforcement**
- **Miles balance integrity checks**

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Google Cloud Platform account with billing enabled
- Python 3.8+ (for local development)

### 1. Environment Setup
```bash
git clone github.com/cyse-dev/modern-analytics-stack.git
cd modern-analytics-stack

# Ensure GCP credentials are properly configured in service-account-key.json, which should exist in your root directory.
```

### 2. Launch Dagster Analytics Pipeline
```bash
# Build and start Dagster services (data pipeline and orchestration)
docker-compose build
docker-compose up -d dagster_webserver dagster_daemon postgres

# Verify Dagster is running
docker-compose ps
```

### 3. Access Dagster Interface
- **Dagster UI**: http://localhost:3000 - Data pipeline orchestration and monitoring

### 4. Verify Setup
```bash
# Check Dagster containers are running
docker-compose ps

# View logs if needed
docker-compose logs -f dagster_webserver
docker-compose logs -f dagster_daemon
```

## 📊 Apache Superset Installation (Optional BI Platform)

Apache Superset is not included in this repository but can be installed separately for business intelligence dashboards.

### Option 1: Docker Installation (Recommended)
```bash
# Clone Apache Superset repository
git clone https://github.com/apache/superset.git
cd superset

# Enter the repository you just cloned
$ cd superset

# Set the repo to the state associated with the latest official version
$ git checkout tags/5.0.0

# Fire up Superset using Docker Compose
$ docker compose -f docker-compose-image-tag.yml up

# Access Superset at http://localhost:8088
# Default credentials: admin/admin
```

### Option 2: Local Installation
```bash
# Install Superset via pip
pip install apache-superset

# Initialize database
superset db upgrade

# Create admin user
export FLASK_APP=superset
superset fab create-admin

# Initialize Superset
superset init

# Start Superset
superset run -p 8088 --with-threads --reload --debugger
```

### Connecting Superset to BigQuery
Once Superset is installed:

**Add BigQuery Database Connection**:
   - Go to Settings → Database Connections
   - Add new database with BigQuery connection string:
   ```
   bigquery://your-project-id/your-dataset-id?credentials_path=/path/to/service-account-key.json
   ```


## 🔄 Daily Pipeline Operations

The analytics pipeline processes data through:

1. **Data Ingestion**: CSV files → BigQuery raw tables
2. **Data Validation**: 179 automated quality checks
3. **dbt Staging**: Raw events → clean staging tables  
4. **dbt Analytics**: Staging → 11 production analytics tables
5. **Data Quality Tests**: Validate analytical outputs

## 🛠️ Development Commands

```bash
# Start/stop Dagster services
docker-compose up -d dagster_webserver dagster_daemon postgres
docker-compose stop dagster_webserver dagster_daemon postgres

# Access Dagster container shell
docker-compose exec dagster_webserver bash

# Run dbt models from within container
cd /opt/dagster/app/dbt
dbt run --models marts
dbt test

# View Dagster logs
docker-compose logs -f dagster_webserver
docker-compose logs -f dagster_daemon

# Full cleanup
docker-compose down

# Rebuild containers after changes
docker-compose up -d --build dagster_webserver dagster_daemon postgres
```

## 📊 Key Analytics Features

### Social Capital Growth Framework
- **MAU Decomposition**: new + retained + resurrected users
- **Quick Ratio Analysis**: Growth quality measurement
- **Strategic Recommendations**: Data-driven growth guidance

### Advanced Retention Analytics
- **User Lifecycle Stages**: New, Growing, Established, Mature
- **Resurrection Patterns**: Short, Medium, Long, Very Long dormancy analysis
- **Consecutive Day Tracking**: Daily habit formation metrics

### Business Health Monitoring
- **Miles Economy Health**: Earning vs redemption patterns
- **Platform Performance**: iOS/Android/Web comparative analytics
- **Data Quality Alerts**: Negative balance monitoring

## 🚨 Troubleshooting

### Common Issues

**Container Issues**
```bash
# Check container status
docker-compose ps

# View service logs
docker-compose logs dagster_webserver
docker-compose logs dagster_daemon
docker-compose logs postgres

# Restart services
docker-compose restart dagster_webserver dagster_daemon

# Full environment reset
docker-compose down
docker-compose up -d --build dagster_webserver dagster_daemon postgres
```

**Port Conflicts**
```bash
# Check if Dagster port is already in use
lsof -i :3000

# Kill process using port if needed
sudo kill -9 $(lsof -t -i:3000)
```

### dbt Model Issues
```bash
# Access container and debug
docker-compose exec dagster_webserver bash
cd /opt/dagster/app/dbt

# Test dbt connection
dbt debug

# Run specific model with verbose logging
dbt run --models dim_users --full-refresh --log-level debug
```

## 📚 Documentation

- [Dagster Documentation](https://docs.dagster.io/)
- [dbt Documentation](https://docs.getdbt.com/)
- [Social Capital Growth Accounting](https://medium.com/swlh/diligence-at-social-capital-the-ultimate-business-kpi-s-eacab0df92b5)
- [BigQuery Best Practices](https://cloud.google.com/bigquery/docs/best-practices)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add comprehensive tests for new models
4. Update documentation
5. Test changes locally
6. Submit pull request

## 📄 License

This project is licensed under the MIT License.

---

**Built with ❤️ for Modern Data Teams**

*Analytics Stack powered by Dagster, dbt, BigQuery, and Apache Superset*