
  
    

    create or replace table `heymax-interview`.`heymax_data`.`retention_quality_framework`
      
    
    

    OPTIONS()
    as (
      

-- Simplified Retention Quality Framework
-- Core retention quality metrics focusing on daily patterns

WITH daily_activity AS (
    SELECT DISTINCT
        event_date,
        user_id
    FROM `heymax-interview`.`heymax_data`.`fct_events`
    WHERE event_type IN ('reward_search', 'miles_earned', 'miles_redeemed')
),

retention_metrics AS (
    SELECT 
        event_date,
        COUNT(DISTINCT user_id) as daily_active_users,
        
        -- Users active on consecutive days (today and yesterday)
        COUNT(DISTINCT CASE 
            WHEN user_id IN (
                SELECT user_id FROM daily_activity da2 
                WHERE da2.event_date = DATE_SUB(da1.event_date, INTERVAL 1 DAY)
            ) THEN user_id 
        END) as consecutive_day_users,
        
        -- Users returning after gaps
        COUNT(DISTINCT CASE 
            WHEN user_id NOT IN (
                SELECT user_id FROM daily_activity da2 
                WHERE da2.event_date = DATE_SUB(da1.event_date, INTERVAL 1 DAY)
            ) AND user_id IN (
                SELECT user_id FROM daily_activity da3 
                WHERE da3.event_date BETWEEN DATE_SUB(da1.event_date, INTERVAL 7 DAY) 
                  AND DATE_SUB(da1.event_date, INTERVAL 2 DAY)
            ) THEN user_id 
        END) as returning_week_users,
        
        -- Users returning after long gaps (8+ days)
        COUNT(DISTINCT CASE 
            WHEN user_id NOT IN (
                SELECT user_id FROM daily_activity da4 
                WHERE da4.event_date BETWEEN DATE_SUB(da1.event_date, INTERVAL 7 DAY) 
                  AND DATE_SUB(da1.event_date, INTERVAL 1 DAY)
            ) AND user_id IN (
                SELECT user_id FROM daily_activity da5 
                WHERE da5.event_date < DATE_SUB(da1.event_date, INTERVAL 7 DAY)
            ) THEN user_id 
        END) as returning_long_gap_users,
        
        -- User lifecycle stages (simplified)
        COUNT(DISTINCT CASE 
            WHEN da1.event_date = (
                SELECT MIN(event_date) FROM daily_activity da6 WHERE da6.user_id = da1.user_id
            ) THEN user_id 
        END) as new_stage_users,
        
        COUNT(DISTINCT CASE 
            WHEN da1.event_date > (
                SELECT MIN(event_date) FROM daily_activity da7 WHERE da7.user_id = da1.user_id
            ) THEN user_id 
        END) as returning_users
        
    FROM daily_activity da1
    GROUP BY event_date
)

SELECT 
    event_date,
    daily_active_users,
    
    -- Core retention metrics
    consecutive_day_users,
    returning_week_users,
    returning_long_gap_users,
    new_stage_users,
    returning_users as growing_stage_users,
    0 as established_stage_users,  -- Simplified for now
    0 as mature_stage_users,       -- Simplified for now
    
    -- Percentages
    ROUND(100.0 * new_stage_users / NULLIF(daily_active_users, 0), 1) as new_stage_pct,
    ROUND(100.0 * returning_users / NULLIF(daily_active_users, 0), 1) as growing_stage_pct,
    0.0 as established_stage_pct,
    0.0 as mature_stage_pct,
    
    ROUND(100.0 * consecutive_day_users / NULLIF(daily_active_users, 0), 1) as consecutive_day_pct,
    ROUND(100.0 * returning_week_users / NULLIF(daily_active_users, 0), 1) as returning_week_pct,
    
    -- Retention health score (0-100)
    CASE 
        WHEN daily_active_users = 0 THEN 0
        ELSE ROUND(
            (consecutive_day_users * 3 + returning_week_users * 2 + returning_long_gap_users) * 100.0 / 
            (daily_active_users * 3), 1
        )
    END as daily_retention_health_score,
    
    -- Quality categories
    CASE 
        WHEN ROUND(100.0 * consecutive_day_users / NULLIF(daily_active_users, 0), 1) >= 80 THEN 'Excellent'
        WHEN ROUND(100.0 * consecutive_day_users / NULLIF(daily_active_users, 0), 1) >= 60 THEN 'Good'
        WHEN ROUND(100.0 * consecutive_day_users / NULLIF(daily_active_users, 0), 1) >= 40 THEN 'Average'
        WHEN ROUND(100.0 * consecutive_day_users / NULLIF(daily_active_users, 0), 1) >= 20 THEN 'Below Average'
        ELSE 'Poor'
    END as retention_quality_category,
    
    CASE 
        WHEN ROUND(100.0 * consecutive_day_users / NULLIF(daily_active_users, 0), 1) > 70 THEN 'High Engagement'
        WHEN ROUND(100.0 * consecutive_day_users / NULLIF(daily_active_users, 0), 1) > 40 THEN 'Moderate Engagement'
        ELSE 'Low Engagement'
    END as engagement_trend,
    
    -- Schema compatibility fields
    consecutive_day_users as users_consecutive_today,
    ROUND(100.0 * consecutive_day_users / NULLIF(daily_active_users, 0), 1) as consecutive_today_pct,
    
    CURRENT_TIMESTAMP() as calculated_at

FROM retention_metrics
ORDER BY event_date
    );
  