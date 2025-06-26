select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select reward_search_events
from `heymax-interview`.`heymax_data`.`dim_users`
where reward_search_events is null



      
    ) dbt_internal_test