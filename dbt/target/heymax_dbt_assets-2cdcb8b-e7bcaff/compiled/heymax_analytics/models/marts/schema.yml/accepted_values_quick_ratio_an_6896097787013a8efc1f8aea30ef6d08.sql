
    
    

with all_values as (

    select
        retention_benchmark as value_field,
        count(*) as n_records

    from `heymax-interview`.`heymax_analytics`.`quick_ratio_analysis`
    group by retention_benchmark

)

select *
from all_values
where value_field not in (
    'Excellent (80%+)','Good (60-80%)','Average (40-60%)','Below Average (20-40%)','Poor (<20%)'
)


