select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select activity_month
from `heymax-interview`.`heymax_analytics`.`social_capital_growth_accounting`
where activity_month is null



      
    ) dbt_internal_test