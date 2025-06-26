select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select event_sequence_in_session
from `heymax-interview`.`heymax_data`.`fct_events`
where event_sequence_in_session is null



      
    ) dbt_internal_test