select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select consecutive_today_pct
from `heymax-interview`.`heymax_analytics`.`retention_quality_framework`
where consecutive_today_pct is null



      
    ) dbt_internal_test