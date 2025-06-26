
    
    

with all_values as (

    select
        engagement_trend as value_field,
        count(*) as n_records

    from `heymax-interview`.`heymax_data`.`retention_quality_framework`
    group by engagement_trend

)

select *
from all_values
where value_field not in (
    'High Engagement','Moderate Engagement','Low Engagement'
)


