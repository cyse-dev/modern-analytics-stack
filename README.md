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
├── superset/                         # Apache Superset BI Platform
│   ├── README.md
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── [Complete Superset installation]
│
├── docker-compose.yml                # Multi-service setup
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

### 3. Launch Apache Superset (Separate Container)
```bash
# Navigate to Superset directory and start BI platform
cd superset/
docker-compose build
docker-compose up -d

# Verify Superset is running
docker-compose ps
cd ..
```

### 4. Access Interfaces
- **Dagster UI**: http://localhost:3000 - Data pipeline orchestration and monitoring
- **Apache Superset**: http://localhost:8088 - Business intelligence dashboards (admin/admin)

### 5. Verify Setup
```bash
# Check all containers are running
docker ps | grep -E "(dagster|superset)"

# View logs if needed
docker-compose logs -f dagster_webserver  # Dagster logs
cd superset && docker-compose logs -f superset_app  # Superset logs
```

## 🔄 Daily Pipeline Operations

The analytics pipeline processes data through:

1. **Data Ingestion**: CSV files → BigQuery raw tables
2. **Data Validation**: 179 automated quality checks
3. **dbt Staging**: Raw events → clean staging tables  
4. **dbt Analytics**: Staging → 11 production analytics tables
5. **Data Quality Tests**: Validate analytical outputs

## 🛠️ Development Commands

### Dagster Pipeline Commands
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
```

### Superset BI Commands
```bash
# Start/stop Superset (from superset/ directory)
cd superset/
docker-compose up -d
docker-compose stop

# Access Superset container shell
docker-compose exec superset_app bash

# View Superset logs
docker-compose logs -f superset_app
cd ..
```

### Combined Operations
```bash
# Start both services
docker-compose up -d dagster_webserver dagster_daemon postgres
cd superset && docker-compose up -d && cd ..

# Stop both services
docker-compose stop dagster_webserver dagster_daemon postgres
cd superset && docker-compose stop && cd ..

# Full cleanup
docker-compose down
cd superset && docker-compose down && cd ..
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

**Dagster Container Issues**
```bash
# Check Dagster container status
docker-compose ps

# View Dagster service logs
docker-compose logs dagster_webserver
docker-compose logs dagster_daemon

# Restart Dagster services
docker-compose restart dagster_webserver dagster_daemon

# Full Dagster environment reset
docker-compose down
docker-compose up -d --build dagster_webserver dagster_daemon postgres
```

**Superset Container Issues**
```bash
# Check Superset container status (from superset/ directory)
cd superset/
docker-compose ps

# View Superset service logs
docker-compose logs superset_app

# Restart Superset services
docker-compose restart

# Full Superset environment reset
docker-compose down
docker-compose up -d --build
cd ..
```

**Port Conflicts**
```bash
# Check if ports are already in use
lsof -i :3000  # Dagster port
lsof -i :8088  # Superset port

# Kill processes using ports if needed
sudo kill -9 $(lsof -t -i:3000)
sudo kill -9 $(lsof -t -i:8088)
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