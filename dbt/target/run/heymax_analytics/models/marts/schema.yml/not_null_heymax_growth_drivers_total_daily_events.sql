select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select total_daily_events
from `heymax-interview`.`heymax_analytics`.`heymax_growth_drivers`
where total_daily_events is null



      
    ) dbt_internal_test