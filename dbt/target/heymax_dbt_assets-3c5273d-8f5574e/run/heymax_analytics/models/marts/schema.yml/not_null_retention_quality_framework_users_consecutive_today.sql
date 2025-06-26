select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select users_consecutive_today
from `heymax-interview`.`heymax_data`.`retention_quality_framework`
where users_consecutive_today is null



      
    ) dbt_internal_test