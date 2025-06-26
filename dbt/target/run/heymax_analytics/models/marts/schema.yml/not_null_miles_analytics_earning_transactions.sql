select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select earning_transactions
from `heymax-interview`.`heymax_analytics`.`miles_analytics`
where earning_transactions is null



      
    ) dbt_internal_test