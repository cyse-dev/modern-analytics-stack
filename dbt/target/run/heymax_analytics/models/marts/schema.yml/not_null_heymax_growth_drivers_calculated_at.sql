select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select calculated_at
from `heymax-interview`.`heymax_analytics`.`heymax_growth_drivers`
where calculated_at is null



      
    ) dbt_internal_test