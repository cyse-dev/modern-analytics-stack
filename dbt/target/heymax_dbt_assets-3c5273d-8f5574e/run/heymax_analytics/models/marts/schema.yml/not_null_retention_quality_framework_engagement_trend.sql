select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select engagement_trend
from `heymax-interview`.`heymax_data`.`retention_quality_framework`
where engagement_trend is null



      
    ) dbt_internal_test