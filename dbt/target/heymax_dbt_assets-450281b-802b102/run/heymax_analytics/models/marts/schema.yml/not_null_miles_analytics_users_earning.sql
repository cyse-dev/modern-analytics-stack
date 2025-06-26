select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select users_earning
from `heymax-interview`.`heymax_data`.`miles_analytics`
where users_earning is null



      
    ) dbt_internal_test