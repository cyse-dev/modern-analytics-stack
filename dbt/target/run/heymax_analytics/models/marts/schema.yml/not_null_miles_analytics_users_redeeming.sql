select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select users_redeeming
from `heymax-interview`.`heymax_analytics`.`miles_analytics`
where users_redeeming is null



      
    ) dbt_internal_test