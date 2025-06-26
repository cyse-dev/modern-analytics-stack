select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select business_stage
from `heymax-interview`.`heymax_data`.`quick_ratio_analysis`
where business_stage is null



      
    ) dbt_internal_test