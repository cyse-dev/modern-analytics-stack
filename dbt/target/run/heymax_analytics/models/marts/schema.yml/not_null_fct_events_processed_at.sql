select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select processed_at
from `heymax-interview`.`heymax_analytics`.`fct_events`
where processed_at is null



      
    ) dbt_internal_test