select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select daily_retention_health_score
from `heymax-interview`.`heymax_analytics`.`retention_quality_framework`
where daily_retention_health_score is null



      
    ) dbt_internal_test