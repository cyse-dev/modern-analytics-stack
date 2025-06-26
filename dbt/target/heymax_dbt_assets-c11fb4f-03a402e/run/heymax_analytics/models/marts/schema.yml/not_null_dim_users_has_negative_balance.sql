select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select has_negative_balance
from `heymax-interview`.`heymax_data`.`dim_users`
where has_negative_balance is null



      
    ) dbt_internal_test