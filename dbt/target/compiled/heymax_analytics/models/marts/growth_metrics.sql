

-- Enhanced Growth Metrics with Social Capital Framework
-- Provides DAU, WAU, MAU growth accounting with quick ratios and quality metrics

WITH daily_users AS (
    SELECT 
        event_date,
        user_id,
        MIN(event_time) as first_event_of_day
    FROM `heymax-interview`.`heymax_data`.`fct_events`
    GROUP BY event_date, user_id
),

user_activity_by_date AS (
    SELECT 
        event_date,
        user_id,
        first_event_of_day,
        -- Get user's first ever activity date
        FIRST_VALUE(event_date) OVER (
            PARTITION BY user_id 
            ORDER BY event_date 
            ROWS UNBOUNDED PRECEDING
        ) as user_first_date,
        -- Get previous activity date for this user
        LAG(event_date) OVER (
            PARTITION BY user_id 
            ORDER BY event_date
        ) as prev_activity_date
    FROM daily_users
),

classified_users AS (
    SELECT 
        event_date,
        user_id,
        user_first_date,
        prev_activity_date,
        CASE 
            WHEN event_date = user_first_date THEN 'new'
            WHEN prev_activity_date = DATE_SUB(event_date, INTERVAL 1 DAY) THEN 'retained'
            WHEN prev_activity_date IS NOT NULL 
                AND prev_activity_date < DATE_SUB(event_date, INTERVAL 1 DAY) THEN 'resurrected'
            ELSE 'retained' -- This handles edge cases
        END as user_type
    FROM user_activity_by_date
),

-- Calculate churned users (users who were active yesterday but not today)
churned_users AS (
    SELECT 
        DATE_ADD(last_active_date, INTERVAL 1 DAY) as churn_date,
        user_id
    FROM (
        SELECT 
            user_id,
            MAX(event_date) as last_active_date
        FROM daily_users
        WHERE event_date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
        GROUP BY user_id
    ) last_activity
    WHERE last_active_date = DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)
),

daily_metrics AS (
    SELECT 
        event_date,
        COUNT(DISTINCT user_id) as daily_active_users,
        COUNT(DISTINCT CASE WHEN user_type = 'new' THEN user_id END) as new_users,
        COUNT(DISTINCT CASE WHEN user_type = 'retained' THEN user_id END) as retained_users,
        COUNT(DISTINCT CASE WHEN user_type = 'resurrected' THEN user_id END) as resurrected_users
    FROM classified_users
    GROUP BY event_date
),

daily_churn AS (
    SELECT 
        churn_date as event_date,
        COUNT(DISTINCT user_id) as churned_users
    FROM churned_users
    GROUP BY churn_date
),

-- Weekly Active Users (7-day rolling)
weekly_active_users AS (
    SELECT 
        event_date,
        COUNT(DISTINCT user_id) as weekly_active_users_7d
    FROM (
        SELECT DISTINCT
            d1.event_date,
            d2.user_id
        FROM (SELECT DISTINCT event_date FROM daily_users) d1
        JOIN daily_users d2 ON d2.event_date BETWEEN DATE_SUB(d1.event_date, INTERVAL 6 DAY) AND d1.event_date
    ) weekly_data
    GROUP BY event_date
),

-- 28-day rolling active users (Social Capital recommended)
rolling_28d_users AS (
    SELECT 
        event_date,
        COUNT(DISTINCT user_id) as active_users_28d
    FROM (
        SELECT DISTINCT
            d1.event_date,
            d2.user_id
        FROM (SELECT DISTINCT event_date FROM daily_users) d1
        JOIN daily_users d2 ON d2.event_date BETWEEN DATE_SUB(d1.event_date, INTERVAL 27 DAY) AND d1.event_date
    ) rolling_data
    GROUP BY event_date
),

-- Monthly Active Users (30-day rolling)
monthly_active_users AS (
    SELECT 
        event_date,
        COUNT(DISTINCT user_id) as monthly_active_users_30d
    FROM (
        SELECT DISTINCT
            d1.event_date,
            d2.user_id
        FROM (SELECT DISTINCT event_date FROM daily_users) d1
        JOIN daily_users d2 ON d2.event_date BETWEEN DATE_SUB(d1.event_date, INTERVAL 29 DAY) AND d1.event_date
    ) monthly_data
    GROUP BY event_date
),

enhanced_daily_metrics AS (
    SELECT 
        dm.event_date,
        dm.daily_active_users,
        dm.new_users,
        dm.retained_users,
        dm.resurrected_users,
        COALESCE(dc.churned_users, 0) as churned_users,
        wau.weekly_active_users_7d,
        r28.active_users_28d,
        mau.monthly_active_users_30d,
        
        -- Day-over-day growth
        dm.daily_active_users - LAG(dm.daily_active_users) OVER (ORDER BY dm.event_date) as dau_growth,
        
        -- Previous day metrics for retention calculation
        LAG(dm.daily_active_users) OVER (ORDER BY dm.event_date) as prev_day_dau,
        
        -- Social Capital Quick Ratio for daily metrics
        CASE 
            WHEN COALESCE(dc.churned_users, 0) > 0 
            THEN ROUND((dm.new_users + dm.resurrected_users) * 1.0 / dc.churned_users, 2)
            ELSE NULL 
        END as daily_quick_ratio,
        
        -- Day-over-day retention rate
        CASE 
            WHEN LAG(dm.daily_active_users) OVER (ORDER BY dm.event_date) > 0
            THEN ROUND(100.0 * dm.retained_users / LAG(dm.daily_active_users) OVER (ORDER BY dm.event_date), 2)
            ELSE NULL
        END as day_over_day_retention_pct
        
    FROM daily_metrics dm
    LEFT JOIN daily_churn dc ON dm.event_date = dc.event_date
    LEFT JOIN weekly_active_users wau ON dm.event_date = wau.event_date
    LEFT JOIN rolling_28d_users r28 ON dm.event_date = r28.event_date
    LEFT JOIN monthly_active_users mau ON dm.event_date = mau.event_date
)

SELECT 
    event_date,
    
    -- Core daily metrics
    daily_active_users,
    new_users,
    retained_users,
    resurrected_users,
    churned_users,
    dau_growth,
    
    -- Growth composition percentages
    ROUND(100.0 * new_users / NULLIF(daily_active_users, 0), 1) as new_users_pct,
    ROUND(100.0 * retained_users / NULLIF(daily_active_users, 0), 1) as retained_users_pct,
    ROUND(100.0 * resurrected_users / NULLIF(daily_active_users, 0), 1) as resurrected_users_pct,
    
    -- Social Capital metrics
    daily_quick_ratio,
    day_over_day_retention_pct,
    
    -- Rolling active user metrics
    weekly_active_users_7d,
    active_users_28d,
    monthly_active_users_30d,
    
    -- Weekly and monthly averages
    AVG(daily_active_users) OVER (
        ORDER BY event_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as weekly_avg_dau,
    
    AVG(daily_active_users) OVER (
        ORDER BY event_date 
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) as monthly_avg_dau,
    
    -- Stickiness ratios (Social Capital framework)
    CASE 
        WHEN weekly_active_users_7d > 0 
        THEN ROUND(100.0 * daily_active_users / weekly_active_users_7d, 1)
        ELSE NULL 
    END as dau_wau_stickiness,
    
    CASE 
        WHEN monthly_active_users_30d > 0 
        THEN ROUND(100.0 * daily_active_users / monthly_active_users_30d, 1)
        ELSE NULL 
    END as dau_mau_stickiness,
    
    CASE 
        WHEN monthly_active_users_30d > 0 
        THEN ROUND(100.0 * weekly_active_users_7d / monthly_active_users_30d, 1)
        ELSE NULL 
    END as wau_mau_stickiness,
    
    -- Growth quality indicators
    CASE 
        WHEN daily_quick_ratio IS NULL THEN 'Unknown'
        WHEN daily_quick_ratio < 1.0 THEN 'Declining'
        WHEN daily_quick_ratio >= 1.0 AND daily_quick_ratio < 1.5 THEN 'Healthy'
        WHEN daily_quick_ratio >= 1.5 THEN 'Strong'
        ELSE 'Unknown'
    END as daily_growth_quality,
    
    -- Activity trend (7-day comparison)
    CASE 
        WHEN daily_active_users > AVG(daily_active_users) OVER (
            ORDER BY event_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) THEN 'Trending Up'
        WHEN daily_active_users < AVG(daily_active_users) OVER (
            ORDER BY event_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) THEN 'Trending Down'
        ELSE 'Stable'
    END as activity_trend_7d,
    
    CURRENT_TIMESTAMP() as calculated_at

FROM enhanced_daily_metrics
ORDER BY event_date