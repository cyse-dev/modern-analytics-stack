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

##### `fct_events` - Event Fact Table
Primary table containing all user events with session tracking and sequencing.

| Column | Type | Description | Business Logic |
|--------|------|-------------|----------------|
| `event_id` | STRING | Unique identifier for each event | Surrogate key generated from user_id + event_time |
| `user_id` | STRING | Unique identifier for the user | Maps to external user system |
| `event_type` | STRING | Type of event | Valid values: 'miles_earned', 'miles_redeemed', 'share', 'like', 'reward_search' |
| `event_time` | TIMESTAMP | Exact timestamp when event occurred | UTC timezone, microsecond precision |
| `event_date` | DATE | Date portion of event_time | Used for daily aggregations and partitioning |
| `transaction_category` | STRING | Category of the transaction | Business-specific classification for miles transactions |
| `miles_amount` | INTEGER | Number of miles involved | Always ≥ 0; NULL for non-miles events |
| `platform` | STRING | Platform where event occurred | iOS, Android, Web |
| `utm_source` | STRING | UTM source for attribution | organic, paid, social, referral |
| `country` | STRING | Country where event occurred | ISO country codes |
| `session_id` | STRING | Derived session identifier | Based on 30-minute inactivity gaps |
| `is_session_start` | INTEGER | Flag indicating session start | 1 = session start, 0 = continuing session |
| `event_sequence_in_session` | INTEGER | Event order within session | Starts at 1 for each session |
| `processed_at` | TIMESTAMP | When record was processed | Data pipeline timestamp |

##### `dim_users` - User Dimension Table
User attributes with lifecycle metrics and miles balance validation.

| Column | Type | Description | Business Logic |
|--------|------|-------------|----------------|
| `user_id` | STRING | Unique identifier for the user | Primary key |
| `first_seen_at` | TIMESTAMP | User's first event timestamp | Earliest event_time across all events |
| `first_seen_date` | DATE | User's first event date | Date portion of first_seen_at |
| `last_seen_at` | TIMESTAMP | User's most recent event timestamp | Latest event_time across all events |
| `last_seen_date` | DATE | User's most recent event date | Date portion of last_seen_at |
| `days_active` | INTEGER | Days between first and last activity | `DATE_DIFF(last_seen_date, first_seen_date, DAY)` |
| `first_platform` | STRING | Platform of user's first engagement | iOS, Android, Web from first event |
| `first_utm_source` | STRING | UTM source for user acquisition | Attribution from first event |
| `first_country` | STRING | Country of user's first engagement | Country from first event |
| `total_miles_earned` | INTEGER | Lifetime miles earned | Sum of all miles_earned events |
| `total_miles_redeemed` | INTEGER | Lifetime miles redeemed | Sum of all miles_redeemed events |
| `current_miles_balance` | INTEGER | Net miles balance | `total_miles_earned - total_miles_redeemed` |
| `has_negative_balance` | BOOLEAN | Flag for negative balance | TRUE if current_miles_balance < 0 |
| `miles_earned_transactions` | INTEGER | Count of earning transactions | Number of miles_earned events |
| `miles_redeemed_transactions` | INTEGER | Count of redemption transactions | Number of miles_redeemed events |
| `share_events` | INTEGER | Total share events | Count of 'share' event_type |
| `like_events` | INTEGER | Total like events | Count of 'like' event_type |
| `reward_search_events` | INTEGER | Total reward search events | Count of 'reward_search' event_type |
| `updated_at` | TIMESTAMP | Record last updated timestamp | Data pipeline timestamp |

##### `users_with_negative_miles` - Data Quality Monitoring
Table specifically for flagging users with negative miles balances for investigation.

| Column | Type | Description | Business Logic |
|--------|------|-------------|----------------|
| `user_id` | STRING | User with negative balance | From dim_users where has_negative_balance = TRUE |
| `first_seen_at` | TIMESTAMP | User's first activity | Copied from dim_users |
| `last_seen_at` | TIMESTAMP | User's last activity | Copied from dim_users |
| `total_miles_earned` | INTEGER | Total miles earned | Copied from dim_users |
| `total_miles_redeemed` | INTEGER | Total miles redeemed | Copied from dim_users |
| `current_miles_balance` | INTEGER | Negative balance amount | Always < 0 |
| `negative_amount` | INTEGER | Absolute value of negative balance | `ABS(current_miles_balance)` for easier reporting |
| `flagged_at` | TIMESTAMP | When record was flagged | `CURRENT_TIMESTAMP()` at time of creation |

#### Social Capital Growth Analytics

##### `social_capital_growth_accounting` - Monthly MAU Decomposition
Core Social Capital framework implementing MAU(t) = new(t) + retained(t) + resurrected(t).

| Column | Type | Description | Business Logic |
|--------|------|-------------|----------------|
| `activity_month` | DATE | Month for analysis | `DATE_TRUNC(event_date, MONTH)` |
| `total_mau` | INTEGER | Total Monthly Active Users | COUNT(DISTINCT user_id) in month |
| `new_users` | INTEGER | Users active for first time ever | activity_month = user's first_activity_month |
| `retained_users` | INTEGER | Users active in current and previous month | Active in month T and T-1 |
| `resurrected_users` | INTEGER | Users active in current month but not previous, but active before | Active in month T, not T-1, but active in T-2 or earlier |
| `churned_users` | INTEGER | Users active last month but not current | Active in T-1 but not T |
| `retention_rate_pct` | FLOAT | Month-over-month retention percentage | `(retained_users / previous_month_mau) * 100` |
| `quick_ratio` | FLOAT | Social Capital Quick Ratio | `(new_users + resurrected_users) / churned_users` |
| `growth_quality_category` | STRING | Growth quality classification | Based on quick_ratio thresholds (see Value Definitions below) |
| `verification_total` | INTEGER | Data quality check | Should equal total_mau: `new_users + retained_users + resurrected_users` |
| `calculated_at` | TIMESTAMP | Calculation timestamp | When analysis was performed |

##### `quick_ratio_analysis` - Growth Quality Tracking
Advanced quick ratio analysis with alerts and strategic recommendations.

| Column | Type | Description | Business Logic |
|--------|------|-------------|----------------|
| `activity_month` | DATE | Month for analysis | From social_capital_growth_accounting |
| `quick_ratio` | FLOAT | Social Capital Quick Ratio | `(new + resurrected) / churned` |
| `quick_ratio_3mo_avg` | FLOAT | 3-month moving average | Smoothed trend analysis |
| `alert_level` | STRING | Alert classification | See Alert Level Definitions below |
| `growth_quality_score` | INTEGER | Growth quality score (0-100) | Normalized quick_ratio: `MIN(100, quick_ratio * 50)` |
| `retention_benchmark` | STRING | Retention rate classification | Excellent (80%+), Good (60-80%), Average (40-60%), Below Average (20-40%), Poor (<20%) |
| `quick_ratio_benchmark` | STRING | Quick ratio classification | Top Tier (2.0+), Strong (1.5-2.0), Healthy (1.0-1.5), Concerning (0.8-1.0), Critical (<0.8) |
| `business_stage` | STRING | Business maturity classification | Early Stage (<6mo), Growth Stage (6-24mo), Mature Stage (24mo+) |
| `strategic_recommendation` | STRING | Action-oriented guidance | See Strategic Recommendation Definitions below |

##### `growth_metrics` - Enhanced Daily Growth Metrics  
Daily user activity metrics enhanced with Social Capital methodology.

| Column | Type | Description | Business Logic |
|--------|------|-------------|----------------|
| `event_date` | DATE | Date for metrics | Daily grain analysis |
| `daily_active_users` | INTEGER | Unique users active on date | COUNT(DISTINCT user_id) |
| `new_users` | INTEGER | First-time users | Users where event_date = first_seen_date |
| `retained_users` | INTEGER | Users active on consecutive days | Active today AND yesterday |
| `resurrected_users` | INTEGER | Users returning after absence | Active today, NOT yesterday, but active before yesterday |
| `churned_users` | INTEGER | Users who became inactive | Active yesterday but NOT today |
| `dau_growth` | INTEGER | Day-over-day DAU change | `daily_active_users - previous_day_dau` |
| `new_users_pct` | FLOAT | Percentage of DAU that are new | `(new_users / daily_active_users) * 100` |
| `retained_users_pct` | FLOAT | Percentage of DAU that are retained | `(retained_users / daily_active_users) * 100` |
| `resurrected_users_pct` | FLOAT | Percentage of DAU that are resurrected | `(resurrected_users / daily_active_users) * 100` |
| `daily_quick_ratio` | FLOAT | Daily quick ratio | `(new_users + resurrected_users) / churned_users` |
| `day_over_day_retention_pct` | FLOAT | Daily retention rate | `(retained_users / previous_day_dau) * 100` |
| `weekly_active_users_7d` | INTEGER | 7-day rolling active users | Unique users active in last 7 days |
| `active_users_28d` | INTEGER | 28-day rolling active users | Social Capital recommended MAU calculation |
| `monthly_active_users_30d` | INTEGER | 30-day rolling active users | Traditional MAU calculation |
| `weekly_avg_dau` | FLOAT | 7-day average DAU | Rolling average for trend smoothing |
| `monthly_avg_dau` | FLOAT | 30-day average DAU | Long-term trend analysis |
| `dau_wau_stickiness` | FLOAT | DAU/WAU stickiness ratio (%) | `(daily_active_users / weekly_active_users_7d) * 100` |
| `dau_mau_stickiness` | FLOAT | DAU/MAU stickiness ratio (%) | `(daily_active_users / monthly_active_users_30d) * 100` |
| `wau_mau_stickiness` | FLOAT | WAU/MAU stickiness ratio (%) | `(weekly_active_users_7d / monthly_active_users_30d) * 100` |
| `daily_growth_quality` | STRING | Daily growth classification | See Daily Growth Quality Definitions below |
| `activity_trend_7d` | STRING | 7-day trend direction | Trending Up, Trending Down, Stable |
| `calculated_at` | TIMESTAMP | When metrics were calculated | Data pipeline timestamp |

#### Advanced Retention Analysis

##### `retention_quality_framework` - Deep Retention Analysis
Comprehensive retention analysis with user lifecycle tracking.

| Column | Type | Description | Business Logic |
|--------|------|-------------|----------------|
| `event_date` | DATE | Date for analysis | Daily grain analysis |
| `daily_active_users` | INTEGER | Total active users | COUNT(DISTINCT user_id) |
| `new_stage_users` | INTEGER | Users in first 7 days | Users where `DATE_DIFF(event_date, first_seen_date, DAY) <= 7` |
| `growing_stage_users` | INTEGER | Users in days 8-30 | Users where days since first seen is 8-30 |
| `established_stage_users` | INTEGER | Users in days 31-90 | Users where days since first seen is 31-90 |
| `mature_stage_users` | INTEGER | Users with 90+ days | Users where days since first seen > 90 |
| `users_consecutive_today` | INTEGER | Users active on consecutive days | Active today AND yesterday |
| `consecutive_today_pct` | FLOAT | Consecutive day percentage | `(users_consecutive_today / daily_active_users) * 100` |
| `daily_retention_health_score` | INTEGER | Overall retention health (0-100) | Weighted score: `(consecutive * 3 + returning_week * 2 + returning_long) / (total * 3)` |
| `retention_quality_category` | STRING | Retention quality classification | Excellent (80%+), Good (60-80%), Average (40-60%), Below Average (20-40%), Poor (<20%) |
| `engagement_trend` | STRING | Engagement pattern classification | High Engagement (>70%), Moderate Engagement (40-70%), Low Engagement (<40%) |

##### `user_resurrection_analysis` - Dormancy and Comeback Patterns
Analysis of user dormancy periods and successful resurrection campaigns.

| Column | Type | Description | Business Logic |
|--------|------|-------------|----------------|
| `event_date` | DATE | Date for analysis | Daily grain analysis |
| `total_resurrections` | INTEGER | Total users returning after gaps | Users active today but not yesterday, with prior activity |
| `short_dormancy_resurrections` | INTEGER | Returns after 2-7 day gaps | Dormancy period of 2-7 days |
| `medium_dormancy_resurrections` | INTEGER | Returns after 8-30 day gaps | Dormancy period of 8-30 days |
| `long_dormancy_resurrections` | INTEGER | Returns after 31-90 day gaps | Dormancy period of 31-90 days |
| `very_long_dormancy_resurrections` | INTEGER | Returns after 90+ day gaps | Dormancy period > 90 days |
| `resurrection_pct_of_dau` | FLOAT | Resurrections as % of DAU | `(total_resurrections / daily_active_users) * 100` |
| `avg_dormancy_length` | FLOAT | Average dormancy period (days) | Mean days between last activity and return |
| `resurrection_effectiveness_score` | FLOAT | Weighted effectiveness score | `(short*1 + medium*2 + long*3 + very_long*4) / daily_active_users * 100` |
| `resurrection_quality_category` | STRING | Quality classification | Excellent (30%+), Good (20-30%), Average (10-20%), Below Average (5-10%), Poor (<5%) |
| `resurrection_pattern` | STRING | Campaign pattern classification | See Resurrection Pattern Definitions below |
| `avg_7d_resurrections` | FLOAT | 7-day moving average | Trend smoothing for resurrection volume |
| `avg_7d_resurrection_pct` | FLOAT | 7-day moving average percentage | Trend smoothing for resurrection rate |

##### `retention_cohorts` - Daily Cohort Retention Tracking
Daily cohort retention analysis for long-term user lifecycle understanding.

| Column | Type | Description | Business Logic |
|--------|------|-------------|----------------|
| `cohort_month` | DATE | User acquisition month | Month of user's first activity |
| `period_number` | INTEGER | Months since acquisition | 0 = acquisition month, 1 = month 1, etc. |
| `period_month` | DATE | Actual calendar month | Actual month for this period |
| `users_active` | INTEGER | Users from cohort active in period | COUNT(DISTINCT user_id) from cohort active in period_month |
| `cohort_size` | INTEGER | Total size of cohort | Total users acquired in cohort_month |
| `retention_rate` | FLOAT | Retention percentage | `(users_active / cohort_size) * 100` |

#### Business-Specific Analytics

##### `growth_drivers` - Business Growth Factors
Daily analytics focused on rewards economy and platform performance.

| Column | Type | Description | Business Logic |
|--------|------|-------------|----------------|
| `event_date` | DATE | Date for analysis | Daily grain analysis |
| `daily_active_users` | INTEGER | Total active users | COUNT(DISTINCT user_id) |
| `total_daily_events` | INTEGER | Total events on date | COUNT(*) all events |
| **Miles Economy Health** | | | |
| `daily_miles_earned` | INTEGER | Total miles earned | SUM(miles_amount) for miles_earned events |
| `daily_miles_redeemed` | INTEGER | Total miles redeemed | SUM(miles_amount) for miles_redeemed events |
| `net_miles_change` | INTEGER | Net miles change | `daily_miles_earned - daily_miles_redeemed` |
| `users_earning_miles` | INTEGER | Users who earned miles | COUNT(DISTINCT user_id) for miles_earned events |
| `users_redeeming_miles` | INTEGER | Users who redeemed miles | COUNT(DISTINCT user_id) for miles_redeemed events |
| `miles_earning_events` | INTEGER | Number of earning transactions | COUNT(*) miles_earned events |
| `miles_redemption_events` | INTEGER | Number of redemption transactions | COUNT(*) miles_redeemed events |
| `miles_earn_redeem_ratio` | FLOAT | Earning to redemption ratio | `daily_miles_earned / daily_miles_redeemed` |
| `earning_user_pct` | FLOAT | % of DAU earning miles | `(users_earning_miles / daily_active_users) * 100` |
| `redeeming_user_pct` | FLOAT | % of DAU redeeming miles | `(users_redeeming_miles / daily_active_users) * 100` |
| **Social Engagement** | | | |
| `daily_shares` | INTEGER | Total share events | COUNT(*) share events |
| `daily_likes` | INTEGER | Total like events | COUNT(*) like events |
| `daily_searches` | INTEGER | Total reward search events | COUNT(*) reward_search events |
| `users_sharing` | INTEGER | Users who shared | COUNT(DISTINCT user_id) for share events |
| `users_liking` | INTEGER | Users who liked | COUNT(DISTINCT user_id) for like events |
| `users_searching` | INTEGER | Users who searched | COUNT(DISTINCT user_id) for reward_search events |
| `sharing_user_pct` | FLOAT | % of DAU sharing | `(users_sharing / daily_active_users) * 100` |
| `liking_user_pct` | FLOAT | % of DAU liking | `(users_liking / daily_active_users) * 100` |
| `searching_user_pct` | FLOAT | % of DAU searching | `(users_searching / daily_active_users) * 100` |
| **Platform Distribution** | | | |
| `ios_users` | INTEGER | iOS active users | COUNT(DISTINCT user_id) where platform = 'iOS' |
| `android_users` | INTEGER | Android active users | COUNT(DISTINCT user_id) where platform = 'Android' |
| `web_users` | INTEGER | Web active users | COUNT(DISTINCT user_id) where platform = 'Web' |
| `ios_user_pct` | FLOAT | % of DAU on iOS | `(ios_users / daily_active_users) * 100` |
| `android_user_pct` | FLOAT | % of DAU on Android | `(android_users / daily_active_users) * 100` |
| `web_user_pct` | FLOAT | % of DAU on Web | `(web_users / daily_active_users) * 100` |
| `ios_events_per_user` | FLOAT | Average events per iOS user | `ios_events / ios_users` |
| `android_events_per_user` | FLOAT | Average events per Android user | `android_events / android_users` |
| `web_events_per_user` | FLOAT | Average events per Web user | `web_events / web_users` |
| **Acquisition Channels** | | | |
| `new_organic_users` | INTEGER | New users from organic | First-time users where utm_source = 'organic' |
| `new_paid_users` | INTEGER | New users from paid | First-time users where utm_source = 'paid' |
| `new_social_users` | INTEGER | New users from social | First-time users where utm_source = 'social' |
| `new_referral_users` | INTEGER | New users from referrals | First-time users where utm_source = 'referral' |
| `total_new_users` | INTEGER | Total new user acquisitions | Sum of all new user channels |
| **Business Health Indicators** | | | |
| `miles_economy_health` | STRING | Miles economy classification | See Miles Economy Health Definitions below |
| `social_engagement_level` | STRING | Social engagement classification | High Social (20%+), Moderate Social (10-20%), Low Social (<10%) |
| `feature_adoption_score` | INTEGER | Feature adoption score (0-100) | Weighted score across all feature usage rates |
| `avg_7d_miles_earned` | FLOAT | 7-day average miles earned | Trend smoothing for miles earning |
| `avg_7d_social_actions` | FLOAT | 7-day average social actions | Trend smoothing for engagement |
| `calculated_at` | TIMESTAMP | When record was calculated | Data pipeline timestamp |

##### `miles_analytics` - Miles Economy Health Metrics
Detailed daily analytics for miles earning and redemption patterns.

| Column | Type | Description | Business Logic |
|--------|------|-------------|----------------|
| `event_date` | DATE | Date for analysis | Daily grain analysis |
| `daily_miles_earned` | INTEGER | Total miles earned | SUM(miles_amount) for miles_earned events |
| `daily_miles_redeemed` | INTEGER | Total miles redeemed | SUM(miles_amount) for miles_redeemed events |
| `net_miles_change` | INTEGER | Net daily change | `daily_miles_earned - daily_miles_redeemed` |
| `users_earning` | INTEGER | Users earning miles | COUNT(DISTINCT user_id) for earning events |
| `users_redeeming` | INTEGER | Users redeeming miles | COUNT(DISTINCT user_id) for redemption events |
| `earning_transactions` | INTEGER | Number of earning transactions | COUNT(*) earning events |
| `redeeming_transactions` | INTEGER | Number of redemption transactions | COUNT(*) redemption events |
| `cumulative_miles_earned` | INTEGER | Running total miles earned | SUM(daily_miles_earned) up to date |
| `cumulative_miles_redeemed` | INTEGER | Running total miles redeemed | SUM(daily_miles_redeemed) up to date |
| `avg_7d_miles_earned` | INTEGER | 7-day moving average earned | Trend smoothing |
| `avg_7d_miles_redeemed` | INTEGER | 7-day moving average redeemed | Trend smoothing |
| `calculated_at` | TIMESTAMP | When metrics were calculated | Data pipeline timestamp |

### Data Quality Framework
- **179 automated data quality tests**
- **Comprehensive schema validation**
- **Business rule enforcement**
- **Miles balance integrity checks**

## 📋 Categorical Value Definitions

This section provides detailed explanations for all categorical columns and their possible values, including business context and recommended actions.

### Daily Growth Quality (`growth_metrics.daily_growth_quality`)

| Value | Definition | Business Logic | Daily Interpretation | Action Needed |
|-------|------------|----------------|---------------------|---------------|
| **`Unknown`** | Quick ratio cannot be calculated | `daily_quick_ratio IS NULL` | No churn data or insufficient activity | Monitor data quality; ensure tracking working |
| **`Declining`** | More users churning than growing | `daily_quick_ratio < 1.0` | Net user loss; critical growth issue | Immediate retention analysis; pause growth spend |
| **`Healthy`** | Modest positive growth | `1.0 ≤ daily_quick_ratio < 1.5` | Sustainable growth with balanced churn | Continue current strategy; optimize gradually |
| **`Strong`** | Excellent growth momentum | `daily_quick_ratio ≥ 1.5` | High growth with controlled churn | Scale successful strategies; invest in growth |

**Daily Growth Quality Business Context:**
- **Strong Days** (≥1.5): Capitalize on momentum; understand what's working
- **Healthy Days** (1.0-1.5): Steady progress; look for optimization opportunities  
- **Declining Days** (<1.0): Investigate immediately; may indicate issues or seasonal patterns
- **Unknown Days**: Check data pipeline; ensure complete event tracking

### Miles Economy Health (`growth_drivers.miles_economy_health`)

| Value | Definition | Business Logic | Business Interpretation | Action Needed |
|-------|------------|----------------|-------------------------|---------------|
| **`Healthy Growth`** | Miles earning significantly exceeds redemption | `daily_miles_earned > daily_miles_redeemed * 1.2` | Strong user engagement in earning activities; healthy miles liability growth | Focus on maintaining engagement while ensuring adequate reward inventory |
| **`Stable`** | Miles earning slightly exceeds redemption | `daily_miles_earned > daily_miles_redeemed` (but ≤ 1.2x) | Balanced economy with modest net miles growth; sustainable pattern | Monitor for trends; consider promotional campaigns to drive either earning or redemption |
| **`High Redemption`** | Miles redemption significantly exceeds earning | `daily_miles_redeemed > daily_miles_earned * 1.2` | Users actively using rewards; may indicate promotional periods or inventory clearance | Evaluate reward pricing; may need to incentivize more earning activities |
| **`Balanced`** | Miles earning and redemption roughly equal | Neither Healthy Growth nor High Redemption conditions met | Equilibrium state; users earning and spending at similar rates | Ideal steady state; monitor for shifts that might indicate changing user behavior |

### Alert Levels (`quick_ratio_analysis.alert_level`)

| Alert Level | Trigger Conditions | Business Logic | Immediate Actions Required |
|-------------|-------------------|----------------|---------------------------|
| **`OK`** | Normal growth metrics | Quick ratio ≥ 1.2 and stable trends | Continue current growth strategies |
| **`WARNING: Quick Ratio Dropped Below 1.2`** | Growth slowing indicator | `quick_ratio < 1.2` AND `prev_month_quick_ratio >= 1.2` | Review retention initiatives; investigate churn drivers |
| **`WARNING: Quick Ratio Declined >0.3 Points`** | Significant decline | `quick_ratio_change < -0.3` | Deep dive into growth composition; identify specific issues |
| **`WARNING: Churn Significantly Exceeding Growth`** | Retention crisis emerging | `churned_users > (new_users + resurrected_users) * 1.5` | Focus immediately on retention; pause acquisition spend |
| **`CRITICAL: Quick Ratio Below 1.0`** | Losing users faster than acquiring | `quick_ratio < 1.0` | Emergency retention measures; stop all growth spend until fixed |

### Strategic Recommendations (`quick_ratio_analysis.strategic_recommendation`)

| Recommendation | Trigger Conditions | Business Logic | Action Plan | Implementation Priority |
|----------------|-------------------|----------------|-------------|------------------------|
| **`Focus on reducing churn before growth`** | Quick ratio < 1.0 | Losing more users than acquiring | Immediate retention interventions; pause acquisition until churn controlled | **Critical** (Immediate) |
| **`Invest heavily in user acquisition`** | Quick ratio ≥ 1.5 AND retention ≥ 60% | Strong product-market fit with good retention | Scale marketing spend; expand acquisition channels; invest in growth team | **Medium** (When conditions are optimal) |
| **`Improve product stickiness and onboarding`** | Retention rate < 40% | Users not forming strong habits | Focus on user experience; optimize onboarding flow; improve core value delivery | **High** (When retention is poor) |
| **`Restart user acquisition efforts`** | New users = 0 | No new user growth | Re-evaluate acquisition channels; restart marketing campaigns; fix acquisition funnel | **High** (Act quickly when new users = 0) |
| **`Optimize current growth strategy`** | All other conditions | Moderate growth with room for improvement | Fine-tune existing strategies; A/B test improvements; gradual optimization | **Low** (Continuous improvement) |

### Quick Ratio Benchmarks (`quick_ratio_analysis.quick_ratio_benchmark`)

| Benchmark | Quick Ratio Range | Business Interpretation | Strategic Focus |
|-----------|------------------|------------------------|----------------|
| **`Top Tier (2.0+)`** | ≥ 2.0 | Exceptional growth, consider scaling investments | Aggressive expansion; invest heavily in successful channels |
| **`Strong (1.5-2.0)`** | 1.5 - 2.0 | Healthy growth, optimize unit economics | Scale proven strategies; focus on efficiency |
| **`Healthy (1.0-1.5)`** | 1.0 - 1.5 | Balanced growth, focus on retention | Optimize retention while maintaining growth |
| **`Concerning (0.8-1.0)`** | 0.8 - 1.0 | Growth slowing, investigate churn causes | Deep dive into churn; reduce acquisition spend |
| **`Critical (<0.8)`** | < 0.8 | Losing users faster than acquiring, urgent action required | Emergency retention measures; stop growth spend |

### Business Stage Classifications (`quick_ratio_analysis.business_stage`)

| Stage | Definition | Months Since Start | Characteristics | Typical Focus Areas |
|-------|------------|-------------------|----------------|-------------------|
| **`Early Stage`** | Initial product-market fit exploration | < 6 months | High volatility, limited data, rapid iteration | Product development, user feedback, basic analytics |
| **`Growth Stage`** | Scaling with proven metrics | 6-24 months | Growth optimization, channel expansion | Acquisition scaling, retention optimization, operational efficiency |
| **`Mature Stage`** | Established operations | > 24 months | Steady patterns, incremental improvements | Market expansion, new features, long-term retention |

### Retention Quality Categories

#### Retention Quality Framework (`retention_quality_framework.retention_quality_category`)

| Category | Consecutive Day % | Business Interpretation | Recommended Actions |
|----------|------------------|------------------------|-------------------|
| **`Excellent`** | 80%+ | Very strong user habits and engagement | Maintain current strategies; focus on growth |
| **`Good`** | 60-80% | Strong retention with room for improvement | Optimize user experience; reduce friction |
| **`Average`** | 40-60% | Moderate retention requiring attention | Improve onboarding; enhance core value proposition |
| **`Below Average`** | 20-40% | Poor retention requiring immediate action | Major product/experience improvements needed |
| **`Poor`** | <20% | Critical retention issues | Emergency retention initiatives; fundamental product review |

#### Resurrection Quality Categories (`user_resurrection_analysis.resurrection_quality_category`)

| Category | Resurrection % of DAU | Business Interpretation | Campaign Effectiveness |
|----------|---------------------|------------------------|----------------------|
| **`Excellent`** | 30%+ | Outstanding win-back campaign performance | Highly effective resurrection strategies |
| **`Good`** | 20-30% | Strong resurrection campaign results | Good win-back programs with room for optimization |
| **`Average`** | 10-20% | Moderate resurrection success | Standard win-back performance; consider improvements |
| **`Below Average`** | 5-10% | Poor resurrection campaign performance | Win-back campaigns need significant improvement |
| **`Poor`** | <5% | Very poor or no resurrection activity | Urgent need for win-back strategy development |

### Resurrection Pattern Classifications (`user_resurrection_analysis.resurrection_pattern`)

| Pattern | Definition | Business Logic | Business Interpretation |
|---------|------------|----------------|-------------------------|
| **`No Resurrections`** | No users returned after any dormancy period | `total_resurrections = 0` | Either excellent retention (no churn) or ineffective resurrection campaigns |
| **`Quick Return Focus`** | Most resurrections from short dormancy (2-7 days) | `short_dormancy > (medium + long_dormancy)` | Effective short-term re-engagement; emails/push notifications working well |
| **`Long-term Recovery`** | Most resurrections from extended dormancy (31+ days) | `(long + very_long_dormancy) > short_dormancy` | Strong win-back campaigns or seasonal user behavior patterns |
| **`Balanced Recovery`** | Resurrections evenly distributed across dormancy periods | Neither Quick Return nor Long-term conditions met | Healthy mix of re-engagement across all time horizons |

### Activity Trend Classifications (`growth_metrics.activity_trend_7d`)

| Trend | Definition | Business Interpretation | Recommended Response |
|-------|------------|------------------------|---------------------|
| **`Trending Up`** | DAU above 7-day average | Positive momentum in user activity | Capitalize on growth; understand drivers |
| **`Trending Down`** | DAU below 7-day average | Declining user activity | Investigate causes; implement retention measures |
| **`Stable`** | DAU consistent with 7-day average | Steady user activity levels | Monitor for changes; optimize gradually |

### Social Engagement Level Classifications (`growth_drivers.social_engagement_level`)

| Level | Social Action % | Definition | Business Interpretation |
|-------|---------------|------------|-------------------------|
| **`High Social`** | ≥20% | High percentage of users engaging socially | Strong community engagement; viral potential |
| **`Moderate Social`** | 10-20% | Moderate social engagement | Standard social activity; room for improvement |
| **`Low Social`** | <10% | Low social engagement | Need to improve social features and incentives |

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