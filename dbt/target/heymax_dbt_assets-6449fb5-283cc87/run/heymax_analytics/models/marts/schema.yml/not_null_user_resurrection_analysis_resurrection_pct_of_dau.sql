select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select resurrection_pct_of_dau
from `heymax-interview`.`heymax_data`.`user_resurrection_analysis`
where resurrection_pct_of_dau is null



      
    ) dbt_internal_test