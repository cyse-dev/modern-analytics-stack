select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select total_resurrections
from `heymax-interview`.`heymax_data`.`user_resurrection_analysis`
where total_resurrections is null



      
    ) dbt_internal_test