
  
    

    create or replace table `heymax-interview`.`heymax_analytics`.`retention_cohorts`
      
    
    

    OPTIONS()
    as (
      

WITH user_cohorts AS (
    SELECT 
        user_id,
        DATE_TRUNC(first_seen_date, MONTH) as cohort_month
    FROM `heymax-interview`.`heymax_analytics`.`dim_users`
),

user_monthly_activity AS (
    SELECT DISTINCT
        user_id,
        DATE_TRUNC(event_date, MONTH) as activity_month
    FROM `heymax-interview`.`heymax_analytics`.`fct_events`
),

cohort_data AS (
    SELECT 
        uc.cohort_month,
        uma.activity_month,
        uma.user_id,
        DATE_DIFF(uma.activity_month, uc.cohort_month, MONTH) as period_number
    FROM user_cohorts uc
    LEFT JOIN user_monthly_activity uma ON uc.user_id = uma.user_id
    WHERE uma.activity_month >= uc.cohort_month
),

cohort_table AS (
    SELECT 
        cohort_month,
        period_number,
        COUNT(DISTINCT user_id) as users_active
    FROM cohort_data
    GROUP BY cohort_month, period_number
),

cohort_sizes AS (
    SELECT 
        cohort_month,
        COUNT(DISTINCT user_id) as cohort_size
    FROM user_cohorts
    GROUP BY cohort_month
)

SELECT 
    ct.cohort_month,
    ct.period_number,
    ct.users_active,
    cs.cohort_size,
    ROUND(100.0 * ct.users_active / cs.cohort_size, 2) as retention_rate,
    DATE_ADD(ct.cohort_month, INTERVAL ct.period_number MONTH) as period_month
FROM cohort_table ct
LEFT JOIN cohort_sizes cs ON ct.cohort_month = cs.cohort_month
ORDER BY ct.cohort_month, ct.period_number
    );
  