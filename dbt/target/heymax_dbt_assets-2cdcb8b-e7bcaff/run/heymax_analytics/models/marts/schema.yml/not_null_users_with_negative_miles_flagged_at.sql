select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select flagged_at
from `heymax-interview`.`heymax_analytics`.`users_with_negative_miles`
where flagged_at is null



      
    ) dbt_internal_test