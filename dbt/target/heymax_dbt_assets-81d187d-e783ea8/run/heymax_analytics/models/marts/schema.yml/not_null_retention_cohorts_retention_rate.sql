select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select retention_rate
from `heymax-interview`.`heymax_data`.`retention_cohorts`
where retention_rate is null



      
    ) dbt_internal_test