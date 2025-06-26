
    
    

with all_values as (

    select
        retention_quality_category as value_field,
        count(*) as n_records

    from `heymax-interview`.`heymax_analytics`.`retention_quality_framework`
    group by retention_quality_category

)

select *
from all_values
where value_field not in (
    'Excellent','Good','Average','Below Average','Poor'
)


