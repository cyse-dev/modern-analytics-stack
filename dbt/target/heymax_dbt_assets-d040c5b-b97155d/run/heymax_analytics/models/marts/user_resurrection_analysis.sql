
  
    

    create or replace table `heymax-interview`.`heymax_data`.`user_resurrection_analysis`
      
    
    

    OPTIONS()
    as (
      

-- User Resurrection Analysis
-- Analyzes dormant users and successful resurrection patterns

WITH user_activity_gaps AS (
    SELECT 
        user_id,
        event_date,
        LAG(event_date) OVER (PARTITION BY user_id ORDER BY event_date) as prev_activity_date,
        LEAD(event_date) OVER (PARTITION BY user_id ORDER BY event_date) as next_activity_date,
        -- Calculate gap length in days
        CASE 
            WHEN LAG(event_date) OVER (PARTITION BY user_id ORDER BY event_date) IS NOT NULL
            THEN DATE_DIFF(event_date, LAG(event_date) OVER (PARTITION BY user_id ORDER BY event_date), DAY)
            ELSE 0
        END as days_since_last_activity
    FROM (
        SELECT DISTINCT user_id, event_date 
        FROM `heymax-interview`.`heymax_data`.`fct_events`
        WHERE event_type IN ('reward_search', 'miles_earned', 'miles_redeemed')
    ) daily_activity
),

resurrection_events AS (
    SELECT 
        user_id,
        event_date as resurrection_date,
        prev_activity_date as last_activity_before_gap,
        days_since_last_activity as dormancy_length,
        
        -- Classify dormancy periods
        CASE 
            WHEN days_since_last_activity <= 1 THEN 'Consecutive'
            WHEN days_since_last_activity BETWEEN 2 AND 7 THEN 'Short Dormancy (2-7 days)'
            WHEN days_since_last_activity BETWEEN 8 AND 30 THEN 'Medium Dormancy (8-30 days)'
            WHEN days_since_last_activity BETWEEN 31 AND 90 THEN 'Long Dormancy (31-90 days)'
            WHEN days_since_last_activity > 90 THEN 'Very Long Dormancy (90+ days)'
            ELSE 'New User'
        END as dormancy_category,
        
        -- User's first activity date for lifecycle analysis
        MIN(event_date) OVER (PARTITION BY user_id) as user_first_date
        
    FROM user_activity_gaps
    WHERE days_since_last_activity > 1  -- Only resurrection events (not consecutive days)
),

daily_resurrection_metrics AS (
    SELECT 
        resurrection_date as event_date,
        
        -- Count resurrections by dormancy length
        COUNT(DISTINCT user_id) as total_resurrections,
        COUNT(DISTINCT CASE WHEN dormancy_category = 'Short Dormancy (2-7 days)' THEN user_id END) as short_dormancy_resurrections,
        COUNT(DISTINCT CASE WHEN dormancy_category = 'Medium Dormancy (8-30 days)' THEN user_id END) as medium_dormancy_resurrections,
        COUNT(DISTINCT CASE WHEN dormancy_category = 'Long Dormancy (31-90 days)' THEN user_id END) as long_dormancy_resurrections,
        COUNT(DISTINCT CASE WHEN dormancy_category = 'Very Long Dormancy (90+ days)' THEN user_id END) as very_long_dormancy_resurrections,
        
        -- Average dormancy length
        ROUND(AVG(dormancy_length), 1) as avg_dormancy_length,
        ROUND(AVG(CASE WHEN dormancy_category != 'Consecutive' THEN dormancy_length END), 1) as avg_resurrection_gap,
        
        -- Resurrection success rates (users who return after gaps)
        COUNT(DISTINCT CASE WHEN dormancy_length BETWEEN 2 AND 7 THEN user_id END) as resurrected_2_7_days,
        COUNT(DISTINCT CASE WHEN dormancy_length BETWEEN 8 AND 30 THEN user_id END) as resurrected_8_30_days,
        COUNT(DISTINCT CASE WHEN dormancy_length > 30 THEN user_id END) as resurrected_30_plus_days
        
    FROM resurrection_events
    GROUP BY resurrection_date
),

-- Overall daily activity for context
daily_activity_context AS (
    SELECT 
        event_date,
        COUNT(DISTINCT user_id) as daily_active_users
    FROM `heymax-interview`.`heymax_data`.`fct_events`
    WHERE event_type IN ('reward_search', 'miles_earned', 'miles_redeemed')
    GROUP BY event_date
)

SELECT 
    dac.event_date,
    dac.daily_active_users,
    
    -- Resurrection metrics
    COALESCE(drm.total_resurrections, 0) as total_resurrections,
    COALESCE(drm.short_dormancy_resurrections, 0) as short_dormancy_resurrections,
    COALESCE(drm.medium_dormancy_resurrections, 0) as medium_dormancy_resurrections,
    COALESCE(drm.long_dormancy_resurrections, 0) as long_dormancy_resurrections,
    COALESCE(drm.very_long_dormancy_resurrections, 0) as very_long_dormancy_resurrections,
    
    -- Resurrection percentages of DAU
    ROUND(100.0 * COALESCE(drm.total_resurrections, 0) / NULLIF(dac.daily_active_users, 0), 1) as resurrection_pct_of_dau,
    ROUND(100.0 * COALESCE(drm.short_dormancy_resurrections, 0) / NULLIF(dac.daily_active_users, 0), 1) as short_dormancy_pct,
    ROUND(100.0 * COALESCE(drm.medium_dormancy_resurrections, 0) / NULLIF(dac.daily_active_users, 0), 1) as medium_dormancy_pct,
    ROUND(100.0 * COALESCE(drm.long_dormancy_resurrections, 0) / NULLIF(dac.daily_active_users, 0), 1) as long_dormancy_pct,
    
    -- Average gaps
    drm.avg_dormancy_length,
    drm.avg_resurrection_gap,
    
    -- Resurrection effectiveness score (weighted by difficulty)
    CASE 
        WHEN dac.daily_active_users = 0 THEN 0
        ELSE ROUND(
            (COALESCE(drm.short_dormancy_resurrections, 0) * 1 + 
             COALESCE(drm.medium_dormancy_resurrections, 0) * 2 + 
             COALESCE(drm.long_dormancy_resurrections, 0) * 3 + 
             COALESCE(drm.very_long_dormancy_resurrections, 0) * 4) * 100.0 / 
            NULLIF(dac.daily_active_users, 0), 1
        )
    END as resurrection_effectiveness_score,
    
    -- Resurrection quality category
    CASE 
        WHEN ROUND(100.0 * COALESCE(drm.total_resurrections, 0) / NULLIF(dac.daily_active_users, 0), 1) >= 30 THEN 'Excellent'
        WHEN ROUND(100.0 * COALESCE(drm.total_resurrections, 0) / NULLIF(dac.daily_active_users, 0), 1) >= 20 THEN 'Good'
        WHEN ROUND(100.0 * COALESCE(drm.total_resurrections, 0) / NULLIF(dac.daily_active_users, 0), 1) >= 10 THEN 'Average'
        WHEN ROUND(100.0 * COALESCE(drm.total_resurrections, 0) / NULLIF(dac.daily_active_users, 0), 1) >= 5 THEN 'Below Average'
        ELSE 'Poor'
    END as resurrection_quality_category,
    
    -- Campaign insights
    CASE 
        WHEN COALESCE(drm.total_resurrections, 0) = 0 THEN 'No Resurrections'
        WHEN COALESCE(drm.short_dormancy_resurrections, 0) > COALESCE(drm.medium_dormancy_resurrections, 0) + COALESCE(drm.long_dormancy_resurrections, 0) 
             THEN 'Quick Return Focus'
        WHEN COALESCE(drm.long_dormancy_resurrections, 0) + COALESCE(drm.very_long_dormancy_resurrections, 0) > COALESCE(drm.short_dormancy_resurrections, 0) 
             THEN 'Long-term Recovery'
        ELSE 'Balanced Recovery'
    END as resurrection_pattern,
    
    -- 7-day moving averages for trends
    AVG(COALESCE(drm.total_resurrections, 0)) OVER (
        ORDER BY dac.event_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as avg_7d_resurrections,
    
    AVG(ROUND(100.0 * COALESCE(drm.total_resurrections, 0) / NULLIF(dac.daily_active_users, 0), 1)) OVER (
        ORDER BY dac.event_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as avg_7d_resurrection_pct,
    
    CURRENT_TIMESTAMP() as calculated_at

FROM daily_activity_context dac
LEFT JOIN daily_resurrection_metrics drm ON dac.event_date = drm.event_date
ORDER BY dac.event_date
    );
  