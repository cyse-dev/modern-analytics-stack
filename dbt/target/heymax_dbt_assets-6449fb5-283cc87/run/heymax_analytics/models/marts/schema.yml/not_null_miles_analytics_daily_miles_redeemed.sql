select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select daily_miles_redeemed
from `heymax-interview`.`heymax_data`.`miles_analytics`
where daily_miles_redeemed is null



      
    ) dbt_internal_test