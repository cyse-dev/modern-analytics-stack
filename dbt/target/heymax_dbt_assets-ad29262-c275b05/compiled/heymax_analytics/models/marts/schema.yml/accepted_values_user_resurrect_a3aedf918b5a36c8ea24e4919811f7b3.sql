
    
    

with all_values as (

    select
        resurrection_quality_category as value_field,
        count(*) as n_records

    from `heymax-interview`.`heymax_data`.`user_resurrection_analysis`
    group by resurrection_quality_category

)

select *
from all_values
where value_field not in (
    'Excellent','Good','Average','Below Average','Poor'
)


