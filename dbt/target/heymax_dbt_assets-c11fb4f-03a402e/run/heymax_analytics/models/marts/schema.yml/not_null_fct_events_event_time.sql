select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select event_time
from `heymax-interview`.`heymax_data`.`fct_events`
where event_time is null



      
    ) dbt_internal_test