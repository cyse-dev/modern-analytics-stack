select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select cohort_size
from `heymax-interview`.`heymax_analytics`.`retention_cohorts`
where cohort_size is null



      
    ) dbt_internal_test