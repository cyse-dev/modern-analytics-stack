select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select activity_trend_7d
from `heymax-interview`.`heymax_analytics`.`growth_metrics`
where activity_trend_7d is null



      
    ) dbt_internal_test