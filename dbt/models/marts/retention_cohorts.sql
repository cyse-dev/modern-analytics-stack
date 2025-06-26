{{ config(materialized='table', tags=['dagster']) }}

-- Daily Retention Cohorts Analysis
-- Tracks user retention by daily cohorts with daily activity tracking

WITH user_cohorts AS (
    SELECT 
        user_id,
        min(date(event_time)) as cohort_date
    FROM {{ ref('fct_events') }}
    WHERE event_type IN ('reward_search', 'miles_earned', 'miles_redeemed')
    GROUP BY user_id
),

user_daily_activity AS (
    SELECT DISTINCT
        user_id,
        event_date as activity_date
    FROM {{ ref('fct_events') }}
    WHERE event_type IN ('reward_search', 'miles_earned', 'miles_redeemed')
),

cohort_data AS (
    SELECT 
        uc.cohort_date,
        uda.activity_date,
        uda.user_id,
        DATE_DIFF(uda.activity_date, uc.cohort_date, DAY) as period_number
    FROM user_cohorts uc
    LEFT JOIN user_daily_activity uda ON uc.user_id = uda.user_id
    WHERE uda.activity_date >= uc.cohort_date
),

-- Daily cohort table with flexible period grouping
cohort_table AS (
    SELECT 
        cohort_date,
        period_number,
        COUNT(DISTINCT user_id) as users_active,
        
        -- Group periods for analysis (0, 1, 2-7, 8-14, 15-30, 31-60, 61-90, 91+)
        CASE 
            WHEN period_number = 0 THEN 'Day 0'
            WHEN period_number = 1 THEN 'Day 1'
            WHEN period_number BETWEEN 2 AND 7 THEN 'Days 2-7'
            WHEN period_number BETWEEN 8 AND 14 THEN 'Days 8-14'
            WHEN period_number BETWEEN 15 AND 30 THEN 'Days 15-30'
            WHEN period_number BETWEEN 31 AND 60 THEN 'Days 31-60'
            WHEN period_number BETWEEN 61 AND 90 THEN 'Days 61-90'
            WHEN period_number > 90 THEN 'Days 91+'
            ELSE 'Unknown'
        END as period_group
    FROM cohort_data
    GROUP BY cohort_date, period_number
),

-- Weekly grouped cohort table for trend analysis
weekly_cohort_table AS (
    SELECT 
        cohort_date,
        CASE 
            WHEN period_number = 0 THEN 0
            WHEN period_number BETWEEN 1 AND 7 THEN 1
            WHEN period_number BETWEEN 8 AND 14 THEN 2
            WHEN period_number BETWEEN 15 AND 21 THEN 3
            WHEN period_number BETWEEN 22 AND 28 THEN 4
            ELSE FLOOR(period_number / 7)
        END as week_number,
        COUNT(DISTINCT user_id) as users_active_week
    FROM cohort_data
    WHERE period_number >= 0
    GROUP BY cohort_date, week_number
),

cohort_sizes AS (
    SELECT 
        cohort_date,
        COUNT(DISTINCT user_id) as cohort_size
    FROM user_cohorts
    GROUP BY cohort_date
)

SELECT 
    ct.cohort_date,
    ct.period_number,
    ct.users_active,
    ct.period_group,
    cs.cohort_size,
    
    -- Daily retention rate
    ROUND(100.0 * ct.users_active / NULLIF(cs.cohort_size, 0), 2) as retention_rate,
    
    -- Actual activity date for this period
    DATE_ADD(ct.cohort_date, INTERVAL ct.period_number DAY) as activity_date,
    
    -- Key milestone indicators
    CASE 
        WHEN ct.period_number = 1 THEN 'Day 1 Retention'
        WHEN ct.period_number = 7 THEN 'Week 1 Retention'
        WHEN ct.period_number = 30 THEN 'Month 1 Retention'
        WHEN ct.period_number = 90 THEN 'Quarter 1 Retention'
        ELSE NULL
    END as milestone_type,
    
    -- Cohort age in days (for filtering recent cohorts)
    DATE_DIFF(CURRENT_DATE(), ct.cohort_date, DAY) as cohort_age_days,
    
    -- Cohort quality indicators
    CASE 
        WHEN DATE_DIFF(CURRENT_DATE(), ct.cohort_date, DAY) < 7 THEN 'Very Recent'
        WHEN DATE_DIFF(CURRENT_DATE(), ct.cohort_date, DAY) < 30 THEN 'Recent'
        WHEN DATE_DIFF(CURRENT_DATE(), ct.cohort_date, DAY) < 90 THEN 'Mature'
        ELSE 'Historical'
    END as cohort_maturity,
    
    -- Day-over-day retention change
    LAG(ROUND(100.0 * ct.users_active / NULLIF(cs.cohort_size, 0), 2)) 
        OVER (PARTITION BY ct.cohort_date ORDER BY ct.period_number) as prev_day_retention_rate,
    
    CURRENT_TIMESTAMP() as calculated_at

FROM cohort_table ct
LEFT JOIN cohort_sizes cs ON ct.cohort_date = cs.cohort_date
WHERE cs.cohort_size > 0  -- Only include cohorts with users
ORDER BY ct.cohort_date DESC, ct.period_number ASC