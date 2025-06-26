select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select miles_redeemed_transactions
from `heymax-interview`.`heymax_analytics`.`dim_users`
where miles_redeemed_transactions is null



      
    ) dbt_internal_test