

WITH daily_miles_activity AS (
    SELECT 
        event_date,
        event_type,
        transaction_category,
        platform,
        utm_source,
        country,
        COUNT(*) as transaction_count,
        COUNT(DISTINCT user_id) as unique_users,
        SUM(COALESCE(miles_amount, 0)) as total_miles,
        AVG(COALESCE(miles_amount, 0)) as avg_miles_per_transaction
    FROM `heymax-interview`.`heymax_data`.`fct_events`
    WHERE event_type IN ('miles_earned', 'miles_redeemed')
    GROUP BY event_date, event_type, transaction_category, platform, utm_source, country
),

user_miles_balance AS (
    SELECT 
        user_id,
        SUM(CASE WHEN event_type = 'miles_earned' THEN COALESCE(miles_amount, 0) ELSE 0 END) as total_earned,
        SUM(CASE WHEN event_type = 'miles_redeemed' THEN COALESCE(miles_amount, 0) ELSE 0 END) as total_redeemed,
        COUNT(CASE WHEN event_type = 'miles_earned' THEN 1 END) as earn_transactions,
        COUNT(CASE WHEN event_type = 'miles_redeemed' THEN 1 END) as redeem_transactions
    FROM `heymax-interview`.`heymax_data`.`fct_events`
    WHERE event_type IN ('miles_earned', 'miles_redeemed')
    GROUP BY user_id
),

miles_summary AS (
    SELECT 
        event_date,
        SUM(CASE WHEN event_type = 'miles_earned' THEN total_miles ELSE 0 END) as daily_miles_earned,
        SUM(CASE WHEN event_type = 'miles_redeemed' THEN total_miles ELSE 0 END) as daily_miles_redeemed,
        COUNT(CASE WHEN event_type = 'miles_earned' THEN unique_users END) as users_earning,
        COUNT(CASE WHEN event_type = 'miles_redeemed' THEN unique_users END) as users_redeeming,
        SUM(CASE WHEN event_type = 'miles_earned' THEN transaction_count ELSE 0 END) as earning_transactions,
        SUM(CASE WHEN event_type = 'miles_redeemed' THEN transaction_count ELSE 0 END) as redeeming_transactions
    FROM daily_miles_activity
    GROUP BY event_date
)

SELECT 
    ms.event_date,
    ms.daily_miles_earned,
    ms.daily_miles_redeemed,
    ms.daily_miles_earned - ms.daily_miles_redeemed as net_miles_change,
    ms.users_earning,
    ms.users_redeeming,
    ms.earning_transactions,
    ms.redeeming_transactions,
    -- Running totals
    SUM(ms.daily_miles_earned) OVER (
        ORDER BY ms.event_date 
        ROWS UNBOUNDED PRECEDING
    ) as cumulative_miles_earned,
    SUM(ms.daily_miles_redeemed) OVER (
        ORDER BY ms.event_date 
        ROWS UNBOUNDED PRECEDING
    ) as cumulative_miles_redeemed,
    -- 7-day moving averages
    AVG(ms.daily_miles_earned) OVER (
        ORDER BY ms.event_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as avg_7d_miles_earned,
    AVG(ms.daily_miles_redeemed) OVER (
        ORDER BY ms.event_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as avg_7d_miles_redeemed,
    CURRENT_TIMESTAMP() as calculated_at
FROM miles_summary ms
ORDER BY ms.event_date