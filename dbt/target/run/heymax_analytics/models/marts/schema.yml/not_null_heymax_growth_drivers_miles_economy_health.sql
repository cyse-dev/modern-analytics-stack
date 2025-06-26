select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select miles_economy_health
from `heymax-interview`.`heymax_analytics`.`heymax_growth_drivers`
where miles_economy_health is null



      
    ) dbt_internal_test