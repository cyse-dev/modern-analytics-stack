
  
    

    create or replace table `heymax-interview`.`heymax_analytics`.`users_with_negative_miles`
      
    
    

    OPTIONS()
    as (
      

-- Table to highlight users with negative miles balance
-- This is a data quality check to identify potential data issues

SELECT 
    user_id,
    first_seen_at,
    last_seen_at,
    total_miles_earned,
    total_miles_redeemed,
    current_miles_balance,
    ABS(current_miles_balance) as negative_amount,
    miles_earned_transactions,
    miles_redeemed_transactions,
    first_platform,
    first_country,
    updated_at,
    CURRENT_TIMESTAMP() as flagged_at
FROM `heymax-interview`.`heymax_analytics`.`dim_users`
WHERE has_negative_balance = TRUE
ORDER BY current_miles_balance ASC
    );
  