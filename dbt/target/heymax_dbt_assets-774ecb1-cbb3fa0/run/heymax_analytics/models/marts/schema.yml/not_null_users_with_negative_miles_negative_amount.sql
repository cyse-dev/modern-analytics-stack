select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select negative_amount
from `heymax-interview`.`heymax_data`.`users_with_negative_miles`
where negative_amount is null



      
    ) dbt_internal_test