select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select daily_growth_quality
from `heymax-interview`.`heymax_data`.`growth_metrics`
where daily_growth_quality is null



      
    ) dbt_internal_test