select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select daily_miles_earned
from `heymax-interview`.`heymax_analytics`.`miles_analytics`
where daily_miles_earned is null



      
    ) dbt_internal_test