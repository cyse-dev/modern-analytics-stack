
    
    

with dbt_test__target as (

  select event_date as unique_field
  from `heymax-interview`.`heymax_data`.`heymax_growth_drivers`
  where event_date is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


