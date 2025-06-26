
  
    

    create or replace table `heymax-interview`.`heymax_data`.`social_capital_growth_accounting`
      
    
    

    OPTIONS()
    as (
      

-- Social Capital Growth Accounting Framework
-- Implements MAU(t) = new(t) + retained(t) + resurrected(t)
-- and calculates Quick Ratio = (new + resurrected) / churned

WITH monthly_active_users AS (
    SELECT DISTINCT
        DATE_TRUNC(event_date, MONTH) as activity_month,
        user_id
    FROM `heymax-interview`.`heymax_data`.`fct_events`
    WHERE event_type IN ('reward_search', 'miles_earned', 'miles_redeemed')
),

user_first_activity AS (
    SELECT 
        user_id,
        MIN(activity_month) as first_activity_month
    FROM monthly_active_users
    GROUP BY user_id
),

user_monthly_activity_with_history AS (
    SELECT 
        mau.activity_month,
        mau.user_id,
        ufa.first_activity_month,
        -- Previous month activity
        LAG(mau.activity_month) OVER (
            PARTITION BY mau.user_id 
            ORDER BY mau.activity_month
        ) as prev_activity_month,
        -- Activity two months ago
        LAG(mau.activity_month, 2) OVER (
            PARTITION BY mau.user_id 
            ORDER BY mau.activity_month
        ) as prev_2_activity_month
    FROM monthly_active_users mau
    LEFT JOIN user_first_activity ufa ON mau.user_id = ufa.user_id
),

user_classification AS (
    SELECT 
        activity_month,
        user_id,
        CASE 
            -- New: First time ever active
            WHEN activity_month = first_activity_month THEN 'new'
            -- Retained: Active in previous month  
            WHEN prev_activity_month = DATE_SUB(activity_month, INTERVAL 1 MONTH) THEN 'retained'
            -- Resurrected: Active before but not last month
            WHEN prev_activity_month IS NOT NULL 
                AND prev_activity_month < DATE_SUB(activity_month, INTERVAL 1 MONTH) THEN 'resurrected'
            -- Edge case handling
            ELSE 'retained'
        END as user_type
    FROM user_monthly_activity_with_history
),

-- Calculate churned users (were active last month but not this month)
churned_users AS (
    SELECT 
        DATE_ADD(last_active_month, INTERVAL 1 MONTH) as churn_month,
        user_id
    FROM (
        SELECT 
            user_id,
            MAX(activity_month) as last_active_month
        FROM monthly_active_users
        GROUP BY user_id
    ) last_activity
    WHERE last_active_month < DATE_TRUNC(CURRENT_DATE(), MONTH)
),

monthly_metrics AS (
    SELECT 
        activity_month,
        COUNT(DISTINCT user_id) as total_mau,
        COUNT(DISTINCT CASE WHEN user_type = 'new' THEN user_id END) as new_users,
        COUNT(DISTINCT CASE WHEN user_type = 'retained' THEN user_id END) as retained_users,
        COUNT(DISTINCT CASE WHEN user_type = 'resurrected' THEN user_id END) as resurrected_users
    FROM user_classification
    GROUP BY activity_month
),

churn_metrics AS (
    SELECT 
        churn_month as activity_month,
        COUNT(DISTINCT user_id) as churned_users
    FROM churned_users
    GROUP BY churn_month
),

combined_metrics AS (
    SELECT 
        mm.activity_month,
        mm.total_mau,
        mm.new_users,
        mm.retained_users,
        mm.resurrected_users,
        COALESCE(cm.churned_users, 0) as churned_users
    FROM monthly_metrics mm
    LEFT JOIN churn_metrics cm ON mm.activity_month = cm.activity_month
),

metrics_with_calculations AS (
    SELECT 
        *,
        -- Previous month MAU for growth calculation
        LAG(total_mau) OVER (ORDER BY activity_month) as prev_month_mau,
        -- Month-over-month growth
        total_mau - LAG(total_mau) OVER (ORDER BY activity_month) as mau_growth,
        -- Retention rate (retained users / previous month MAU)
        CASE 
            WHEN LAG(total_mau) OVER (ORDER BY activity_month) > 0 
            THEN ROUND(100.0 * retained_users / LAG(total_mau) OVER (ORDER BY activity_month), 2)
            ELSE NULL 
        END as retention_rate_pct,
        -- Churn rate (complement of retention rate)
        CASE 
            WHEN LAG(total_mau) OVER (ORDER BY activity_month) > 0 
            THEN ROUND(100.0 * churned_users / LAG(total_mau) OVER (ORDER BY activity_month), 2)
            ELSE NULL 
        END as churn_rate_pct,
        -- Quick Ratio (new + resurrected) / churned
        CASE 
            WHEN churned_users > 0 
            THEN ROUND((new_users + resurrected_users) * 1.0 / churned_users, 2)
            ELSE NULL 
        END as quick_ratio
    FROM combined_metrics
)

SELECT 
    activity_month,
    total_mau,
    prev_month_mau,
    mau_growth,
    
    -- Growth components (Social Capital framework)
    new_users,
    retained_users, 
    resurrected_users,
    churned_users,
    
    -- Key ratios
    retention_rate_pct,
    churn_rate_pct,
    quick_ratio,
    
    -- Growth component percentages
    ROUND(100.0 * new_users / NULLIF(total_mau, 0), 1) as new_users_pct,
    ROUND(100.0 * retained_users / NULLIF(total_mau, 0), 1) as retained_users_pct,
    ROUND(100.0 * resurrected_users / NULLIF(total_mau, 0), 1) as resurrected_users_pct,
    
    -- Growth quality indicators
    CASE 
        WHEN quick_ratio IS NULL THEN 'Unknown'
        WHEN quick_ratio < 1.0 THEN 'Declining'
        WHEN quick_ratio >= 1.0 AND quick_ratio < 1.5 THEN 'Typical Consumer'
        WHEN quick_ratio >= 1.5 AND quick_ratio < 2.0 THEN 'Good Consumer'
        WHEN quick_ratio >= 2.0 THEN 'Excellent Consumer'
        ELSE 'Unknown'
    END as growth_quality_category,
    
    -- Verification: new + retained + resurrected should equal total_mau
    new_users + retained_users + resurrected_users as verification_total,
    
    CURRENT_TIMESTAMP() as calculated_at

FROM metrics_with_calculations
WHERE activity_month IS NOT NULL
ORDER BY activity_month
    );
  