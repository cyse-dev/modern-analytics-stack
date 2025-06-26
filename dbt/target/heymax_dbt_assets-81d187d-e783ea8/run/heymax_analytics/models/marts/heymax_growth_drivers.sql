
  
    

    create or replace table `heymax-interview`.`heymax_data`.`heymax_growth_drivers`
      
    
    

    OPTIONS()
    as (
      

-- HeyMax Business-Specific Growth Drivers
-- Analyzes miles economy, social engagement, and platform-specific growth factors

WITH daily_event_summary AS (
    SELECT 
        event_date,
        event_type,
        platform,
        utm_source,
        country,
        COUNT(*) as event_count,
        COUNT(DISTINCT user_id) as unique_users,
        SUM(COALESCE(miles_amount, 0)) as total_miles,
        AVG(COALESCE(miles_amount, 0)) as avg_miles_per_event
    FROM `heymax-interview`.`heymax_data`.`fct_events`
    GROUP BY event_date, event_type, platform, utm_source, country
),

daily_miles_economy AS (
    SELECT 
        event_date,
        SUM(CASE WHEN event_type = 'miles_earned' THEN COALESCE(miles_amount, 0) ELSE 0 END) as daily_miles_earned,
        SUM(CASE WHEN event_type = 'miles_redeemed' THEN COALESCE(miles_amount, 0) ELSE 0 END) as daily_miles_redeemed,
        COUNT(DISTINCT CASE WHEN event_type = 'miles_earned' THEN user_id END) as users_earning_miles,
        COUNT(DISTINCT CASE WHEN event_type = 'miles_redeemed' THEN user_id END) as users_redeeming_miles,
        COUNT(CASE WHEN event_type = 'miles_earned' THEN 1 END) as miles_earning_events,
        COUNT(CASE WHEN event_type = 'miles_redeemed' THEN 1 END) as miles_redemption_events
    FROM `heymax-interview`.`heymax_data`.`fct_events`
    GROUP BY event_date
),

daily_social_engagement AS (
    SELECT 
        event_date,
        COUNT(CASE WHEN event_type = 'share' THEN 1 END) as daily_shares,
        COUNT(CASE WHEN event_type = 'like' THEN 1 END) as daily_likes,
        COUNT(CASE WHEN event_type = 'reward_search' THEN 1 END) as daily_searches,
        COUNT(DISTINCT CASE WHEN event_type = 'share' THEN user_id END) as users_sharing,
        COUNT(DISTINCT CASE WHEN event_type = 'like' THEN user_id END) as users_liking,
        COUNT(DISTINCT CASE WHEN event_type = 'reward_search' THEN user_id END) as users_searching
    FROM `heymax-interview`.`heymax_data`.`fct_events`
    GROUP BY event_date
),

daily_platform_metrics AS (
    SELECT 
        event_date,
        COUNT(DISTINCT CASE WHEN platform = 'iOS' THEN user_id END) as ios_users,
        COUNT(DISTINCT CASE WHEN platform = 'Android' THEN user_id END) as android_users,
        COUNT(DISTINCT CASE WHEN platform = 'Web' THEN user_id END) as web_users,
        COUNT(CASE WHEN platform = 'iOS' THEN 1 END) as ios_events,
        COUNT(CASE WHEN platform = 'Android' THEN 1 END) as android_events,
        COUNT(CASE WHEN platform = 'Web' THEN 1 END) as web_events
    FROM `heymax-interview`.`heymax_data`.`fct_events`
    GROUP BY event_date
),

daily_acquisition_channels AS (
    SELECT 
        event_date,
        -- New users by UTM source (first day they appear)
        COUNT(DISTINCT CASE 
            WHEN utm_source = 'organic' AND event_date = (
                SELECT MIN(event_date) FROM `heymax-interview`.`heymax_data`.`fct_events` f2 
                WHERE f2.user_id = f1.user_id
            ) THEN user_id 
        END) as new_organic_users,
        
        COUNT(DISTINCT CASE 
            WHEN utm_source = 'paid' AND event_date = (
                SELECT MIN(event_date) FROM `heymax-interview`.`heymax_data`.`fct_events` f2 
                WHERE f2.user_id = f1.user_id
            ) THEN user_id 
        END) as new_paid_users,
        
        COUNT(DISTINCT CASE 
            WHEN utm_source = 'social' AND event_date = (
                SELECT MIN(event_date) FROM `heymax-interview`.`heymax_data`.`fct_events` f2 
                WHERE f2.user_id = f1.user_id
            ) THEN user_id 
        END) as new_social_users,
        
        COUNT(DISTINCT CASE 
            WHEN utm_source = 'referral' AND event_date = (
                SELECT MIN(event_date) FROM `heymax-interview`.`heymax_data`.`fct_events` f2 
                WHERE f2.user_id = f1.user_id
            ) THEN user_id 
        END) as new_referral_users
        
    FROM `heymax-interview`.`heymax_data`.`fct_events` f1
    GROUP BY event_date
),

-- Overall daily activity context
daily_totals AS (
    SELECT 
        event_date,
        COUNT(DISTINCT user_id) as daily_active_users,
        COUNT(*) as total_daily_events
    FROM `heymax-interview`.`heymax_data`.`fct_events`
    GROUP BY event_date
)

SELECT 
    dt.event_date,
    dt.daily_active_users,
    dt.total_daily_events,
    
    -- Miles Economy Health
    dme.daily_miles_earned,
    dme.daily_miles_redeemed,
    dme.daily_miles_earned - dme.daily_miles_redeemed as net_miles_change,
    dme.users_earning_miles,
    dme.users_redeeming_miles,
    dme.miles_earning_events,
    dme.miles_redemption_events,
    
    -- Miles Economy Ratios
    CASE 
        WHEN dme.daily_miles_redeemed > 0 
        THEN ROUND(dme.daily_miles_earned / dme.daily_miles_redeemed, 2)
        ELSE NULL 
    END as miles_earn_redeem_ratio,
    
    ROUND(100.0 * dme.users_earning_miles / NULLIF(dt.daily_active_users, 0), 1) as earning_user_pct,
    ROUND(100.0 * dme.users_redeeming_miles / NULLIF(dt.daily_active_users, 0), 1) as redeeming_user_pct,
    
    -- Social Engagement
    dse.daily_shares,
    dse.daily_likes,
    dse.daily_searches,
    dse.users_sharing,
    dse.users_liking,
    dse.users_searching,
    
    -- Social Engagement Rates
    ROUND(100.0 * dse.users_sharing / NULLIF(dt.daily_active_users, 0), 1) as sharing_user_pct,
    ROUND(100.0 * dse.users_liking / NULLIF(dt.daily_active_users, 0), 1) as liking_user_pct,
    ROUND(100.0 * dse.users_searching / NULLIF(dt.daily_active_users, 0), 1) as searching_user_pct,
    
    -- Platform Distribution
    dpm.ios_users,
    dpm.android_users,
    dpm.web_users,
    ROUND(100.0 * dpm.ios_users / NULLIF(dt.daily_active_users, 0), 1) as ios_user_pct,
    ROUND(100.0 * dpm.android_users / NULLIF(dt.daily_active_users, 0), 1) as android_user_pct,
    ROUND(100.0 * dpm.web_users / NULLIF(dt.daily_active_users, 0), 1) as web_user_pct,
    
    -- Platform Engagement (events per user)
    CASE WHEN dpm.ios_users > 0 THEN ROUND(dpm.ios_events / dpm.ios_users, 1) ELSE 0 END as ios_events_per_user,
    CASE WHEN dpm.android_users > 0 THEN ROUND(dpm.android_events / dpm.android_users, 1) ELSE 0 END as android_events_per_user,
    CASE WHEN dpm.web_users > 0 THEN ROUND(dpm.web_events / dpm.web_users, 1) ELSE 0 END as web_events_per_user,
    
    -- New User Acquisition by Channel
    dac.new_organic_users,
    dac.new_paid_users,
    dac.new_social_users,
    dac.new_referral_users,
    dac.new_organic_users + dac.new_paid_users + dac.new_social_users + dac.new_referral_users as total_new_users,
    
    -- Business Health Indicators
    CASE 
        WHEN dme.daily_miles_earned > dme.daily_miles_redeemed * 1.2 THEN 'Healthy Growth'
        WHEN dme.daily_miles_earned > dme.daily_miles_redeemed THEN 'Stable'
        WHEN dme.daily_miles_redeemed > dme.daily_miles_earned * 1.2 THEN 'High Redemption'
        ELSE 'Balanced'
    END as miles_economy_health,
    
    CASE 
        WHEN ROUND(100.0 * (dse.users_sharing + dse.users_liking) / NULLIF(dt.daily_active_users, 0), 1) >= 20 THEN 'High Social'
        WHEN ROUND(100.0 * (dse.users_sharing + dse.users_liking) / NULLIF(dt.daily_active_users, 0), 1) >= 10 THEN 'Moderate Social'
        ELSE 'Low Social'
    END as social_engagement_level,
    
    -- Feature Adoption Score (0-100)
    ROUND(
        (LEAST(100, ROUND(100.0 * dme.users_earning_miles / NULLIF(dt.daily_active_users, 0), 1)) * 0.3 +
         LEAST(100, ROUND(100.0 * dme.users_redeeming_miles / NULLIF(dt.daily_active_users, 0), 1)) * 0.2 +
         LEAST(100, ROUND(100.0 * dse.users_sharing / NULLIF(dt.daily_active_users, 0), 1)) * 0.2 +
         LEAST(100, ROUND(100.0 * dse.users_liking / NULLIF(dt.daily_active_users, 0), 1)) * 0.15 +
         LEAST(100, ROUND(100.0 * dse.users_searching / NULLIF(dt.daily_active_users, 0), 1)) * 0.15), 1
    ) as feature_adoption_score,
    
    -- 7-day moving averages for trend analysis
    AVG(dme.daily_miles_earned) OVER (
        ORDER BY dt.event_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as avg_7d_miles_earned,
    
    AVG(dse.daily_shares + dse.daily_likes) OVER (
        ORDER BY dt.event_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as avg_7d_social_actions,
    
    CURRENT_TIMESTAMP() as calculated_at

FROM daily_totals dt
LEFT JOIN daily_miles_economy dme ON dt.event_date = dme.event_date
LEFT JOIN daily_social_engagement dse ON dt.event_date = dse.event_date
LEFT JOIN daily_platform_metrics dpm ON dt.event_date = dpm.event_date
LEFT JOIN daily_acquisition_channels dac ON dt.event_date = dac.event_date
ORDER BY dt.event_date
    );
  