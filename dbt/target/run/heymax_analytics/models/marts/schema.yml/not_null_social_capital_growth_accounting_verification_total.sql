select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select verification_total
from `heymax-interview`.`heymax_analytics`.`social_capital_growth_accounting`
where verification_total is null



      
    ) dbt_internal_test