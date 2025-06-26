select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select redeeming_transactions
from `heymax-interview`.`heymax_data`.`miles_analytics`
where redeeming_transactions is null



      
    ) dbt_internal_test