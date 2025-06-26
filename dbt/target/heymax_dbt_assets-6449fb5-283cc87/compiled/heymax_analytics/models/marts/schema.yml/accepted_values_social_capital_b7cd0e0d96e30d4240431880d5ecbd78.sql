
    
    

with all_values as (

    select
        growth_quality_category as value_field,
        count(*) as n_records

    from `heymax-interview`.`heymax_data`.`social_capital_growth_accounting`
    group by growth_quality_category

)

select *
from all_values
where value_field not in (
    'Unknown','Declining','Typical Consumer','Good Consumer','Excellent Consumer'
)


