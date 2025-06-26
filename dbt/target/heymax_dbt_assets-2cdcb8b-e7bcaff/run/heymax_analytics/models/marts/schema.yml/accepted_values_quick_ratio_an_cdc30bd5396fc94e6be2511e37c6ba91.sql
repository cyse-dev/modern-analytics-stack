select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        quick_ratio_benchmark as value_field,
        count(*) as n_records

    from `heymax-interview`.`heymax_analytics`.`quick_ratio_analysis`
    group by quick_ratio_benchmark

)

select *
from all_values
where value_field not in (
    'Top Tier (2.0+)','Strong (1.5-2.0)','Healthy (1.0-1.5)','Concerning (0.8-1.0)','Critical (<0.8)'
)



      
    ) dbt_internal_test