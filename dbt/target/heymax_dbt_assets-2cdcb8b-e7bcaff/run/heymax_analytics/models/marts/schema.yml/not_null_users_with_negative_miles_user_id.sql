select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select user_id
from `heymax-interview`.`heymax_analytics`.`users_with_negative_miles`
where user_id is null



      
    ) dbt_internal_test