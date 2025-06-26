select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select feature_adoption_score
from `heymax-interview`.`heymax_data`.`heymax_growth_drivers`
where feature_adoption_score is null



      
    ) dbt_internal_test