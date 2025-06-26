
  
    

    create or replace table `heymax-interview`.`heymax_data`.`dim_users`
      
    
    

    OPTIONS()
    as (
      

WITH user_first_seen AS (
    SELECT 
        user_id,
        MIN(event_time) as first_seen_at,
        MIN(event_date) as first_seen_date
    FROM `heymax-interview`.`heymax_data`.`stg_raw_user_events`
    GROUP BY user_id
),

user_last_seen AS (
    SELECT 
        user_id,
        MAX(event_time) as last_seen_at,
        MAX(event_date) as last_seen_date
    FROM `heymax-interview`.`heymax_data`.`stg_raw_user_events`
    GROUP BY user_id
),

user_attributes AS (
    SELECT DISTINCT
        user_id,
        FIRST_VALUE(platform) OVER (
            PARTITION BY user_id 
            ORDER BY event_time ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) as first_platform,
        FIRST_VALUE(utm_source) OVER (
            PARTITION BY user_id 
            ORDER BY event_time ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) as first_utm_source,
        FIRST_VALUE(country) OVER (
            PARTITION BY user_id 
            ORDER BY event_time ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) as first_country
    FROM `heymax-interview`.`heymax_data`.`stg_raw_user_events`
),

user_miles_summary AS (
    SELECT 
        user_id,
        SUM(CASE WHEN event_type = 'miles_earned' THEN miles_amount ELSE 0 END) as total_miles_earned,
        SUM(CASE WHEN event_type = 'miles_redeemed' THEN miles_amount ELSE 0 END) as total_miles_redeemed,
        COUNT(CASE WHEN event_type = 'miles_earned' THEN 1 END) as miles_earned_transactions,
        COUNT(CASE WHEN event_type = 'miles_redeemed' THEN 1 END) as miles_redeemed_transactions,
        COUNT(CASE WHEN event_type = 'share' THEN 1 END) as share_events,
        COUNT(CASE WHEN event_type = 'like' THEN 1 END) as like_events,
        COUNT(CASE WHEN event_type = 'reward_search' THEN 1 END) as reward_search_events
    FROM `heymax-interview`.`heymax_data`.`stg_raw_user_events`
    GROUP BY user_id
)

SELECT 
    uf.user_id,
    uf.first_seen_at,
    uf.first_seen_date,
    ul.last_seen_at,
    ul.last_seen_date,
    DATE_DIFF(ul.last_seen_date, uf.first_seen_date, DAY) as days_active,
    ua.first_platform,
    ua.first_utm_source,
    ua.first_country,
    ums.total_miles_earned,
    ums.total_miles_redeemed,
    COALESCE(ums.total_miles_earned, 0) - COALESCE(ums.total_miles_redeemed, 0) as current_miles_balance,
    CASE 
        WHEN COALESCE(ums.total_miles_earned, 0) - COALESCE(ums.total_miles_redeemed, 0) < 0 
        THEN TRUE 
        ELSE FALSE 
    END as has_negative_balance,
    ums.miles_earned_transactions,
    ums.miles_redeemed_transactions,
    ums.share_events,
    ums.like_events,
    ums.reward_search_events,
    CURRENT_TIMESTAMP() as updated_at
FROM user_first_seen uf
LEFT JOIN user_last_seen ul ON uf.user_id = ul.user_id
LEFT JOIN user_attributes ua ON uf.user_id = ua.user_id
LEFT JOIN user_miles_summary ums ON uf.user_id = ums.user_id
    );
  