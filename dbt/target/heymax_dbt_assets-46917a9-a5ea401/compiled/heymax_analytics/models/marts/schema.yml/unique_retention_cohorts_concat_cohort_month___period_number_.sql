
    
    

with dbt_test__target as (

  select concat(cohort_month, '_', period_number) as unique_field
  from `heymax-interview`.`heymax_data`.`retention_cohorts`
  where concat(cohort_month, '_', period_number) is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


