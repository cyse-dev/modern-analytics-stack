select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select is_session_start
from `heymax-interview`.`heymax_analytics`.`fct_events`
where is_session_start is null



      
    ) dbt_internal_test