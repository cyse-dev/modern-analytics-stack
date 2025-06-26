select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select retained_users
from `heymax-interview`.`heymax_data`.`social_capital_growth_accounting`
where retained_users is null



      
    ) dbt_internal_test