
    
    

with all_values as (

    select
        miles_economy_health as value_field,
        count(*) as n_records

    from `heymax-interview`.`heymax_analytics`.`heymax_growth_drivers`
    group by miles_economy_health

)

select *
from all_values
where value_field not in (
    'Healthy Growth','Stable','High Redemption','Balanced'
)


