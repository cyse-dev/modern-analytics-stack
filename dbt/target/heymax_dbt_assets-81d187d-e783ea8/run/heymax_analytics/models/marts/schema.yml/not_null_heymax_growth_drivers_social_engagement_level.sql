select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select social_engagement_level
from `heymax-interview`.`heymax_data`.`heymax_growth_drivers`
where social_engagement_level is null



      
    ) dbt_internal_test