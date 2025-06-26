select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        alert_level as value_field,
        count(*) as n_records

    from `heymax-interview`.`heymax_data`.`quick_ratio_analysis`
    group by alert_level

)

select *
from all_values
where value_field not in (
    'OK','WARNING: Quick Ratio Dropped Below 1.2','WARNING: Quick Ratio Declined >0.3 Points','WARNING: Churn Significantly Exceeding Growth','CRITICAL: Quick Ratio Below 1.0'
)



      
    ) dbt_internal_test