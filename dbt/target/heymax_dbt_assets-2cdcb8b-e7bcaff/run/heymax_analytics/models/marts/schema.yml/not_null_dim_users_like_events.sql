select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select like_events
from `heymax-interview`.`heymax_analytics`.`dim_users`
where like_events is null



      
    ) dbt_internal_test