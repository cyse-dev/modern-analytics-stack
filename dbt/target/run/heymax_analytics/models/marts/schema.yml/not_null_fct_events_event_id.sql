select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select event_id
from `heymax-interview`.`heymax_analytics`.`fct_events`
where event_id is null



      
    ) dbt_internal_test