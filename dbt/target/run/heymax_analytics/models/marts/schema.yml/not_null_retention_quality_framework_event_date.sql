select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select event_date
from `heymax-interview`.`heymax_analytics`.`retention_quality_framework`
where event_date is null



      
    ) dbt_internal_test