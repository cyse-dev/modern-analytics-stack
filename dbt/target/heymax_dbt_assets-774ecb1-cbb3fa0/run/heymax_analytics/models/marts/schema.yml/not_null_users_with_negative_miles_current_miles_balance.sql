select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select current_miles_balance
from `heymax-interview`.`heymax_data`.`users_with_negative_miles`
where current_miles_balance is null



      
    ) dbt_internal_test