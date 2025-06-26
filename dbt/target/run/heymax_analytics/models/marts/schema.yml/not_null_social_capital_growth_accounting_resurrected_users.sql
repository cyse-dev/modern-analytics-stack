select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select resurrected_users
from `heymax-interview`.`heymax_analytics`.`social_capital_growth_accounting`
where resurrected_users is null



      
    ) dbt_internal_test