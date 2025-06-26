select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select alert_level
from `heymax-interview`.`heymax_analytics`.`quick_ratio_analysis`
where alert_level is null



      
    ) dbt_internal_test