select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select event_type
from `heymax-interview`.`heymax_analytics`.`fct_events`
where event_type is null



      
    ) dbt_internal_test