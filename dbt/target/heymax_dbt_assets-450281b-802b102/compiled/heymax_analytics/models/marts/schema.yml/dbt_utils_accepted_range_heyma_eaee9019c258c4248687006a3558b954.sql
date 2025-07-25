

with meet_condition as(
  select *
  from `heymax-interview`.`heymax_data`.`heymax_growth_drivers`
),

validation_errors as (
  select *
  from meet_condition
  where
    -- never true, defaults to an empty result set. Exists to ensure any combo of the `or` clauses below succeeds
    1 = 2
    -- records with a value >= min_value are permitted. The `not` flips this to find records that don't meet the rule.
    or not feature_adoption_score >= 0
    -- records with a value <= max_value are permitted. The `not` flips this to find records that don't meet the rule.
    or not feature_adoption_score <= 100
)

select *
from validation_errors

