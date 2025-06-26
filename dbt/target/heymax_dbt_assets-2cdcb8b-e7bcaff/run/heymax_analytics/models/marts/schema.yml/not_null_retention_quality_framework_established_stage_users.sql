select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select established_stage_users
from `heymax-interview`.`heymax_analytics`.`retention_quality_framework`
where established_stage_users is null



      
    ) dbt_internal_test