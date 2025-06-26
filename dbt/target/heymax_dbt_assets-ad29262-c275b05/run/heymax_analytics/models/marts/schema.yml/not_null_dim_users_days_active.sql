select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select days_active
from `heymax-interview`.`heymax_data`.`dim_users`
where days_active is null



      
    ) dbt_internal_test