
    
    

with dbt_test__target as (

  select activity_month as unique_field
  from `heymax-interview`.`heymax_data`.`social_capital_growth_accounting`
  where activity_month is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


