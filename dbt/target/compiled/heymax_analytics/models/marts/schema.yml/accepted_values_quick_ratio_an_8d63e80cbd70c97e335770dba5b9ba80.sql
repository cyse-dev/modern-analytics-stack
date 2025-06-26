
    
    

with all_values as (

    select
        business_stage as value_field,
        count(*) as n_records

    from `heymax-interview`.`heymax_analytics`.`quick_ratio_analysis`
    group by business_stage

)

select *
from all_values
where value_field not in (
    'Early Stage','Growth Stage','Mature Stage'
)


