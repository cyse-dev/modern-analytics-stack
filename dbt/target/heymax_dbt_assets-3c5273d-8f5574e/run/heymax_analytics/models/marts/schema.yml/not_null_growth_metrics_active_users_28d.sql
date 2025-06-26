select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select active_users_28d
from `heymax-interview`.`heymax_data`.`growth_metrics`
where active_users_28d is null



      
    ) dbt_internal_test