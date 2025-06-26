select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        daily_growth_quality as value_field,
        count(*) as n_records

    from `heymax-interview`.`heymax_analytics`.`growth_metrics`
    group by daily_growth_quality

)

select *
from all_values
where value_field not in (
    'Unknown','Declining','Healthy','Strong'
)



      
    ) dbt_internal_test