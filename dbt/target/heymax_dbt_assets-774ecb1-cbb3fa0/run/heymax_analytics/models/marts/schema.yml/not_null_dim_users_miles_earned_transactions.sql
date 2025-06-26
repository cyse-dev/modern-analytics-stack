select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select miles_earned_transactions
from `heymax-interview`.`heymax_data`.`dim_users`
where miles_earned_transactions is null



      
    ) dbt_internal_test