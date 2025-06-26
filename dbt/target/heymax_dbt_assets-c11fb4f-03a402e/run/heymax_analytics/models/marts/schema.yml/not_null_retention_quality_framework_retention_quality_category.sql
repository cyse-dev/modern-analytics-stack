select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select retention_quality_category
from `heymax-interview`.`heymax_data`.`retention_quality_framework`
where retention_quality_category is null



      
    ) dbt_internal_test