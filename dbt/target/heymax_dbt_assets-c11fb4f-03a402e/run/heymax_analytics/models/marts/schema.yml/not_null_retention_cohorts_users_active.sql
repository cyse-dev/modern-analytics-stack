select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select users_active
from `heymax-interview`.`heymax_data`.`retention_cohorts`
where users_active is null



      
    ) dbt_internal_test