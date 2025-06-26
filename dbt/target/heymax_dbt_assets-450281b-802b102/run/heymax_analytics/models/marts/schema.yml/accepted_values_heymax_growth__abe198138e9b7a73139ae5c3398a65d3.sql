select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        social_engagement_level as value_field,
        count(*) as n_records

    from `heymax-interview`.`heymax_data`.`heymax_growth_drivers`
    group by social_engagement_level

)

select *
from all_values
where value_field not in (
    'High Social','Moderate Social','Low Social'
)



      
    ) dbt_internal_test