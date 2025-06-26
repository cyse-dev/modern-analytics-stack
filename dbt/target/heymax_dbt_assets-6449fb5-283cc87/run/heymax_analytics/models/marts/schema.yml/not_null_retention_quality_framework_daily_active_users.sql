select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select daily_active_users
from `heymax-interview`.`heymax_data`.`retention_quality_framework`
where daily_active_users is null



      
    ) dbt_internal_test