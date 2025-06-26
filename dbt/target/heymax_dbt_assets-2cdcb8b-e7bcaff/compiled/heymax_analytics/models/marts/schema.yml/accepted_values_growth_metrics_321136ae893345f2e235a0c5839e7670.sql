
    
    

with all_values as (

    select
        activity_trend_7d as value_field,
        count(*) as n_records

    from `heymax-interview`.`heymax_analytics`.`growth_metrics`
    group by activity_trend_7d

)

select *
from all_values
where value_field not in (
    'Trending Up','Trending Down','Stable'
)


