select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select total_mau
from `heymax-interview`.`heymax_data`.`social_capital_growth_accounting`
where total_mau is null



      
    ) dbt_internal_test