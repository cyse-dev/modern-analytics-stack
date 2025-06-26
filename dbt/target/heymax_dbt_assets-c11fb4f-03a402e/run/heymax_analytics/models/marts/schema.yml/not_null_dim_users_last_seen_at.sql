select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select last_seen_at
from `heymax-interview`.`heymax_data`.`dim_users`
where last_seen_at is null



      
    ) dbt_internal_test