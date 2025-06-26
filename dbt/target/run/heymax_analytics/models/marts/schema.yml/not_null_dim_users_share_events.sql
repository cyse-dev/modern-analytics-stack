select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select share_events
from `heymax-interview`.`heymax_analytics`.`dim_users`
where share_events is null



      
    ) dbt_internal_test