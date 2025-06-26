select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select resurrection_effectiveness_score
from `heymax-interview`.`heymax_analytics`.`user_resurrection_analysis`
where resurrection_effectiveness_score is null



      
    ) dbt_internal_test