select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select cumulative_miles_earned
from `heymax-interview`.`heymax_data`.`miles_analytics`
where cumulative_miles_earned is null



      
    ) dbt_internal_test