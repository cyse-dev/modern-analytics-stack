select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        resurrection_quality_category as value_field,
        count(*) as n_records

    from `heymax-interview`.`heymax_analytics`.`user_resurrection_analysis`
    group by resurrection_quality_category

)

select *
from all_values
where value_field not in (
    'Excellent','Good','Average','Below Average','Poor'
)



      
    ) dbt_internal_test