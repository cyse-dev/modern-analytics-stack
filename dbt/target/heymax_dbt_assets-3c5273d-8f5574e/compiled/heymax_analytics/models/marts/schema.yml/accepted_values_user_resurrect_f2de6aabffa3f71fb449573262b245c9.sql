
    
    

with all_values as (

    select
        resurrection_pattern as value_field,
        count(*) as n_records

    from `heymax-interview`.`heymax_data`.`user_resurrection_analysis`
    group by resurrection_pattern

)

select *
from all_values
where value_field not in (
    'No Resurrections','Quick Return Focus','Long-term Recovery','Balanced Recovery'
)


