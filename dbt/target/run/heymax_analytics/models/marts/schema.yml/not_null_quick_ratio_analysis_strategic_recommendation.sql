select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select strategic_recommendation
from `heymax-interview`.`heymax_analytics`.`quick_ratio_analysis`
where strategic_recommendation is null



      
    ) dbt_internal_test