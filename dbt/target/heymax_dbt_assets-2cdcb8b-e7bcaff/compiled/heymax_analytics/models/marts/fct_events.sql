

WITH events_with_session_info AS (
    SELECT 
        e.*,
        LAG(event_time) OVER (
            PARTITION BY user_id 
            ORDER BY event_time
        ) as prev_event_time,
        -- Mark session start (no previous event or > 30 min gap)
        CASE 
            WHEN LAG(event_time) OVER (
                PARTITION BY user_id 
                ORDER BY event_time
            ) IS NULL 
            OR TIMESTAMP_DIFF(
                event_time, 
                LAG(event_time) OVER (
                    PARTITION BY user_id 
                    ORDER BY event_time
                ), 
                MINUTE
            ) > 30 
            THEN 1 
            ELSE 0 
        END as is_session_start
    FROM `heymax-interview`.`heymax_analytics`.`stg_raw_user_events` e
),

events_with_session_id AS (
    SELECT 
        *,
        -- Create session ID by counting session starts
        CONCAT(
            user_id, 
            '_', 
            SUM(is_session_start) OVER (
                PARTITION BY user_id 
                ORDER BY event_time 
                ROWS UNBOUNDED PRECEDING
            )
        ) as derived_session_id
    FROM events_with_session_info
)

SELECT 
    to_hex(md5(cast(coalesce(cast(user_id as STRING), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(event_time as STRING), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(event_type as STRING), '_dbt_utils_surrogate_key_null_') as STRING))) as event_id,
    user_id,
    event_type,
    event_time,
    event_date,
    transaction_category,
    miles_amount,
    platform,
    utm_source,
    country,
    derived_session_id as session_id,
    is_session_start,
    -- Add event sequence within session
    ROW_NUMBER() OVER (
        PARTITION BY derived_session_id 
        ORDER BY event_time
    ) as event_sequence_in_session,
    CURRENT_TIMESTAMP() as processed_at
FROM events_with_session_id