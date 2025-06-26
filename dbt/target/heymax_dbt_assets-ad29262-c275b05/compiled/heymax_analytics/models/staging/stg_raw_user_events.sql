

SELECT
    user_id,
    event_type,
    event_time,
    transaction_category,
    miles_amount,
    platform,
    utm_source,
    country,
    DATE(event_time) as event_date
FROM `heymax-interview`.`heymax_data`.`raw_user_events`
WHERE event_time IS NOT NULL
    AND user_id IS NOT NULL