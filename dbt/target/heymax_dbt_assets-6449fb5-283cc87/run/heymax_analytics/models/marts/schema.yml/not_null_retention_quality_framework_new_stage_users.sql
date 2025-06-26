select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select new_stage_users
from `heymax-interview`.`heymax_data`.`retention_quality_framework`
where new_stage_users is null



      
    ) dbt_internal_test