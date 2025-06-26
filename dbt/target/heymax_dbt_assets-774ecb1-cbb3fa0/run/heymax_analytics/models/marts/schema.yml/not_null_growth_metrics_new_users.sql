select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select new_users
from `heymax-interview`.`heymax_data`.`growth_metrics`
where new_users is null



      
    ) dbt_internal_test