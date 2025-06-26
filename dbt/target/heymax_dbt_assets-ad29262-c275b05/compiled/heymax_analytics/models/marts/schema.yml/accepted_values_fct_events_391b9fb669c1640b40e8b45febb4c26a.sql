
    
    

with all_values as (

    select
        event_type as value_field,
        count(*) as n_records

    from `heymax-interview`.`heymax_data`.`fct_events`
    group by event_type

)

select *
from all_values
where value_field not in (
    'miles_earned','miles_redeemed','share','like','reward_search'
)


