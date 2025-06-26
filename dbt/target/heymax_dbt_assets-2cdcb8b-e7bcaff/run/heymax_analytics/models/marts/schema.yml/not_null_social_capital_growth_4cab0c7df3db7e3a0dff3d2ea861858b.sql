select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select growth_quality_category
from `heymax-interview`.`heymax_analytics`.`social_capital_growth_accounting`
where growth_quality_category is null



      
    ) dbt_internal_test