select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select monthly_active_users_30d
from `heymax-interview`.`heymax_analytics`.`growth_metrics`
where monthly_active_users_30d is null



      
    ) dbt_internal_test