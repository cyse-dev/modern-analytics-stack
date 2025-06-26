select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select daily_active_users
from `heymax-interview`.`heymax_analytics`.`growth_metrics`
where daily_active_users is null



      
    ) dbt_internal_test