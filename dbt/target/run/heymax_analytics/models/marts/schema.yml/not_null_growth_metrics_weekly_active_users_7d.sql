select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select weekly_active_users_7d
from `heymax-interview`.`heymax_analytics`.`growth_metrics`
where weekly_active_users_7d is null



      
    ) dbt_internal_test