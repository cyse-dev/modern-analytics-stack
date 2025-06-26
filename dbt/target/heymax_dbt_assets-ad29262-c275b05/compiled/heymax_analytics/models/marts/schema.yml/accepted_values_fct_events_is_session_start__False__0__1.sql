
    
    

with all_values as (

    select
        is_session_start as value_field,
        count(*) as n_records

    from `heymax-interview`.`heymax_data`.`fct_events`
    group by is_session_start

)

select *
from all_values
where value_field not in (
    0,1
)


